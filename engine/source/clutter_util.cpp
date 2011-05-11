#include <cstring>
#include <string>
#include <cstdlib>

#include "clutter_util.h"
#include "lb.h"

#define abs_index(L, i) ((i) > 0 || (i) <= LUA_REGISTRYINDEX ? (i) : lua_gettop(L) + (i) + 1)


//.............................................................................

ClutterActor * ClutterUtil::make_actor( ClutterActor * ( constructor )() )
{
    return CLUTTER_ACTOR( g_object_ref( g_object_ref_sink( G_OBJECT( constructor() ) ) ) );
}

//.............................................................................

void ClutterUtil::push_clutter_color( lua_State * L, ClutterColor * color )
{
    LSG;

    lua_newtable( L );
    lua_pushnumber( L, color->red );
    lua_rawseti( L, -2, 1 );
    lua_pushnumber( L, color->green );
    lua_rawseti( L, -2, 2 );
    lua_pushnumber( L, color->blue );
    lua_rawseti( L, -2, 3 );
    lua_pushnumber( L, color->alpha );
    lua_rawseti( L, -2, 4 );

    (void)LSG_END( 1 );
}

//.............................................................................

ClutterColor ClutterUtil::string_to_color( const char * s )
{
    ClutterColor result = { 0 , 0 , 0 , 0 };

    if ( s )
    {
        int colors[4] = {0, 0, 0, 255};
        char buffer[3] = {0, 0, 0};

        if ( *s == '#' )
        {
            ++s;
        }

        int len = strlen( s );
        int i = 0;

        while ( len >= 2 )
        {
            buffer[0] = *( s++ );
            buffer[1] = *( s++ );

            sscanf( buffer, "%x", &colors[i] );

            if ( colors[i] < 0 )
            {
                colors[i] = 0;
            }
            else if ( colors[i] > 255 )
            {
                colors[i] = 255;
            }

            len -= 2;
            i++;
        }

        result.red   = colors[0];
        result.green = colors[1];
        result.blue  = colors[2];
        result.alpha = colors[3];
    }

    return result;
}

//.............................................................................

void ClutterUtil::to_clutter_color( lua_State * L, int index, ClutterColor * color )
{
    LSG;

	index = abs_index(L, index);

    if ( lua_istable( L, index ) )
    {
        lua_rawgeti( L, index, 1 );
        lua_rawgeti( L, index, 2 );
        lua_rawgeti( L, index, 3 );
        lua_rawgeti( L, index, 4 );
        color->red = luaL_optint( L, -4, 0 );
        color->green = luaL_optint( L, -3, 0 );
        color->blue = luaL_optint( L, -2, 0 );
        color->alpha = luaL_optint( L, -1, 255 );
        lua_pop( L, 4 );
    }
    else if ( lua_isstring( L, index ) )
    {
        * color = string_to_color( lua_tostring( L, index ) );
    }
    else
    {
        luaL_error( L, "Expecting a color as a table or a string" );
    }

    LSG_END( 0 );
}

//.............................................................................

gulong ClutterUtil::to_clutter_animation_mode( const char * mode )
{
    if ( !mode )
    {
        return CLUTTER_LINEAR;
    }

    gulong result = CLUTTER_LINEAR;

    GEnumClass * ec = G_ENUM_CLASS( g_type_class_ref( CLUTTER_TYPE_ANIMATION_MODE ) );
    gchar * cm = g_strdup_printf( "CLUTTER_%s", mode );
    GEnumValue * v = g_enum_get_value_by_name( ec, cm );
    g_free( cm );

    if ( v )
    {
        result = v->value;
    }

    g_type_class_unref( ec );

    return result;
}

//.............................................................................

ClutterActor * ClutterUtil::user_data_to_actor( lua_State * L, int n )
{
    if ( ! lb_check_udata_type( L , n , "actor" , false ) )
    {
        luaL_where( L , 1 );
        g_warning( "%s : NOT A UI ELEMENT" , lua_tostring( L , -1 ) );
        lua_pop( L , 1 );
        return NULL;
    }

    UserData * ud = UserData::get( L , n );

    if ( ! ud )
    {
        return NULL;
    }

    GObject * obj = ud->get_master();

    return CLUTTER_IS_ACTOR( obj ) ? CLUTTER_ACTOR( obj ) : NULL;
}

//.............................................................................

ClutterTimeline * ClutterUtil::user_data_to_timeline( lua_State * L, int n )
{
    if ( ! lb_check_udata_type( L , n , "Timeline" , false ) )
    {
        luaL_where( L , 1 );
        lua_pop( L , 1 );
        return NULL;
    }

    UserData * ud = UserData::get( L , n );

    if ( ! ud )
    {
        return NULL;
    }

    GObject * obj = ud->get_master();

    return CLUTTER_IS_TIMELINE( obj ) ? CLUTTER_TIMELINE( obj ) : NULL;
}

