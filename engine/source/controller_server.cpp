
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
static Debug_ON log( "CONTROLLER-SERVER" );
//-----------------------------------------------------------------------------
// This is how quickly we disconnect a controller that has not identified itself

#define DISCONNECT_TIMEOUT_SEC  30

//-----------------------------------------------------------------------------

ControllerServer::ControllerServer( TPContext * ctx, const String & name, int port )
    :
    discovery_mdns( NULL ),
    discovery_upnp( NULL ),
    server( NULL ),
    context( ctx )
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

        log( "READY ON PORT %d", server->get_port() );

        context->get_http_server()->register_handler( "/controllers" , this );

#ifdef TP_CONTROLLER_DISCOVERY_MDNS

        if ( context->get_bool( TP_CONTROLLERS_MDNS_ENABLED , true ) )
        {
            discovery_mdns.reset( new ControllerDiscoveryMDNS( context , name, server->get_port() ) );
        }
        else
        {
            log( "MDNS DISCOVERY IS DISABLED" );
        }

#endif

#ifdef TP_CONTROLLER_DISCOVERY_UPNP

        if ( context->get_bool( TP_CONTROLLERS_UPNP_ENABLED , false ) )
        {
            discovery_upnp.reset( new ControllerDiscoveryUPnP( context , name, server->get_port() ) );
        }
        else
        {
            log( "UPNP DISCOVERY IS DISABLED" );
        }
#endif

    }
}

//-----------------------------------------------------------------------------

