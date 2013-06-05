
#include <cstring>
#include <cstdio>
#include <cstdlib>

#include "libsoup/soup.h"
#include "tp-clutter.h"
#include "uriparser/Uri.h"

#include "app.h"
#include "controller_server.h"
#include "util.h"
#include "sysdb.h"
#include "json.h"

//-----------------------------------------------------------------------------

#ifdef TP_CONTROLLER_DISCOVERY_MDNS
#include "controller_discovery_mdns.h"
#endif

#ifdef TP_CONTROLLER_DISCOVERY_UPNP
#include "controller_discovery_upnp.h"
#endif

//-----------------------------------------------------------------------------
#define TP_LOG_DOMAIN   "CONTROLLER-SERVER"
#define TP_LOG_ON       true
#define TP_LOG2_ON      false

#include "log.h"

//-----------------------------------------------------------------------------

#define CONTROLLER_PROTOCOL_VERSION     "44"

//-----------------------------------------------------------------------------
// This is how quickly we disconnect a controller that has not identified itself

#define DISCONNECT_TIMEOUT_SEC  30

//-----------------------------------------------------------------------------

gulong ControllerServer::ConnectionInfo::aui_next_id = 1;

//-----------------------------------------------------------------------------

ControllerServer::ControllerServer( TPContext* ctx, const String& name, int port )
    :
    discovery_mdns( NULL ),
    discovery_upnp( NULL ),
    server( NULL ),
    context( ctx )
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

        HttpServer* http_server = context->get_http_server();

        http_server->register_handler( "/controllers" , this );

#ifdef TP_CONTROLLER_DISCOVERY_MDNS

        if ( context->get_bool( TP_CONTROLLERS_MDNS_ENABLED , true ) )
        {
            discovery_mdns.reset( new ControllerDiscoveryMDNS( context , name, server->get_port() , http_server->get_port() ) );
        }
        else
        {
            tplog( "MDNS DISCOVERY IS DISABLED" );
        }

#endif