//.............................................................................

ClutterAnimator * ClutterUtil::user_data_to_animator( lua_State * L, int n )
{
    if ( ! lb_check_udata_type( L , n , "Animator" , false ) )
    {
        luaL_where( L , 1 );
        lua_pop( L , 1 );
        return NULL;
    }

    UserData * ud = UserData::get( L , n );

    if ( ! ud )
    {
        return NULL;
    }

    GObject * obj = ud->get_master();

    return CLUTTER_IS_ANIMATOR( obj ) ? CLUTTER_ANIMATOR( obj ) : NULL;
}

//.............................................................................

void ClutterUtil::set_props_from_table( lua_State * L, int table )
{
    LSG;

    if ( table )
    {
        if ( table == lua_gettop( L ) )
        {
            lb_set_props_from_table( L );
        }
        else
        {
            lua_pushvalue( L, table );
            lb_set_props_from_table( L );
            lua_pop( L, 1 );
        }
    }

    LSG_END( 0 );
}

//.............................................................................

// We want all actors to have a listener on their opacity property.  When opacity goes to 0,
// the object should automatically hide(); when opacity stops being 0, unless hide() has been called manually,
// it should show() itself

void ClutterUtil::actor_opacity_notify( GObject * , GParamSpec * , ClutterActor * self )
{
    unsigned opacity = clutter_actor_get_opacity(self);

    if(opacity == 0)
    {
        if(CLUTTER_ACTOR_IS_VISIBLE(self))
        {
//            g_debug("Opacity is 0 so hiding %p (%s)", self, clutter_actor_get_name(self));
            clutter_actor_hide(self);
        }
    } else {
        if(!CLUTTER_ACTOR_IS_VISIBLE(self))
        {
//            g_debug("Opacity is not 0 so showing %p (%s)", self, clutter_actor_get_name(self));
            clutter_actor_show(self);
        }
    }
}

void ClutterUtil::actor_on_show(ClutterActor*actor,void*)
{
	if( clutter_actor_get_opacity( actor ) == 0 )
	{
//        g_debug("Opacity is 0 so reversing show of %p (%s)", actor, clutter_actor_get_name(actor));
	    clutter_actor_hide( actor );
	}
}

void ClutterUtil::actor_on_hide(ClutterActor*actor,void*)
{
}


void ClutterUtil::initialize_actor( lua_State * L, ClutterActor * actor, const char * metatable )
{
    // Metatables are static, so we don't need to free it
    g_object_set_data( G_OBJECT( actor ), "tp-metatable", ( gpointer )metatable );

#if 0
    g_signal_connect( G_OBJECT(actor), "notify::opacity", (GCallback)actor_opacity_notify, actor );
    g_signal_connect( G_OBJECT(actor), "show", (GCallback)actor_on_show, actor );
    g_signal_connect( G_OBJECT(actor), "hide", (GCallback)actor_on_hide, actor );
#endif

}

//.............................................................................

const char * ClutterUtil::get_actor_metatable( ClutterActor * actor )
{
    if ( !actor )
    {
        return NULL;
    }

    return ( const char * )g_object_get_data( G_OBJECT( actor ), "tp-metatable" );
}

//.............................................................................

void ClutterUtil::wrap_concrete_actor( lua_State * L, ClutterActor * actor )
{
    if ( ! actor )
    {
        lua_pushnil( L );
    }
    else if ( UserData * ud = UserData::get( G_OBJECT( actor ) ) )
    {
        ud->push_proxy();
    }
    else
    {
        lua_pushnil( L );
    }
}

//-----------------------------------------------------------------------------

void ClutterUtil::wrap_timeline( lua_State * L , ClutterTimeline * timeline )
{
    if ( ! timeline )
    {
        lua_pushnil( L );
        return;
    }

    if ( UserData * ud = UserData::get( G_OBJECT( timeline ) ) )
    {
        ud->push_proxy();
        if ( ! lua_isnil( L , -1 ) )
        {
            return;
        }
        lua_pop( L , 1 );
    }

    UserData * ud = UserData::make( L , "Timeline" );
    g_object_ref( G_OBJECT( timeline ) );
    ud->initialize_with_master( timeline );
    ud->check_initialized();
    luaL_getmetatable( L , "TIMELINE_METATABLE" );
    if ( lua_isnil( L , -1 ) )
    {
        lua_getglobal( L , "Timeline" );
        lua_pop( L , 2 );
        luaL_getmetatable( L , "TIMELINE_METATABLE" );
    }
    lua_setmetatable( L , -2 );
}

//-----------------------------------------------------------------------------

#ifdef TP_CLUTTER_BACKEND_EGL

static gboolean event_pump( gpointer )
{
    while ( ClutterEvent * event = clutter_event_get() )
    {
        clutter_do_event ( event );
        clutter_event_free ( event );
    }

    return FALSE;
}

