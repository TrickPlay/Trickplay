
#include <fstream>
#include <sstream>

#include "controller_list.h"
#include "clutter_util.h"
#include "context.h"
#include "log.h"

//=============================================================================
// If defined, will time and report times for controller events.

//#define TP_TIME_CONTROLLER_EVENTS   1

//==============================================================================
// This is the structure we give the outside world. To them, it is opaque.
// It has a pointer to a Controller instance, the associated ControllerList
// and a marker, which points to itself. The marker lets us do sanity checks
// to ensure the outside doesn't pass garbage.

struct TPController
{
    TPController( Controller* _controller, ControllerList* _list )
        :
        controller( _controller ),
        list( _list ),
        marker( this )
    {
        check( this );
    }

    inline static void check( TPController* controller )
    {
        g_assert( controller );
        g_assert( controller->list );
        g_assert( controller->controller );

        // An assertion here means that either the controller is garbage or
        // it has already been disconnected.

        g_assert( controller->marker == controller );
    }

    Controller*         controller;
    ControllerList*     list;
    TPController*       marker;
};

//==============================================================================
// This is a struct which encapsulates all of the events we receive from the
// controller API. It is a struct so that it can use the glib slice allocator.
// Because all events are the same size, come in from different threads and happen
// fairly often, we can get some benefits that new/delete don't have.
// The slice allocator keeps some instances around, so they can be re-used.

struct Event
{
    enum Type
    {
        ADDED, REMOVED,
        KEY_DOWN, KEY_UP,
        ACCELEROMETER, GYROSCOPE, MAGNETOMETER, ATTITUDE,
        POINTER_MOVE , POINTER_DOWN , POINTER_UP, POINTER_ACTIVE, POINTER_INACTIVE,
        TOUCH_DOWN, TOUCH_MOVE, TOUCH_UP,
        UI, SUBMIT_IMAGE, SUBMIT_AUDIO_CLIP, CANCEL_IMAGE, CANCEL_AUDIO_CLIP,
        ADVANCED_UI_READY, ADVANCED_UI_EVENT , SCROLL,
        STREAMING_VIDEO_CONNECTED, STREAMING_VIDEO_FAILED, STREAMING_VIDEO_DROPPED, STREAMING_VIDEO_ENDED, STREAMING_VIDEO_STATUS
    };

public:

    inline static Event* make( Type type, Controller* controller )
    {
        g_assert( controller );

        controller->ref();

        Event* event = g_slice_new( Event );

        event->type = type;
        event->controller = controller;
        event->modifiers = TP_CONTROLLER_MODIFIER_NONE;

#ifdef TP_TIME_CONTROLLER_EVENTS

        event->create_time = timestamp();

#endif

        if ( type == UI || type == ADVANCED_UI_EVENT )
        {
            event->ui.parameters = NULL;
        }

        return event;
    }

    static void destroy( Event* event )
    {
        g_assert( event );
        g_assert( event->controller );

        switch ( event->type )
        {
            case UI:
            case ADVANCED_UI_EVENT:
                g_free( event->ui.parameters );
                break;

            case SUBMIT_IMAGE:
            case SUBMIT_AUDIO_CLIP:
                g_free( event->data.data );
                g_free( event->data.mime_type );
                break;

            case STREAMING_VIDEO_CONNECTED:
                g_free( event->streaming_video.address );
                break;

            case STREAMING_VIDEO_FAILED:
            case STREAMING_VIDEO_DROPPED:
                g_free( event->streaming_video.address );
                g_free( event->streaming_video.reason );
                break;

            case STREAMING_VIDEO_ENDED:
                g_free( event->streaming_video.address );
                g_free( event->streaming_video.who );
                break;

            case STREAMING_VIDEO_STATUS:
                g_free( event->streaming_video.status );
                g_free( event->streaming_video.arg );
                break;

            default:
                break;
        };

        event->controller->unref();

        g_slice_free( Event, event );
    }

    inline static Event* make_key( Type type, Controller* controller, unsigned int key_code, unsigned long int unicode , unsigned long int modifiers )
    {
        Event* event = make( type, controller );

        event->key.key_code = key_code;
        event->key.unicode = unicode;
        event->modifiers = modifiers;

        return event;
    }

    inline static Event* make_accelerometer( Controller* controller, double x, double y, double z , unsigned long int modifiers )
    {
        Event* event = make( ACCELEROMETER, controller );

        event->accelerometer.x = x;
        event->accelerometer.y = y;
        event->accelerometer.z = z;
        event->modifiers = modifiers;

        return event;
    }

    inline static Event* make_gyroscope( Controller* controller, double x, double y, double z , unsigned long int modifiers )
    {
        Event* event = make( GYROSCOPE, controller );

        event->gyroscope.x = x;
        event->gyroscope.y = y;
        event->gyroscope.z = z;
        event->modifiers = modifiers;

        return event;
    }

    inline static Event* make_magnetometer( Controller* controller, double x, double y, double z , unsigned long int modifiers )
    {
        Event* event = make( MAGNETOMETER, controller );

        event->magnetometer.x = x;
        event->magnetometer.y = y;
        event->magnetometer.z = z;
        event->modifiers = modifiers;

        return event;
    }

    inline static Event* make_attitude( Controller* controller, double roll, double pitch, double yaw, unsigned long int modifiers )
    {
        Event* event = make( ATTITUDE, controller );

        event->attitude.roll = roll;
        event->attitude.pitch = pitch;
        event->attitude.yaw = yaw;
        event->modifiers = modifiers;

        return event;
    }

    inline static Event* make_click_touch( Type type, Controller* controller, int button_or_finger, int x, int y , unsigned long int modifiers )
    {
        Event* event = make( type, controller );

        event->click_touch.button_or_finger = button_or_finger;
        event->click_touch.x = x;
        event->click_touch.y = y;
        event->modifiers = modifiers;

        return event;
    }

    inline static Event* make_ui( Controller* controller, const char* parameters )
    {
        Event* event = make( UI, controller );

        event->ui.parameters = g_strdup( parameters );

        return event;
    }

    inline static Event* make_advanced_ui_event( Controller* controller, const char* json )
    {
        Event* event = make( ADVANCED_UI_EVENT, controller );

        event->ui.parameters = g_strdup( json );

        return event;
    }

