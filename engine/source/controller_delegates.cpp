
#include "controller_delegates.h"

#include "context.h"
#include "bitmap.h"
#include "clutter_util.h"

//=============================================================================

extern int new_Controller( lua_State * );

extern int invoke_Controller_on_accelerometer( lua_State * , ControllerDelegate * , int , int );
extern int invoke_Controller_on_advanced_ui_event( lua_State * , ControllerDelegate * , int , int );
extern int invoke_Controller_on_advanced_ui_ready( lua_State * , ControllerDelegate * , int , int );
extern int invoke_Controller_on_audio_clip_cancelled( lua_State * , ControllerDelegate * , int , int );
extern int invoke_Controller_on_disconnected( lua_State * , ControllerDelegate * , int , int );
extern int invoke_Controller_on_image_cancelled( lua_State * , ControllerDelegate * , int , int );
extern int invoke_Controller_on_image( lua_State * , ControllerDelegate * , int , int );
extern int invoke_Controller_on_key_down( lua_State * , ControllerDelegate * , int , int );
extern int invoke_Controller_on_key_up( lua_State * , ControllerDelegate * , int , int );
extern int invoke_Controller_on_pointer_button_down( lua_State * , ControllerDelegate * , int , int );
extern int invoke_Controller_on_pointer_button_up( lua_State * , ControllerDelegate * , int , int );
extern int invoke_Controller_on_pointer_move( lua_State * , ControllerDelegate * , int , int );
extern int invoke_Controller_on_touch_down( lua_State * , ControllerDelegate * , int , int );
extern int invoke_Controller_on_touch_move( lua_State * , ControllerDelegate * , int , int );
extern int invoke_Controller_on_touch_up( lua_State * , ControllerDelegate * , int , int );
extern int invoke_Controller_on_ui_event( lua_State * , ControllerDelegate * , int , int );

extern int invoke_controllers_on_controller_connected( lua_State * , ControllerListDelegate * , int , int );

//=============================================================================

ControllerDelegate::ControllerDelegate(lua_State * _L,Controller * _controller,ControllerListDelegate * _list)
:
    L(_L),
    controller(_controller),
    list(_list)
{
    controller->ref();
    controller->add_delegate(this);
}

//.........................................................................

ControllerDelegate::~ControllerDelegate()
{
    if ( ! resource_group.empty() )
    {
        controller->drop_resource_group( resource_group );
    }

    controller->remove_delegate(this);
    controller->unref();
}

//.........................................................................
// Delegate functions

void ControllerDelegate::disconnected()
{
    invoke_Controller_on_disconnected(L,this,0,0);

    list->proxy_disconnected(this);
}

//.........................................................................