#ifdef TP_CONTROLLER_DISCOVERY_UPNP

        if ( context->get_bool( TP_CONTROLLERS_UPNP_ENABLED , false ) )
        {
            discovery_upnp.reset( new ControllerDiscoveryUPnP( context , name, http_server->get_port() ) );
        }
        else
        {
            tplog( "UPNP DISCOVERY IS DISABLED" );
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

int ControllerServer::execute_command( TPController* controller, unsigned int command, void* parameters, void* data )
{
    g_assert( data );

    return ( ( ControllerServer* )data )->execute_command( controller, command, parameters );
}

int ControllerServer::execute_command( TPController* controller, unsigned int command, void* parameters )
{
    if ( !server.get() )
    {
        return 1;
    }

    ConnectionInfo* info = 0;

    gpointer connection = 0;

    for ( ConnectionMap::iterator it = connections.begin(); it != connections.end(); ++it )
    {
        if ( it->second.controller == controller )
        {
            info = & it->second;
            connection = it->first;
            break;
        }
    }

    if ( ! connection || ! info )
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
            TPControllerStartMotion* sa = ( TPControllerStartMotion* )parameters;

            const char* filter = "N";

            switch ( sa->filter )
            {
                case TP_CONTROLLER_MOTION_FILTER_LOW:
                    filter = "L";
                    break;

                case TP_CONTROLLER_MOTION_FILTER_HIGH:
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

        case TP_CONTROLLER_COMMAND_START_GYROSCOPE  :
        {
            TPControllerStartMotion* sa = ( TPControllerStartMotion* )parameters;

            server->write_printf( connection, "SGY\t%f\n", sa->interval );

            break;
        }

        case TP_CONTROLLER_COMMAND_STOP_GYROSCOPE    :
        {
            server->write( connection, "PGY\n" );
            break;
        }

        case TP_CONTROLLER_COMMAND_START_MAGNETOMETER   :
        {
            TPControllerStartMotion* sa = ( TPControllerStartMotion* )parameters;

            server->write_printf( connection, "SMM\t%f\n", sa->interval );

            break;
        }

        case TP_CONTROLLER_COMMAND_STOP_MAGNETOMETER    :
        {
            server->write( connection, "PMM\n" );
            break;
        }

        case TP_CONTROLLER_COMMAND_START_ATTITUDE   :
        {
            TPControllerStartMotion* sa = ( TPControllerStartMotion* )parameters;

            server->write_printf( connection, "SAT\t%f\n", sa->interval );

            break;
        }

        case TP_CONTROLLER_COMMAND_STOP_ATTITUDE   :
        {
            server->write( connection, "PAT\n" );
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
            TPControllerMultipleChoice* mc = ( TPControllerMultipleChoice* )parameters;

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
            TPControllerSetUIBackground* sb = ( TPControllerSetUIBackground* )parameters;

            const char* mode = "S";

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
            TPControllerSetUIImage* im = ( TPControllerSetUIImage* )parameters;
            server->write_printf( connection, "UG\t%s\t%d\t%d\t%d\t%d\n", im->resource, im->x, im->y, im->width, im->height );
            break;
        }

        case TP_CONTROLLER_COMMAND_PLAY_SOUND            :
        {
            TPControllerPlaySound* ps = ( TPControllerPlaySound* )parameters;
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
            TPControllerDeclareResource* ds = ( TPControllerDeclareResource* )parameters;

            GFile* file = g_file_new_for_uri( ds->uri );

            bool native = g_file_is_native( file );

            g_object_unref( file );


            const char* uri = 0;
            String path;

            if ( ! native )
            {
                uri = ds->uri;
            }
            else
            {
                path = start_serving_resource( connection , ds->uri , ds->group );
                uri = path.c_str();
            }

            if ( ! uri )
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
            TPControllerDropResourceGroup* dg = ( TPControllerDropResourceGroup* ) parameters;

            drop_resource_group( connection , dg->group );

            server->write_printf( connection , "DG\t%s\n" , dg->group );

            break;
        }

        case TP_CONTROLLER_COMMAND_ENTER_TEXT            :
        {
            TPControllerEnterText* et = ( TPControllerEnterText* )parameters;
            server->write_printf( connection, "ET\t%s\t%s\n", et->label, et->text );
            break;
        }

        case TP_CONTROLLER_COMMAND_REQUEST_IMAGE    :
        {
            TPControllerRequestImage* ri = ( TPControllerRequestImage* ) parameters;
            String path = start_post_endpoint( connection , PostInfo::IMAGE );
            server->write_printf( connection, "PI\t%s\t%u\t%u\t%d\t%s\t%s\t%s\n" ,
                    path.c_str() + 1 ,
                    ri->max_width ,
                    ri->max_height ,
                    ri->edit ? 1 : 0 ,
                    ri->mask ? ri->mask : "",
                    ri->dialog_label ? ri->dialog_label : "",
                    ri->cancel_label ? ri->cancel_label : "" );
            break;
        }

        case TP_CONTROLLER_COMMAND_REQUEST_AUDIO_CLIP   :
        {
            TPControllerRequestAudioClip* ra = ( TPControllerRequestAudioClip* ) parameters;
            String path = start_post_endpoint( connection , PostInfo::AUDIO );
            server->write_printf( connection, "AC\t%s\t%s\t%s\n" , path.c_str() + 1,
                    ra->dialog_label ? ra->dialog_label : "",
                    ra->cancel_label ? ra->cancel_label : "" );
            break;
        }

        case TP_CONTROLLER_COMMAND_VIDEO_START_CALL:
        {
            const char* address = ( const char* )parameters;
            server->write_printf( connection, "SVSC\t%s\n", address );
            break;
        }

        case TP_CONTROLLER_COMMAND_VIDEO_END_CALL:
        {
            const char* address = ( const char* )parameters;
            server->write_printf( connection, "SVEC\t%s\n", address );
            break;
        }

        case TP_CONTROLLER_COMMAND_VIDEO_SEND_STATUS:
        {
            server->write_printf( connection, "SVSS\n" );
            break;
        }

        case TP_CONTROLLER_COMMAND_ADVANCED_UI:
        {
            if ( ! info->aui_connection )
            {
                return 4;
            }

            TPControllerAdvancedUI* aui = ( TPControllerAdvancedUI* ) parameters;

            if ( ! server->write_printf( info->aui_connection , "%s\n" , aui->payload ) )
            {
                return 5;
            }

            // Read the response synchronously

            gssize bytes_read;

            GString* response = g_string_new( "" );

            gchar* new_line = 0;

            char buffer[256];

            while ( new_line == 0 )
            {
                bytes_read = server->read( info->aui_connection , buffer , 256 );

                if ( bytes_read <= 0 )
                {
                    g_string_free( response , TRUE );
                    return 6;
                }

                g_string_append_len( response , buffer , bytes_read );

                new_line = g_strstr_len( response->str , response->len , "\n" );
            }

            * new_line = 0;

            aui->result = response->str;
            aui->free_result = g_free;

            g_string_free( response , FALSE );

            break;
        }

        case TP_CONTROLLER_COMMAND_SHOW_VIRTUAL_REMOTE:
        {
            server->write( connection, "SV\n" );
            break;
        }

        case TP_CONTROLLER_COMMAND_HIDE_VIRTUAL_REMOTE:
        {
            server->write( connection, "HV\n" );
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

ControllerServer::ConnectionInfo* ControllerServer::find_connection( gpointer connection )
{
    ConnectionMap::iterator it = connections.find( connection );

    return it == connections.end() ? NULL : &it->second;
}

//-----------------------------------------------------------------------------

void ControllerServer::connection_accepted( gpointer connection, const char* remote_address )
{
    tplog( "ACCEPTED CONNECTION %p FROM %s", connection, remote_address );

    // This adds the connection to the map and sets its address at the same time

    ConnectionInfo& info = connections[connection];

    info.address = remote_address;

    // Now, set a timer to disconnect the connection if it has not identified
    // itself within a few seconds

    GSource* source = g_timeout_source_new( DISCONNECT_TIMEOUT_SEC * 1000 );
    g_source_set_callback( source, timed_disconnect_callback, new TimerClosure( connection, this ), NULL );
    g_source_attach( source, g_main_context_default() );
    g_source_unref( source );
}

//-----------------------------------------------------------------------------

gboolean ControllerServer::timed_disconnect_callback( gpointer data )
{
    tplog( "TIMED DISCONNECT" );

    // Check to see that the controller has reported a version

    TimerClosure* tc = ( TimerClosure* )data;

    ConnectionInfo* ci = tc->self->find_connection( tc->connection );

    if ( ci && !ci->version )
    {
        tplog( "DROPPING UNIDENTIFIED CONNECTION %p", tc->connection );

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
    ConnectionInfo* info = find_connection( connection );
    gpointer aui_connection = NULL;

    if ( info && info->controller )
    {
        tp_context_remove_controller( context, info->controller );
        aui_connection = info->aui_connection;
    }

    drop_resource_group( connection , String() );

    drop_post_endpoint( connection );

    connections.erase( connection );

    if ( aui_connection )
    {
        server->close_connection( aui_connection );
    }

    tplog( "CONNECTION CLOSED %p", connection );
}

//-----------------------------------------------------------------------------

void ControllerServer::connection_data_received( gpointer connection, const char* line , gsize bytes_read , bool* read_again )
{
    if ( ! strlen( line ) )
    {
        return;
    }

    ConnectionMap::iterator it = connections.find( connection );

    if ( it == connections.end() )
    {
        return;
    }

    gchar** parts = g_strsplit( line, "\t", 0 );

    process_command( connection, it->second, parts , read_again );

    g_strfreev( parts );
}

//-----------------------------------------------------------------------------

static inline bool cmp2( const char* a, const char* b )
{
    return ( a[0] == b[0] ) && ( a[1] == b[1] );
}

static inline bool cmp3( const char* a, const char* b )
{
    return ( a[0] == b[0] ) && ( a[1] == b[1] ) && ( a[2] == b[2] );
}

static inline bool cmp4( const char* a, const char* b )
{
    return ( a[0] == b[0] ) && ( a[1] == b[1] ) && ( a[2] == b[2] ) && ( a[3] == b[3] );
}

void ControllerServer::process_command( gpointer connection, ConnectionInfo& info, gchar** parts , bool* read_again )
{
    guint count = g_strv_length( parts );

    if ( count < 1 )
    {
        return;
    }

    const gchar* cmd = parts[0];

    if ( strlen( cmd ) < 2 )
    {
        return;
    }

    if ( cmp2( cmd, "ID" ) )
    {
        // Device id line
        // ID <version> <name> <cap>*

        * read_again = false;

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

        if ( info.version < 4 )
        {
            g_warning( "CONTROLLER DOES NOT SUPPORT PROTOCOL VERSION >= 4" );
            info.version = 0;
            return;
        }

        const char* name = g_strstrip( parts[2] );

        // Capability entries

        TPControllerSpec spec;

        memset( &spec, 0, sizeof( spec ) );

        for ( guint i = 3; i < count; ++i )
        {
            const gchar* cap = g_strstrip( parts[i] );

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
                else if ( cmp2( cap, "FM" ) )
                {
                    spec.capabilities |= TP_CONTROLLER_HAS_FULL_MOTION;
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
                    spec.capabilities |= TP_CONTROLLER_HAS_IMAGES;
                }
                else if ( cmp2( cap, "AC" ) )
                {
                    spec.capabilities |= TP_CONTROLLER_HAS_AUDIO_CLIPS;
                }
                else if ( cmp2( cap , "UX" ) )
                {
                    spec.capabilities |= TP_CONTROLLER_HAS_ADVANCED_UI;
                }
                else if ( cmp2( cap , "VR" ) )
                {
                    spec.capabilities |= TP_CONTROLLER_HAS_VIRTUAL_REMOTE;
                }
                else if ( cmp2( cap , "SV" ) )
                {
                    spec.capabilities |= TP_CONTROLLER_HAS_STREAMING_VIDEO;
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
                else if ( cmp2( cap , "ID" ) )
                {
                    spec.id = cap + 3;
                }
                else
                {
                    g_warning( "UNKNOWN CONTROLLER CAPABILITY '%s'", cap );
                }
            }
        }

        * read_again = true;

        spec.execute_command = execute_command;

        info.controller = tp_context_add_controller( context, name, &spec, this );

        server->write_printf( connection , "WM\t%s\t%u\t%lu\n" , CONTROLLER_PROTOCOL_VERSION , context->get_http_server()->get_port() , info.aui_id );
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

        tp_controller_key_down( info.controller, key_code, unicode , TP_CONTROLLER_MODIFIER_NONE );
        tp_controller_key_up( info.controller, key_code, unicode , TP_CONTROLLER_MODIFIER_NONE );
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

        tp_controller_key_down( info.controller, key_code, unicode , TP_CONTROLLER_MODIFIER_NONE );
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

        tp_controller_key_up( info.controller, key_code, unicode , TP_CONTROLLER_MODIFIER_NONE );
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

        tp_controller_accelerometer( info.controller, atof( parts[1] ), atof( parts[2] ), atof( parts[3] ) , TP_CONTROLLER_MODIFIER_NONE );
    }
    else if ( cmp2( cmd, "GY" ) )
    {
        // Acelerometer
        // AX <x> <y> <z>

        if ( count < 4 || !info.controller )
        {
            return;
        }

        tp_controller_gyroscope( info.controller, atof( parts[1] ), atof( parts[2] ), atof( parts[3] ) , TP_CONTROLLER_MODIFIER_NONE );
    }
    else if ( cmp2( cmd, "MM" ) )
    {
        // Acelerometer
        // AX <x> <y> <z>

        if ( count < 4 || !info.controller )
        {
            return;
        }

        tp_controller_magnetometer( info.controller, atof( parts[1] ), atof( parts[2] ), atof( parts[3] ) , TP_CONTROLLER_MODIFIER_NONE );
    }
    else if ( cmp2( cmd, "AT" ) )
    {
        // Acelerometer
        // AX <x> <y> <z>

        if ( count < 4 || !info.controller )
        {
            return;
        }

        tp_controller_attitude( info.controller, atof( parts[1] ), atof( parts[2] ), atof( parts[3] ) , TP_CONTROLLER_MODIFIER_NONE );
    }
    else if ( cmp2( cmd, "UI" ) )
    {
        // UI
        // UI <type> <txt>

        if ( count < 2 || !info.controller || strlen( parts[1] ) != 2 )
        {
            return;
        }

        // Enter text or multiple-choice
        if ( cmp2( parts[1], "ET" ) || cmp2( parts[1], "MC" ) )
        {
            if ( count < 3 )
            {
                return;
            }

            tp_controller_ui_event( info.controller, parts[2] );
        }
        // Advanced UI event
        else if ( cmp2( parts[1] , "UX" ) )
        {
            if ( count < 3 )
            {
                return;
            }

            tp_controller_advanced_ui_event( info.controller , parts[ 2 ] );
        }
        // Cancel image
        else if ( cmp2( parts[1], "CI" ) )
        {
            tp_controller_cancel_image( info.controller );
        }
        // Cancel audio
        else if ( cmp2( parts[1], "CA" ) )
        {
            tp_controller_cancel_audio_clip( info.controller );
        }
    }
    else if ( cmp2( cmd, "PD" ) )
    {
        // Pointer button down
        // PD <button> <x> <y>

        if ( count < 4 || !info.controller )
        {
            return;
        }

        tp_controller_pointer_button_down( info.controller, atoi( parts[1] ), atoi( parts[2] ) , atoi( parts[ 3 ] ) , TP_CONTROLLER_MODIFIER_NONE );
    }
    else if ( cmp2( cmd, "PM" ) )
    {
        // Pointer move
        // PM <x> <y>

        if ( count < 3 || !info.controller )
        {
            return;
        }

        tp_controller_pointer_move( info.controller, atoi( parts[1] ), atoi( parts[2] ) , TP_CONTROLLER_MODIFIER_NONE );
    }
    else if ( cmp2( cmd, "PU" ) )
    {
        // Pointer button up
        // PU <button> <x> <y>

        if ( count < 4 || !info.controller )
        {
            return;
        }

        tp_controller_pointer_button_up( info.controller, atoi( parts[1] ), atoi( parts[2] ) , atoi( parts[ 3 ] ) , TP_CONTROLLER_MODIFIER_NONE );
    }
    else if ( cmp2( cmd, "TD" ) )
    {
        // Touch down
        // TD <finger> <x> <y>

        if ( count < 4 || !info.controller )
        {
            return;
        }

        tp_controller_touch_down( info.controller, atoi( parts[1] ), atoi( parts[2] ) , atoi( parts[ 3 ] ) , TP_CONTROLLER_MODIFIER_NONE );
    }
    else if ( cmp2( cmd, "TM" ) )
    {
        // Touch move
        // TM <finger> <x> <y>

        if ( count < 4 || !info.controller )
        {
            return;
        }

        tp_controller_touch_move( info.controller, atoi( parts[1] ), atoi( parts[2] ) , atoi( parts[ 3 ] ) , TP_CONTROLLER_MODIFIER_NONE );
    }
    else if ( cmp2( cmd, "TU" ) )
    {
        // Touch up
        // TU <finger> <x> <y>

        if ( count < 4 || !info.controller )
        {
            return;
        }

        tp_controller_touch_up( info.controller, atoi( parts[1] ), atoi( parts[2] ) , atoi( parts[ 3 ] ) , TP_CONTROLLER_MODIFIER_NONE );
    }
    else if ( cmp2( cmd , "UX" ) )
    {
        // Stop reading from this connection. We will only read
        // synchronously after we write. If there is a problem with the UX message,
        // we stop reading anyway - they only get one shot at it.

        * read_again = false;

        if ( count < 2 )
        {
            return;
        }

        gulong id = 0;

        if ( sscanf( parts[1], "%lu", & id ) != 1 )
        {
            return;
        }

        // The ID is bad

        if ( id == 0 )
        {
            return;
        }

        ConnectionInfo* parent_info = 0;

        for ( ConnectionMap::iterator it = connections.begin(); it != connections.end(); ++it )
        {
            if ( it->second.aui_id == id )
            {
                parent_info = & it->second;
                break;
            }
        }

        // Could not find a connection for this ID

        if ( ! parent_info )
        {
            return;
        }

        // The controller connection for this ID has not identified itself yet

        if ( ! parent_info->version )
        {
            return;
        }

        // OK, everything is cool

        // Set this connection's version, so it does not get booted.

        info.version = parent_info->version;

        // Tell the parent that this connection belongs to it

        parent_info->aui_connection = connection;

        // Now, generate the event that it is ready

        tp_controller_advanced_ui_ready( parent_info->controller );
    }
    else if ( cmp4( cmd, "SVCC" ) )
    {
        // Streaming video call connected
        // SVCC <address>

        if ( count < 2 || !info.controller )
        {
            return;
        }

        tp_controller_streaming_video_connected( info.controller, parts[1] );
    }
    else if ( cmp4( cmd, "SVCF" ) )
    {
        // Streaming video call failed
        // SVCF <address> <reason>

        if ( count < 3 || !info.controller )
        {
            return;
        }

        tp_controller_streaming_video_failed( info.controller, parts[1], parts[2] );
    }
    else if ( cmp4( cmd, "SVCD" ) )
    {
        // Streaming video call was dropped
        // SVCD <address> <reason>

        if ( count < 3 || !info.controller )
        {
            return;
        }

        tp_controller_streaming_video_dropped( info.controller, parts[1], parts[2] );
    }
    else if ( cmp4( cmd, "SVCE" ) )
    {
        // Streaming video call ended
        // SVCE <address> <who>

        if ( count < 3 || !info.controller )
        {
            return;
        }

        tp_controller_streaming_video_ended( info.controller, parts[1], parts[2] );
    }
    else if ( cmp4( cmd, "SVCS" ) )
    {
        // Streaming video call status
        // SVCS <status> <address>

        if ( count < 3 || !info.controller )
        {
            return;
        }

        tp_controller_streaming_video_status( info.controller, parts[1], parts[2] );
    }
    else
    {
        g_warning( "UNKNOWN CONTROLLER COMMAND '%s'", cmd );
    }
}

//-----------------------------------------------------------------------------

String ControllerServer::start_serving_resource( gpointer connection , const String& native_uri , const String& group )
{
    String path = group + ":" + native_uri;

    gchar* h = g_compute_checksum_for_string( G_CHECKSUM_MD5 , path.c_str() , path.length() );

    path = h;

    g_free( h );

    path = String( "/controllers/resource/" ) + path;

    tplog( "SERVING %s : %s" , path.c_str() , native_uri.c_str() );

    ResourceInfo& info( resources[ path ] );

    info.connection = connection;
    info.native_uri = native_uri;
    info.group = group;

    return path;
}

//-----------------------------------------------------------------------------

void ControllerServer::drop_resource_group( gpointer connection , const String& group )
{
    for ( ResourceMap::iterator it = resources.begin(); it != resources.end(); )
    {
        if ( it->second.connection == connection && ( group.empty() || it->second.group == group ) )
        {
            tplog( "DROPPING %s : %s : %s", it->first.c_str(), it->second.group.c_str() , it->second.native_uri.c_str() );

            resources.erase( it++ );
        }
        else
        {
            ++it;
        }
    }
}

//-----------------------------------------------------------------------------

void ControllerServer::handle_http_get( const HttpServer::Request& request , HttpServer::Response& response )
{
    if ( request.get_path() == "/controllers" )
    {
        JSON::Object result;

        result[ "version" ] = CONTROLLER_PROTOCOL_VERSION;
        result[ "port" ] = server->get_port();

        response.set_response( "application/json", result.stringify() );
        response.set_status( HttpServer::HTTP_STATUS_OK );

        return;
    }

    ResourceMap::iterator it = resources.find( request.get_path() );

    if ( it == resources.end() )
    {
        return;
    }

    response.respond_with_file_contents( it->second.native_uri );
}

//-----------------------------------------------------------------------------

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

        switch ( type )
        {
            case PostInfo::AUDIO:
                path += "/audio/";
                break;

            case PostInfo::IMAGE:
                path += "/image/";
                break;
        }

        path += Util::random_string( 20 );
    }
    while ( post_map.find( path ) != post_map.end() );

    tplog( "STARTED POST END POINT %s" , path.c_str() );

    PostInfo& info( post_map[ path ] );

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
            tplog( "DROPPING POST END POINT %s", it->first.c_str() );

            post_map.erase( it++ );
        }
        else
        {
            ++it;
        }
    }
}

//-----------------------------------------------------------------------------

void ControllerServer::handle_http_post( const HttpServer::Request& request , HttpServer::Response& response )
{
    PostMap::iterator it = post_map.find( request.get_path() );

    if ( it == post_map.end() )
    {
        return;
    }

    ConnectionInfo* info = find_connection( it->second.connection );

    if ( ! info )
    {
        return;
    }

    const HttpServer::Request::Body& body( request.get_body() );

    if ( ! body.get_data() || ! body.get_length() )
    {
        response.set_status( HttpServer::HTTP_STATUS_BAD_REQUEST );

        return;
    }

    String ct( request.get_content_type() );

    const char* content_type = ct.empty() ? 0 : ct.c_str();

    switch ( it->second.type )
    {
        case PostInfo::AUDIO:
            tp_controller_submit_audio_clip( info->controller , body.get_data() , body.get_length() , content_type );
            break;

        case PostInfo::IMAGE:
            tp_controller_submit_image( info->controller , body.get_data() , body.get_length() , content_type );
            break;
    }

    response.set_status( HttpServer::HTTP_STATUS_OK );
}

//-----------------------------------------------------------------------------

guint16 ControllerServer::get_port() const
{
    return server.get() ? server->get_port() : 0;
}

