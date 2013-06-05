
#include "controller_delegates.h"

#include "context.h"
#include "bitmap.h"
#include "clutter_util.h"
#include "lb.h"

//=============================================================================

extern int new_Controller( lua_State* );

extern int invoke_Controller_on_accelerometer( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_gyroscope( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_magnetometer( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_attitude( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_advanced_ui_event( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_advanced_ui_ready( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_audio_clip_cancelled( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_disconnected( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_image_cancelled( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_image( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_key_down( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_key_up( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_pointer_button_down( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_pointer_button_up( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_pointer_move( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_pointer_active( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_pointer_inactive( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_touch_down( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_touch_move( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_touch_up( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_scroll( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_ui_event( lua_State* , ControllerDelegate* , int , int );
extern int invoke_Controller_on_streaming_video_connected( lua_State*, ControllerDelegate*, int, int );
extern int invoke_Controller_on_streaming_video_failed( lua_State*, ControllerDelegate*, int, int );
extern int invoke_Controller_on_streaming_video_dropped( lua_State*, ControllerDelegate*, int, int );
extern int invoke_Controller_on_streaming_video_ended( lua_State*, ControllerDelegate*, int, int );
extern int invoke_Controller_on_streaming_video_status( lua_State*, ControllerDelegate*, int, int );

extern int invoke_controllers_on_controller_connected( lua_State* , ControllerListDelegate* , int , int );

//=============================================================================

ControllerDelegate::ControllerDelegate( lua_State* _LS, Controller* _controller, ControllerListDelegate* _list )
    :
    L( _LS ),
    controller( _controller ),
    list( _list )
{
    controller->ref();
    controller->add_delegate( this );
}

//.........................................................................

ControllerDelegate::~ControllerDelegate()
{
    if ( ! resource_group.empty() )
    {
        controller->drop_resource_group( resource_group );
    }

    controller->remove_delegate( this );
    controller->unref();
}

//.........................................................................
// Delegate functions

void ControllerDelegate::disconnected()
{
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_disconnected", 0, 0 );

    list->proxy_disconnected( this );
}

//.........................................................................

bool ControllerDelegate::key_down( unsigned int key_code, unsigned long int unicode, unsigned long int modifiers )
{
    lua_pushnumber( L, key_code );
    lua_pushnumber( L, unicode );
    ClutterUtil::push_event_modifiers( L, modifiers );

    bool result = true;

    if ( lb_invoke_callbacks_r( L, this, "CONTROLLER_METATABLE", "on_key_down", 3, 1, 1 ) )
    {
        if ( lua_isboolean( L , -1 ) && ! lua_toboolean( L , -1 ) )
        {
            result = false;
        }

        lua_pop( L , 1 );
    }

    return result;
}

//.........................................................................

bool ControllerDelegate::key_up( unsigned int key_code, unsigned long int unicode, unsigned long int modifiers )
{
    lua_pushnumber( L, key_code );
    lua_pushnumber( L, unicode );
    ClutterUtil::push_event_modifiers( L, modifiers );

    bool result = true;

    if ( lb_invoke_callbacks_r( L, this, "CONTROLLER_METATABLE", "on_key_up", 3, 1, 1 ) )
    {

        if ( lua_isboolean( L , -1 ) && ! lua_toboolean( L , -1 ) )
        {
            result = false;
        }

        lua_pop( L , 1 );
    }

    return result;
}

//.........................................................................

void ControllerDelegate::accelerometer( double x, double y, double z, unsigned long int modifiers )
{
    lua_pushnumber( L, x );
    lua_pushnumber( L, y );
    lua_pushnumber( L, z );
    ClutterUtil::push_event_modifiers( L, modifiers );
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_accelerometer", 4, 0 );
}

//.........................................................................

void ControllerDelegate::gyroscope( double x, double y, double z, unsigned long int modifiers )
{
    lua_pushnumber( L, x );
    lua_pushnumber( L, y );
    lua_pushnumber( L, z );
    ClutterUtil::push_event_modifiers( L, modifiers );
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_gyroscope", 4, 0 );
}

//.........................................................................

void ControllerDelegate::magnetometer( double x, double y, double z, unsigned long int modifiers )
{
    lua_pushnumber( L, x );
    lua_pushnumber( L, y );
    lua_pushnumber( L, z );
    ClutterUtil::push_event_modifiers( L, modifiers );
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_magnetometer", 4, 0 );
}

//.........................................................................

void ControllerDelegate::attitude( double roll, double pitch, double yaw, unsigned long int modifiers )
{
    lua_pushnumber( L, roll );
    lua_pushnumber( L, pitch );
    lua_pushnumber( L, yaw );
    ClutterUtil::push_event_modifiers( L, modifiers );
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_attitude", 4, 0 );
}

//.........................................................................

bool ControllerDelegate::pointer_move( int x, int y, unsigned long int modifiers )
{
    lua_pushnumber( L, x );
    lua_pushnumber( L, y );
    ClutterUtil::push_event_modifiers( L, modifiers );

    bool result = true;

    if ( lb_invoke_callbacks_r( L, this, "CONTROLLER_METATABLE", "on_pointer_move", 3, 1, 1 ) )
    {
        if ( lua_isboolean( L , -1 ) && ! lua_toboolean( L , -1 ) )
        {
            result = false;
        }

        lua_pop( L , 1 );
    }

    return result;
}

//.........................................................................

bool ControllerDelegate::pointer_button_down( int button, int x, int y, unsigned long int modifiers )
{
    lua_pushnumber( L, button );
    lua_pushnumber( L, x );
    lua_pushnumber( L, y );
    ClutterUtil::push_event_modifiers( L, modifiers );

    bool result = true;

    if ( lb_invoke_callbacks_r( L, this, "CONTROLLER_METATABLE", "on_pointer_button_down", 4, 1, 1 ) )
    {
        if ( lua_isboolean( L , -1 ) && ! lua_toboolean( L , -1 ) )
        {
            result = false;
        }

        lua_pop( L , 1 );
    }

    return result;
}

//.........................................................................

bool ControllerDelegate::pointer_button_up( int button, int x, int y, unsigned long int modifiers )
{
    lua_pushnumber( L, button );
    lua_pushnumber( L, x );
    lua_pushnumber( L, y );
    ClutterUtil::push_event_modifiers( L, modifiers );

    bool result = true;

    if ( lb_invoke_callbacks_r( L, this, "CONTROLLER_METATABLE", "on_pointer_button_up", 4, 1, 1 ) )
    {
        if ( lua_isboolean( L , -1 ) && ! lua_toboolean( L , -1 ) )
        {
            result = false;
        }

        lua_pop( L , 1 );
    }

    return result;
}

//.........................................................................

void ControllerDelegate::pointer_active()
{
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_pointer_active", 0, 0 );
}

//.........................................................................

void ControllerDelegate::pointer_inactive()
{
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_pointer_inactive", 0, 0 );
}

//.........................................................................

void ControllerDelegate::touch_down( int finger, int x, int y, unsigned long int modifiers )
{
    lua_pushnumber( L, finger );
    lua_pushnumber( L, x );
    lua_pushnumber( L, y );
    ClutterUtil::push_event_modifiers( L, modifiers );
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_touch_down", 4, 0 );
}

//.........................................................................

void ControllerDelegate::touch_move( int finger, int x, int y, unsigned long int modifiers )
{
    lua_pushnumber( L, finger );
    lua_pushnumber( L, x );
    lua_pushnumber( L, y );
    ClutterUtil::push_event_modifiers( L, modifiers );
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_touch_move", 4, 0 );
}

//.........................................................................

void ControllerDelegate::touch_up( int finger, int x, int y, unsigned long int modifiers )
{
    lua_pushnumber( L, finger );
    lua_pushnumber( L, x );
    lua_pushnumber( L, y );
    ClutterUtil::push_event_modifiers( L, modifiers );
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_touch_up", 4, 0 );
}

//.........................................................................

bool ControllerDelegate::scroll( int direction , unsigned long int modifiers )
{
    lua_pushnumber( L , direction );
    ClutterUtil::push_event_modifiers( L, modifiers );

    bool result = true;

    if ( lb_invoke_callbacks_r( L, this, "CONTROLLER_METATABLE", "on_scroll", 2, 1, 1 ) )
    {
        if ( lua_isboolean( L , -1 ) && ! lua_toboolean( L , -1 ) )
        {
            result = false;
        }

        lua_pop( L , 1 );
    }

    return result;
}

//.........................................................................

void ControllerDelegate::ui_event( const String& parameters )
{
    lua_pushstring( L, parameters.c_str() );
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_ui_event", 1, 0 );
}

//.........................................................................

void ControllerDelegate::submit_image( void* data, unsigned int size, const char* mime_type )
{
    Image* image = Image::decode( data, size, mime_type );

    if ( !image )
    {
        return;
    }

    lua_getglobal( L , "Bitmap" );
    lua_pushliteral( L , "" );
    lua_call( L , 1 , 1 );

    if ( Bitmap* bitmap = ( Bitmap* ) UserData::get_client( L , lua_gettop( L ) ) )
    {
        bitmap->set_image( image );

        lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_image", 1, 0 );
    }
    else
    {
        lua_pop( L , 1 );

        delete image;
    }
}

//.........................................................................

void ControllerDelegate::cancel_image( void )
{
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_image_cancelled", 0, 0 );
}

//.........................................................................

void ControllerDelegate::cancel_audio_clip( void )
{
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_audio_clip_cancelled", 0, 0 );
}

//.........................................................................

void ControllerDelegate::submit_audio_clip( void* data, unsigned int size, const char* mime_type )
{
}

//.........................................................................

bool ControllerDelegate::declare_resource( const String& name , const String& uri )
{
    if ( resource_group.empty() )
    {
        resource_group = App::get( L )->get_id();
    }

    return controller->declare_resource( name , uri , resource_group );
}

//.........................................................................

void ControllerDelegate::advanced_ui_ready( void )
{
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_advanced_ui_ready", 0, 0 );
}

//.........................................................................

void ControllerDelegate::advanced_ui_event( const char* json )
{
    JSON::parse( L , json );

    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_advanced_ui_event", 1, 0 );
}

//.........................................................................

void ControllerDelegate::streaming_video_connected( const char* address )
{
    lua_pushstring( L, address );
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_streaming_video_connected", 1, 0 );
}

//.........................................................................

void ControllerDelegate::streaming_video_failed( const char* address, const char* reason )
{
    lua_pushstring( L, address );
    lua_pushstring( L, reason );
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_streaming_video_failed", 2, 0 );
}

//.........................................................................

void ControllerDelegate::streaming_video_dropped( const char* address, const char* reason )
{
    lua_pushstring( L, address );
    lua_pushstring( L, reason );
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_streaming_video_dropped", 2, 0 );
}

//.........................................................................

void ControllerDelegate::streaming_video_ended( const char* address, const char* who )
{
    lua_pushstring( L, address );
    lua_pushstring( L, who );
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_streaming_video_ended", 2, 0 );
}

//.........................................................................

void ControllerDelegate::streaming_video_status( const char* status, const char* arg )
{
    lua_pushstring( L, status );
    lua_pushstring( L, arg );
    lb_invoke_callbacks( L, this, "CONTROLLER_METATABLE", "on_streaming_video_status", 2, 0 );
}


//=============================================================================

ControllerListDelegate::ControllerListDelegate( lua_State* l )
    :
    L( l )
{
    list = App::get( L )->get_context()->get_controller_list();
    list->add_delegate( this );
}

//.........................................................................

ControllerListDelegate::~ControllerListDelegate()
{
    list->remove_delegate( this );

    for ( ProxyMap::iterator it = proxies.begin(); it != proxies.end(); ++it )
    {
        UserData::Handle::destroy( it->second );
    }
}

//.........................................................................
// Delegate function

void ControllerListDelegate::connected( Controller* controller )
{
    ControllerDelegate* d = new ControllerDelegate( L, controller, this );

    lua_pushlightuserdata( L, d );

    new_Controller( L );

    lua_remove( L, -2 );

    // When a controller is connected, we create a handle to it - to keep the
    // Lua object around as long as it remains connected.

    proxies[ d ] = UserData::Handle::make( L , -1 );

    lb_invoke_callbacks( L, this, "CONTROLLERS_METATABLE", "on_controller_connected", 1, 0 );
}

//.........................................................................

void ControllerListDelegate::proxy_disconnected( ControllerDelegate* proxy )
{
    ProxyMap::iterator it = proxies.find( proxy );

    if ( it != proxies.end() )
    {
        UserData::Handle::destroy( it->second );

        proxies.erase( it );
    }
}

//.........................................................................

void ControllerListDelegate::push_connected()
{
    lua_newtable( L );

    // These exist as Lua objects, so we should be able to find instances
    // for all of them. However, the proxies may not be connected

    int i = 1;

    ControllerList::ControllerSet found;

    for ( ProxyMap::iterator it = proxies.begin(); it != proxies.end(); ++it )
    {
        if ( ! it->first->get_controller()->is_connected() )
        {
            continue;
        }

        UserData* ud = it->second->get_user_data();
        g_assert( ud );
        ud->push_proxy();

        lua_rawseti( L, -2, i++ );

        found.insert( it->first->get_controller() );
    }

    // These may not exist as Lua objects but they are definitely connected

    // This should not happen any more - since we hold on to the Lua objects as
    // soon as they connect.

    ControllerList::ControllerSet controllers( list->get_controllers() );

    for ( ControllerList::ControllerSet::iterator it = controllers.begin(); it != controllers.end(); ++it )
    {
        if ( found.find( *it ) != found.end() )
        {
            continue;
        }

        ControllerDelegate* d = new ControllerDelegate( L, *it, this );

        lua_pushlightuserdata( L, d );

        new_Controller( L );

        lua_remove( L, -2 );

        proxies[ d ] = UserData::Handle::make( L , -1 );

        lua_rawseti( L, -2, i++ );
    }
}

//.........................................................................

void ControllerListDelegate::start_pointer()
{
    ControllerList::ControllerSet controllers( list->get_controllers() );

    for ( ControllerList::ControllerSet::iterator it = controllers.begin();
            it != controllers.end(); ++it )
    {
        ( *it )->start_pointer();
    }
}