    inline static Event* make_data( Type type, Controller* controller, const void* data, unsigned int size, const char* mime_type )
    {
        Event* event = make( type, controller );

        event->data.data = g_memdup( data, size );
        event->data.size = size;
        event->data.mime_type = g_strdup( mime_type );

        return event;
    }

    inline static Event* make_scroll( Controller* controller , int direction , unsigned long int modifiers )
    {
        Event* event = make( SCROLL , controller );

        event->scroll.direction = direction;
        event->modifiers = modifiers;

        return event;
    }

    inline static Event* make_streaming_video_connected( Controller* controller, const char* address )
    {
        Event* event = make( STREAMING_VIDEO_CONNECTED, controller );

        event->streaming_video.address = g_strdup( address );

        return event;
    }

    inline static Event* make_streaming_video_failed( Controller* controller, const char* address, const char* reason )
    {
        Event* event = make( STREAMING_VIDEO_FAILED, controller );

        event->streaming_video.address = g_strdup( address );
        event->streaming_video.reason = g_strdup( reason );

        return event;
    }

    inline static Event* make_streaming_video_dropped( Controller* controller, const char* address, const char* reason )
    {
        Event* event = make( STREAMING_VIDEO_DROPPED, controller );

        event->streaming_video.address = g_strdup( address );
        event->streaming_video.reason = g_strdup( reason );

        return event;
    }

    inline static Event* make_streaming_video_ended( Controller* controller, const char* address, const char* who )
    {
        Event* event = make( STREAMING_VIDEO_ENDED, controller );

        event->streaming_video.address = g_strdup( address );
        event->streaming_video.who = g_strdup( who );

        return event;
    }

    inline static Event* make_streaming_video_status( Controller* controller, const char* status, const char* arg )
    {
        Event* event = make( STREAMING_VIDEO_STATUS, controller );

        event->streaming_video.status = g_strdup( status );
        event->streaming_video.arg = g_strdup( arg );

        return event;
    }

    inline void process()
    {

#ifdef TP_TIME_CONTROLLER_EVENTS

        gsize t = timestamp();

        g_debug( "EVENT TYPE %d : ARRIVED AT %" G_GSIZE_FORMAT " : PROCESSED AT %" G_GSIZE_FORMAT " : %d ms" , type , create_time , t ,  int( t - create_time ) );

#endif

        switch ( type )
        {
            case ADDED:
                controller->get_tp_controller()->list->controller_added( controller );
                break;

            case REMOVED:
                controller->get_tp_controller()->list->controller_removed( controller );
                break;

            case KEY_DOWN:
                controller->key_down( key.key_code, key.unicode , modifiers );
                break;

            case KEY_UP:
                controller->key_up( key.key_code, key.unicode , modifiers );
                break;

            case ACCELEROMETER:
                controller->accelerometer( accelerometer.x, accelerometer.y, accelerometer.z , modifiers );
                break;

            case GYROSCOPE:
                controller->gyroscope( gyroscope.x, gyroscope.y, gyroscope.z , modifiers );
                break;

            case MAGNETOMETER:
                controller->magnetometer( magnetometer.x, magnetometer.y, magnetometer.z , modifiers );
                break;

            case ATTITUDE:
                controller->attitude( attitude.roll, attitude.pitch, attitude.yaw, modifiers );
                break;

            case POINTER_MOVE:
                controller->pointer_move( click_touch.x, click_touch.y , modifiers );
                break;

            case POINTER_DOWN:
                controller->pointer_button_down( click_touch.button_or_finger,  click_touch.x, click_touch.y , modifiers );
                break;

            case POINTER_UP:
                controller->pointer_button_up( click_touch.button_or_finger,  click_touch.x, click_touch.y , modifiers );
                break;

            case TOUCH_DOWN:
                controller->touch_down( click_touch.button_or_finger, click_touch.x, click_touch.y , modifiers );
                break;

            case TOUCH_MOVE:
                controller->touch_move( click_touch.button_or_finger, click_touch.x, click_touch.y , modifiers );
                break;

            case TOUCH_UP:
                controller->touch_up( click_touch.button_or_finger, click_touch.x, click_touch.y , modifiers );
                break;

            case UI:
                controller->ui_event( ui.parameters );
                break;

            case SUBMIT_IMAGE:
                controller->submit_image( data.data, data.size, data.mime_type );
                break;

            case SUBMIT_AUDIO_CLIP:
                controller->submit_audio_clip( data.data, data.size, data.mime_type );
                break;

            case CANCEL_IMAGE:
                controller->cancel_image();
                break;

            case CANCEL_AUDIO_CLIP:
                controller->cancel_audio_clip();
                break;

            case ADVANCED_UI_READY:
                controller->advanced_ui_ready();
                break;

            case ADVANCED_UI_EVENT:
                controller->advanced_ui_event( ui.parameters );
                break;

            case SCROLL:
                controller->scroll( scroll.direction , modifiers );
                break;

            case POINTER_ACTIVE:
                controller->pointer_active();
                break;

            case POINTER_INACTIVE:
                controller->pointer_inactive();
                break;

            case STREAMING_VIDEO_CONNECTED:
                controller->streaming_video_connected( streaming_video.address );
                break;

            case STREAMING_VIDEO_FAILED:
                controller->streaming_video_failed( streaming_video.address, streaming_video.reason );
                break;

            case STREAMING_VIDEO_DROPPED:
                controller->streaming_video_dropped( streaming_video.address, streaming_video.reason );
                break;

            case STREAMING_VIDEO_ENDED:
                controller->streaming_video_ended( streaming_video.address, streaming_video.who );
                break;

            case STREAMING_VIDEO_STATUS:
                controller->streaming_video_status( streaming_video.status, streaming_video.arg );
                break;
        }
    }

private:

    Type            type;
    Controller*     controller;

#ifdef TP_TIME_CONTROLLER_EVENTS

    gsize           create_time;

#endif

    unsigned long int modifiers;

    union
    {
        struct
        {
            unsigned int key_code;
            unsigned long int unicode;
        }                           key;

        struct
        {
            double x;
            double y;
            double z;
        }                           accelerometer;

        struct
        {
            double x;
            double y;
            double z;
        }                           gyroscope;

        struct
        {
            double x;
            double y;
            double z;
        }                           magnetometer;

        struct
        {
            double roll;
            double pitch;
            double yaw;
        }                           attitude;

        struct
        {
            int button_or_finger;
            int x;
            int y;
        }                           click_touch;

        struct
        {
            char* parameters;
        }                           ui;

