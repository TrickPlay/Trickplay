
#include <iostream>
#include <fstream>
#include <cstdlib>

#include "debugger.h"
#include "app.h"
#include "context.h"
#include "console.h"
#include "util.h"
#include "http_server.h"
#include "user_data.h"
#include "app_resource.h"

//.............................................................................

#define TP_LOG_DOMAIN   "DEBUGGER"
#define TP_LOG_ON       true
#define TP_LOG2_ON      false

#include "log.h"

//.............................................................................

class Debugger::Command
{
public:

    Command() {}

    virtual ~Command() {}

    virtual String get() const = 0;

    virtual bool reply( const JSON::Object& obj ) = 0;

    static void destroy( gpointer me )
    {
        delete( Command* ) me;
    }

    virtual void cancel()
    {
    }

    typedef std::list<Command*> List;

    class Filter
    {
    public:
        virtual ~Filter() {}
        virtual bool operator()( Command* command ) const = 0;
    };

private:

    Command( const Command& ) {}
};

class Debugger::Server
{
public:

    Server( TPContext* context )
    {
        g_assert( context );

        static char key = 0;

        context->add_internal( & key , this , destroy );
    }

    virtual Command* get_next_command( bool wait ) = 0;

    virtual guint16 get_port() const = 0;

    virtual void enable_console() = 0;

    virtual void disable_console() = 0;

    virtual void clear_pending_commands() = 0;

    virtual Command::List get_commands_matching( const Command::Filter& filter ) = 0;

    Command::List get_all_commands()
    {
        class FilterNone : public Command::Filter
        {
            virtual bool operator()( Command* ) const
            {
                return true;
            }
        };

        return get_commands_matching( FilterNone() );
    }

protected:

    virtual ~Server() {}

private:

    Server( const Server& ) {}

    static void destroy( gpointer me )
    {
        delete( Server* ) me;
    }
};

//.............................................................................

class HCommand : public Debugger::Command
{
public:

    HCommand( GMainContext* _gctx , const HttpServer::Request::Body& body , HttpServer::Response& _response )
        :
        gctx( _gctx )
    {
        line = String( body.get_data() , body.get_length() );

        response = _response.pause();
    }

    virtual ~HCommand()
    {
        resume();
    }

    virtual String get() const
    {
        return line;
    }

    virtual bool reply( const JSON::Object& obj )
    {
        if ( 0 == response )
        {
            return false;
        }

        resume( obj.stringify() );

        fprintf( stdout , "\n" );
        fflush( stdout );

        return true;
    }

    virtual void cancel()
    {
        if ( response )
        {
            response->unref();
            response = 0;
        }
    }

private:

    // In order to execute the actual resume in the server thread,
    // we create a struct with the response and the content and
    // queue an idle source in that thread's main context.

    struct ResumeInfo
    {
        ResumeInfo( const String& _content , HttpServer::Response* _response )
            :
            content( _content ),
            response( _response )
        {}

        static void destroy( gpointer me )
        {
            ResumeInfo* info = ( ResumeInfo* ) me;

            if ( info->response )
            {
                info->response->unref();
            }

            delete info;
        }

        String                  content;
        HttpServer::Response*  response;
    };

    static gboolean resume_it( gpointer resume_info )
    {
        ResumeInfo* info = ( ResumeInfo* ) resume_info;

        if ( ! info->content.empty() )
        {
            info->response->set_status( HttpServer::HTTP_STATUS_OK );
            info->response->set_response( "application/json" , info->content );
        }

        info->response->resume();

        info->response = 0;

        return FALSE;
    }

    void resume( const String& content = String() )
    {
        if ( response )
        {
            GSource* source = g_idle_source_new();
            g_source_set_priority( source , G_PRIORITY_DEFAULT );
            g_source_set_callback( source , resume_it , new ResumeInfo( content , response ) , ResumeInfo::destroy );
            g_source_attach( source , gctx );
            g_source_unref( source );

            response = 0;
        }
    }


    GMainContext*           gctx;
    String                  line;
    HttpServer::Response*  response;

};

//.............................................................................

class HServer : public Debugger::Server , public HttpServer::RequestHandler
{
public:

    HServer( TPContext* context )
        :
        Debugger::Server( context ),
        queue( g_async_queue_new_full( Debugger::Command::destroy ) ),
        gctx( g_main_context_new() ),
        server( 0 ),
        thread( 0 ),
        channel( 0 ),
        console_enabled( 0 )
    {
        server = new HttpServer( context->get_int( TP_DEBUGGER_PORT , 0 ) , gctx );

        if ( 0 == server->get_port() )
        {
            delete server;

            server = 0;

            tpwarn( "FAILED TO START HTTP SERVER" );
        }
        else
        {
            tp_context_set( context , TP_DEBUGGER_PORT , Util::format( "%u" , server->get_port() ).c_str() );

            tplog( "HTTP SERVER READY ON PORT %u" , server->get_port() );

            server->register_handler( "/debugger" , this );

            //.................................................................
            // Set up machinery to read from stdin

            int fd = fileno( stdin );

            if ( fd > -1 )
            {
                channel = g_io_channel_unix_new( fd );

                if ( channel )
                {
                    if ( GSource* source = g_io_create_watch( channel , G_IO_IN ) )
                    {
                        g_source_set_callback( source , ( GSourceFunc ) console_read , this , 0 );

                        g_source_attach( source , gctx );

                        g_source_unref( source );
                    }
                }
            }

            //.................................................................
            // Create and start the thread that will run the HTTP server

#ifndef GLIB_VERSION_2_32
            thread = g_thread_create( process , this , TRUE , 0 );
#else
            thread = g_thread_new( "DebuggerServer", process, this );
#endif
        }
    }

    virtual Debugger::Command* get_next_command( bool wait )
    {
        if ( wait )
        {
            return ( Debugger::Command* ) g_async_queue_pop( queue );
        }

        return ( Debugger::Command* ) g_async_queue_try_pop( queue );
    }

    virtual guint16 get_port() const
    {
        return server ? server->get_port() : 0;
    }

    virtual void enable_console()
    {
        g_atomic_int_set( & console_enabled , 1 );
    }

    virtual void disable_console()
    {
        g_atomic_int_set( & console_enabled , 0 );
    }

    virtual void clear_pending_commands()
    {
        Debugger::Command::List commands = get_all_commands();

        for ( Debugger::Command::List::const_iterator it = commands.begin(); it != commands.end(); ++it )
        {
            tplog( "CLEARING PENDING COMMAND %s" , ( *it )->get().c_str() );

            delete( *it );
        }
    }

    virtual Debugger::Command::List get_commands_matching( const Debugger::Command::Filter& filter )
    {
        Debugger::Command::List result;
        Debugger::Command::List putback;

        g_async_queue_lock( queue );

        while ( Debugger::Command* command = ( Debugger::Command* ) g_async_queue_try_pop_unlocked( queue ) )
        {
            if ( filter( command ) )
            {
                result.push_back( command );
            }
            else
            {
                putback.push_back( command );
            }
        }

        if ( ! putback.empty() )
        {
            for ( Debugger::Command::List::const_iterator it = putback.begin(); it != putback.end(); ++it )
            {
                g_async_queue_push_unlocked( queue , * it );
            }
        }

        g_async_queue_unlock( queue );

        return result;
    }

protected:

    virtual ~HServer()
    {
        if ( channel )
        {
            g_io_channel_unref( channel );
        }

        if ( server )
        {
            tplog2( "STOPPING HTTP SERVER" );

            server->unregister_handler( "/debugger" );

            server->quit();

            delete server;
        }

        if ( thread )
        {
            tplog2( "WAITING FOR HTTP SERVER THREAD" );

            ( void ) g_thread_join( thread );
        }

        // Cancel any commands that are in the queue now. Otherwise, we will
        // try to reply to them when the server has already been destroyed.

        Debugger::Command::List list = get_all_commands();

        for ( Debugger::Command::List::const_iterator it = list.begin(); it != list.end(); ++it )
        {
            tplog2( "CANCELLING COMMAND '%s'" , ( *it )->get().c_str() );

            ( *it )->cancel();

            delete( *it );
        }

        g_async_queue_unref( queue );

        g_main_context_unref( gctx );

        tplog2( "HTTP SERVER DESTROYED" );
    }

