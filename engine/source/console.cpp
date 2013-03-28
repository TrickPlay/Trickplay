
#ifdef TP_HAS_READLINE
#include <cstdio>
#include "readline/readline.h"
#include "readline/history.h"
#endif

#include "console.h"
#include "util.h"
#include "context.h"


#ifdef TP_HAS_READLINE

static Console* readline_console = 0;

void Console::readline_handler( char* line )
{
    if ( line && strlen( line ) && readline_console )
    {
        readline_console->process_line( line );

        add_history( line );
    }
}

#endif


//-----------------------------------------------------------------------------
#define TP_LOG_DOMAIN   "CONSOLE"
#define TP_LOG_ON       true
#define TP_LOG2_ON      false

#include "log.h"
//-----------------------------------------------------------------------------

Console* Console::make( TPContext* context )
{
#ifdef TP_PRODUCTION
    return 0;
#else

    return new Console( context , context->get_bool( TP_CONSOLE_ENABLED, TP_CONSOLE_ENABLED_DEFAULT ),
            context->get_int( TP_TELNET_CONSOLE_PORT, TP_TELNET_CONSOLE_PORT_DEFAULT ) );
#endif
}

Console::Console( TPContext* ctx, bool read_stdin, int port )
    :
    context( ctx ),
    L( NULL ),
    channel( NULL ),
    watch( 0 ),
    stdin_buffer( NULL ),
    server( NULL ),
    enabled( true )
{
    if ( read_stdin )
    {
        int fd = fileno( stdin );

        if ( fd > -1 )
        {
            channel = g_io_channel_unix_new( fd );

            if ( channel )
            {
                stdin_buffer = g_string_new( NULL );

                watch = g_io_add_watch( channel, G_IO_IN, channel_watch, this );

#ifdef TP_HAS_READLINE

                using_history();

                rl_catch_signals = 0;

                rl_callback_handler_install( "" , readline_handler );

#endif
            }
        }
    }

    if ( port )
    {
        GError* error = NULL;

        Server* new_server = new Server( port, this, '\n', &error );

        if ( error )
        {
            delete new_server;
            tpwarn( "FAILED TO START ON PORT %d : %s", port, error->message );
            g_clear_error( &error );
        }
        else
        {
            server.reset( new_server );
            tplog( "READY ON PORT %d", server->get_port() );
        }
    }

    context->add_output_handler( output_handler, this );
}

Console::~Console()
{
    if ( channel )
    {
        if ( watch )
        {
            g_source_remove( watch );
        }

        g_io_channel_unref( channel );
    }

    if ( stdin_buffer )
    {
        g_string_free( stdin_buffer, TRUE );
    }

    context->remove_output_handler( output_handler, this );

#ifdef TP_HAS_READLINE

    rl_callback_handler_remove();

#endif

}

void Console::add_command_handler( CommandHandler handler, void* data )
{
    handlers.push_back( CommandHandlerClosure( handler, data ) );
}

void Console::attach_to_lua( lua_State* l )
{
    L = l;
}

gboolean Console::read_data()
{
    GError* error = NULL;

    g_io_channel_read_line_string( channel, stdin_buffer, NULL, &error );

    if ( error )
    {
        g_clear_error( &error );
        return FALSE;
    }

    process_line( stdin_buffer->str );

    return TRUE;
}

void Console::process_line( gchar* line )
{
    // Removes leading and trailing white space in place

    g_strstrip( line );

    if ( g_strstr_len( line, 1, "/" ) == line )
    {
        // This is a console command. Skipping the initial
        // slash, we split it into at most 2 parts - the command
        // and the rest of the line

        gchar** parts = g_strsplit( line + 1, " ", 2 );

        if ( g_strv_length( parts ) >= 1 )
        {
            for ( CommandHandlerList::iterator it = handlers.begin(); it != handlers.end(); ++it )
            {
                if ( it->first( parts[0], parts[1], it->second ) )
                {
                    break;
                }
            }
        }

        g_strfreev( parts );
    }
    else if ( strlen( line ) && L )
    {
        // This is plain lua

        int n = lua_gettop( L );

        if ( luaL_loadstring( L, line ) != 0 )
        {
            g_warning( "%s", lua_tostring( L, -1 ) );
            lua_pop( L, 1 );
        }
        else
        {
            if ( lua_pcall( L, 0, LUA_MULTRET, 0 ) != 0 )
            {
                g_warning( "%s", lua_tostring( L, -1 ) );
                lua_pop( L, 1 );
            }
            else
            {
                // We have the results from the call
                int nargs = lua_gettop( L ) - n;

                if ( nargs )
                {
                    // Get the global print function
                    lua_getglobal( L, "print" );
                    // Move it before the results
                    lua_insert( L, lua_gettop( L ) - nargs );

                    // Call it
                    if ( lua_pcall( L, nargs, 0, 0 ) != 0 )
                    {
                        lua_pop( L, 1 );
                    }
                }
            }
        }
    }
}

gboolean Console::channel_watch( GIOChannel* source, GIOCondition condition, gpointer data )
{
    Console* self = ( Console* ) data;

    if ( ! self->enabled )
    {
        return TRUE;
    }

#ifdef TP_HAS_READLINE

    readline_console = self;

    rl_callback_read_char();

    readline_console = 0;

    return TRUE;

#else
    return self->read_data();
#endif
}

void Console::connection_accepted( gpointer connection, const char* remote_address )
{
    server->write_printf( connection, "WELCOME TO TrickPlay %d.%d.%d\n", TP_MAJOR_VERSION, TP_MINOR_VERSION, TP_PATCH_VERSION );
    tplog( "ACCEPTED CONNECTION FROM %s", remote_address );
}

void Console::connection_data_received( gpointer connection, const char* data , gsize , bool* )
{
    gchar* line = g_strdup( data );
    process_line( line );
    g_free( line );
}

void Console::output_handler( const gchar* line, gpointer data )
{
    Console* console = ( Console* )data;

    if ( console->server.get() )
    {
        console->server->write_to_all( line );
    }
}

void Console::enable()
{
#ifdef TP_HAS_READLINE
    rl_callback_handler_install( "" , readline_handler );
#endif

    enabled = true;
}

void Console::disable()
{
#ifdef TP_HAS_READLINE
    rl_callback_handler_remove();
#endif

    enabled = false;
}

guint16 Console::get_port() const
{
    return server.get() ? server->get_port() : 0;
}