        struct
        {
            int direction;
        }                           scroll;

        struct
        {
            void* data;
            unsigned int size;
            char* mime_type;
        }                           data;

        struct
        {
            char* address;
            char* reason;
            char* who;
            char* status;
            char* arg;
        }                           streaming_video;
    };
};

//==============================================================================


Controller::Controller( ControllerList* _list, TPContext* _context , const char* _name, const TPControllerSpec* _spec, void* _data )
    :
    tp_controller( new TPController( this, _list ) ),
    connected( true ),
    name( _name ),
    spec( *_spec ),
    data( _data ),
    context( _context ),
    loaded_external_map( false ),
    ts_accelerometer_started( 0 ),
    ts_gyroscope_started( 0 ),
    ts_magnetometer_started( 0 ),
    ts_attitude_started( 0 ),
    ts_pointer_started( 0 ),
    ts_touch_started( 0 ),
    advanced_ui_is_ready( false )
{
    // If the outside world did not provide a function to execute commands,
    // we set our own which always fails.

    if ( ! spec.execute_command )
    {
        spec.execute_command = default_execute_command;
    }

    // If the spec has a key map, copy its contents into an stl map

    if ( spec.key_map )
    {
        for ( TPControllerKeyMap* k = spec.key_map; k->your_key_code || k->trickplay_key_code; ++k )
        {
            key_map[k->your_key_code] = k->trickplay_key_code;
        }

        // NULL it because we don't own the memory past this call

        spec.key_map = 0;
    }

    if ( spec.id )
    {
        id = spec.id;

        spec.id = 0;
    }
    else
    {
        id = Util::make_v4_uuid();
    }
}

//.............................................................................

Controller::~Controller()
{
    delete tp_controller;
}

//.............................................................................

int Controller::default_execute_command( TPController* controller, unsigned int, void*, void* )
{
    // Failure
    return 1;
}

//.............................................................................

TPController* Controller::get_tp_controller()
{
    return tp_controller;
}

//.............................................................................

String Controller::get_name() const
{
    return name;
}

//.............................................................................

unsigned long long Controller::get_capabilities() const
{
    return spec.capabilities;
}

//.............................................................................

void Controller::get_input_size( unsigned int& width, unsigned int& height )
{
    width = spec.input_width;
    height = spec.input_height;
}

//.............................................................................

void Controller::get_ui_size( unsigned int& width, unsigned int& height )
{
    width = spec.ui_width;
    height = spec.ui_height;
}

//.............................................................................

bool Controller::is_connected() const
{
    return connected;
}


//.............................................................................

String Controller::get_key_map_file_name() const
{
    gchar* name_hash = g_compute_checksum_for_string( G_CHECKSUM_MD5 , name.c_str() , -1 );

    gchar* file_name = g_strdup_printf( "%s.map" , name_hash );

    gchar* path = g_build_filename( context->get( TP_DATA_PATH ) , "controllers" , file_name , NULL );

    String result( path );

    g_free( name_hash );
    g_free( file_name );
    g_free( path );

    return result;
}

//.............................................................................

void Controller::load_external_map()
{
    if ( loaded_external_map )
    {
        return;
    }

    // We don't care whether we succeed or n
    loaded_external_map = true;

    String file_name = get_key_map_file_name();

    std::ifstream stream;

    stream.open( file_name.c_str() , std::ios_base::in );

    String line;

    unsigned int a;
    unsigned int b;

    while ( std::getline( stream , line ) )
    {
        if ( std::istringstream( line ) >> a >> b )
        {
            key_map[ a ] = b;
        }
    }
}

//.............................................................................

bool Controller::save_key_map( const KeyMap& km )
{
    FreeLater free_later;

    String file_name = get_key_map_file_name();

    gchar* path = g_path_get_dirname( file_name.c_str() );

    free_later( path );

    if ( 0 != g_mkdir_with_parents( path , 0700 ) )
    {
        return false;
    }

    std::ofstream stream;

    stream.open( file_name.c_str() , std::ios_base::out | std::ios_base::trunc );

    for ( KeyMap::const_iterator it = km.begin(); it != km.end(); ++it )
    {
        stream << it->first << "\t" << it->second << "\n";

        if ( ! stream )
        {
            return false;
        }
    }

    stream.close();

    key_map.insert( km.begin() , km.end() );

    return true;
}

//.............................................................................

unsigned int Controller::map_key_code( unsigned int key_code )
{
    if ( ! loaded_external_map )
    {
        load_external_map();
    }

    if ( !key_map.empty() )
    {
        KeyMap::const_iterator it = key_map.find( key_code );

        if ( it != key_map.end() )
        {
            return it->second;
        }
    }

    return key_code;
}

//.............................................................................

void Controller::disconnected()
{
    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->disconnected();
    }

    connected = false;

    // We nuke the marker, so that TPController::check will assert if this
    // controller is used again after it has been disconnected.

    tp_controller->marker = NULL;
}

//.............................................................................

void Controller::key_down( unsigned int key_code, unsigned long int unicode , unsigned long int modifiers )
{
    if ( !connected )
    {
        return;
    }

    key_code = map_key_code( key_code );

    bool inject = true;

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        if ( !( *it )->key_down( key_code, unicode , modifiers ) )
        {
            inject = false;
        }
    }

    if ( inject )
    {
        ClutterUtil::inject_key_down( context->get_stage(), key_code, unicode , modifiers );
    }
}

//.............................................................................

void Controller::key_up( unsigned int key_code, unsigned long int unicode , unsigned long int modifiers )
{
    if ( !connected )
    {
        return;
    }

    key_code = map_key_code( key_code );

    bool inject = true;

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        if ( !( *it )->key_up( key_code, unicode , modifiers ) )
        {
            inject = false;
        }
    }

    if ( inject )
    {
        ClutterUtil::inject_key_up( context->get_stage(), key_code, unicode , modifiers );
    }
}

//.............................................................................

void Controller::accelerometer( double x, double y, double z , unsigned long int modifiers )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->accelerometer( x, y, z , modifiers );
    }
}

//.............................................................................

void Controller::gyroscope( double x, double y, double z , unsigned long int modifiers )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->gyroscope( x, y, z , modifiers );
    }
}

//.............................................................................

void Controller::magnetometer( double x, double y, double z , unsigned long int modifiers )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->magnetometer( x, y, z , modifiers );
    }
}

//.............................................................................