    //-------------------------------------------------------------------------
    // Happens in other thread

    virtual void handle_http_request( const HttpServer::Request& request , HttpServer::Response& response )
    {
        response.set_status( HttpServer::HTTP_STATUS_BAD_REQUEST );

        if ( request.get_method() != HttpServer::Request::HTTP_POST )
        {
            return;
        }

        const HttpServer::Request::Body& body( request.get_body() );

        if ( 0 == body.get_length() )
        {
            return;
        }

        g_async_queue_push( queue , new HCommand( gctx , body , response ) );
    }

    static gpointer process( gpointer me )
    {
        tplog2( "STARTING SERVER THREAD" );

        ( ( HServer* ) me )->server->run();

        tplog2( "SERVER THREAD EXITING" );

        return 0;
    }

    class ConsoleCommand : public Debugger::Command
    {
    public:

        ConsoleCommand( const String& _line )
            :
            line( _line )
        {
        }

        virtual String get() const
        {
            return line;
        }

        virtual bool reply( const JSON::Object& obj )
        {
            JSON::Object::Map::const_iterator key;

            //.................................................................
            // An error

            key = obj.find( "error" );

            if ( key != obj.end() )
            {
                fprintf( stdout , "%s\n" , key->second.as<String>().c_str() );
                fflush( stdout );
                return true;
            }

            //.................................................................
            // List locals

            key = obj.find( "locals" );

            if ( key != obj.end() )
            {
                JSON::Array array( key->second.as<JSON::Array>() );

                JSON::Array::Vector::iterator it;

                for ( it = array.begin(); it != array.end(); ++it )
                {
                    JSON::Object& local( ( *it ).as<JSON::Object>() );

                    const String& name = local[ "name" ].as<String>();

                    if ( name != "(*temporary)" )
                    {
                        fprintf( stdout , "%s (%s) = %s\n" ,
                                name.c_str(),
                                local[ "type" ].as<String>().c_str(),
                                local[ "value"].as<String>().c_str() );
                    }
                }

                fflush( stdout );
            }

            //.................................................................
            // List globals

            key = obj.find( "globals" );

            if ( key != obj.end() )
            {
                JSON::Array array( key->second.as<JSON::Array>() );

                JSON::Array::Vector::iterator it;

                for ( it = array.begin(); it != array.end(); ++it )
                {
                    JSON::Object& global( ( *it ).as<JSON::Object>() );

                    const String& name = global[ "name" ].as<String>();

                    if ( name != "(*temporary)" )
                    {
                        fprintf( stdout , "%s (%s) = %s [%s]\n" ,
                                name.c_str(),
                                global[ "type" ].as<String>().c_str(),
                                global[ "value"].as<String>().c_str(),
                                global[ "defined"].as<String>().c_str() );
                    }
                }

                fflush( stdout );
            }


            //.................................................................
            // Back trace

            key = obj.find( "stack" );

            if ( key != obj.end() )
            {
                JSON::Array array( key->second.as<JSON::Array>() );

                JSON::Array::Vector::iterator it;

                int i = 0;

                for ( it = array.begin(); it != array.end(); ++it , ++i )
                {
                    JSON::Object& local( ( *it ).as<JSON::Object>() );

                    String func = local[ "name" ].as<String>();

                    if ( ! func.empty() )
                    {
                        func += "()";
                    }

                    fprintf( stdout , "[%d] %s:%lld %s\n" ,
                            i,
                            local[ "file" ].as<String>().c_str(),
                            local[ "line" ].as< long long >(),
                            func.c_str() );
                }

                fflush( stdout );
            }

            //.................................................................
            // List breakpoints

            key = obj.find( "breakpoints" );

            if ( key != obj.end() )
            {
                JSON::Array array( key->second.as<JSON::Array>() );

                if ( array.empty() )
                {
                    fprintf( stdout , "No breakpoints set\n" );
                }
                else
                {
                    JSON::Array::Vector::iterator it;

                    int i = 0;

                    for ( it = array.begin(); it != array.end(); ++it , ++i )
                    {
                        JSON::Object& bp( ( *it ).as<JSON::Object>() );

                        fprintf( stdout , "[%d] %s:%lld%s\n" ,
                                i,
                                bp[ "file" ].as<String>().c_str(),
                                bp[ "line" ].as< long long >(),
                                bp[ "on" ].as<bool>() ? "" : " (disabled)" );
                    }
                }

                fflush( stdout );
            }

            //.................................................................
            // Source listing

            key = obj.find( "source" );

            if ( key != obj.end() )
            {
                JSON::Array array( key->second.as<JSON::Array>() );

                JSON::Array::Vector::iterator it;

                long long current_line = -1;

                key = obj.find( "line" );

                if ( key != obj.end() )
                {
                    current_line = key->second.as<long long>();
                }

                for ( it = array.begin(); it != array.end(); ++it )
                {
                    JSON::Object& src( ( *it ).as<JSON::Object>() );

                    long long line = src[ "line" ].as< long long >();
                    const char* marker = ( line == current_line ) ?  " >>" : "   ";

                    fprintf( stdout , "%4.4lld%s %s\n" ,
                            line,
                            marker,
                            src[ "text" ].as<String>().c_str() );
                }

                fflush( stdout );
            }

            //.................................................................
            // List app info

            key = obj.find( "app" );

            if ( key != obj.end() )
            {
            }

            return true;
        }

