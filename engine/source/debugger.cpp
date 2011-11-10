
#include <iostream>
#include <fstream>
#include <cstdlib>

#include "debugger.h"
#include "app.h"
#include "context.h"
#include "console.h"
#include "util.h"
#include "http_server.h"

//.............................................................................

#define TP_LOG_DOMAIN   "DEBUGGER"
#define TP_LOG_ON       true
#define TP_LOG2_ON      true

#include "log.h"

//.............................................................................

class Debugger::Server
{
public:

	class Command
	{
	public:

		virtual ~Command() {}

		virtual String get() const = 0;

		virtual bool reply( const JSON::Object & obj ) = 0;
	};

	Server( TPContext * context )
	{
		g_assert( context );

		static char key = 0;

		context->add_internal( & key , this , destroy );
	}

	virtual Command * get_next_command( bool wait ) = 0;

	virtual guint16 get_port() const = 0;

protected:

	virtual ~Server() {}

private:

	Server( const Server & ) {}

	static void destroy( gpointer me )
	{
		delete ( Server * ) me;
	}
};

//.............................................................................

class HServer : public Debugger::Server , public HttpServer::RequestHandler
{
public:

	HServer( TPContext * context )
	:
		Debugger::Server( context ),
		queue( g_async_queue_new_full( HCommand::destroy ) ),
		gctx(  g_main_context_new() ),
		server( 0 ),
		thread( 0 )
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
			tplog2( "HTTP SERVER READY ON PORT %u" , server->get_port() );

			server->register_handler( "/debugger" , this );

			thread = g_thread_create( process , this , TRUE , 0 );
		}
	}

	virtual Debugger::Server::Command * get_next_command( bool wait )
	{
		if ( wait )
		{
			return ( Debugger::Server::Command * ) g_async_queue_pop( queue );
		}

		return ( Debugger::Server::Command * ) g_async_queue_try_pop( queue );
	}

	virtual guint16 get_port() const
	{
		return server ? server->get_port() : 0;
	}

protected:

	virtual ~HServer()
	{
		if ( server )
		{
			tplog2( "STOPPING HTTP SERVER" );

			server->quit();

			delete server;
		}

		if ( thread )
		{
			tplog2( "WAITING FOR HTTP SERVER THREAD" );

			( void ) g_thread_join( thread );
		}

		g_async_queue_unref( queue );

		g_main_context_unref( gctx );

		tplog2( "HTTP SERVER DESTROYED" );
	}

	class HCommand : public Debugger::Server::Command
	{
	public:

		HCommand( const HttpServer::Request::Body & body , HttpServer::Response & _response )
		{
			line = String( body.get_data() , body.get_length() );

			response = _response.pause();
		}

		virtual ~HCommand()
		{
			if ( response )
			{
				response->resume();
			}
		}

		virtual String get() const
		{
			return line;
		}

		virtual bool reply( const JSON::Object & obj )
		{
			response->set_status( HttpServer::HTTP_STATUS_OK );
			response->set_response( "application/json" , obj.stringify() );
			response->resume();

			response = 0;

			return true;
		}

		static void destroy( gpointer me )
		{
			delete ( HCommand * ) me;
		}

	private:

		String 					line;
		HttpServer::Response * 	response;

	};
	//-------------------------------------------------------------------------
	// Happens in other thread

    virtual void handle_http_request( const HttpServer::Request & request , HttpServer::Response & response )
    {
    	response.set_status( HttpServer::HTTP_STATUS_BAD_REQUEST );

    	if ( request.get_method() != HttpServer::Request::HTTP_POST )
    	{
    		return;
    	}

    	const HttpServer::Request::Body & body( request.get_body() );

    	if ( 0 == body.get_length() )
    	{
    		return;
    	}

    	g_async_queue_push( queue , new HCommand( body , response ) );
    }

    static gpointer process( gpointer me )
    {
    	tplog2( "STARTING SERVER THREAD" );

    	( ( HServer * ) me )->server->run();

    	tplog2( "SERVER THREAD EXITING" );

    	return 0;
    }