void Controller::attitude( double roll, double pitch, double yaw, unsigned long int modifiers )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->attitude( roll, pitch, yaw, modifiers );
    }
}

//.............................................................................

void Controller::pointer_move( int x, int y , unsigned long int modifiers )
{
    if ( !connected )
    {
        return;
    }

    bool inject = true;

    gdouble sx = x;
    gdouble sy = y;

    ClutterUtil::stage_coordinates_to_screen_coordinates( context->get_stage(), & sx , & sy );

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        if ( !( *it )->pointer_move( sx, sy , modifiers ) )
        {
            inject = false;
        }
    }

    if ( inject )
    {
        ClutterUtil::inject_motion( context->get_stage(), x , y , modifiers );
    }
}

//.............................................................................

void Controller::pointer_button_down( int button, int x, int y , unsigned long int modifiers )
{
    if ( !connected )
    {
        return;
    }

    bool inject = true;

    gdouble sx = x;
    gdouble sy = y;

    ClutterUtil::stage_coordinates_to_screen_coordinates( context->get_stage(), & sx , & sy );

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        if ( !( *it )->pointer_button_down( button, sx, sy , modifiers ) )
        {
            inject = false;
        }
    }

    if ( inject )
    {
        ClutterUtil::inject_button_press( context->get_stage(), button , x , y , modifiers );
    }
}

//.............................................................................

void Controller::pointer_button_up( int button, int x, int y , unsigned long int modifiers )
{
    if ( !connected )
    {
        return;
    }

    bool inject = true;

    gdouble sx = x;
    gdouble sy = y;

    ClutterUtil::stage_coordinates_to_screen_coordinates( context->get_stage(), & sx , & sy );

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        if ( !( *it )->pointer_button_up( button, sx, sy , modifiers ) )
        {
            inject = false;
        }
    }

    if ( inject )
    {
        ClutterUtil::inject_button_release( context->get_stage(), button , x , y , modifiers );
    }
}

//.............................................................................

void Controller::pointer_active( )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->pointer_active();
    }
}

//.............................................................................

void Controller::pointer_inactive( )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->pointer_inactive();
    }
}

//.............................................................................

void Controller::touch_down( int finger, int x, int y , unsigned long int modifiers )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->touch_down( finger, x, y , modifiers );
    }
}

//.............................................................................

void Controller::touch_move( int finger, int x, int y , unsigned long int modifiers )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->touch_move( finger, x, y , modifiers );
    }
}

//.............................................................................

void Controller::touch_up( int finger, int x, int y , unsigned long int modifiers )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->touch_up( finger, x, y , modifiers );
    }
}

//.............................................................................

void Controller::scroll( int direction , unsigned long int modifiers )
{
    if ( !connected )
    {
        return;
    }

    bool inject = true;

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        if ( !( *it )->scroll( direction , modifiers ) )
        {
            inject = false;
        }
    }

    if ( inject )
    {
        ClutterUtil::inject_scroll( context->get_stage(), direction , modifiers );
    }
}

//.............................................................................

void Controller::ui_event( const String& parameters )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->ui_event( parameters );
    }
}

//.............................................................................

void Controller::submit_image( void* data, unsigned int size, const char* mime_type )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->submit_image( data, size, mime_type );
    }
}

//.............................................................................

void Controller::cancel_image( void )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->cancel_image( );
    }
}

//.............................................................................

void Controller::submit_audio_clip( void* data, unsigned int size, const char* mime_type )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->submit_audio_clip( data, size, mime_type );
    }
}

//.............................................................................

void Controller::cancel_audio_clip( void )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->cancel_audio_clip( );
    }
}

//.............................................................................

void Controller::advanced_ui_ready( void )
{
    if ( !connected )
    {
        return;
    }

    advanced_ui_is_ready = true;

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->advanced_ui_ready( );
    }
}


//.............................................................................

void Controller::advanced_ui_event( const char* json )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->advanced_ui_event( json );
    }
}

//.............................................................................

void Controller::streaming_video_connected( const char* address )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->streaming_video_connected( address );
    }
}

//.............................................................................

void Controller::streaming_video_failed( const char* address, const char* reason )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->streaming_video_failed( address, reason );
    }
}

//.............................................................................

void Controller::streaming_video_dropped( const char* address, const char* reason )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->streaming_video_dropped( address, reason );
    }
}

//.............................................................................

void Controller::streaming_video_ended( const char* address, const char* who )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->streaming_video_ended( address, who );
    }
}

//.............................................................................

void Controller::streaming_video_status( const char* status, const char* arg )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->streaming_video_status( status, arg );
    }
}

//.............................................................................

void Controller::add_delegate( Delegate* delegate )
{
    delegates.insert( delegate );
}

//.............................................................................

void Controller::remove_delegate( Delegate* delegate )
{
    delegates.erase( delegate );
}

//.............................................................................

bool Controller::reset()
{
    g_atomic_int_set( & ts_accelerometer_started , 0 );
    g_atomic_int_set( & ts_gyroscope_started , 0 );
    g_atomic_int_set( & ts_magnetometer_started , 0 );
    g_atomic_int_set( & ts_attitude_started , 0 );
    g_atomic_int_set( & ts_pointer_started , 0 );
    g_atomic_int_set( & ts_touch_started , 0 );

    return
            ( connected ) &&
            ( spec.execute_command(
                    tp_controller,
                    TP_CONTROLLER_COMMAND_RESET,
                    NULL,
                    data ) == 0 );
}

bool Controller::start_accelerometer( MotionFilter filter, double interval )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_ACCELEROMETER ) )
    {
        return false;

    }

    TPControllerStartMotion parameters;

    switch ( filter )
    {
        case LOW:
            parameters.filter = TP_CONTROLLER_MOTION_FILTER_LOW;
            break;

        case HIGH:
            parameters.filter = TP_CONTROLLER_MOTION_FILTER_HIGH;
            break;

        default:
            parameters.filter = TP_CONTROLLER_MOTION_FILTER_NONE;
            break;
    }

    parameters.interval = interval;

    bool accelerometer_started = spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_START_ACCELEROMETER,
            &parameters,
            data ) == 0;

    g_atomic_int_set( & ts_accelerometer_started , accelerometer_started ? 1 : 0 );

    return accelerometer_started;
}

