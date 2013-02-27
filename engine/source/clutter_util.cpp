#include <cstring>
#include <string>
#include <cstdlib>

#include "clutter_util.h"
#include "lb.h"
#include "profiler.h"
#include "trickplay/controller.h"

#include "clutter_actor.lb.h"
#include "clutter_timeline.lb.h"
#include "clutter_animator.lb.h"
#include "clutter_constraint.lb.h"

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
    	if ( clutter_color_from_string( & result , s ) )
    	{
    		return result;
    	}

        int colors[4] = {0, 0, 0, 255};
        char buffer[3] = {0, 0, 0};

        if ( *s == '#' )
        {
            ++s;
        }

        int len = strlen( s );
        int i = 0;

        while ( len >= 2 && i < 4 )
        {
            buffer[0] = *( s++ );
            buffer[1] = *( s++ );

            if ( 1 != sscanf( buffer, "%x", &colors[i] ) )
            {
            	break;
            }

			if ( colors[i] < 0 )
			{
				colors[i] = 0;
			}
			else if ( colors[i] > 255 )
			{
				colors[i] = 255;
			}

            len -= 2;
            ++i;
        }

        result.red   = colors[0];
        result.green = colors[1];
        result.blue  = colors[2];
        result.alpha = colors[3];
    }

    return result;
}

//.............................................................................

void ClutterUtil::to_clutter_geometry( lua_State * L, int index, ClutterGeometry * geometry )
{
    LSG;

	index = abs_index(L, index);

    if ( lua_istable( L, index ) )
    {
        lua_rawgeti( L, index, 1 );
        lua_rawgeti( L, index, 2 );
        lua_rawgeti( L, index, 3 );
        lua_rawgeti( L, index, 4 );
        geometry->x = luaL_optint( L, -4, 0 );
        geometry->y = luaL_optint( L, -3, 0 );
        geometry->width = luaL_optint( L, -2, 0 );
        geometry->height = luaL_optint( L, -1, 0 );
        lua_pop( L, 4 );
    }
    else
    {
        luaL_error( L, "Expecting a clip as a table" );
    }

    LSG_END( 0 );
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
	ClutterActor * result = LB_GET_ACTOR( L , n );

    if ( ! result )
    {
        luaL_where( L , 1 );
        g_warning( "%s : NOT A UI ELEMENT" , lua_tostring( L , -1 ) );
        lua_pop( L , 1 );
        return 0;
    }

    return CLUTTER_IS_ACTOR( result ) ? result : 0;
}

//.............................................................................

ClutterTimeline * ClutterUtil::user_data_to_timeline( lua_State * L, int n )
{
	ClutterTimeline * result = LB_GET_TIMELINE( L , n );

    if ( ! result )
    {
        luaL_where( L , 1 );
        g_warning( "%s : NOT A TIMELINE" , lua_tostring( L , -1 ) );
        lua_pop( L , 1 );
        return 0;
    }

    return CLUTTER_IS_TIMELINE( result ) ? result : 0;
}

//.............................................................................

ClutterAnimator * ClutterUtil::user_data_to_animator( lua_State * L, int n )
{
	ClutterAnimator * result = LB_GET_ANIMATOR( L , n );

    if ( ! result )
    {
        luaL_where( L , 1 );
        g_warning( "%s : NOT AN ANIMATOR" , lua_tostring( L , -1 ) );
        lua_pop( L , 1 );
        return NULL;
    }

    return CLUTTER_IS_ANIMATOR( result ) ? result : 0;
}

//.............................................................................

