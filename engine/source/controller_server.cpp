
#include <cstring>
#include <cstdio>
#include <cstdlib>

#include "clutter/clutter.h"

#include "controller_server.h"
#include "util.h"

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

        g_info( "CONTROLLER SERVER LISTENER READY ON PORT %d", server->get_port() );

#ifdef TP_CONTROLLER_DISCOVERY_MDNS

        discovery_mdns.reset( new ControllerDiscoveryMDNS( context , name, server->get_port() ) );

#endif

#ifdef TP_CONTROLLER_DISCOVERY_UPNP

        discovery_upnp.reset( new ControllerDiscoveryUPnP( context , name, server->get_port() ) );

#endif

    }
}

//-----------------------------------------------------------------------------

ControllerServer::~ControllerServer()
{
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
                path = serve_path( "", String( ( ds->uri ) + 7 ) );
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

    if ( it->second.http.is_http )
    {
        handle_http_line( connection, it->second, line );
    }
    else
    {
        if ( !strlen( line ) )
        {
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

        // It is http

        if ( info.http.is_http )
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
    else if ( cmp2( cmd, "GE" ) )
    {
        // Possibly an HTTP get

        // Cannot come from a connection that is already a controller

        if ( info.controller )
        {
            return;
        }

        handle_http_get( connection, parts[0] );
    }
    else
    {
        g_warning( "UNKNOWN CONTROLLER COMMAND '%s'", cmd );
    }
}

//-----------------------------------------------------------------------------

void ControllerServer::handle_http_get( gpointer connection, const gchar * line )
{
    ConnectionInfo * info = find_connection( connection );

    if ( !info )
    {
        return;
    }

    gchar ** parts = g_strsplit( line, " ", 3 );

    if ( g_strv_length( parts ) == 3 && !strcmp( parts[0], "GET" ) )
    {
        info->disconnect = false;
        info->http.is_http = true;
        info->http.method = parts[0];
        info->http.url = parts[1];
        info->http.version = parts[2];
    }

    g_strfreev( parts );
}

//-----------------------------------------------------------------------------

void ControllerServer::handle_http_line( gpointer connection, ConnectionInfo & info, const gchar * line )
{
    HTTPInfo & hi = info.http;

    if ( !hi.headers_done )
    {
        if ( strlen( line ) )
        {
// We are not using the headers yet
#if 0

            hi.headers.push_back( line );

            // Protect against too many headers

            if ( hi.headers.size() > 256 )
            {
                server->close_connection( connection );
            }
#endif
        }
        else
        {
            // We have received all the headers

#if 0
            for ( StringList::const_iterator it = hi.headers.begin(); it != hi.headers.end(); ++it )
            {
                g_debug( "[%s]", it->c_str() );
            }
#endif

            g_debug( "PROCESSING %s '%s'", hi.method.c_str(), hi.url.c_str() );

            bool found = false;

            if ( hi.url.size() > 1 )
            {
                String id( hi.url.substr( 1 ) );

                WebServerPathMap::const_iterator it = path_map.find( id );

                if ( it != path_map.end() )
                {
                    String path( it->second.first );

                    found = server->write_file( connection, path.c_str(), true );

                    g_debug( "  SERVED '%s'", path.c_str() );
                }
            }

            if ( !found )
            {
                server->write_printf( connection, "%s 404 Not found\r\nContent-Length: 0\r\n\r\n", hi.version.c_str() );

                g_debug( "  NOT FOUND" );
            }

            hi.reset();
        }
    }
}

String get_file_extension( const String & path, bool include_dot = true )
{
    String result;

    if ( !path.empty() )
    {
        // See if the last character is a separator. If it is,
        // we bail. Otherwise, g_path_get_basename would give us
        // the element before the separator and not the last element.

        if ( !g_str_has_suffix( path.c_str(), G_DIR_SEPARATOR_S ) )
        {
            gchar * basename = g_path_get_basename( path.c_str() );

            if ( basename )
            {
                gchar * * parts = g_strsplit( basename, ".", 0 );

                guint count = g_strv_length( parts );

                if ( count > 1 )
                {
                    result = parts[count - 1];

                    if ( !result.empty() && include_dot )
                    {
                        result = "." + result;
                    }
                }

                g_strfreev( parts );

                g_free( basename );
            }
        }
    }

    return result;
}

//-----------------------------------------------------------------------------

String ControllerServer::serve_path( const String & group, const String & path )
{
    String s = group + ":" + path;

    gchar * id = g_compute_checksum_for_string( G_CHECKSUM_SHA1, s.c_str(), -1 );
    String result( id );
    g_free( id );

    result += get_file_extension( path );

    if ( path_map.find( result ) == path_map.end() )
    {
        g_debug( "SERVING %s : %s", result.c_str(), path.c_str() );

        path_map[result] = StringPair( path, group );
    }

    return result;
}

//-----------------------------------------------------------------------------

void ControllerServer::drop_web_server_group( const String & group )
{
    for ( WebServerPathMap::iterator it = path_map.begin(); it != path_map.end(); )
    {
        if ( it->second.second == group )
        {
            g_debug( "DROPPING %s : %s", it->first.c_str(), it->second.first.c_str() );

            path_map.erase( it++ );
        }
        else
        {
            ++it;
        }
    }
}

//-----------------------------------------------------------------------------