bool Controller::stop_accelerometer()
{
    g_atomic_int_set( & ts_accelerometer_started , 0 );

    return
            ( connected ) &&
            ( spec.capabilities & TP_CONTROLLER_HAS_ACCELEROMETER ) &&
            ( spec.execute_command(
                    tp_controller,
                    TP_CONTROLLER_COMMAND_STOP_ACCELEROMETER,
                    NULL,
                    data ) == 0 );
}

bool Controller::start_gyroscope( double interval )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_FULL_MOTION ) )
    {
        return false;

    }

    TPControllerStartMotion parameters;

    parameters.filter = TP_CONTROLLER_MOTION_FILTER_NONE;

    parameters.interval = interval;

    bool gyroscope_started = spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_START_GYROSCOPE,
            &parameters,
            data ) == 0;

    g_atomic_int_set( & ts_gyroscope_started , gyroscope_started ? 1 : 0 );

    return gyroscope_started;
}

bool Controller::stop_gyroscope()
{
    g_atomic_int_set( & ts_gyroscope_started , 0 );

    return
            ( connected ) &&
            ( spec.capabilities & TP_CONTROLLER_HAS_FULL_MOTION ) &&
            ( spec.execute_command(
                    tp_controller,
                    TP_CONTROLLER_COMMAND_STOP_GYROSCOPE,
                    NULL,
                    data ) == 0 );
}

bool Controller::start_magnetometer( double interval )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_FULL_MOTION ) )
    {
        return false;

    }

    TPControllerStartMotion parameters;

    parameters.filter = TP_CONTROLLER_MOTION_FILTER_NONE;

    parameters.interval = interval;

    bool magnetometer_started = spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_START_MAGNETOMETER,
            &parameters,
            data ) == 0;

    g_atomic_int_set( & ts_magnetometer_started , magnetometer_started ? 1 : 0 );

    return magnetometer_started;
}

bool Controller::stop_magnetometer()
{
    g_atomic_int_set( & ts_magnetometer_started , 0 );

    return
            ( connected ) &&
            ( spec.capabilities & TP_CONTROLLER_HAS_FULL_MOTION ) &&
            ( spec.execute_command(
                    tp_controller,
                    TP_CONTROLLER_COMMAND_STOP_MAGNETOMETER,
                    NULL,
                    data ) == 0 );
}

bool Controller::start_attitude( double interval )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_FULL_MOTION ) )
    {
        return false;

    }

    TPControllerStartMotion parameters;

    parameters.filter = TP_CONTROLLER_MOTION_FILTER_NONE;

    parameters.interval = interval;

    bool attitude_started = spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_START_ATTITUDE,
            &parameters,
            data ) == 0;

    g_atomic_int_set( & ts_attitude_started , attitude_started ? 1 : 0 );

    return attitude_started;
}

bool Controller::stop_attitude()
{
    g_atomic_int_set( & ts_attitude_started , 0 );

    return
            ( connected ) &&
            ( spec.capabilities & TP_CONTROLLER_HAS_FULL_MOTION ) &&
            ( spec.execute_command(
                    tp_controller,
                    TP_CONTROLLER_COMMAND_STOP_ATTITUDE,
                    NULL,
                    data ) == 0 );
}

bool Controller::start_pointer()
{
    bool pointer_started =
            ( connected ) &&
            ( spec.capabilities & TP_CONTROLLER_HAS_POINTER ) &&
            ( spec.execute_command(
                    tp_controller,
                    TP_CONTROLLER_COMMAND_START_POINTER,
                    NULL,
                    data ) == 0 );

    g_atomic_int_set( & ts_pointer_started , pointer_started ? 1 : 0 );

    return pointer_started;
}

bool Controller::stop_pointer()
{
    g_atomic_int_set( & ts_pointer_started , 0 );

    return
            ( connected ) &&
            ( spec.capabilities & TP_CONTROLLER_HAS_POINTER ) &&
            ( spec.execute_command(
                    tp_controller,
                    TP_CONTROLLER_COMMAND_STOP_POINTER,
                    NULL,
                    data ) == 0 );
}

bool Controller::show_pointer_cursor()
{
    return
            ( connected ) &&
            ( spec.capabilities & TP_CONTROLLER_HAS_POINTER_CURSOR ) &&
            ( spec.execute_command(
                    tp_controller,
                    TP_CONTROLLER_COMMAND_SHOW_POINTER_CURSOR,
                    NULL,
                    data ) == 0 );
}

bool Controller::hide_pointer_cursor()
{
    return
            ( connected ) &&
            ( spec.capabilities & TP_CONTROLLER_HAS_POINTER_CURSOR ) &&
            ( spec.execute_command(
                    tp_controller,
                    TP_CONTROLLER_COMMAND_HIDE_POINTER_CURSOR,
                    NULL,
                    data ) == 0 );
}

bool Controller::set_pointer_cursor( int x , int y , const String& image_uri )
{
    TPControllerSetPointerCursor parameters;

    parameters.x = x;
    parameters.y = y;
    parameters.image_uri = image_uri.c_str();

    return
            ( connected ) &&
            ( spec.capabilities & TP_CONTROLLER_HAS_POINTER_CURSOR ) &&
            ( spec.execute_command(
                    tp_controller,
                    TP_CONTROLLER_COMMAND_SET_POINTER_CURSOR,
                    &parameters,
                    data ) == 0 );

}


bool Controller::start_touches()
{
    bool touch_started =
            ( connected ) &&
            ( spec.capabilities & TP_CONTROLLER_HAS_TOUCHES ) &&
            ( spec.execute_command(
                    tp_controller,
                    TP_CONTROLLER_COMMAND_START_TOUCHES,
                    NULL,
                    data ) == 0 );

    g_atomic_int_set( & ts_touch_started , touch_started ? 1 : 0 );

    return touch_started;
}

bool Controller::stop_touches()
{
    g_atomic_int_set( & ts_touch_started , 0 );

    return
            ( connected ) &&
            ( spec.capabilities & TP_CONTROLLER_HAS_TOUCHES ) &&
            ( spec.execute_command(
                    tp_controller,
                    TP_CONTROLLER_COMMAND_STOP_TOUCHES,
                    NULL,
                    data ) == 0 );
}