private:

	GAsyncQueue * 	queue;
	GMainContext *	gctx;
	HttpServer  *	server;
	GThread *		thread;
};

//.............................................................................

Debugger::Server * Debugger::server = 0;

//.............................................................................

Debugger::Debugger( App * _app )
:
    app( _app ),
    installed( false ),
    break_next( false ),
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
    }
}

//.............................................................................

void Debugger::install( bool break_next_line )
{
	break_next = break_next_line;

    if ( installed )
    {
        return;
    }

    lua_sethook( app->get_lua_state(), lua_hook, /* LUA_MASKCALL | LUA_MASKRET | */ LUA_MASKLINE, 0 );

    installed = true;
}

//.............................................................................

void Debugger::lua_hook( lua_State * L, lua_Debug * ar )
{
    if ( Debugger * debugger = App::get( L )->get_debugger() )
    {
        debugger->debug_break( L, ar );
    }
}

//.............................................................................

void Debugger::break_next_line()
{
    install();
    break_next = true;
}

//.............................................................................

guint16 Debugger::get_server_port() const
{
	return server->get_port();
}

//.............................................................................

JSON::Array Debugger::get_back_trace( lua_State * L , lua_Debug * ar )
{
	JSON::Array array;

    lua_Debug stack;

    for( int i = 0; lua_getstack( L , i, & stack ); ++i )
    {
        if ( lua_getinfo( L, "nSl", & stack ) )
        {
            String source;

            if ( g_str_has_prefix( stack.source, "@" ) )
            {
                gchar * basename = g_path_get_basename( stack.source + 1 );

                source = basename;

                g_free( basename );
            }
            else
            {
                source = ar->source;
            }

            JSON::Object & frame( array.append<JSON::Object>() );

            frame[ "file" ] = source;
            frame[ "line" ] = stack.currentline;

            if ( stack.name && stack.namewhat )
            {
            	frame[ "name" ] = stack.name;
            	frame[ "type" ] = stack.namewhat;
            }
        }
    }

    return array;
}

//.............................................................................

JSON::Array Debugger::get_locals( lua_State * L , lua_Debug * ar )
{
	JSON::Array array;

    for( int i = 1; ; ++i )
    {
        const char * name = lua_getlocal( L , ar , i );

        if ( ! name )
        {
            break;
        }

        JSON::Object & local( array.append<JSON::Object>() );

		local[ "type"  ] = lua_typename( L , lua_type( L , -1 ) );

		const char * value = lua_tostring( L , -1 );


		local[ "name"  ] = name;

		if ( value )
		{
			local[ "value" ] = value;
		}

		lua_pop( L , 1 );
    }

    return array;
}

//.............................................................................