    private:

        String line;
    };

    static gboolean console_read( GIOChannel* channel , GIOCondition condition , gpointer me )
    {
        HServer* server = ( HServer* ) me;

        if ( 1 == g_atomic_int_get( & server->console_enabled ) )
        {
            GString* line = g_string_new( 0 );

            if ( G_IO_STATUS_NORMAL == g_io_channel_read_line_string( channel , line , 0 , 0 ) )
            {
                g_async_queue_push( server->queue , new ConsoleCommand( g_strstrip( line->str ) ) );
            }

            g_string_free( line , TRUE );
        }

        return TRUE;
    }

private:

    GAsyncQueue*   queue;
    GMainContext*   gctx;
    HttpServer*     server;
    GThread*        thread;
    GIOChannel*    channel;
    gint            console_enabled;
};

//.............................................................................

Debugger::Server* Debugger::server = 0;

//.............................................................................

Debugger::Debugger( App* _app )
    :
    app( _app ),
    installed( false ),
    break_next( false ),
    returns( 0 ),
    in_break( false )
{
    if ( 0 == server )
    {
        server = new HServer( app->get_context() );
    }
}

//.............................................................................

Debugger::~Debugger()
{
    uninstall();
}

//.............................................................................

void Debugger::uninstall()
{
    if ( installed )
    {
        lua_sethook( app->get_lua_state(), lua_hook, 0, 0 );

        server->clear_pending_commands();

        installed = false;

        tplog( "UNINSTALLED FOR %s" , app->get_id().c_str() );
    }
}

//.............................................................................

void Debugger::install( bool break_next_line )
{
    break_next = break_next_line;

    if ( installed )
    {
        tplog( "BREAK NEXT IS %s" , break_next ? "TRUE" : "FALSE" );
        return;
    }

    tplog( "INSTALLED FOR %s : BREAK NEXT IS %s" , app->get_id().c_str() , break_next ? "TRUE" : "FALSE" );

    lua_sethook( app->get_lua_state(), lua_hook, /* LUA_MASKCALL | LUA_MASKRET |*/ LUA_MASKLINE, 0 );

    installed = true;
}

//.............................................................................

void Debugger::lua_hook( lua_State* L, lua_Debug* ar )
{
    if ( Debugger* debugger = App::get( L )->get_debugger() )
    {
        debugger->debug_break( L, ar );
    }
}

//.............................................................................

void Debugger::break_next_line()
{
    install( true );
}

//.............................................................................

guint16 Debugger::get_server_port() const
{
    return server->get_port();
}

//.............................................................................