ClutterConstraint * ClutterUtil::user_data_to_constraint( lua_State * L , int n )
{
	ClutterConstraint * result = LB_GET_CONSTRAINT( L , n );

    if ( ! result )
    {
        luaL_where( L , 1 );
        g_warning( "%s : NOT A CONSTRAINT" , lua_tostring( L , -1 ) );
        lua_pop( L , 1 );
        return NULL;
    }

    return CLUTTER_IS_CONSTRAINT( result ) ? result : 0;
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

const gchar * ClutterUtil::get_actor_type( ClutterActor * actor )
{
    g_assert( actor );

    const gchar *metatable = get_actor_metatable( actor );
    static gchar the_type[64];
    if( metatable )
    {
        const gchar *end = g_strstr_len( metatable, -1, "_METATABLE" );
        g_assert( end );

        const gchar *cursor = metatable;
        gsize len = 0;
        // First letter caps, rest lower case
        the_type[len++] = g_ascii_toupper(*(cursor++));
        while(cursor < end && len < sizeof(the_type))
        {
            the_type[len++] = g_ascii_tolower(*(cursor++));
        }
        the_type[len] = '\0';

        return the_type;
    }
    else
    {
        const gchar *type = g_type_name( G_TYPE_FROM_INSTANCE( actor ) );
	    if ( g_str_has_prefix( type, "Clutter" ) )
	    {
	        type += 7;
	    }

	    return type;
    }
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

void ClutterUtil::wrap_constraint( lua_State * L , ClutterConstraint * constraint )
{
    if ( ! constraint )
    {
        lua_pushnil( L );
    }
    else if ( UserData * ud = UserData::get( G_OBJECT( constraint ) ) )
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
    PROFILER_CREATED("Timeline",timeline);
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

static ClutterModifierType to_clutter_modifier( unsigned long int modifiers )
{
	unsigned long int result = 0;

	if ( modifiers & TP_CONTROLLER_MODIFIER_SHIFT )
	{
		result |= CLUTTER_SHIFT_MASK;
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_LOCK )
	{
		result |= CLUTTER_LOCK_MASK;
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_CONTROL )
	{
		result |= CLUTTER_CONTROL_MASK;
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_SUPER )
	{
		result |= CLUTTER_SUPER_MASK;
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_HYPER )
	{
		result |= CLUTTER_HYPER_MASK;
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_META )
	{
		result |= CLUTTER_META_MASK;
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_1 )
	{
		result |= CLUTTER_MOD1_MASK;
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_2 )
	{
		result |= CLUTTER_MOD2_MASK;
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_3 )
	{
		result |= CLUTTER_MOD3_MASK;
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_4 )
	{
		result |= CLUTTER_MOD4_MASK;
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_5 )
	{
		result |= CLUTTER_MOD5_MASK;
	}

	return ClutterModifierType( result );
}

void ClutterUtil::inject_key_down( ClutterActor *stage, guint key_code, gunichar unicode , unsigned long int modifiers )
{
    clutter_threads_enter();

    ClutterEvent * event = clutter_event_new( CLUTTER_KEY_PRESS );
    event->any.stage = CLUTTER_STAGE( stage );
    event->any.time = timestamp();
    event->any.flags = CLUTTER_EVENT_FLAG_SYNTHETIC;
    event->key.keyval = key_code;
    event->key.unicode_value = unicode;
    event->key.modifier_state = to_clutter_modifier( modifiers );

    clutter_event_put( event );

    clutter_event_free( event );

    clutter_threads_leave();

#ifdef TP_CLUTTER_BACKEND_EGL

    // In the EGL backend, there is nothing pulling the events from
    // the event queue, so we force that by adding an idle source

    g_idle_add_full( TRICKPLAY_PRIORITY , event_pump, NULL, NULL );

#endif
}

void ClutterUtil::inject_key_up( ClutterActor *stage, guint key_code, gunichar unicode , unsigned long int modifiers )
{
    clutter_threads_enter();

    ClutterEvent * event = clutter_event_new( CLUTTER_KEY_RELEASE );
    event->any.stage = CLUTTER_STAGE( stage );
    event->any.time = timestamp();
    event->any.flags = CLUTTER_EVENT_FLAG_SYNTHETIC;
    event->key.keyval = key_code;
    event->key.unicode_value = unicode;
    event->key.modifier_state = to_clutter_modifier( modifiers );

    clutter_event_put( event );

    clutter_event_free( event );

    clutter_threads_leave();

#ifdef TP_CLUTTER_BACKEND_EGL

    // In the EGL backend, there is nothing pulling the events from
    // the event queue, so we force that by adding an idle source

    g_idle_add_full( TRICKPLAY_PRIORITY , event_pump, NULL, NULL );

#endif
}

void ClutterUtil::inject_motion( ClutterActor *stage, gfloat x , gfloat y , unsigned long int modifiers )
{
    clutter_threads_enter();

    ClutterEvent * event = clutter_event_new( CLUTTER_MOTION );
    event->any.stage = CLUTTER_STAGE( stage );
    event->any.time = timestamp();
    event->any.flags = CLUTTER_EVENT_FLAG_SYNTHETIC;
    event->motion.x = x;
    event->motion.y = y;
    event->motion.modifier_state = to_clutter_modifier( modifiers );

    clutter_event_put( event );

    clutter_event_free( event );

    clutter_threads_leave();

#ifdef TP_CLUTTER_BACKEND_EGL

    // In the EGL backend, there is nothing pulling the events from
    // the event queue, so we force that by adding an idle source

    g_idle_add_full( TRICKPLAY_PRIORITY , event_pump, NULL, NULL );

#endif
}

void ClutterUtil::inject_button_press( ClutterActor *stage, guint32 button , gfloat x , gfloat y , unsigned long int modifiers )
{
    clutter_threads_enter();

    ClutterEvent * event = clutter_event_new( CLUTTER_BUTTON_PRESS );
    event->any.stage = CLUTTER_STAGE( stage );
    event->any.time = timestamp();
    event->any.flags = CLUTTER_EVENT_FLAG_SYNTHETIC;
    event->button.button = button;
    event->button.x = x;
    event->button.y = y;
    event->button.modifier_state = to_clutter_modifier( modifiers );

    clutter_event_put( event );

    clutter_event_free( event );

    clutter_threads_leave();

#ifdef TP_CLUTTER_BACKEND_EGL

    // In the EGL backend, there is nothing pulling the events from
    // the event queue, so we force that by adding an idle source

    g_idle_add_full( TRICKPLAY_PRIORITY , event_pump, NULL, NULL );

#endif
}

void ClutterUtil::inject_button_release( ClutterActor *stage, guint32 button , gfloat x , gfloat y , unsigned long int modifiers )
{
    clutter_threads_enter();

    ClutterEvent * event = clutter_event_new( CLUTTER_BUTTON_RELEASE );
    event->any.stage = CLUTTER_STAGE( stage );
    event->any.time = timestamp();
    event->any.flags = CLUTTER_EVENT_FLAG_SYNTHETIC;
    event->button.button = button;
    event->button.x = x;
    event->button.y = y;
    event->button.modifier_state = to_clutter_modifier( modifiers );

    clutter_event_put( event );

    clutter_event_free( event );

    clutter_threads_leave();

#ifdef TP_CLUTTER_BACKEND_EGL

    // In the EGL backend, there is nothing pulling the events from
    // the event queue, so we force that by adding an idle source

    g_idle_add_full( TRICKPLAY_PRIORITY , event_pump, NULL, NULL );

#endif
}

void ClutterUtil::inject_scroll( ClutterActor *stage, int direction , unsigned long int modifiers )
{
    clutter_threads_enter();

    ClutterEvent * event = clutter_event_new( CLUTTER_SCROLL );
    event->any.stage = CLUTTER_STAGE( stage );
    event->any.time = timestamp();
    event->any.flags = CLUTTER_EVENT_FLAG_SYNTHETIC;
    event->scroll.modifier_state = to_clutter_modifier( modifiers );

    switch( direction )
    {
    case TP_CONTROLLER_SCROLL_UP:		event->scroll.direction = CLUTTER_SCROLL_UP; break;
    case TP_CONTROLLER_SCROLL_DOWN:		event->scroll.direction = CLUTTER_SCROLL_DOWN; break;
    case TP_CONTROLLER_SCROLL_LEFT:		event->scroll.direction = CLUTTER_SCROLL_LEFT; break;
    case TP_CONTROLLER_SCROLL_RIGHT:	event->scroll.direction = CLUTTER_SCROLL_RIGHT; break;
    default:
    	clutter_event_free( event );
    	clutter_threads_leave();
    	return;
    }

    clutter_event_put( event );

    clutter_event_free( event );

    clutter_threads_leave();

#ifdef TP_CLUTTER_BACKEND_EGL

    // In the EGL backend, there is nothing pulling the events from
    // the event queue, so we force that by adding an idle source

    g_idle_add_full( TRICKPLAY_PRIORITY , event_pump, NULL, NULL );

#endif
}

void ClutterUtil::stage_coordinates_to_screen_coordinates( ClutterActor *stage, gdouble *x, gdouble *y )
{

    if ( ClutterActor * screen = clutter_container_find_child_by_name( CLUTTER_CONTAINER( stage ), "screen") )
    {
        gdouble scale_x, scale_y;

        clutter_actor_get_scale(screen, &scale_x, &scale_y);

        *x /= scale_x;
        *y /= scale_y;
    }
}

unsigned long int ClutterUtil::get_tp_modifiers( ClutterEvent * event )
{
	unsigned long int result = TP_CONTROLLER_MODIFIER_NONE;

	ClutterModifierType cm = clutter_event_get_state( event );

	if ( cm & CLUTTER_SHIFT_MASK )
	{
		result |= TP_CONTROLLER_MODIFIER_SHIFT;
	}
	if ( cm & CLUTTER_LOCK_MASK )
	{
		result |= TP_CONTROLLER_MODIFIER_LOCK;
	}
	if ( cm & CLUTTER_CONTROL_MASK )
	{
		result |= TP_CONTROLLER_MODIFIER_CONTROL;
	}
	if ( cm & CLUTTER_SUPER_MASK )
	{
		result |= TP_CONTROLLER_MODIFIER_SUPER;
	}
	if ( cm & CLUTTER_HYPER_MASK )
	{
		result |= TP_CONTROLLER_MODIFIER_HYPER;
	}
	if ( cm & CLUTTER_META_MASK )
	{
		result |= TP_CONTROLLER_MODIFIER_META;
	}

	if ( cm & CLUTTER_MOD1_MASK )
	{
		result |= TP_CONTROLLER_MODIFIER_1;
	}
	if ( cm & CLUTTER_MOD2_MASK )
	{
		result |= TP_CONTROLLER_MODIFIER_2;
	}
	if ( cm & CLUTTER_MOD3_MASK )
	{
		result |= TP_CONTROLLER_MODIFIER_3;
	}
	if ( cm & CLUTTER_MOD4_MASK )
	{
		result |= TP_CONTROLLER_MODIFIER_4;
	}
	if ( cm & CLUTTER_MOD5_MASK )
	{
		result |= TP_CONTROLLER_MODIFIER_5;
	}

	return result;
}

void ClutterUtil::push_event_modifiers( lua_State * L , ClutterEvent * event )
{
	push_event_modifiers( L , get_tp_modifiers( event ) );
}

void ClutterUtil::push_event_modifiers( lua_State * L , unsigned long int modifiers )
{
	if ( ! modifiers )
	{
		lua_pushnil( L );
		return;
	}

	lua_newtable( L );

	int t = lua_gettop( L );

	if ( modifiers & TP_CONTROLLER_MODIFIER_SHIFT )
	{
		lua_pushliteral( L , "shift" );
		lua_pushboolean( L , true );
		lua_rawset( L , t );
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_LOCK )
	{
		lua_pushliteral( L , "lock" );
		lua_pushboolean( L , true );
		lua_rawset( L , t );
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_CONTROL )
	{
		lua_pushliteral( L , "control" );
		lua_pushboolean( L , true );
		lua_rawset( L , t );
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_SUPER )
	{
		lua_pushliteral( L , "super" );
		lua_pushboolean( L , true );
		lua_rawset( L , t );
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_HYPER )
	{
		lua_pushliteral( L , "hyper" );
		lua_pushboolean( L , true );
		lua_rawset( L , t );
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_META )
	{
		lua_pushliteral( L , "meta" );
		lua_pushboolean( L , true );
		lua_rawset( L , t );
	}

	if ( modifiers & TP_CONTROLLER_MODIFIER_1 )
	{
		lua_pushliteral( L , "mod1" );
		lua_pushboolean( L , true );
		lua_rawset( L , t );
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_2 )
	{
		lua_pushliteral( L , "mod2" );
		lua_pushboolean( L , true );
		lua_rawset( L , t );
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_3 )
	{
		lua_pushliteral( L , "mod3" );
		lua_pushboolean( L , true );
		lua_rawset( L , t );
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_4 )
	{
		lua_pushliteral( L , "mod4" );
		lua_pushboolean( L , true );
		lua_rawset( L , t );
	}
	if ( modifiers & TP_CONTROLLER_MODIFIER_5 )
	{
		lua_pushliteral( L , "mod5" );
		lua_pushboolean( L , true );
		lua_rawset( L , t );
	}

}

//-----------------------------------------------------------------------------

bool ClutterUtil::is_qualified_child( ClutterActor * container , ClutterActor* actor )
{
    if(actor)
	{
        if ( ClutterActor * parent = clutter_actor_get_parent( actor ) )
        {
            g_warning( "TRYING TO ADD ELEMENT %p TO CONTAINER %p BUT IT ALREADY HAS PARENT %p" , actor , container , parent );
            return false;
        }
        else
        {
            /* check if source is not already a parent or ancestor of the self */
            ClutterActor* ancestor = clutter_actor_get_parent( container );
            if ( CLUTTER_IS_CONTAINER( actor ) && ancestor != NULL )
            {
                while ( ancestor != NULL && ancestor != actor )
                {
                    ancestor = clutter_actor_get_parent( ancestor );
                }
                if ( ancestor != NULL )
                {
                    g_warning( "TRYING TO ADD ELEMENT %p TO CONTAINER %p BUT IT IS ALREADY A PARENT OR ANCESTOR OF %p. IGNORING %p" ,
								actor , container , container , actor );
                    return false;
                }
            }
            return true;
        }
	}
    return false;
}

//-----------------------------------------------------------------------------

void ClutterUtil::keep_alive( gpointer o , bool on )
{
    g_assert( o );

    GObject * object = G_OBJECT( o );

    static GQuark key = 0;
    static char value = 0;

    if ( 0 == key )
    {
    	key = g_quark_from_string( "__tp-keep-alive" );
    }

    bool has_one = g_object_get_qdata( object , key );

    if ( on && ! has_one )
    {
        g_object_set_qdata( object , key , & value );
        g_object_ref( object );
    }
    else if ( ! on && has_one )
    {
        g_object_set_qdata( object , key , 0 );
        g_object_unref( object );
    }

}

//-----------------------------------------------------------------------------
