
#include <iostream>
#include <cstdlib>

#include "debugger.h"
#include "app.h"
#include "context.h"
#include "console.h"
#include "util.h"

Debugger::Debugger( App * _app )
:
    app( _app ),
    installed( false ),
    break_next( false )
{
    app->get_context()->add_console_command_handler( "debug", command_handler, this );
}

Debugger::~Debugger()
{
    uninstall();

    app->get_context()->remove_console_command_handler( "debug", command_handler, this );
}

void Debugger::command_handler( TPContext * context , const char * command, const char * parameters, void * me )
{
    ( ( Debugger * ) me )->handle_command( parameters );
}

void Debugger::uninstall()
{
    if ( installed )
    {
        lua_sethook( app->get_lua_state(), lua_hook, 0, 0 );
    }
}

void Debugger::install()
{
    if ( installed )
    {
        return;
    }

    lua_sethook( app->get_lua_state(), lua_hook, /* LUA_MASKCALL | LUA_MASKRET | */ LUA_MASKLINE, 0 );

    installed = true;
}

void Debugger::handle_command( const char * parameters )
{
    lua_State * L = app->get_lua_state();

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

void Debugger::lua_hook( lua_State * L, lua_Debug * ar )
{
    if ( Debugger * debugger = App::get( L )->get_debugger() )
    {
        debugger->debug_break( L, ar );
    }
}

void Debugger::break_next_line()
{
    install();
    break_next = true;
}

void Debugger::debug_break( lua_State * L, lua_Debug * ar )
{
    bool should_break = false;

    lua_getinfo( L, "nSl", ar );

    switch( ar->event )
    {
        case LUA_HOOKCALL:
            break;

        case LUA_HOOKRET:
            break;

        case LUA_HOOKTAILCALL:
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

    Console * console = app->get_context()->get_console();

    if ( console )
    {
        console->disable();
    }

    // Print where we are

    String source;

    if ( g_str_has_prefix( ar->source, "@" ) )
    {
        gchar * basename = g_path_get_basename( ar->source + 1 );

        source = basename;

        g_free( basename );
    }
    else
    {
        source = ar->source;
    }

    std::cout << source << ":" << ar->currentline << std::endl;

    while ( true )
    {
        std::cout << "(debug) ";

        String command;

        std::getline( std::cin, command );

        // Show backtrace

        if ( command == "bt")
        {
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

                    std::cout << i << ") " << source << ":" << stack.currentline;

                    if ( stack.name && stack.namewhat )
                    {
                        std::cout << " " << stack.name << " (" << stack.namewhat << ")";
                    }

                    std::cout << std::endl;
                }
            }
        }

        // Quit

        else if ( command == "q" )
        {
            tp_context_quit( app->get_context() );
            break_next = false;
            break;
        }

        // Continue

        else if ( command == "c" )
        {
            break_next = false;
            break;
        }

        // Step or next

        else if ( command == "s" || command == "n" )
        {
            break_next = true;
            break;
        }

        // Print out locals

        else if ( command == "l" )
        {
            std::cout << "Locals:" << std::endl;

            for( int i = 1; ; ++i )
            {
                const char * name = lua_getlocal( L, ar, i );

                if ( ! name )
                {
                    break;
                }
                else
                {
                    const char * value = lua_tostring( L , -1 );

                    if ( value )
                    {
                        std::cout << name << " = " << value << std::endl;
                    }

                    lua_pop( L , 1 );
                }
            }
        }

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
                    "'r <some Lua>' to run some Lua (in global scope)" << std::endl <<
                    "'q' to quit TrickPlay" << std::endl;
        }

        // Handle it in the command handler

        else
        {
            handle_command( command.c_str() );
        }
    }

    if ( console )
    {
        console->enable();
    }
}
