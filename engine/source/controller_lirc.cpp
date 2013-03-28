
#include "gio/gunixsocketaddress.h"

#include "trickplay/keys.h"
#include "controller_lirc.h"
#include "util.h"
#include "context.h"

//.............................................................................

#define TP_LOG_DOMAIN   "LIRC"
#define TP_LOG_ON       true
#define TP_LOG2_ON      false

#include "log.h"

//.............................................................................

ControllerLIRC* ControllerLIRC::make( TPContext* context )
{
    g_assert( context );

    if ( ! context->get_bool( TP_LIRC_ENABLED , TP_LIRC_ENABLED_DEFAULT ) )
    {
        return 0;
    }

    return new ControllerLIRC( context ,
            context->get( TP_LIRC_UDS , TP_LIRC_UDS_DEFAULT ) ,
            context->get_int( TP_LIRC_REPEAT , TP_LIRC_REPEAT_DEFAULT ) );
}

//.............................................................................

ControllerLIRC::ControllerLIRC( TPContext* context , const char* uds , guint _repeat )
    :
    connection( 0 ),
    controller( 0 ),
    timer( 0 ),
    repeat( gdouble( _repeat ) / 1000.0 )
{
    g_assert( context );
    g_assert( uds );

    //.........................................................................
    // Get the address of the Unix Domain Socket

    GSocketAddress* socket_address = g_unix_socket_address_new( uds );

    if ( ! socket_address )
    {
        tpwarn( "FAILED TO CREATE SOCKET ADDRESS WITH '%d'" , uds );
        return;
    }

    //.........................................................................
    // Create a socket client and attempt to connect to the address

    GSocketClient* client = g_socket_client_new();

    connection = g_socket_client_connect( client , G_SOCKET_CONNECTABLE( socket_address ) , NULL , NULL );

    g_object_unref( socket_address );

    g_object_unref( client );

    if ( ! connection )
    {
        tplog( "FAILED TO CONNECT TO LIRC SOCKET" );
        return;
    }

    //.........................................................................
    // Now, get the socket's input stream, create a data input stream from it
    // and start reading lines.

    GDataInputStream* input_stream = g_data_input_stream_new( g_io_stream_get_input_stream( G_IO_STREAM( connection ) ) );

    g_assert( input_stream );

    g_data_input_stream_read_line_async( input_stream , 0 , NULL , line_read , this );

    g_object_unref( input_stream );

    //.........................................................................
    // Add the controller

    TPControllerSpec controller_spec;

    memset( & controller_spec , 0 , sizeof( controller_spec ) );

    controller_spec.capabilities = TP_CONTROLLER_HAS_KEYS;

    controller = tp_context_add_controller( context , "Remote" , & controller_spec , 0 );

    g_assert( controller );

    //.........................................................................
    // Populate the key map

    key_map[ "0"         ] = TP_KEY_0;
    key_map[ "1"         ] = TP_KEY_1;
    key_map[ "2"         ] = TP_KEY_2;
    key_map[ "3"         ] = TP_KEY_3;
    key_map[ "4"         ] = TP_KEY_4;
    key_map[ "5"         ] = TP_KEY_5;
    key_map[ "6"         ] = TP_KEY_6;
    key_map[ "7"         ] = TP_KEY_7;
    key_map[ "8"         ] = TP_KEY_8;
    key_map[ "9"         ] = TP_KEY_9;
    key_map[ "MUTE"      ] = TP_KEY_MUTE;
    key_map[ "CH_UP"     ] = TP_KEY_CHAN_UP;
    key_map[ "VOL_UP"    ] = TP_KEY_VOL_UP;
    key_map[ "CH_DOWN"   ] = TP_KEY_CHAN_DOWN;
    key_map[ "VOL_DOWN"  ] = TP_KEY_VOL_DOWN;
    key_map[ "UP"        ] = TP_KEY_UP;
    key_map[ "LEFT"      ] = TP_KEY_LEFT;
    key_map[ "OK"        ] = TP_KEY_OK;
    key_map[ "RIGHT"     ] = TP_KEY_RIGHT;
    key_map[ "DOWN"      ] = TP_KEY_DOWN;
    key_map[ "MENU"      ] = TP_KEY_MENU;
    key_map[ "EXIT"      ] = TP_KEY_EXIT;
    key_map[ "PLAY"      ] = TP_KEY_PLAY;
    key_map[ "PAUSE"     ] = TP_KEY_PAUSE;
    key_map[ "STOP"      ] = TP_KEY_STOP;
    key_map[ "|<<"       ] = TP_KEY_PREV;
    key_map[ ">>|"       ] = TP_KEY_NEXT;
    key_map[ "RECORD"    ] = TP_KEY_REC;
    key_map[ "<<"        ] = TP_KEY_REW;
    key_map[ ">>"        ] = TP_KEY_FFWD;
    key_map[ "RED"       ] = TP_KEY_RED;
    key_map[ "GREEN"     ] = TP_KEY_GREEN;
    key_map[ "YELLOW"    ] = TP_KEY_YELLOW;
    key_map[ "BLUE"      ] = TP_KEY_BLUE;
    key_map[ "BACK"      ] = TP_KEY_BACK;

    timer = g_timer_new();

    tplog( "READY" );
}

//.............................................................................

ControllerLIRC::~ControllerLIRC()
{
    if ( connection )
    {
        g_object_unref( connection );

        connection = 0;
    }

    if ( timer )
    {
        g_timer_destroy( timer );

        timer = 0;
    }
}

//.............................................................................

void ControllerLIRC::line_read( GObject* stream , GAsyncResult* result , gpointer me )
{
    g_assert( stream );
    g_assert( result );
    g_assert( me );

    ( ( ControllerLIRC* ) me )->line_read( stream , result );
}

//.............................................................................

void ControllerLIRC::line_read( GObject* stream , GAsyncResult* result )
{
    GError* error = 0;

    char* line = g_data_input_stream_read_line_finish( G_DATA_INPUT_STREAM( stream ) , result , NULL , & error );

    if ( error )
    {
        tplog( "READ ERROR : %s" , error->message );
        g_clear_error( & error );
        g_object_unref( connection );
        connection = 0;
        return;
    }

    if ( line )
    {
        // Split it into 4 pieces

        gchar * * parts = g_strsplit( line , " " , 4 );

        if ( g_strv_length( parts ) >= 3 )
        {
            KeyMap::const_iterator it = key_map.find( parts[ 2 ] );

            if ( it != key_map.end() )
            {
                if ( g_timer_elapsed( timer , NULL ) >= repeat )
                {
                    tp_controller_key_down( controller , it->second , 0 , TP_CONTROLLER_MODIFIER_NONE );
                    tp_controller_key_up( controller , it->second , 0 , TP_CONTROLLER_MODIFIER_NONE );

                    g_timer_start( timer );
                }
            }
        }

        g_strfreev( parts );

        g_free( line );
    }

    g_data_input_stream_read_line_async( G_DATA_INPUT_STREAM( stream ) , 0 , NULL , line_read , this );
}