JSON::Array Debugger::get_back_trace( lua_State* L , lua_Debug* ar )
{
    JSON::Array array;

    for ( int i = 0; true; ++i )
    {
        lua_Debug stack;

        memset( & stack , 0 , sizeof( stack ) );

        if ( 0 == lua_getstack( L , i, & stack ) )
        {
            break;
        }

        if ( lua_getinfo( L, "nSl", & stack ) )
        {
            if ( strcmp( stack.what , "C" ) && stack.currentline >= 0 )
            {
                String source;

                if ( g_str_has_prefix( stack.source, "@" ) )
                {
                    gchar* basename = g_path_get_basename( stack.source + 1 );

                    source = basename;

                    g_free( basename );
                }
                else
                {
                    source = stack.source;
                }

                JSON::Object& frame = array.append<JSON::Object>();

                frame[ "file" ] = source;
                frame[ "line" ] = stack.currentline;

                if ( stack.name && stack.namewhat )
                {
                    frame[ "name" ] = stack.name;
                    frame[ "type" ] = stack.namewhat;
                }
            }
        }
    }

    return array;
}

//.............................................................................

JSON::Array Debugger::get_locals( lua_State* L , lua_Debug* ar )
{
    JSON::Array array;

    for ( int i = 1; ; ++i )
    {
        const char* name = lua_getlocal( L , ar , i );

        if ( ! name )
        {
            break;
        }

        JSON::Object& local( array.append<JSON::Object>() );

        local[ "name"  ] = name;

        int type = lua_type( L , -1 );

        local[ "type"  ] = lua_typename( L , type );
        local[ "value" ] = Util::describe_lua_value( L , -1 );

        lua_pop( L , 1 );
    }

    // Get the function that is currently executing and
    // then go through all of is upvalues.

    lua_getinfo( L , "f" , ar );

    int f = lua_gettop( L );

    if ( ! lua_isnil( L , f ) )
    {
        for ( int i = 1; ; ++i )
        {
            const char* name = lua_getupvalue( L , f , i );

            if ( ! name )
            {
                break;
            }

            JSON::Object& local( array.append<JSON::Object>() );

            local[ "name"  ] = name;

            int type = lua_type( L , -1 );

            local[ "type"  ] = lua_typename( L , type );
            local[ "value" ] = Util::describe_lua_value( L , -1 );

            lua_pop( L , 1 );
        }
    }

    lua_pop( L , 1 );

    return array;
}

//.............................................................................

JSON::Array Debugger::get_globals( lua_State* L )
{
    JSON::Array array;

    const StringMap& globals( app->get_globals() );

    lua_rawgeti( L , LUA_REGISTRYINDEX , LUA_RIDX_GLOBALS );

    int g = lua_gettop( L );

    for ( StringMap::const_iterator it = globals.begin(); it != globals.end(); ++it )
    {
        lua_pushstring( L , it->first.c_str() );
        lua_rawget( L , g );

        if ( ! lua_isnil( L , -1 ) )
        {
            JSON::Object& g( array.append<JSON::Object>() );

            g[ "name"  ] = it->first;

            int type = lua_type( L , -1 );

            g[ "type"  ] = lua_typename( L , type );
            g[ "value" ] = Util::describe_lua_value( L , -1 );
            g[ "defined" ] = it->second;
        }

        lua_pop( L , 1 );
    }

    lua_pop( L , 1 );

    return array;
}

//.............................................................................

JSON::Object Debugger::get_location( lua_State* L , lua_Debug* ar )
{
    JSON::Object result;

    if ( g_str_has_prefix( ar->source, "@" ) )
    {
        gchar* basename = g_path_get_basename( ar->source + 1 );

        result[ "file" ] = basename;

        g_free( basename );
    }
    else
    {
        result[ "file" ] = ar->source;
    }

    result[ "line" ] = ar->currentline;

    result[ "id" ] = app->get_id();

    return result;
}

//.............................................................................

JSON::Array Debugger::get_breakpoints( lua_State* L , lua_Debug* ar )
{
    JSON::Array result;

    for ( BreakpointList::const_iterator it = breakpoints.begin(); it != breakpoints.end(); ++it )
    {
        JSON::Object& b = result.append<JSON::Object>();

        b[ "file" ] = it->file;
        b[ "line" ] = it->line;
        b[ "on"   ] = it->enabled;
    }

    return result;
}

//.............................................................................

