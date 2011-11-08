
#include <iostream>
#include <fstream>
#include <cstdlib>

#include "debugger.h"
#include "app.h"
#include "context.h"
#include "console.h"
#include "util.h"

//.............................................................................

#define TP_LOG_DOMAIN   "DEBUGGER"
#define TP_LOG_ON       true
#define TP_LOG2_ON      true

#include "log.h"

//.............................................................................

class Debugger::Server
{
public:

	Server( TPContext * context )
	:
		listener( g_socket_listener_new() ),
		port( 0 ),
		stream( 0 )
	{
		GError * error = 0;

		port = context->get_int( TP_DEBUGGER_PORT , 0 );

		if ( 0 == port )
		{
			port = g_socket_listener_add_any_inet_port( listener , 0 , & error );
		}
		else
		{
			g_socket_listener_add_inet_port( listener , port , 0 , & error );
		}

		if ( error )
		{
			port = 0;
			tpwarn( "FAILED TO START SERVER : %s" , error->message );
			g_clear_error( & error );
		}
		else
		{
			tpinfo( "READY ON PORT %u" , port );
		}
	}

	static void destroy( gpointer me )
	{
		delete ( Server * ) me;
	}

	virtual bool wait_for_connection()
	{
		if ( 0 == port )
		{
			return false;
		}

		if ( 0 == stream )
		{
			// This will block forever waiting for a connection

			tplog( "WAITING FOR REMOTE CONNECTION ON PORT %u" , port );

			GSocketConnection * client = g_socket_listener_accept( listener , 0 , 0 , 0 );

			tplog( "ACCEPTED CONNECTION" );

			if ( client )
			{
				stream = g_data_input_stream_new( g_io_stream_get_input_stream( G_IO_STREAM( client ) ) );

				if ( stream )
				{
					// We attach the client to the stream so that the former will get destroyed with the latter.

					g_object_set_data_full( G_OBJECT( stream ) , "tp-socket-connection" , client , g_object_unref );
				}
				else
				{
					g_object_unref( client );
				}
			}
		}

		return 0 != stream;
	}

	virtual bool read_line( String & result )
	{
		if ( 0 == port || 0 == stream )
		{
			return false;
		}

		gsize length = 0;

		char * line = g_data_input_stream_read_line( stream , & length , 0 , 0 );

		if ( line )
		{
			if ( length > 1 )
			{
				result = String( line , length - 1 );
			}

			g_free( line );

			return true;
		}

		tpwarn( "CLIENT DISCONNECTED" );

		g_object_unref( stream );

		stream = 0;

		return false;
	}

	virtual bool write( const JSON::Object & obj )
	{
		if ( 0 == port || 0 == stream )
		{
			return false;
		}

		String line( obj.stringify() );

		line += "\n";

		GIOStream * iostream = G_IO_STREAM( g_object_get_data( G_OBJECT( stream ) , "tp-socket-connection" ) );

		if ( 0 == iostream )
		{
			return false;
		}

		GOutputStream * os = g_io_stream_get_output_stream( iostream );

		if ( 0 == os )
		{
			return false;
		}

		if ( ! g_output_stream_write_all( os , line.c_str() , line.size() , 0 , 0 , 0 ) )
		{
			g_object_unref( stream );

			stream = 0;

			return false;
		}

		return true;
	}

private:

	virtual ~Server()
	{
		tplog( "CLOSING SERVER" );

		if ( stream )
		{
			g_object_unref( stream );
		}

		g_object_unref( listener );
	}

	GSocketListener * 	listener;
	guint16 			port;
	GDataInputStream * 	stream;
};

//.............................................................................

Debugger::Server * Debugger::server = 0;

//.............................................................................

Debugger::Debugger( App * _app )
:
    app( _app ),
    installed( false ),
    break_next( false ),
    tracing( false )
{
    app->get_context()->add_console_command_handler( "debug", command_handler, this );

    if ( 0 == server )
    {
    	server = new Debugger::Server( app->get_context() );

		static char key = 0;

		app->get_context()->add_internal( & key , server , Server::destroy );
    }
}