#endif


void ClutterUtil::inject_key_down( guint key_code, gunichar unicode )
{
    clutter_threads_enter();

    ClutterEvent * event = clutter_event_new( CLUTTER_KEY_PRESS );
    event->any.stage = CLUTTER_STAGE( clutter_stage_get_default() );
    event->any.time = timestamp();
    event->any.flags = CLUTTER_EVENT_FLAG_SYNTHETIC;
    event->key.keyval = key_code;
    event->key.unicode_value = unicode;

    clutter_event_put( event );

    clutter_event_free( event );

    clutter_threads_leave();

#ifdef TP_CLUTTER_BACKEND_EGL

    // In the EGL backend, there is nothing pulling the events from
    // the event queue, so we force that by adding an idle source

    g_idle_add_full( TRICKPLAY_PRIORITY , event_pump, NULL, NULL );

#endif
}

void ClutterUtil::inject_key_up( guint key_code, gunichar unicode )
{
    clutter_threads_enter();

    ClutterEvent * event = clutter_event_new( CLUTTER_KEY_RELEASE );
    event->any.stage = CLUTTER_STAGE( clutter_stage_get_default() );
    event->any.time = timestamp();
    event->any.flags = CLUTTER_EVENT_FLAG_SYNTHETIC;
    event->key.keyval = key_code;
    event->key.unicode_value = unicode;

    clutter_event_put( event );

    clutter_event_free( event );

    clutter_threads_leave();

#ifdef TP_CLUTTER_BACKEND_EGL

    // In the EGL backend, there is nothing pulling the events from
    // the event queue, so we force that by adding an idle source

    g_idle_add_full( TRICKPLAY_PRIORITY , event_pump, NULL, NULL );

#endif
}

void ClutterUtil::inject_motion( gfloat x , gfloat y )
{
    clutter_threads_enter();

    ClutterEvent * event = clutter_event_new( CLUTTER_MOTION );
    event->any.stage = CLUTTER_STAGE( clutter_stage_get_default() );
    event->any.time = timestamp();
    event->any.flags = CLUTTER_EVENT_FLAG_SYNTHETIC;
    event->motion.x = x;
    event->motion.y = y;

    clutter_event_put( event );

    clutter_event_free( event );

    clutter_threads_leave();

#ifdef TP_CLUTTER_BACKEND_EGL

    // In the EGL backend, there is nothing pulling the events from
    // the event queue, so we force that by adding an idle source

    g_idle_add_full( TRICKPLAY_PRIORITY , event_pump, NULL, NULL );

#endif
}

void ClutterUtil::inject_button_press( guint32 button , gfloat x , gfloat y )
{
    clutter_threads_enter();

    ClutterEvent * event = clutter_event_new( CLUTTER_BUTTON_PRESS );
    event->any.stage = CLUTTER_STAGE( clutter_stage_get_default() );
    event->any.time = timestamp();
    event->any.flags = CLUTTER_EVENT_FLAG_SYNTHETIC;
    event->button.button = button;
    event->button.x = x;
    event->button.y = y;

    clutter_event_put( event );

    clutter_event_free( event );

    clutter_threads_leave();

#ifdef TP_CLUTTER_BACKEND_EGL

    // In the EGL backend, there is nothing pulling the events from
    // the event queue, so we force that by adding an idle source

    g_idle_add_full( TRICKPLAY_PRIORITY , event_pump, NULL, NULL );

#endif
}

void ClutterUtil::inject_button_release( guint32 button , gfloat x , gfloat y )
{
    clutter_threads_enter();

    ClutterEvent * event = clutter_event_new( CLUTTER_BUTTON_RELEASE );
    event->any.stage = CLUTTER_STAGE( clutter_stage_get_default() );
    event->any.time = timestamp();
    event->any.flags = CLUTTER_EVENT_FLAG_SYNTHETIC;
    event->button.button = button;
    event->button.x = x;
    event->button.y = y;

    clutter_event_put( event );

    clutter_event_free( event );

    clutter_threads_leave();

#ifdef TP_CLUTTER_BACKEND_EGL

    // In the EGL backend, there is nothing pulling the events from
    // the event queue, so we force that by adding an idle source

    g_idle_add_full( TRICKPLAY_PRIORITY , event_pump, NULL, NULL );

#endif
}

void ClutterUtil::stage_coordinates_to_screen_coordinates( gdouble *x, gdouble *y )
{
    ClutterContainer *stage = (ClutterContainer*)clutter_stage_get_default();

    if ( ClutterActor * screen = clutter_container_find_child_by_name(stage, "screen") )
    {
        gdouble scale_x, scale_y;

        clutter_actor_get_scale(screen, &scale_x, &scale_y);

        *x /= scale_x;
        *y /= scale_y;
    }
}


//-----------------------------------------------------------------------------
