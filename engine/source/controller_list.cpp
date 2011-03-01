
#include "controller_list.h"
#include "clutter_util.h"

//==============================================================================
// This is the structure we give the outside world. To them, it is opaque.
// It has a pointer to a Controller instance, the associated ControllerList
// and a marker, which points to itself. The marker lets us do sanity checks
// to ensure the outside doesn't pass garbage.

struct TPController
{
    TPController( Controller * _controller, ControllerList * _list )
        :
        controller( _controller ),
        list( _list ),
        marker( this )
    {
        check( this );
    }

    inline static void check( TPController * controller )
    {
        g_assert( controller );
        g_assert( controller->list );
        g_assert( controller->controller );

        // An assertion here means that either the controller is garbage or
        // it has already been disconnected.

        g_assert( controller->marker == controller );
    }

    Controller     *    controller;
    ControllerList   *  list;
    TPController    *   marker;
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
        ACCELEROMETER,
        POINTER_MOVE , POINTER_DOWN , POINTER_UP,
        TOUCH_DOWN, TOUCH_MOVE, TOUCH_UP,
        UI
    };

public:

    inline static Event * make( Type type, Controller * controller )
    {
        g_assert( controller );

        controller->ref();

        Event * event = g_slice_new( Event );

        event->type = type;
        event->controller = controller;
        event->time = controller->get_tp_controller()->list->time();

        if ( type == UI )
        {
            event->ui.parameters = NULL;
        }

        return event;
    }

    static void destroy( Event * event )
    {
        g_assert( event );
        g_assert( event->controller );

        if ( event->type == UI )
        {
            g_free( event->ui.parameters );
        };

        event->controller->unref();

        g_slice_free( Event, event );
    }

    inline static Event * make_key( Type type, Controller * controller, unsigned int key_code, unsigned long int unicode )
    {
        Event * event = make( type, controller );

        event->key.key_code = key_code;
        event->key.unicode = unicode;

        return event;
    }

    inline static Event * make_accelerometer( Controller * controller, double x, double y, double z )
    {
        Event * event = make( ACCELEROMETER, controller );

        event->accelerometer.x = x;
        event->accelerometer.y = y;
        event->accelerometer.z = z;

        return event;
    }

    inline static Event * make_click_touch( Type type, Controller * controller, int button_or_finger, int x, int y )
    {
        Event * event = make( type, controller );

        event->click_touch.button_or_finger = button_or_finger;
        event->click_touch.x = x;
        event->click_touch.y = y;

        return event;
    }

    inline static Event * make_ui( Controller * controller, const char * parameters )
    {
        Event * event = make( UI, controller );

        event->ui.parameters = g_strdup( parameters );

        return event;
    }

    inline void process()
    {
        switch ( type )
        {
            case ADDED:
                controller->get_tp_controller()->list->controller_added( controller );
                break;

            case REMOVED:
                controller->disconnected();
                controller->unref();
                break;

            case KEY_DOWN:
                controller->key_down( key.key_code, key.unicode );
                break;

            case KEY_UP:
                controller->key_up( key.key_code, key.unicode );
                break;

            case ACCELEROMETER:
                controller->accelerometer( accelerometer.x, accelerometer.y, accelerometer.z );
                break;

            case POINTER_MOVE:
                controller->pointer_move( click_touch.x, click_touch.y );
                break;

            case POINTER_DOWN:
                controller->pointer_button_down( click_touch.button_or_finger,  click_touch.x, click_touch.y );
                break;

            case POINTER_UP:
                controller->pointer_button_up( click_touch.button_or_finger,  click_touch.x, click_touch.y );
                break;

            case TOUCH_DOWN:
                controller->touch_down( click_touch.button_or_finger, click_touch.x, click_touch.y );
                break;

            case TOUCH_MOVE:
                controller->touch_move( click_touch.button_or_finger, click_touch.x, click_touch.y );
                break;

            case TOUCH_UP:
                controller->touch_up( click_touch.button_or_finger, click_touch.x, click_touch.y );
                break;

            case UI:
                controller->ui_event( ui.parameters );
                break;
        }
    }

    inline gdouble get_time()
    {
        return time;
    }

private:

    Type            type;
    Controller   *  controller;
    gdouble         time;

    union
    {
        struct
        {
            unsigned int key_code;
            unsigned long int unicode;
        }    key;

        struct
        {
            double x;
            double y;
            double z;
        }                     accelerometer;

        struct
        {
            int button_or_finger;
            int x;
            int y;
        }                        click_touch;

        struct
        {
            char * parameters;
        }            ui;
    };
};