JSON::Object Debugger::get_app_info()
{
    JSON::Object result;

    const App::Metadata& md = app->get_metadata();

    result[ "id"         ] = md.id;
    result[ "name"       ] = md.name;
    result[ "release"    ] = md.release;
    result[ "version"    ] = md.version;
    result[ "description"] = md.description;
    result[ "author"     ] = md.author;
    result[ "copyright"  ] = md.copyright;

    JSON::Array& array = result[ "contents" ].as<JSON::Array>();

    StringList contents = AppResource::get_pi_children( md.get_root_uri() );

    for ( StringList::const_iterator it = contents.begin(); it != contents.end(); ++it )
    {
        array.append( * it );
    }

    return result;
}

//.............................................................................

bool Debugger::handle_command( lua_State* L , lua_Debug* ar , Command* server_command , bool with_location )
{
    bool result = false;

    String command( server_command->get() );

    JSON::Object reply;

    if ( with_location )
    {
        reply = get_location( L , ar );
    }

    reply[ "command" ] = command;

    if ( command == "i" )
    {
        reply[ "locals" ] = get_locals( L , ar );
        reply[ "stack" ] = get_back_trace( L , ar );
        reply[ "breakpoints" ] = get_breakpoints( L , ar );
        reply[ "globals" ] = get_globals( L );
    }

    // List locals

    else if ( command == "l" )
    {
        reply[ "locals" ] = get_locals( L , ar );
    }

    // List globals

    else if ( command == "g" )
    {
        reply[ "globals" ] = get_globals( L );
    }

    // Where

    else if ( command == "w" )
    {
        StringVector* lines = get_source( reply[ "file" ].as<String>() );

        if ( lines )
        {
            int line = reply[ "line" ].as<long long>();

            int start_line = line - 4;
            int end_line = line + 5;

            if ( start_line < 0 )
            {
                start_line = 0;
            }

            if ( end_line >= int( lines->size() ) )
            {
                end_line = lines->size() - 1;
            }

            if ( end_line > start_line )
            {
                JSON::Array& array = reply[ "source" ].as<JSON::Array>();

                for ( line = start_line; line <= end_line; ++line )
                {
                    JSON::Object& l = array.append<JSON::Object>();

                    l[ "line" ] = line + 1;
                    l[ "text" ] = ( *lines )[ line ];
                }
            }
        }
    }

    // Reset - delete all breakpoints and continue

    else if ( command == "r" )
    {
        break_next = false;

        breakpoints.clear();

        result = true;
    }

    // Back trace

    else if ( command == "bt" )
    {
        reply[ "stack" ] = get_back_trace( L , ar );
    }

    // Break next

    else if ( command == "bn" )
    {
        break_next = true;
    }

    // Quit

    else if ( command == "q" )
    {
        tp_context_quit( app->get_context() );
        break_next = false;
        result = true;
    }

    // Continue

    else if ( command == "c" )
    {
        break_next = false;
        result = true;
    }

    // Step

    else if ( command == "s" )
    {
        break_next = true;
        result = true;
    }

    // Next

    else if ( command == "n" )
    {
        // To step over, we change the hook to watch for function calls.
        // If, during the next iteration, a function call happens, it
        // will increment the number of returns, start watching for
        // returns and stopping watching for lines.

        // When a return happens, the number of returns is
        // decremented until it reaches zero. When it does, it means
        // we are done stepping over, so we reset the hook to only
        // watch for lines and break on the next one.

        lua_sethook( L , lua_hook, LUA_MASKCALL | LUA_MASKLINE , 0 );
        result = true;
    }

    // List breakpoints

    else if ( command == "b" )
    {
        reply[ "breakpoints" ] = get_breakpoints( L , ar );
    }

    // App information

    else if ( command == "a" )
    {
        reply[ "app" ] = get_app_info();
    }

    // Batch breakpoints

    else if ( 0 == command.find( "bb " ) )
    {
        StringVector parts = split_string( command , " " , 2 );

        if ( parts.size() == 2 )
        {
            JSON::Value root = JSON::Parser::parse( parts[ 1 ] );

            if ( root.is<JSON::Object>() )
            {
                JSON::Object& o = root.as<JSON::Object>();

                if ( o.has( "clear" ) &&  o["clear"].as<bool>() )
                {
                    breakpoints.clear();
                }

                JSON::Array& b = o["add"].as<JSON::Array>();

                for ( JSON::Array::Vector::iterator it = b.begin(); it != b.end(); ++it )
                {
                    JSON::Object& bo = it->as<JSON::Object>();

                    String file = bo[ "file" ].as<String>();
                    int line = bo[ "line" ].as<long long>();
                    bool on = bo.has( "on" ) ? bo[ "on" ].as<bool>() : true;

                    breakpoints.push_back( Breakpoint( file , line , on ) );
                }

                b = o[ "delete" ].as<JSON::Array>();

                for ( JSON::Array::Vector::iterator it = b.begin(); it != b.end(); ++it )
                {
                    JSON::Object& bo = it->as<JSON::Object>();

                    String file = bo[ "file" ].as<String>();
                    int line = bo[ "line" ].as<long long>();

                    for ( BreakpointList::iterator ib = breakpoints.begin(); ib != breakpoints.end(); ++ib )
                    {
                        if ( ib->file == file && ib->line == line )
                        {
                            breakpoints.erase( ib );
                            break;
                        }
                    }
                }
            }
        }

        reply[ "breakpoints" ] = get_breakpoints( L , ar );
    }

    // Set a breakpoint
    // b 57 - set a breakpoint at line 57 of the current file
    // b main.lua:57 - set a breakpoint at line 57 of main.lua
    // b 1 on|off - enable/disable breakpoints

    else if ( 0 == command.find( "b " ) )
    {
        StringVector parts = split_string( command , " " , 3 );

        if ( parts.size() == 3 )
        {
            // This is an enable/disable command

            unsigned int index = atoi( parts[ 1 ].c_str() );

            if ( index >= breakpoints.size() )
            {
                reply[ "error" ] = Util::format( "Invalid breakpoint index '%u'" , index );
            }
            else
            {
                ( breakpoints.begin() + index )->enabled = parts[ 2 ] == "on";
            }
        }
        else if ( parts.size() == 2 )
        {
            parts = split_string( parts[ 1 ] , ":" , 2 );

            if ( parts.size() == 1 )
            {
                // b <line>

                breakpoints.push_back( Breakpoint( reply[ "file" ].as<String>() , atoi( parts[ 0 ].c_str() ) ) );
            }
            else if ( parts.size() == 2 )
            {
                // b <file>:<line>

                breakpoints.push_back( Breakpoint( parts[ 0 ] , atoi( parts[ 1 ].c_str() ) ) );
            }
        }
        else
        {
            reply[ "error" ] = "To set a breakpoint, enter 'b <file>:<line>' or 'b <line>'. To enable or disable breakpoints, enter 'b <index> on|off'";
        }

        reply[ "breakpoints" ] = get_breakpoints( L , ar );
    }

    // Delete a breakpoint

    else if ( 0 == command.find( "d " ) )
    {
        StringVector parts = split_string( command , " " , 2 );

        if ( parts.size() != 2 )
        {
            reply[ "error" ] = "To delete a breakpoint, enter 'd <breakpoint index>' or 'd all'";
        }
        else if ( parts[ 1 ] == "all" )
        {
            breakpoints.clear();
        }
        else
        {
            unsigned int index = atoi( parts[ 1 ].c_str() );

            if ( index < breakpoints.size() )
            {
                breakpoints.erase( breakpoints.begin() + index );
            }
            else
            {
                reply[ "error" ] = "Invalid breakpoint index";
            }
        }

        reply[ "breakpoints" ] = get_breakpoints( L , ar );
    }

    // Fetch a file

    else if ( 0 == command.find( "f " ) )
    {
        StringVector parts = split_string( command , " " , 2 );

        if ( parts.size() != 2 )
        {
            reply[ "error" ] = "To fetch a file, enter 'f <file name>'";
        }
        else
        {
            StringVector* lines = get_source( parts[ 1 ] );

            if ( 0 == lines )
            {
                reply[ "error" ] = Util::format( "Failed to fetch '%s'" , parts[ 1 ].c_str() );
            }
            else
            {
                JSON::Array& array = reply[ "lines" ].as<JSON::Array>();

                for ( StringVector::const_iterator it = lines->begin(); it != lines->end(); ++it )
                {
                    array.append( *it );
                }
            }
        }
    }

    server_command->reply( reply );

    delete server_command;

    return result;
}