JSON::Object Debugger::get_location( lua_State * L , lua_Debug * ar )
{
	JSON::Object result;

	if ( g_str_has_prefix( ar->source, "@" ) )
    {
        gchar * basename = g_path_get_basename( ar->source + 1 );

        result[ "file" ] = basename;

        g_free( basename );

		// lines = load_source_file( ar->source + 1 );
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

JSON::Array Debugger::get_breakpoints( lua_State * L , lua_Debug * ar )
{
	JSON::Array result;

	for ( BreakpointList::const_iterator it = breakpoints.begin(); it != breakpoints.end(); ++it )
	{
		JSON::Object & b = result.append<JSON::Object>();

		b[ "file" ] = it->first;
		b[ "line" ] = it->second;
	}

	return result;
}

//.............................................................................

JSON::Object Debugger::get_app_info()
{
	JSON::Object result;

	const App::Metadata & md = app->get_metadata();

	result[ "id"         ] = md.id;
	result[ "name" 		 ] = md.name;
	result[ "release" 	 ] = md.release;
	result[ "version" 	 ] = md.version;
	result[ "description"] = md.description;
	result[ "author"     ] = md.author;
	result[ "copyright"  ] = md.copyright;

	JSON::Array & array = result[ "contents" ].as<JSON::Array>();

	StringList contents = md.sandbox.get_pi_children();

	for ( StringList::const_iterator it = contents.begin(); it != contents.end(); ++it )
	{
		array.append( * it );
	}

	return result;
}

//.............................................................................

bool Debugger::handle_command( lua_State * L , lua_Debug * ar , void * cmd )
{
	bool result = false;

	Server::Command * server_command = ( Server::Command * ) cmd;

	String command( server_command->get() );

	JSON::Object reply( get_location( L , ar ) );

	// List locals

	if ( command == "l" )
	{
		reply[ "locals" ] = get_locals( L , ar );
	}

	// Where? Just sends the location

	else if ( command == "w" )
	{
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
		break_next = true;
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

	// Commands with parameters are submitted as JSON

	else
	{
		JSON::Object co = JSON::Parser::parse( command ).as<JSON::Object>();

		command = co[ "command" ].as<String>();

		// Set a new breakpoint

		if ( command == "b" )
		{
			String file = co[ "file" ].as<String>();

			int line = co[ "line" ].as<long long>();

			if ( line > 0 && ! file.empty() )
			{
				bool is_native = false;

				if ( ! app->get_metadata().sandbox.get_pi_child_uri( file , is_native ).empty() )
				{
					breakpoints.push_back( Breakpoint( file , line ) );
				}
			}
		}

		// Delete a breakpoint

		else if ( command == "d" )
		{
			if ( co.has( "all" ) )
			{
				breakpoints.clear();
			}
			else
			{
				unsigned int index = co[ "breakpoint" ].as<long long>();

				if ( index >= 0 && index < breakpoints.size() )
				{
					breakpoints.erase( breakpoints.begin() + index );
				}
			}
		}

		// Fetch a file

		else if ( command == "f" )
		{
			String file = co[ "file" ].as<String>();

			if ( ! file.empty() )
			{
				gsize length = 0;

				gchar * contents = app->get_metadata().sandbox.get_pi_child_contents( file , length );

				if ( contents && length )
				{
					reply[ "contents" ] = String( contents , length );
				}

				g_free( contents );
			}
		}
	}

	server_command->reply( reply );

	delete server_command;

	return result;
}

//.............................................................................

void Debugger::debug_break( lua_State * L, lua_Debug * ar )
{
	lua_getinfo( L, "nSl", ar );

    //.........................................................................
	// Process any pending debugger commands here

	for ( Server::Command * server_command = server->get_next_command( false ); server_command; server_command = server->get_next_command( false ) )
	{
		( void ) handle_command( L , ar , server_command );
	}

	//.........................................................................

    bool should_break = false;

	switch( ar->event )
	{
		case LUA_HOOKCALL:
		case LUA_HOOKRET:
		case LUA_HOOKTAILRET:
			break;

		case LUA_HOOKLINE:

			if ( break_next )
			{
				should_break = true;
			}
			else
			{
				// see if there is a breakpoint for this file/line

				for ( BreakpointList::const_iterator it = breakpoints.begin(); it != breakpoints.end(); ++it )
				{
					if ( it->second == ar->currentline && g_str_has_suffix( ar->source, it->first.c_str() ) )
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

    JSON::Object location( get_location( L , ar ) );

	tpinfo( "BREAK AT %s:%lld" , location[ "file" ].as< String >().c_str() , location[ "line" ].as< long long >() );

	in_break = true;

	while ( true )
    {
    	//.....................................................................
    	// Wait for a command from the server, this will pause indefinitely

    	Server::Command * server_command = server->get_next_command( true );

    	if ( ! server_command )
    	{
    		// Something went very wrong

    		break;
    	}

    	// Deal with the command, deletes it.
    	// If it returns true, it means we should jump out

    	if ( handle_command( L , ar , server_command ) )
    	{
    		break;
    	}

    }

	in_break = false;
}

#if 0

//.............................................................................

StringVector * Debugger::load_source_file( const char * file_name )
{
	SourceMap::iterator it = source.find( file_name );

	if ( it != source.end() )
	{
		return & it->second;
	}

	std::ifstream stream( file_name , std::ios_base::in );

	if ( ! stream )
	{
		return 0;
	}

	String line;

	StringVector & lines( source[ file_name ] );

	while ( std::getline( stream , line ) )
	{
		lines.push_back( line );
	}

	return & lines;
}

#endif