//==============================================================================


Controller::Controller( ControllerList * _list, const char * _name, const TPControllerSpec * _spec, void * _data )
    :
    tp_controller( new TPController( this, _list ) ),
    connected( true ),
    name( _name ),
    spec( *_spec ),
    data( _data ),
    ts_accelerometer_started( 0 ),
    ts_pointer_started( 0 ),
    ts_touch_started( 0 )
{
    // If the outside world did not provide a function to execute commands,
    // we set our own which always fails.

    if ( !spec.execute_command )
    {
        spec.execute_command = default_execute_command;
    }

    // If the spec has a key map, copy its contents into an stl map

    if ( spec.key_map )
    {
        for ( TPControllerKeyMap * k = spec.key_map; k->your_key_code || k->trickplay_key_code; ++k )
        {
            key_map[k->your_key_code] = k->trickplay_key_code;
        }

        // NULL it because we don't own the memory past this call

        spec.key_map = NULL;
    }
}

//.............................................................................

Controller::~Controller()
{
    delete tp_controller;
}

//.............................................................................

int Controller::default_execute_command( TPController * controller, unsigned int, void *, void * )
{
    // Failure
    return 1;
}

//.............................................................................

TPController * Controller::get_tp_controller()
{
    return tp_controller;
}

//.............................................................................

String Controller::get_name() const
{
    return name;
}

//.............................................................................

unsigned int Controller::get_capabilities() const
{
    return spec.capabilities;
}

//.............................................................................

void Controller::get_input_size( unsigned int & width, unsigned int & height )
{
    width = spec.input_width;
    height = spec.input_height;
}

//.............................................................................

void Controller::get_ui_size( unsigned int & width, unsigned int & height )
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

unsigned int Controller::map_key_code( unsigned int key_code )
{
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

void Controller::key_down( unsigned int key_code, unsigned long int unicode )
{
    if ( !connected )
    {
        return;
    }

    key_code = map_key_code( key_code );

    bool inject = true;

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        if ( ! ( *it )->key_down( key_code, unicode ) )
        {
            inject = false;
        }
    }

    if ( inject )
    {
        ClutterUtil::inject_key_down( key_code, unicode );
    }
}

//.............................................................................

void Controller::key_up( unsigned int key_code, unsigned long int unicode )
{
    if ( !connected )
    {
        return;
    }

    key_code = map_key_code( key_code );

    bool inject = true;

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        if ( ! ( *it )->key_up( key_code, unicode ) )
        {
            inject = false;
        }
    }

    if ( inject )
    {
        ClutterUtil::inject_key_up( key_code, unicode );
    }
}

//.............................................................................

void Controller::accelerometer( double x, double y, double z )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->accelerometer( x, y, z );
    }
}

//.............................................................................

void Controller::pointer_move( int x, int y )
{
    if ( !connected )
    {
        return;
    }

    bool inject = true;

    gdouble sx = x;
    gdouble sy = y;

    ClutterUtil::stage_coordinates_to_screen_coordinates( & sx , & sy );

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        if ( ! ( *it )->pointer_move( sx, sy ) )
        {
            inject = false;
        }
    }

    if ( inject )
    {
        ClutterUtil::inject_motion( x , y );
    }
}

//.............................................................................

void Controller::pointer_button_down( int button, int x, int y )
{
    if ( !connected )
    {
        return;
    }

    bool inject = true;

    gdouble sx = x;
    gdouble sy = y;

    ClutterUtil::stage_coordinates_to_screen_coordinates( & sx , & sy );

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        if ( ! ( *it )->pointer_button_down( button, sx, sy ) )
        {
            inject = false;
        }
    }

    if ( inject )
    {
        ClutterUtil::inject_button_press( button , x , y );
    }
}

//.............................................................................

void Controller::pointer_button_up( int button, int x, int y )
{
    if ( !connected )
    {
        return;
    }

    bool inject = true;

    gdouble sx = x;
    gdouble sy = y;

    ClutterUtil::stage_coordinates_to_screen_coordinates( & sx , & sy );

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        if ( ! ( *it )->pointer_button_up( button, sx, sy ) )
        {
            inject = false;
        }
    }

    if ( inject )
    {
        ClutterUtil::inject_button_release( button , x , y );
    }
}

//.............................................................................

void Controller::touch_down( int finger, int x, int y )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->touch_down( finger, x, y );
    }
}

//.............................................................................