bool Controller::show_multiple_choice( const String& label, const StringPairList& choices )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_MULTIPLE_CHOICE ) || choices.empty() )
    {
        return false;
    }

    GPtrArray* id_array = g_ptr_array_new();
    GPtrArray* choice_array = g_ptr_array_new();

    for ( StringPairList::const_iterator it = choices.begin(); it != choices.end(); ++it )
    {
        g_ptr_array_add( id_array, ( void* )it->first.c_str() );
        g_ptr_array_add( choice_array, ( void* )it->second.c_str() );
    }

    TPControllerMultipleChoice parameters;

    parameters.label = label.c_str();
    parameters.count = choices.size();
    parameters.ids = ( const char** )id_array->pdata;
    parameters.choices = ( const char** )choice_array->pdata;

    bool result = spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_SHOW_MULTIPLE_CHOICE,
            &parameters,
            data ) == 0;

    g_ptr_array_free( id_array, FALSE );
    g_ptr_array_free( choice_array, FALSE );

    return result;
}

bool Controller::clear_ui()
{
    return
            ( connected ) &&
            ( spec.capabilities &
                    ( TP_CONTROLLER_HAS_UI |
                            TP_CONTROLLER_HAS_MULTIPLE_CHOICE |
                            TP_CONTROLLER_HAS_TEXT_ENTRY ) ) &&
            ( spec.execute_command(
                    tp_controller,
                    TP_CONTROLLER_COMMAND_CLEAR_UI,
                    NULL,
                    data ) == 0 );
}

bool Controller::set_ui_background( const String& resource, UIBackgroundMode mode )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_UI ) )
    {
        return false;
    }

    TPControllerSetUIBackground parameters;

    parameters.resource = resource.c_str();

    switch ( mode )
    {
        case CENTER:
            parameters.mode = TP_CONTROLLER_UI_BACKGROUND_MODE_CENTER;
            break;

        case TILE:
            parameters.mode = TP_CONTROLLER_UI_BACKGROUND_MODE_TILE;
            break;

        default:
            parameters.mode = TP_CONTROLLER_UI_BACKGROUND_MODE_STRETCH;
            break;
    }

    return spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_SET_UI_BACKGROUND,
            &parameters,
            data ) == 0;
}

bool Controller::set_ui_image( const String& resource, int x, int y, int width, int height )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_UI ) )
    {
        return false;
    }

    TPControllerSetUIImage parameters;

    parameters.resource = resource.c_str();
    parameters.x = x;
    parameters.y = y;
    parameters.width = width;
    parameters.height = height;

    return spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_SET_UI_IMAGE,
            &parameters,
            data ) == 0;
}

bool Controller::play_sound( const String& resource, unsigned int loop )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_SOUND ) )
    {
        return false;
    }

    TPControllerPlaySound parameters;

    parameters.resource = resource.c_str();
    parameters.loop = loop;

    return spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_PLAY_SOUND,
            &parameters,
            data ) == 0;
}

bool Controller::stop_sound()
{
    return
            ( connected ) &&
            ( spec.capabilities & TP_CONTROLLER_HAS_SOUND ) &&
            ( spec.execute_command(
                    tp_controller,
                    TP_CONTROLLER_COMMAND_STOP_SOUND,
                    NULL,
                    data ) == 0 );
}

bool Controller::declare_resource( const String& resource, const String& uri , const String& group )
{
    if ( !connected || !( spec.capabilities & ( TP_CONTROLLER_HAS_UI | TP_CONTROLLER_HAS_SOUND ) ) )
    {
        return false;
    }

    TPControllerDeclareResource parameters;

    parameters.resource = resource.c_str();
    parameters.uri = uri.c_str();
    parameters.group = group.c_str();

    return spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_DECLARE_RESOURCE,
            &parameters,
            data ) == 0;
}

bool Controller::drop_resource_group( const String& group )
{
    if ( !connected || !( spec.capabilities & ( TP_CONTROLLER_HAS_UI | TP_CONTROLLER_HAS_SOUND ) ) )
    {
        return false;
    }

    TPControllerDropResourceGroup parameters;

    parameters.group = group.c_str();

    return spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_DROP_RESOURCE_GROUP,
            &parameters,
            data ) == 0;
}


bool Controller::enter_text( const String& label, const String& text )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_TEXT_ENTRY ) )
    {
        return false;
    }

    TPControllerEnterText parameters;

    parameters.label = label.c_str();
    parameters.text = text.c_str();

    return spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_ENTER_TEXT,
            &parameters,
            data ) == 0;
}

bool Controller::request_image( unsigned int max_width , unsigned int max_height , bool edit , const String& mask_resource, const String& dialog_label, const String& cancel_label )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_IMAGES ) )
    {
        return false;
    }

    TPControllerRequestImage parameters;

    parameters.max_width = max_width;
    parameters.max_height = max_height;
    parameters.edit = edit ? 1 : 0;
    parameters.mask = mask_resource.empty() ? 0 : mask_resource.c_str();
    parameters.dialog_label = dialog_label.empty() ? 0 : dialog_label.c_str();
    parameters.cancel_label = cancel_label.empty() ? 0 : cancel_label.c_str();

    return spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_REQUEST_IMAGE,
            & parameters,
            data ) == 0;
}

bool Controller::request_audio_clip( const String& dialog_label, const String& cancel_label )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_AUDIO_CLIPS ) )
    {
        return false;
    }

    TPControllerRequestAudioClip parameters;

    parameters.dialog_label = dialog_label.empty() ? 0 : dialog_label.c_str();
    parameters.cancel_label = cancel_label.empty() ? 0 : cancel_label.c_str();

    return spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_REQUEST_AUDIO_CLIP,
            & parameters,
            data ) == 0;
}

bool Controller::advanced_ui( const String& payload , String& result )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_ADVANCED_UI ) || payload.empty() )
    {
        return false;
    }

    TPControllerAdvancedUI parameters;

    parameters.payload = payload.c_str();
    parameters.result = 0;
    parameters.free_result = 0;

    bool r = spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_ADVANCED_UI,
            & parameters,
            data ) == 0;

    if ( parameters.result )
    {
        result.assign( parameters.result );

        if ( parameters.free_result )
        {
            parameters.free_result( parameters.result );
        }
    }

    return r;
}

bool Controller::show_virtual_remote()
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_VIRTUAL_REMOTE ) )
    {
        return false;
    }

    return spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_SHOW_VIRTUAL_REMOTE,
            0,
            data ) == 0;
}

bool Controller::hide_virtual_remote()
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_VIRTUAL_REMOTE ) )
    {
        return false;
    }

    return spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_HIDE_VIRTUAL_REMOTE,
            0,
            data ) == 0;
}

