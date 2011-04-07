
#include <cstring>
#include <cstdio>
#include <cstdlib>

#include "libsoup/soup.h"
#include "clutter/clutter.h"
#include "uriparser/Uri.h"

#include "app.h"
#include "controller_server.h"
#include "util.h"
#include "sysdb.h"

//-----------------------------------------------------------------------------

#ifdef TP_CONTROLLER_DISCOVERY_MDNS
#include "controller_discovery_mdns.h"
#endif

#ifdef TP_CONTROLLER_DISCOVERY_UPNP
#include "controller_discovery_upnp.h"
#endif

//-----------------------------------------------------------------------------
// This is how quickly we disconnect a controller that has not identified itself

#define DISCONNECT_TIMEOUT_SEC  30

//-----------------------------------------------------------------------------

ControllerServer::ControllerServer( TPContext * ctx, const String & name, int port )
    :
    discovery_mdns( NULL ),
    discovery_upnp( NULL ),
    server( NULL ),
    context( ctx ),
    app_resource_request_handler( NULL )
{
    GError * error = NULL;

    Server * new_server = new Server( port, this, '\n', &error );

    if ( error )
    {
        delete new_server;
        g_warning( "FAILED TO START CONTROLLER SERVER ON PORT %d : %s", port, error->message );
        g_clear_error( &error );
    }
    else
    {
        server.reset( new_server );

        g_info( "CONTROLLER SERVER LISTENER READY ON PORT %d", server->get_port() );

        app_resource_request_handler = new AppResourceRequestHandler( context );

        //TODO: remove the below line as it is added only for testing
        String resource_id = app_resource_request_handler->serve_path( "", "hosts" );
        g_info ( ( String( " resource_id of 'hosts' is " ) + resource_id ).c_str() );
#ifdef TP_CONTROLLER_DISCOVERY_MDNS

        if ( context->get_bool( TP_CONTROLLERS_MDNS_ENABLED , true ) )
        {
            discovery_mdns.reset( new ControllerDiscoveryMDNS( context , name, server->get_port() ) );
        }
        else
        {
            g_info( "CONTROLLER MDNS DISCOVERY IS DISABLED" );
        }

#endif

#ifdef TP_CONTROLLER_DISCOVERY_UPNP

        if ( context->get_bool( TP_CONTROLLERS_UPNP_ENABLED , false ) )
        {
            discovery_upnp.reset( new ControllerDiscoveryUPnP( context , name, server->get_port() ) );
        }
        else
        {
            g_info( "CONTROLLER UPNP DISCOVERY IS DISABLED" );
        }
#endif

    }
}

//-----------------------------------------------------------------------------

ControllerServer::~ControllerServer()
{
	if ( app_resource_request_handler ) {
		delete app_resource_request_handler;
	}
}

//-----------------------------------------------------------------------------

bool ControllerServer::is_ready() const
{
    if ( discovery_mdns.get() )
    {
        return discovery_mdns->is_ready();
    }

    if ( discovery_upnp.get() )
    {
        return discovery_upnp->is_ready();
    }

    return true;
}

//-----------------------------------------------------------------------------

int ControllerServer::execute_command( TPController * controller, unsigned int command, void * parameters, void * data )
{
    g_assert( data );

    return ( ( ControllerServer * )data )->execute_command( controller, command, parameters );
}