//.............................................................................

Debugger::~Debugger()
{
    uninstall();

    app->get_context()->remove_console_command_handler( "debug", command_handler, this );
}

//.............................................................................

void Debugger::command_handler( TPContext * context , const char * command, const char * parameters, void * me )
{
    ( ( Debugger * ) me )->handle_command( parameters );
}

//.............................................................................

void Debugger::uninstall()
{
    if ( installed )
    {
        lua_sethook( app->get_lua_state(), lua_hook, 0, 0 );
    }

    source.clear();
}

//.............................................................................

void Debugger::install()
{
    if ( installed )
    {
        return;
    }

    lua_sethook( app->get_lua_state(), lua_hook, /* LUA_MASKCALL | LUA_MASKRET | */ LUA_MASKLINE, 0 );

    installed = true;
}

//.............................................................................

void Debugger::handle_command( const char * parameters )
{
    install();

    if ( ! parameters )
    {
        return;
    }

    FreeLater free_later;

    gchar * * p = g_strsplit( parameters, " ", 0 );

    free_later( p );

    guint count = g_strv_length( p );

    if ( ! count )
    {
        return;
    }

    if ( g_str_has_prefix( p[ 0 ], "b" ) )
    {
        // List or set breakpoints

        if ( count == 1 )
        {
            // No parameters, list breakpoints

            if ( breakpoints.empty() )
            {
                std::cout << "No breakpoints set" << std::endl;
            }
            else
            {
                int i = 1;

                for ( BreakpointList::const_iterator it = breakpoints.begin(); it != breakpoints.end(); ++it, ++i )
                {
                    std::cout << i << ") " << it->first << ":" << it->second << std::endl;
                }
            }
        }
        else if ( count == 3 )
        {
            int line = atoi( p[ 2 ] );

            if ( ! line )
            {
                std::cout << "Invalid line" << std::endl;
            }
            else
            {
                breakpoints.push_back( Breakpoint( p[ 1 ], line ) );

                std::cout << "Breakpoint " << breakpoints.size() << " set at " << p[1] << ":" << line << std::endl;
            }
        }
        else
        {
            std::cout << "Use 'b' to list breakpoints or 'b <file> <line>' to set a breakpoint" << std::endl;
        }
    }
    else if ( g_str_has_prefix( p[ 0 ], "d" ) )
    {
        // Delete a breakpoint

        if ( count < 2 )
        {
            std::cout << "Use 'd <breakpoint number>' to delete a breakpoint"  << std::endl;
        }
        else if ( ! strcmp( p[ 1 ] , "all" ) )
        {
            breakpoints.clear();

            std::cout << "Deleted all breakpoints" << std::endl;
        }
        else
        {
            int n = atoi( p[ 1 ] );

            int i = 1;

            bool deleted = false;

            for ( BreakpointList::iterator it = breakpoints.begin(); it != breakpoints.end() && ! deleted; ++it, ++i )
            {
                if ( i == n )
                {
                    breakpoints.erase( it );
                    deleted = true;
                }
            }

            if ( deleted )
            {
                std::cout << "Deleted breakpoint " << n << std::endl;
            }
            else
            {
                std::cout << "No such breakpoint" << std::endl;
            }
        }
    }
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

void Debugger::debug_break( lua_State * L, lua_Debug * ar )
{
    bool should_break = tracing;

    lua_getinfo( L, "nSl", ar );

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

    if ( ! should_break )
    {
        return;
    }

	//.....................................................................
    // Disable the console, because it interferes with stdin

    Console * console = app->get_context()->get_console();

    if ( console )
    {
        console->disable();
    }

	//.....................................................................
    // Figure out where we are

    String source;

    StringVector * lines = 0;

	if ( g_str_has_prefix( ar->source, "@" ) )
    {
        gchar * basename = g_path_get_basename( ar->source + 1 );

        source = basename;

        g_free( basename );

		lines = load_source_file( ar->source + 1 );
    }
    else
    {
        source = ar->source;
    }

#if 0

	if ( lines && tracing )
    {
    	if ( ( ar->currentline - 1 ) >= 0 && ( ar->currentline - 1 ) < int( lines->size() ) )
    	{
    		std::cout << ":" << (*lines)[ ar->currentline - 1 ];
    	}
    }


    if ( lines && ! tracing )
	{
		int list_start = std::max( ar->currentline - 5 , 1 );
		int list_end = std::min( ar->currentline + 5 , int( lines->size() ) );

		for ( int i = list_start; i < list_end; ++i )
		{
			std::cout << ( ( i == ar->currentline ) ? ">" : " " ) << (*lines)[i-1] << std::endl;
		}
	}

#endif

    while ( true )
    {
    	if ( tracing )
    	{
    		break;
    	}

    	tpinfo( "BREAK AT %s:%d" , source.c_str() , ar->currentline );

    	//.....................................................................
    	// Wait for a client to connect

        if ( ! server->wait_for_connection() )
        {
        	break;
        }

    	//.....................................................................
        // Tell the client where we are - this is a cue to the client that
        // we will be waiting for its response.

        JSON::Object response;

        response[ "type"   ] = "break";
        response[ "file"   ] = source;
        response[ "line"   ] = ar->currentline;
        response[ "stack"  ] = get_back_trace( L , ar );
        response[ "locals" ] = get_locals( L , ar );

        if ( ! server->write( response ) )
        {
        	continue;
        }

    	//.....................................................................
        // Now wait for the client to respond. If something goes wrong, the
        // client is disconnected and we wait for a new connection.

        String command;

        if ( ! server->read_line( command ) )
        {
        	// The client disconnected, we go back to waiting for a connection

        	continue;
        }

    	//.....................................................................
        // The client sent an empty command, do nothing.

        if ( command.empty() )
        {
        	continue;
        }

    	//.....................................................................
        // Reset our response object

        response.clear();

    	//.....................................................................
        // Quit

        if ( command == "q" )
        {
            tp_context_quit( app->get_context() );
            break_next = false;
            break;
        }

    	//.....................................................................
        // Continue

        else if ( command == "c" )
        {
            break_next = false;
            break;
        }

    	//.....................................................................
        // Step or next

        else if ( command == "s" || command == "n" )
        {
            break_next = true;
            break;
        }


#if 0

        else if ( command == "t" )
        {
        	// tracing = true;
        }

#endif

        // Run some Lua

        else if ( command.substr( 0 , 2 ) == "r " )
        {
            String exp( command.substr( 2 ) );

            int top = lua_gettop( L );

            if ( luaL_dostring( L, exp.c_str() ) )
            {
                std::cout << "Error: " << lua_tostring( L, -1 ) << std::endl;

                lua_pop( L, 1 );
            }
            else
            {
                lua_pop( L, lua_gettop( L ) - top );
            }
        }

#if 0
        // Help

        else if ( command == "help" || command == "h" || command == "?" )
        {
            std::cout <<

                    "'b' to list breakpoints" << std::endl <<
                    "'b <file> <line number>' to set a breakpoint" << std::endl <<
                    "'d <breakpoint number>' to delete a breakpoint" << std::endl <<
                    "'bt' to show a backtrace" << std::endl <<
                    "'c' to continue" << std::endl <<
                    "'s' or 'n' to continue until the next line" << std::endl <<
                    "'l' to list local variables" << std::endl <<
                    "'t' to trace execution" << std::endl <<
                    "'r <some Lua>' to run some Lua (in global scope)" << std::endl <<
                    "'q' to quit TrickPlay" << std::endl;
        }

        // Handle it in the command handler

        else
        {
            handle_command( command.c_str() );
        }
#endif

        if ( response.size() > 0 )
        {
        	server->write( response );
        }

    }

    if ( console )
    {
        console->enable();
    }
}

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