bool Controller::streaming_video_start_call( const String& address )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_STREAMING_VIDEO ) )
    {
        return false;
    }

    return spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_VIDEO_START_CALL,
            ( void* )address.c_str(),
            data ) == 0;
}

bool Controller::streaming_video_end_call( const String& address )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_STREAMING_VIDEO ) )
    {
        return false;
    }

    return spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_VIDEO_END_CALL,
            ( void* )address.c_str(),
            data ) == 0;
}

bool Controller::streaming_video_send_status()
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_STREAMING_VIDEO ) )
    {
        return false;
    }

    return spec.execute_command(
            tp_controller,
            TP_CONTROLLER_COMMAND_VIDEO_SEND_STATUS,
            0,
            data ) == 0;
}

//==============================================================================

#define LOCK Util::GSRMutexLock _lock(&mutex)

//-----------------------------------------------------------------------------

ControllerList::ControllerList()
    :
    queue( g_async_queue_new_full( ( GDestroyNotify )Event::destroy ) ),
    stopped( 0 )
{
#ifndef GLIB_VERSION_2_32
    g_static_rec_mutex_init( &mutex );
#else
    g_rec_mutex_init( &mutex );
#endif
}

//.............................................................................

ControllerList::~ControllerList()
{
    for ( TPControllerSet::iterator it = controllers.begin(); it != controllers.end(); ++it )
    {
        ( *it )->controller->unref();
    }

#ifndef GLIB_VERSION_2_32
    g_static_rec_mutex_free( &mutex );
#else
    g_rec_mutex_clear( &mutex );
#endif
    g_async_queue_unref( queue );
}

//.............................................................................

void ControllerList::stop_events()
{
    g_atomic_int_set( & stopped , 1 );
}

//.............................................................................
// Called in any thread. Adds event to queue and adds an idle source to pump
// events.

void ControllerList::post_event( gpointer event )
{
    g_assert( event );

    if ( g_atomic_int_get( & stopped ) )
    {
        Event::destroy( ( Event* ) event );
    }
    else
    {
        g_async_queue_push( queue, event );
        g_idle_add_full( TRICKPLAY_PRIORITY, process_events, this, NULL );
    }
}

//.............................................................................
// Called in main thread by an idle source.

gboolean ControllerList::process_events( gpointer self )
{
    g_assert( self );

    ControllerList* list = ( ControllerList* )self;

    while ( Event* event = ( Event* )g_async_queue_try_pop( list->queue ) )
    {
        event->process();
        Event::destroy( event );
    }

    return FALSE;
}

//.............................................................................
// Most likely called in a different thread.
// Adds the controller to our list and posts an event.

TPController* ControllerList::add_controller( TPContext* context , const char* name, const TPControllerSpec* spec, void* data )
{
    g_assert( name );
    g_assert( spec );

    Controller* controller = new Controller( this , context , name , spec , data );

    TPController* result = controller->get_tp_controller();

    post_event( Event::make( Event::ADDED, controller ) );

    return result;
}

//.............................................................................
// Most likely called in a different thread.
// Removes the controller from the list and posts an event.

void ControllerList::remove_controller( TPController* controller )
{
    TPController::check( controller );

    post_event( Event::make( Event::REMOVED, controller->controller ) );
}

//.............................................................................
// Called in main thread - to let delegates know that a new controller is here.

void ControllerList::controller_added( Controller* controller )
{
    controllers.insert( controller->get_tp_controller() );

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->connected( controller );
    }
}

//.............................................................................

void ControllerList::controller_removed( Controller* controller )
{
    controllers.erase( controller->get_tp_controller() );

    controller->disconnected();
    controller->unref();
}

//.............................................................................

void ControllerList::add_delegate( Delegate* delegate )
{
    delegates.insert( delegate );
}

//.............................................................................

void ControllerList::remove_delegate( Delegate* delegate )
{
    delegates.erase( delegate );
}

//.............................................................................
// Be careful with this one. It returns a copy of the list of connected
// controllers as the list is now.
// A different thread could come in and remove one from our internal list at any
// time. (This won't affect the copy you have)
// On top of that, the returned list does not add a ref to the controllers...
// The expectation is that you will only use the returned list in the main thread
// in which case the controllers won't be unrefed from under you.

ControllerList::ControllerSet ControllerList::get_controllers()
{
    ControllerSet result;

    LOCK;

    for ( TPControllerSet::iterator it = controllers.begin(); it != controllers.end(); ++it )
    {
        Controller* controller = ( *it )->controller;

        if ( controller->is_connected() )
        {
            result.insert( controller );
        }
    }

    return result;
}

//.............................................................................

void ControllerList::reset_all()
{
    LOCK;

    for ( TPControllerSet::iterator it = controllers.begin(); it != controllers.end(); ++it )
    {
        ( *it )->controller->reset();
    }
}


//==============================================================================
// External-facing functions. They all do a sanity check and then post an event.

void tp_controller_key_down( TPController* controller, unsigned int key_code, unsigned long int unicode , unsigned long int modifiers )
{
    TPController::check( controller );

    controller->list->post_event( Event::make_key( Event::KEY_DOWN, controller->controller, key_code, unicode , modifiers ) );
}

void tp_controller_key_up( TPController* controller, unsigned int key_code, unsigned long int unicode , unsigned long int modifiers )
{
    TPController::check( controller );

    controller->list->post_event( Event::make_key( Event::KEY_UP, controller->controller, key_code, unicode , modifiers ) );
}

void tp_controller_accelerometer( TPController* controller, double x, double y, double z , unsigned long int modifiers )
{
    TPController::check( controller );

    if ( controller->controller->wants_accelerometer_events() )
    {
        controller->list->post_event( Event::make_accelerometer( controller->controller, x, y, z , modifiers ) );
    }
}

void tp_controller_gyroscope( TPController* controller, double x, double y, double z , unsigned long int modifiers )
{
    TPController::check( controller );

    if ( controller->controller->wants_gyroscope_events() )
    {
        controller->list->post_event( Event::make_gyroscope( controller->controller, x, y, z , modifiers ) );
    }
}

void tp_controller_magnetometer( TPController* controller, double x, double y, double z , unsigned long int modifiers )
{
    TPController::check( controller );

    if ( controller->controller->wants_magnetometer_events() )
    {
        controller->list->post_event( Event::make_magnetometer( controller->controller, x, y, z , modifiers ) );
    }
}