//.............................................................................

void Debugger::debug_break( lua_State* L, lua_Debug* ar )
{
    lua_getinfo( L, "nSl", ar );

    {
        // Some commands can be (and should be) handled here, when we may not be
        // breaking.

        class NoBreakCommands : public Command::Filter
        {
            virtual bool operator()( Command* command ) const
            {
                String s( command->get() );

                return s == "r" || s == "bn" || s == "q" || s == "b" || s == "a" ||
                        ( 0 == s.find( "b " ) ) ||
                        ( 0 == s.find( "bb " ) ) ||
                        ( 0 == s.find( "d " ) ) ||
                        ( 0 == s.find( "f " ) );
            }
        };

        Command::List commands = server->get_commands_matching( NoBreakCommands() );

        if ( ! commands.empty() )
        {
            for ( Command::List::const_iterator it = commands.begin(); it != commands.end(); ++it )
            {
                handle_command( L , ar , * it , false );
            }
        }
    }

    //.........................................................................

    JSON::Object location( get_location( L , ar ) );

    String at = Util::format( "%s:%lld" , location[ "file" ].as<String>().c_str() , location[ "line" ].as<long long>() );

    //.........................................................................

    bool should_break = false;

    switch ( ar->event )
    {
        case LUA_HOOKCALL:
            ++returns;
            tplog2( "HOOK CALL %s RETURNS %d" , at.c_str() , returns );
            lua_sethook( L , lua_hook , LUA_MASKCALL | LUA_MASKRET , 0 );
            break;

        case LUA_HOOKRET:
            --returns;
            tplog2( "HOOK RET %s RETURNS %d" , at.c_str() , returns );

            if ( returns <= 0 )
            {
                lua_sethook( L , lua_hook, LUA_MASKLINE, 0 );
                break_next = true;
            }

            break;

        case LUA_HOOKLINE:

            tplog2( "HOOK LINE %s" , at.c_str() );

            if ( break_next )
            {
                should_break = true;
            }
            else
            {
                // see if there is a breakpoint for this file/line

                for ( BreakpointList::const_iterator it = breakpoints.begin(); it != breakpoints.end(); ++it )
                {
                    if ( it->enabled && it->line == ar->currentline && g_str_has_suffix( ar->source, it->file.c_str() ) )
                    {
                        should_break = true;
                        break;
                    }
                }
            }

            break;
    }

    //.........................................................................
    // If we are not breaking, we are done

    if ( ! should_break )
    {
        return;
    }

    //.........................................................................

    in_break = true;

    //.........................................................................
    // Disable the console

    Console* console = app->get_context()->get_console();

    if ( console )
    {
        console->disable();
    }

    //.........................................................................

    server->enable_console();

    fprintf( stdout , "(%s) " , at.c_str() );
    fflush( stdout );

    lua_sethook( L , lua_hook, LUA_MASKLINE , 0 );
    returns = 0;

    while ( true )
    {
        //.....................................................................
        // Wait for a command from the server, this will pause indefinitely

        Command* server_command = server->get_next_command( true );

        if ( ! server_command )
        {
            // Something went very wrong

            break;
        }

        // Deal with the command, deletes it.
        // If it returns true, it means we should jump out

        if ( handle_command( L , ar , server_command , true ) )
        {
            break;
        }

        fprintf( stdout , "(%s) " , at.c_str() );
        fflush( stdout );
    }

    server->disable_console();

    //.........................................................................

    if ( console )
    {
        console->enable();
    }

    in_break = false;
}

StringVector* Debugger::get_source( const String& pi_path )
{
    SourceMap::iterator it = source.find( pi_path );

    if ( it != source.end() )
    {
        return & it->second;
    }

    StringVector* result = 0;

    Util::Buffer contents( AppResource( app , pi_path ).load_contents( app ) );

    if ( contents.length() )
    {
        imstream stream( ( char* ) contents.data() , contents.length() );

        StringVector& lines = source[ pi_path ];

        String line;

        while ( std::getline( stream , line ) )
        {
            lines.push_back( line );
        }

        result = & lines;
    }

    return result;
}