ControllerServer::~ControllerServer()
{
    context->get_http_server()->unregister_handler( "/controllers" );
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

    for ( ConnectionMap::iterator it = connections.begin(); it != connections.end(); ++it )
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
                path = start_serving_resource( connection , ( ds->uri ) + 7 , ds->group );
                uri = path.c_str();
            }

            if ( !uri )
            {
                return 5;
            }

            if ( * uri == '/' )
            {
                ++uri;
            }

            server->write_printf( connection, "DR\t%s\t%s\t%s\n", ds->resource, uri , ds->group );
            break;
        }

        case TP_CONTROLLER_COMMAND_DROP_RESOURCE_GROUP   :
        {
            TPControllerDropResourceGroup * dg = ( TPControllerDropResourceGroup * ) parameters;

            drop_resource_group( connection , dg->group );

            server->write_printf( connection , "DG\t%s\n" , dg->group );

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
		    String path = start_post_endpoint( connection , PostInfo::PICTURES );
			server->write_printf( connection, "PI\t%s\n" , path.c_str() + 1 );
			break;
		}

        case TP_CONTROLLER_COMMAND_SUBMIT_AUDIO_CLIP	:
		{
            String path = start_post_endpoint( connection , PostInfo::AUDIO);
			server->write_printf( connection, "AC\t%s\n" , path.c_str() + 1 );
			break;
		}

        case TP_CONTROLLER_COMMAND_ADVANCED_UI:
        {
            TPControllerAdvancedUI * aui = ( TPControllerAdvancedUI * ) parameters;
            const char * cmd = 0;
            switch( aui->command )
            {
                case TP_CONTROLLER_ADVANCED_UI_CREATE:
                    cmd = "CREATE";
                    break;
                case TP_CONTROLLER_ADVANCED_UI_DESTROY:
                    cmd = "DESTROY";
                    break;
                case TP_CONTROLLER_ADVANCED_UI_SET:
                    cmd = "SET";
                    break;
                case TP_CONTROLLER_ADVANCED_UI_GET:
                    cmd = "GET";
                    break;
            }
            if ( ! cmd )
            {
                return 4;
            }
            server->write_printf( connection , "UX\t%s\t%s\n" , cmd , aui->payload );
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
    log( "ACCEPTED CONNECTION %p FROM %s", connection, remote_address );

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
    log( "TIMED DISCONNECT" );

    // Check to see that the controller has reported a version

    TimerClosure * tc = ( TimerClosure * )data;

    ConnectionInfo * ci = tc->self->find_connection( tc->connection );

    if ( ci && ci->disconnect && !ci->version )
    {
        log( "DROPPING UNIDENTIFIED CONNECTION %p", tc->connection );

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

    drop_resource_group( connection , String() );

    drop_post_endpoint( connection );

    connections.erase( connection );

    log( "CONNECTION CLOSED %p", connection );
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
    static const char * PROTOCOL_VERSION = "32";

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
                else if ( cmp2( cap , "UX" ) )
                {
                    spec.capabilities |= TP_CONTROLLER_HAS_ADVANCED_UI;
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

        server->write_printf( connection , "WM\t%s\t%u\n" , PROTOCOL_VERSION , context->get_http_server()->get_port() );
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

//-----------------------------------------------------------------------------

String ControllerServer::start_serving_resource( gpointer connection , const String & file_name , const String & group )
{
    String path = group + ":" + file_name;

    gchar * h = g_compute_checksum_for_string( G_CHECKSUM_MD5 , path.c_str() , path.length() );

    path = h;

    g_free( h );

    path = String( "/controllers/resource/" ) + path;

    log( "SERVING %s : %s" , path.c_str() , file_name.c_str() );

    ResourceInfo & info( resources[ path ] );

    info.connection = connection;
    info.file_name = file_name;
    info.group = group;

    return path;
}

//-----------------------------------------------------------------------------

void ControllerServer::drop_resource_group( gpointer connection , const String & group )
{
    for ( ResourceMap::iterator it = resources.begin(); it != resources.end(); )
    {
        if ( it->second.connection == connection && ( group.empty() || it->second.group == group  ) )
        {
            log( "DROPPING %s : %s : %s", it->first.c_str(), it->second.group.c_str() , it->second.file_name.c_str() );

            resources.erase( it++ );
        }
        else
        {
            ++it;
        }
    }
}

//-----------------------------------------------------------------------------

void ControllerServer::handle_http_get( const HttpServer::Request & request , HttpServer::Response & response )
{
    ResourceMap::iterator it = resources.find( request.get_path() );

    if ( it == resources.end() )
    {
        return;
    }

    response.respond_with_file_contents( it->second.file_name );
}

//-----------------------------------------------------------------------------

String random_string( guint length )
{
    static const char * pieces = "0123456789abcdefghijklmnopqrstuvwxyz";

    char buffer[ length ];

    for ( guint i = 0; i < length ; ++i )
    {
        buffer[ i ] = pieces[ g_random_int_range( 0 , sizeof( pieces ) ) ];
    }

    return String( buffer , length );
}

String ControllerServer::start_post_endpoint( gpointer connection , PostInfo::Type type )
{
    for ( PostMap::const_iterator it = post_map.begin(); it != post_map.end(); ++it )
    {
        if ( it->second.connection == connection && it->second.type == type )
        {
            return it->first;
        }
    }

    // It doesn't exist

    String path;

    do
    {
        path = "/controllers";
        path += type == PostInfo::AUDIO ? "/audio/" : "/picture/";
        path += random_string( 20 );
    }
    while( post_map.find( path ) != post_map.end() );

    log( "STARTED POST END POINT %s" , path.c_str() );

    PostInfo & info( post_map[ path ] );

    info.connection = connection;
    info.type = type;

    return path;
}

void ControllerServer::drop_post_endpoint( gpointer connection )
{
    for ( PostMap::iterator it = post_map.begin(); it != post_map.end(); )
    {
        if ( it->second.connection == connection )
        {
            log( "DROPPING POST END POINT %s", it->first.c_str() );

            post_map.erase( it++ );
        }
        else
        {
            ++it;
        }
    }
}

//-----------------------------------------------------------------------------

void ControllerServer::handle_http_post( const HttpServer::Request & request , HttpServer::Response & response )
{
    PostMap::iterator it = post_map.find( request.get_path() );

    if ( it == post_map.end() )
    {
        return;
    }

    ConnectionInfo * info = find_connection( it->second.connection );

    if ( ! info )
    {
        return;
    }

    const HttpServer::Request::Body & body( request.get_body() );

    if ( ! body.get_data() || ! body.get_length() )
    {
        response.set_status( HttpServer::HTTP_STATUS_BAD_REQUEST );

        return;
    }

    String ct( request.get_content_type() );

    const char * content_type = ct.empty() ? 0 : ct.c_str();

    switch( it->second.type )
    {
        case PostInfo::AUDIO:

            tp_controller_submit_audio_clip( info->controller , body.get_data() , body.get_length() , content_type );
            break;

        case PostInfo::PICTURES:

            tp_controller_submit_picture( info->controller , body.get_data() , body.get_length() , content_type );
            break;
    }

    response.set_status( HttpServer::HTTP_STATUS_OK );
}

//-----------------------------------------------------------------------------