int ControllerServer::execute_command( TPController * controller, unsigned int command, void * parameters )
{
    if ( !server.get() )
    {
        return 1;
    }

    gpointer connection = NULL;

    for ( ConnectionMap::const_iterator it = connections.begin(); it != connections.end(); ++it )
    {
        if ( it->second.controller == controller )
        {
            connection = it->first;
            break;
        }
    }

    if ( !connection )
    {
        return 2;
    }

    switch ( command )
    {
        case TP_CONTROLLER_COMMAND_RESET                 :
        {
            server->write( connection, "RT\n" );
            break;
        }

        case TP_CONTROLLER_COMMAND_START_ACCELEROMETER   :
        {
            TPControllerStartAccelerometer * sa = ( TPControllerStartAccelerometer * )parameters;

            const char * filter = "N";

            switch ( sa->filter )
            {
                case TP_CONTROLLER_ACCELEROMETER_FILTER_LOW:
                    filter = "L";
                    break;

                case TP_CONTROLLER_ACCELEROMETER_FILTER_HIGH:
                    filter = "H";
                    break;
            }

            server->write_printf( connection, "SA\t%s\t%f\n", filter, sa->interval );

            break;
        }

        case TP_CONTROLLER_COMMAND_STOP_ACCELEROMETER    :
        {
            server->write( connection, "PA\n" );
            break;
        }


        case TP_CONTROLLER_COMMAND_START_POINTER         :
        {
            server->write( connection, "SP\n" );
            break;
        }

        case TP_CONTROLLER_COMMAND_STOP_POINTER          :
        {
            server->write( connection, "PP\n" );
            break;
        }

        case TP_CONTROLLER_COMMAND_START_TOUCHES         :
        {
            server->write( connection, "ST\n" );
            break;
        }

        case TP_CONTROLLER_COMMAND_STOP_TOUCHES          :
        {
            server->write( connection, "PT\n" );
            break;
        }

        case TP_CONTROLLER_COMMAND_SHOW_MULTIPLE_CHOICE  :
        {
            TPControllerMultipleChoice * mc = ( TPControllerMultipleChoice * )parameters;

            String line;

            for ( unsigned int i = 0; i < mc->count; ++i )
            {
                if ( i > 0 )
                {
                    line += "\t";
                }

                line += mc->ids[i];
                line += "\t";
                line += mc->choices[i];
            }

            server->write_printf( connection, "MC\t%s\t%s\n", mc->label, line.c_str() );

            break;
        }

        case TP_CONTROLLER_COMMAND_CLEAR_UI              :
        {
            server->write( connection, "CU\n" );
            break;
        }

        case TP_CONTROLLER_COMMAND_SET_UI_BACKGROUND     :
        {
            TPControllerSetUIBackground * sb = ( TPControllerSetUIBackground * )parameters;

            const char * mode = "S";

            switch ( sb->mode )
            {
                case TP_CONTROLLER_UI_BACKGROUND_MODE_CENTER:
                    mode = "C";
                    break;

                case TP_CONTROLLER_UI_BACKGROUND_MODE_TILE:
                    mode = "T";
                    break;
            }

            server->write_printf( connection, "UB\t%s\t%s\n", sb->resource, mode );

            break;
        }

        case TP_CONTROLLER_COMMAND_SET_UI_IMAGE          :
        {
            TPControllerSetUIImage * im = ( TPControllerSetUIImage * )parameters;
            server->write_printf( connection, "UG\t%s\t%d\t%d\t%d\t%d\n", im->resource, im->x, im->y, im->width, im->height );
            break;
        }

        case TP_CONTROLLER_COMMAND_PLAY_SOUND            :
        {
            TPControllerPlaySound * ps = ( TPControllerPlaySound * )parameters;
            server->write_printf( connection, "SS\t%s\t%u\n", ps->resource, ps->loop );
            break;
        }

        case TP_CONTROLLER_COMMAND_STOP_SOUND            :
        {
            server->write( connection, "PS\n" );
            break;
        }

        case TP_CONTROLLER_COMMAND_DECLARE_RESOURCE      :
        {
            TPControllerDeclareResource * ds = ( TPControllerDeclareResource * )parameters;

            const char * uri = NULL;

            String path;

            if ( g_str_has_prefix( ds->uri, "http://" ) || g_str_has_prefix( ds->uri, "https://" ) )
            {
                uri = ds->uri;
            }
            else if ( g_str_has_prefix( ds->uri, "file://" ) )
            {
                path = app_resource_request_handler->serve_path( "", String( ( ds->uri ) + 7 ) );
                uri = path.c_str();
            }

            if ( !uri )
            {
                return 5;
            }

            server->write_printf( connection, "DR\t%s\t%s\n", ds->resource, uri );
            break;
        }

        case TP_CONTROLLER_COMMAND_ENTER_TEXT            :
        {
            TPControllerEnterText * et = ( TPControllerEnterText * )parameters;
            server->write_printf( connection, "ET\t%s\t%s\n", et->label, et->text );
            break;
        }

        case TP_CONTROLLER_COMMAND_SUBMIT_PICTURE	:
		{
			server->write_printf( connection, "PI\n");
			break;
		}

        case TP_CONTROLLER_COMMAND_SUBMIT_AUDIO_CLIP	:
		{
			server->write_printf( connection, "AC\n");
			break;
		}

        default:
        {
            return 3;
        }
    }

    // Success

    return 0;
}