void tp_controller_attitude( TPController* controller, double roll, double pitch, double yaw , unsigned long int modifiers )
{
    TPController::check( controller );

    if ( controller->controller->wants_attitude_events() )
    {
        controller->list->post_event( Event::make_attitude( controller->controller, roll, pitch, yaw , modifiers ) );
    }
}

void tp_controller_pointer_move( TPController* controller, int x, int y , unsigned long int modifiers )
{
    TPController::check( controller );

    if ( controller->controller->wants_pointer_events() )
    {
        controller->list->post_event( Event::make_click_touch( Event::POINTER_MOVE, controller->controller, 0 , x, y , modifiers ) );
    }
}

void tp_controller_pointer_button_down( TPController* controller, int button, int x, int y , unsigned long int modifiers )
{
    TPController::check( controller );

    if ( controller->controller->wants_pointer_events() )
    {
        controller->list->post_event( Event::make_click_touch( Event::POINTER_DOWN, controller->controller, button , x, y , modifiers ) );
    }
}

void tp_controller_pointer_button_up( TPController* controller, int button, int x, int y , unsigned long int modifiers )
{
    TPController::check( controller );

    if ( controller->controller->wants_pointer_events() )
    {
        controller->list->post_event( Event::make_click_touch( Event::POINTER_UP, controller->controller, button, x, y , modifiers ) );
    }
}

void tp_controller_pointer_active( TPController* controller )
{
    TPController::check( controller );

    controller->list->post_event( Event::make( Event::POINTER_ACTIVE , controller->controller ) );
}

void tp_controller_pointer_inactive( TPController* controller )
{
    TPController::check( controller );

    controller->list->post_event( Event::make( Event::POINTER_INACTIVE , controller->controller ) );
}

void tp_controller_touch_down( TPController* controller, int finger, int x, int y , unsigned long int modifiers )
{
    TPController::check( controller );

    if ( controller->controller->wants_touch_events() )
    {
        controller->list->post_event( Event::make_click_touch( Event::TOUCH_DOWN, controller->controller, finger, x, y , modifiers ) );
    }
}

void tp_controller_touch_move( TPController* controller, int finger, int x, int y , unsigned long int modifiers )
{
    TPController::check( controller );

    if ( controller->controller->wants_touch_events() )
    {
        controller->list->post_event( Event::make_click_touch( Event::TOUCH_MOVE, controller->controller, finger, x, y , modifiers ) );
    }
}

void tp_controller_touch_up( TPController* controller, int finger, int x, int y , unsigned long int modifiers )
{
    TPController::check( controller );

    if ( controller->controller->wants_touch_events() )
    {
        controller->list->post_event( Event::make_click_touch( Event::TOUCH_UP, controller->controller, finger, x, y , modifiers ) );
    }
}

void tp_controller_scroll( TPController* controller, int direction , unsigned long int modifiers )
{
    TPController::check( controller );

    controller->list->post_event( Event::make_scroll( controller->controller , direction , modifiers ) );
}

void tp_controller_ui_event( TPController* controller, const char* parameters )
{
    TPController::check( controller );

    controller->list->post_event( Event::make_ui( controller->controller, parameters ) );
}

int tp_controller_wants_accelerometer_events( TPController* controller )
{
    TPController::check( controller );

    return controller->controller->wants_accelerometer_events();
}

int tp_controller_wants_pointer_events( TPController* controller )
{
    TPController::check( controller );

    return controller->controller->wants_pointer_events();
}

int tp_controller_wants_touch_events( TPController* controller )
{
    TPController::check( controller );

    return controller->controller->wants_touch_events();
}

void tp_controller_submit_image( TPController* controller, const void* data, unsigned int size, const char* mime_type )
{
    g_assert( data );
    g_assert( size );

    TPController::check( controller );
    controller->list->post_event( Event::make_data( Event::SUBMIT_IMAGE, controller->controller, data, size, mime_type ) );
}

void tp_controller_submit_audio_clip( TPController* controller, const void* data, unsigned int size, const char* mime_type )
{
    g_assert( data );
    g_assert( size );

    TPController::check( controller );
    controller->list->post_event( Event::make_data( Event::SUBMIT_AUDIO_CLIP, controller->controller, data, size, mime_type ) );
}

void tp_controller_cancel_image( TPController* controller )
{
    TPController::check( controller );
    controller->list->post_event( Event::make( Event::CANCEL_IMAGE, controller->controller ) );
}

void tp_controller_cancel_audio_clip( TPController* controller )
{
    TPController::check( controller );
    controller->list->post_event( Event::make( Event::CANCEL_AUDIO_CLIP, controller->controller ) );
}

void tp_controller_advanced_ui_ready( TPController* controller )
{
    TPController::check( controller );
    controller->list->post_event( Event::make( Event::ADVANCED_UI_READY, controller->controller ) );
}

void tp_controller_advanced_ui_event( TPController* controller , const char* json )
{
    g_assert( json );

    TPController::check( controller );
    controller->list->post_event( Event::make_advanced_ui_event( controller->controller , json ) );
}


void tp_controller_streaming_video_connected( TPController* controller, const char* address )
{
    g_assert( address );

    TPController::check( controller );

    controller->list->post_event( Event::make_streaming_video_connected( controller->controller, address ) );
}

void tp_controller_streaming_video_failed( TPController* controller, const char* address, const char* reason )
{
    g_assert( address );
    g_assert( reason );

    TPController::check( controller );

    controller->list->post_event( Event::make_streaming_video_failed( controller->controller, address, reason ) );
}

void tp_controller_streaming_video_dropped( TPController* controller, const char* address, const char* reason )
{
    g_assert( address );
    g_assert( reason );

    TPController::check( controller );

    controller->list->post_event( Event::make_streaming_video_dropped( controller->controller, address, reason ) );
}

void tp_controller_streaming_video_ended( TPController* controller, const char* address, const char* who )
{
    g_assert( address );
    g_assert( who );

    TPController::check( controller );

    controller->list->post_event( Event::make_streaming_video_ended( controller->controller, address, who ) );
}

void tp_controller_streaming_video_status( TPController* controller, const char* status, const char* arg )
{
    g_assert( status );
    g_assert( arg );

    TPController::check( controller );

    controller->list->post_event( Event::make_streaming_video_status( controller->controller, status, arg ) );
}