bool ControllerDelegate::key_down(unsigned int key_code,unsigned long int unicode,unsigned long int modifiers)
{
    lua_pushnumber(L,key_code);
    lua_pushnumber(L,unicode);
    ClutterUtil::push_event_modifiers(L,modifiers);

    bool result = true;

    if ( invoke_Controller_on_key_down(L,this,3,1) )
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

bool ControllerDelegate::key_up(unsigned int key_code,unsigned long int unicode,unsigned long int modifiers)
{
    lua_pushnumber(L,key_code);
    lua_pushnumber(L,unicode);
    ClutterUtil::push_event_modifiers(L,modifiers);

    bool result = true;

    if ( invoke_Controller_on_key_up(L,this,3,1) )
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

void ControllerDelegate::accelerometer(double x,double y,double z,unsigned long int modifiers)
{
    lua_pushnumber(L,x);
    lua_pushnumber(L,y);
    lua_pushnumber(L,z);
    ClutterUtil::push_event_modifiers(L,modifiers);
    invoke_Controller_on_accelerometer(L,this,4,0);
}

//.........................................................................

bool ControllerDelegate::pointer_move(int x,int y,unsigned long int modifiers)
{
    lua_pushnumber(L,x);
    lua_pushnumber(L,y);
    ClutterUtil::push_event_modifiers(L,modifiers);

    bool result = true;

    if ( invoke_Controller_on_pointer_move(L,this,3,1) )
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

bool ControllerDelegate::pointer_button_down(int button,int x,int y,unsigned long int modifiers)
{
    lua_pushnumber(L,button);
    lua_pushnumber(L,x);
    lua_pushnumber(L,y);
    ClutterUtil::push_event_modifiers(L,modifiers);

    bool result = true;

    if ( invoke_Controller_on_pointer_button_down(L,this,4,1) )
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

bool ControllerDelegate::pointer_button_up(int button,int x,int y,unsigned long int modifiers)
{
    lua_pushnumber(L,button);
    lua_pushnumber(L,x);
    lua_pushnumber(L,y);
    ClutterUtil::push_event_modifiers(L,modifiers);

    bool result = true;

    if ( invoke_Controller_on_pointer_button_up(L,this,4,1) )
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

void ControllerDelegate::touch_down(int finger,int x,int y,unsigned long int modifiers)
{
    lua_pushnumber(L,finger);
    lua_pushnumber(L,x);
    lua_pushnumber(L,y);
    ClutterUtil::push_event_modifiers(L,modifiers);
    invoke_Controller_on_touch_down(L,this,4,0);
}

//.........................................................................

void ControllerDelegate::touch_move(int finger, int x,int y,unsigned long int modifiers)
{
    lua_pushnumber(L,finger);
    lua_pushnumber(L,x);
    lua_pushnumber(L,y);
    ClutterUtil::push_event_modifiers(L,modifiers);
    invoke_Controller_on_touch_move(L,this,4,0);
}

//.........................................................................

void ControllerDelegate::touch_up(int finger, int x,int y,unsigned long int modifiers)
{
    lua_pushnumber(L,finger);
    lua_pushnumber(L,x);
    lua_pushnumber(L,y);
    ClutterUtil::push_event_modifiers(L,modifiers);
    invoke_Controller_on_touch_up(L,this,4,0);
}

//.........................................................................

void ControllerDelegate::ui_event(const String & parameters)
{
    lua_pushstring(L,parameters.c_str());
    invoke_Controller_on_ui_event(L,this,1,0);
}

//.........................................................................

void ControllerDelegate::submit_image( void * data, unsigned int size, const char * mime_type )
{
    Image * image = Image::decode(data, size, mime_type);

    if ( !image )
    {
        return;
    }

    lua_getglobal( L , "Bitmap" );
    lua_pushliteral( L , "" );
    lua_call( L , 1 , 1 );

    if ( Bitmap * bitmap = ( Bitmap * ) UserData::get_client( L , lua_gettop( L ) ) )
    {
        bitmap->set_image( image );

        invoke_Controller_on_image( L , this , 1 , 0 );
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
	invoke_Controller_on_image_cancelled( L, this, 0, 0 );
}

//.........................................................................

void ControllerDelegate::cancel_audio_clip( void )
{
	invoke_Controller_on_audio_clip_cancelled( L, this, 0, 0 );
}

//.........................................................................

void ControllerDelegate::submit_audio_clip( void * data, unsigned int size, const char * mime_type )
{
}

//.........................................................................

bool ControllerDelegate::declare_resource( const String & name , const String & uri )
{
    if ( resource_group.empty() )
    {
        resource_group = App::get(L)->get_id();
    }

    return controller->declare_resource( name , uri , resource_group );
}

//.........................................................................

void ControllerDelegate::advanced_ui_ready( void )
{
    invoke_Controller_on_advanced_ui_ready( L, this, 0, 0 );
}

//.........................................................................

void ControllerDelegate::advanced_ui_event( const char * json )
{
    JSON::parse( L , json );

    invoke_Controller_on_advanced_ui_event( L , this , 1 , 0 );
}

//=============================================================================

ControllerListDelegate::ControllerListDelegate(lua_State * l)
:
    L(l)
{
    list=App::get(L)->get_context()->get_controller_list();
    list->add_delegate(this);
}

//.........................................................................

ControllerListDelegate::~ControllerListDelegate()
{
    list->remove_delegate(this);

    for ( ProxyMap::iterator it = proxies.begin(); it != proxies.end(); ++it )
    {
    	UserData::Handle::destroy( it->second );
    }
}

//.........................................................................
// Delegate function

void ControllerListDelegate::connected(Controller * controller)
{
    ControllerDelegate * d=new ControllerDelegate(L,controller,this);

    lua_pushlightuserdata(L,d);

    new_Controller(L);

    lua_remove(L,-2);

	// When a controller is connected, we create a handle to it - to keep the
	// Lua object around as long as it remains connected.

	proxies[ d ] = UserData::Handle::make( L , -1 );

    invoke_controllers_on_controller_connected(L,this,1,0);
}

//.........................................................................

void ControllerListDelegate::proxy_disconnected(ControllerDelegate * proxy)
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
    lua_newtable(L);

    // These exist as Lua objects, so we should be able to find instances
    // for all of them. However, the proxies may not be connected

    int i=1;

    ControllerList::ControllerSet found;

    for(ProxyMap::iterator it=proxies.begin();it!=proxies.end();++it)
    {
        if (! it->first->get_controller()->is_connected())
            continue;

        UserData * ud = it->second->get_user_data();
        g_assert( ud );
        ud->push_proxy();

        lua_rawseti(L,-2,i++);

        found.insert(it->first->get_controller());
    }

    // These may not exist as Lua objects but they are definitely connected

    // This should not happen any more - since we hold on to the Lua objects as
    // soon as they connect.

    ControllerList::ControllerSet controllers(list->get_controllers());

    for(ControllerList::ControllerSet::iterator it=controllers.begin();it!=controllers.end();++it)
    {
        if (found.find(*it)!=found.end())
        {
            continue;
        }

        ControllerDelegate * d=new ControllerDelegate(L,*it,this);

        lua_pushlightuserdata(L,d);

        new_Controller(L);

        lua_remove(L,-2);

        proxies[ d ] = UserData::Handle::make( L , -1 );

        lua_rawseti(L,-2,i++);
    }
}

//.........................................................................

void ControllerListDelegate::start_pointer()
{
    ControllerList::ControllerSet controllers(list->get_controllers());

    for(ControllerList::ControllerSet::iterator it=controllers.begin();
        it!=controllers.end();++it)
    {
        (*it)->start_pointer();
    }
}