//-----------------------------------------------------------------------------

ControllerServer::ConnectionInfo * ControllerServer::find_connection( gpointer connection )
{
    ConnectionMap::iterator it = connections.find( connection );

    return it == connections.end() ? NULL : &it->second;
}

//-----------------------------------------------------------------------------

void ControllerServer::connection_accepted( gpointer connection, const char * remote_address )
{
    g_debug( "ACCEPTED CONTROLLER CONNECTION %p FROM %s", connection, remote_address );

    // This adds the connection to the map and sets its address at the same time

    ConnectionInfo & info = connections[connection];

    info.address = remote_address;

    // Now, set a timer to disconnect the connection if it has not identified
    // itself within a few seconds

    GSource * source = g_timeout_source_new( DISCONNECT_TIMEOUT_SEC * 1000 );
    g_source_set_callback( source, timed_disconnect_callback, new TimerClosure( connection, this ), NULL );
    g_source_attach( source, g_main_context_default() );
    g_source_unref( source );
}

//-----------------------------------------------------------------------------

gboolean ControllerServer::timed_disconnect_callback( gpointer data )
{
    g_debug( "TIMED DISCONNECT" );

    // Check to see that the controller has reported a version

    TimerClosure * tc = ( TimerClosure * )data;

    ConnectionInfo * ci = tc->self->find_connection( tc->connection );

    if ( ci && ci->disconnect && !ci->version )
    {
        g_debug( "DROPPING UNIDENTIFIED CONNECTION %p", tc->connection );

        if ( tc->self->server.get() )
        {
            tc->self->server->close_connection( tc->connection );
        }
    }

    delete tc;

    return FALSE;
}

//-----------------------------------------------------------------------------

void ControllerServer::connection_closed( gpointer connection )
{
    ConnectionInfo * info = find_connection( connection );

    if ( info && info->controller )
    {
        tp_context_remove_controller( context, info->controller );
    }

    connections.erase( connection );

    g_debug( "CONTROLLER CONNECTION CLOSED %p", connection );
}

//-----------------------------------------------------------------------------

void ControllerServer::connection_data_received( gpointer connection, const char * line , gsize bytes_read )
{
    ConnectionMap::iterator it = connections.find( connection );

    if ( it == connections.end() )
    {
        return;
    }
    else {
		if (!strlen( line )) {
			return;
		}

		gchar ** parts = g_strsplit( line, "\t", 0 );

		process_command( connection, it->second, parts );

		g_strfreev( parts );
	}
}

//-----------------------------------------------------------------------------

static inline bool cmp2( const char * a, const char * b )
{
    return ( a[0] == b[0] ) && ( a[1] == b[1] );
}