void Controller::touch_move( int finger, int x, int y )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->touch_move( finger, x, y );
    }
}

//.............................................................................

void Controller::touch_up( int finger, int x, int y )
{
    if ( !connected )
    {
        return;
    }

    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->touch_up( finger, x, y );
    }
}

//.............................................................................

void Controller::ui_event( const String & parameters )
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

void Controller::add_delegate( Delegate * delegate )
{
    delegates.insert( delegate );
}

//.............................................................................

void Controller::remove_delegate( Delegate * delegate )
{
    delegates.erase( delegate );
}

//.............................................................................

bool Controller::reset()
{
    g_atomic_int_set( & ts_accelerometer_started , 0 );
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

bool Controller::start_accelerometer( AccelerometerFilter filter, double interval )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_ACCELEROMETER ) )
    {
        return false;

    }

    TPControllerStartAccelerometer parameters;

    switch ( filter )
    {
        case LOW:
            parameters.filter = TP_CONTROLLER_ACCELEROMETER_FILTER_LOW;
            break;

        case HIGH:
            parameters.filter = TP_CONTROLLER_ACCELEROMETER_FILTER_HIGH;
            break;

        default:
            parameters.filter = TP_CONTROLLER_ACCELEROMETER_FILTER_NONE;
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

bool Controller::show_multiple_choice( const String & label, const StringPairList & choices )
{
    if ( !connected || !( spec.capabilities & TP_CONTROLLER_HAS_MULTIPLE_CHOICE ) || choices.empty() )
    {
        return false;
    }

    GPtrArray * id_array = g_ptr_array_new();
    GPtrArray * choice_array = g_ptr_array_new();

    for ( StringPairList::const_iterator it = choices.begin(); it != choices.end(); ++it )
    {
        g_ptr_array_add( id_array, ( void * )it->first.c_str() );
        g_ptr_array_add( choice_array, ( void * )it->second.c_str() );
    }

    TPControllerMultipleChoice parameters;

    parameters.label = label.c_str();
    parameters.count = choices.size();
    parameters.ids = ( const char ** )id_array->pdata;
    parameters.choices = ( const char ** )choice_array->pdata;

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

bool Controller::set_ui_background( const String & resource, UIBackgroundMode mode )
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

bool Controller::set_ui_image( const String & resource, int x, int y, int width, int height )
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

bool Controller::play_sound( const String & resource, unsigned int loop )
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

bool Controller::declare_resource( const String & resource, const String & uri )
{
    if ( !connected || !( spec.capabilities&( TP_CONTROLLER_HAS_UI | TP_CONTROLLER_HAS_SOUND ) ) )
    {
        return false;
    }

    TPControllerDeclareResource parameters;

    parameters.resource = resource.c_str();
    parameters.uri = uri.c_str();

    return spec.execute_command(
               tp_controller,
               TP_CONTROLLER_COMMAND_DECLARE_RESOURCE,
               &parameters,
               data ) == 0;
}

bool Controller::enter_text( const String & label, const String & text )
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

//==============================================================================

#define LOCK Util::GSRMutexLock _lock(&mutex)

//-----------------------------------------------------------------------------

ControllerList::ControllerList()
    :
    queue( g_async_queue_new_full( ( GDestroyNotify )Event::destroy ) ),
    timer( g_timer_new() )
{
    g_static_rec_mutex_init( &mutex );
}

//.............................................................................

ControllerList::~ControllerList()
{
    for ( TPControllerSet::iterator it = controllers.begin(); it != controllers.end(); ++it )
    {
        ( *it )->controller->unref();
    }

    g_static_rec_mutex_free( &mutex );
    g_async_queue_unref( queue );

    g_timer_destroy( timer );
}

//.............................................................................
// Called in any thread. Adds event to queue and adds an idle source to pump
// events.

void ControllerList::post_event( gpointer event )
{
    g_assert( event );

    g_async_queue_push( queue, event );
    g_idle_add_full( TRICKPLAY_PRIORITY, process_events, this, NULL );
}

//.............................................................................
// Called in main thread by an idle source.

gboolean ControllerList::process_events( gpointer self )
{
    g_assert( self );

    ControllerList * list = ( ControllerList * )self;

    while ( Event * event = ( Event * )g_async_queue_try_pop( list->queue ) )
    {
#if 0
        g_debug( "EVENT PROCESS TIME %f ms" , ( list->time() - event->get_time() ) * 1000 );
#endif
        event->process();
        Event::destroy( event );
    }

    return FALSE;
}

//.............................................................................
// Most likely called in a different thread.
// Adds the controller to our list and posts an event.

TPController * ControllerList::add_controller( const char * name, const TPControllerSpec * spec, void * data )
{
    g_assert( name );
    g_assert( spec );

    Controller * controller = new Controller( this, name, spec, data );

    TPController * result = controller->get_tp_controller();

    LOCK;

    controllers.insert( result );

    post_event( Event::make( Event::ADDED, controller ) );

    return result;
}

//.............................................................................
// Most likely called in a different thread.
// Removes the controller from the list and posts an event.

void ControllerList::remove_controller( TPController * controller )
{
    TPController::check( controller );

    LOCK;

    if ( controllers.erase( controller ) == 1 )
    {
        post_event( Event::make( Event::REMOVED, controller->controller ) );
    }
}

//.............................................................................
// Called in main thread - to let delegates know that a new controller is here.

void ControllerList::controller_added( Controller * controller )
{
    for ( DelegateSet::iterator it = delegates.begin(); it != delegates.end(); ++it )
    {
        ( *it )->connected( controller );
    }
}

//.............................................................................

void ControllerList::add_delegate( Delegate * delegate )
{
    delegates.insert( delegate );
}

//.............................................................................

void ControllerList::remove_delegate( Delegate * delegate )
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
        Controller * controller = ( *it )->controller;

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

void tp_controller_key_down( TPController * controller, unsigned int key_code, unsigned long int unicode )
{
    TPController::check( controller );

    controller->list->post_event( Event::make_key( Event::KEY_DOWN, controller->controller, key_code, unicode ) );
}

void tp_controller_key_up( TPController * controller, unsigned int key_code, unsigned long int unicode )
{
    TPController::check( controller );

    controller->list->post_event( Event::make_key( Event::KEY_UP, controller->controller, key_code, unicode ) );
}

void tp_controller_accelerometer( TPController * controller, double x, double y, double z )
{
    TPController::check( controller );

    if ( controller->controller->wants_accelerometer_events() )
    {
        controller->list->post_event( Event::make_accelerometer( controller->controller, x, y, z ) );
    }
}

void tp_controller_pointer_move( TPController * controller, int x, int y )
{
    TPController::check( controller );

    if ( controller->controller->wants_pointer_events() )
    {
        controller->list->post_event( Event::make_click_touch( Event::POINTER_MOVE, controller->controller, 0 , x, y ) );
    }
}

void tp_controller_pointer_button_down( TPController * controller, int button, int x, int y )
{
    TPController::check( controller );

    if ( controller->controller->wants_pointer_events() )
    {
        controller->list->post_event( Event::make_click_touch( Event::POINTER_DOWN, controller->controller, button , x, y ) );
    }
}

void tp_controller_pointer_button_up( TPController * controller, int button, int x, int y )
{
    TPController::check( controller );

    if ( controller->controller->wants_pointer_events() )
    {
        controller->list->post_event( Event::make_click_touch( Event::POINTER_UP, controller->controller, button, x, y ) );
    }
}

void tp_controller_touch_down( TPController * controller, int finger, int x, int y )
{
    TPController::check( controller );

    if ( controller->controller->wants_touch_events() )
    {
        controller->list->post_event( Event::make_click_touch( Event::TOUCH_DOWN, controller->controller, finger, x, y ) );
    }
}

void tp_controller_touch_move( TPController * controller, int finger, int x, int y )
{
    TPController::check( controller );

    if ( controller->controller->wants_touch_events() )
    {
        controller->list->post_event( Event::make_click_touch( Event::TOUCH_MOVE, controller->controller, finger, x, y ) );
    }
}

void tp_controller_touch_up( TPController * controller, int finger, int x, int y )
{
    TPController::check( controller );

    if ( controller->controller->wants_touch_events() )
    {
        controller->list->post_event( Event::make_click_touch( Event::TOUCH_UP, controller->controller, finger, x, y ) );
    }
}

void tp_controller_ui_event( TPController * controller, const char * parameters )
{
    TPController::check( controller );

    controller->list->post_event( Event::make_ui( controller->controller, parameters ) );
}

int tp_controller_wants_accelerometer_events( TPController * controller )
{
    TPController::check( controller );

    return controller->controller->wants_accelerometer_events();
}

int tp_controller_wants_pointer_events( TPController * controller )
{
    TPController::check( controller );

    return controller->controller->wants_pointer_events();
}

int tp_controller_wants_touch_events( TPController * controller )
{
    TPController::check( controller );

    return controller->controller->wants_touch_events();
}