void ControllerServer::process_command( gpointer connection, ConnectionInfo & info, gchar ** parts )
{
    guint count = g_strv_length( parts );

    if ( count < 1 )
    {
        return;
    }

    const gchar * cmd = parts[0];

    if ( strlen( cmd ) < 2 )
    {
        return;
    }

    if ( cmp2( cmd, "ID" ) )
    {
        // Device id line
        // ID <version> <name> <cap>*

        // Not enough parts

        if ( count < 3 )
        {
            return;
        }

        // Already have a version

        if ( info.version )
        {
            return;
        }


        info.version = atoi( parts[1] );

        if ( !info.version )
        {
            return;
        }

        if ( info.version < 2 )
        {
            g_warning( "CONTROLLER DOES NOT SUPPORT PROTOCOL VERSION >= 2" );
            info.version = 0;
            return;
        }

        if ( info.version < 3 )
        {
            g_warning( "CONTROLLER DOES NOT SUPPORT PROTOCOL VERSION >= 3" );
            info.version = 0;
            return;
        }

        const char * name = g_strstrip( parts[2] );

        // Capability entries

        TPControllerSpec spec;

        memset( &spec, 0, sizeof( spec ) );

        for ( guint i = 3; i < count; ++i )
        {
            const gchar * cap = g_strstrip( parts[i] );

            size_t len = strlen( cap );

            if ( len == 2 )
            {
                if ( cmp2( cap, "KY" ) )
                {
                    spec.capabilities |= TP_CONTROLLER_HAS_KEYS;
                }
                else if ( cmp2( cap, "AX" ) )
                {
                    spec.capabilities |= TP_CONTROLLER_HAS_ACCELEROMETER;
                }
                else if ( cmp2( cap, "PT" ) )
                {
                    spec.capabilities |= TP_CONTROLLER_HAS_POINTER;
                }
                else if ( cmp2( cap, "CK" ) )
                {
                    // Deprecated
                    // spec.capabilities |= TP_CONTROLLER_HAS_CLICKS;
                }
                else if ( cmp2( cap, "TC" ) )
                {
                    spec.capabilities |= TP_CONTROLLER_HAS_TOUCHES;
                }
                else if ( cmp2( cap, "MC" ) )
                {
                    spec.capabilities |= TP_CONTROLLER_HAS_MULTIPLE_CHOICE;
                }
                else if ( cmp2( cap, "SD" ) )
                {
                    spec.capabilities |= TP_CONTROLLER_HAS_SOUND;
                }
                else if ( cmp2( cap, "UI" ) )
                {
                    spec.capabilities |= TP_CONTROLLER_HAS_UI;
                }
                else if ( cmp2( cap, "TE" ) )
                {
                    spec.capabilities |= TP_CONTROLLER_HAS_TEXT_ENTRY;
                }
                else if ( cmp2( cap, "PS" ) )
				{
					spec.capabilities |= TP_CONTROLLER_HAS_PICTURES;
				}
                else if ( cmp2( cap, "AC" ) )
				{
					spec.capabilities |= TP_CONTROLLER_HAS_AUDIO_CLIPS;
				}
                else
                {
                    g_warning( "UNKNOWN CONTROLLER CAPABILITY '%s'", cap );
                }
            }
            else if ( len > 3 )
            {
                if ( cmp2( cap, "IS" ) )
                {
                    sscanf( cap, "IS=%ux%u", &spec.input_width, &spec.input_height );
                }
                else if ( cmp2( cap, "US" ) )
                {
                    sscanf( cap, "US=%ux%u", &spec.ui_width, &spec.ui_height );
                }
                else
                {
                    g_warning( "UNKNOWN CONTROLLER CAPABILITY '%s'", cap );
                }
            }
        }

        spec.execute_command = execute_command;

        info.controller = tp_context_add_controller( context, name, &spec, this );
    }
    else if ( cmp2( cmd, "KP" ) )
    {
        // Key press
        // KP <hex key code> <hex unicode>

        if ( count < 2 || !info.controller )
        {
            return;
        }

        unsigned int key_code = 0;
        unsigned long int unicode = 0;

        sscanf( parts[1], "%x", &key_code );

        if ( count > 2 )
        {
            sscanf( parts[2], "%lx", &unicode );
        }

        tp_controller_key_down( info.controller, key_code, unicode );
        tp_controller_key_up( info.controller, key_code, unicode );
    }
    else if ( cmp2( cmd, "KD" ) )
    {
        // Key down
        // KD <hex key code> <hex unicode>

        if ( count < 2 || !info.controller )
        {
            return;
        }

        unsigned int key_code = 0;
        unsigned long int unicode = 0;

        sscanf( parts[1], "%x", &key_code );

        if ( count > 2 )
        {
            sscanf( parts[2], "%lx", &unicode );
        }

        tp_controller_key_down( info.controller, key_code, unicode );
    }
    else if ( cmp2( cmd, "KU" ) )
    {
        // Key up
        // KU <hex key code> <hex unicode>

        if ( count < 2 || !info.controller )
        {
            return;
        }

        unsigned int key_code = 0;
        unsigned long int unicode = 0;

        sscanf( parts[1], "%x", &key_code );

        if ( count > 2 )
        {
            sscanf( parts[2], "%lx", &unicode );
        }

        tp_controller_key_up( info.controller, key_code, unicode );
    }
    else if ( cmp2( cmd, "CK" ) )
    {
        // Click
        // CK <x> <y>

        // deprecated

        return;
    }
    else if ( cmp2( cmd, "AX" ) )
    {
        // Acelerometer
        // AX <x> <y> <z>

        if ( count < 4 || !info.controller )
        {
            return;
        }

        tp_controller_accelerometer( info.controller, atof( parts[1] ), atof( parts[2] ), atof( parts[3] ) );
    }
    else if ( cmp2( cmd, "UI" ) )
    {
        // UI
        // UI <txt>

        if ( count < 2 || !info.controller )
        {
            return;
        }

        tp_controller_ui_event( info.controller, parts[1] );
    }
    else if ( cmp2( cmd, "PD" ) )
    {
        // Pointer button down
        // PD <button> <x> <y>

        if ( count < 4 || !info.controller )
        {
            return;
        }

        tp_controller_pointer_button_down( info.controller, atoi( parts[1] ), atoi( parts[2] ) , atoi( parts[ 3 ] ) );
    }
    else if ( cmp2( cmd, "PM" ) )
    {
        // Pointer move
        // PM <x> <y>

        if ( count < 3 || !info.controller )
        {
            return;
        }

        tp_controller_pointer_move( info.controller, atoi( parts[1] ), atoi( parts[2] ) );
    }
    else if ( cmp2( cmd, "PU" ) )
    {
        // Pointer button up
        // PU <button> <x> <y>

        if ( count < 4 || !info.controller )
        {
            return;
        }

        tp_controller_pointer_button_up( info.controller, atoi( parts[1] ), atoi( parts[2] ) , atoi( parts[ 3 ] ) );
    }
    else if ( cmp2( cmd, "TD" ) )
    {
        // Touch down
        // TD <finger> <x> <y>

        if ( count < 4 || !info.controller )
        {
            return;
        }

        tp_controller_touch_down( info.controller, atoi( parts[1] ), atoi( parts[2] ) , atoi( parts[ 3 ] ) );
    }
    else if ( cmp2( cmd, "TM" ) )
    {
        // Touch move
        // TM <finger> <x> <y>

        if ( count < 4 || !info.controller )
        {
            return;
        }

        tp_controller_touch_move( info.controller, atoi( parts[1] ), atoi( parts[2] ) , atoi( parts[ 3 ] ) );
    }
    else if ( cmp2( cmd, "TU" ) )
    {
        // Touch up
        // TU <finger> <x> <y>

        if ( count < 4 || !info.controller )
        {
            return;
        }

        tp_controller_touch_up( info.controller, atoi( parts[1] ), atoi( parts[2] ) , atoi( parts[ 3 ] ) );
    }
    else
    {
        g_warning( "UNKNOWN CONTROLLER COMMAND '%s'", cmd );
    }
}

