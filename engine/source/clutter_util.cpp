#include <cstring>
#include <string>
#include <cstdlib>

#include "clutter_util.h"
#include "lb.h"


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

void ClutterUtil::to_clutter_color( lua_State * L, int index, ClutterColor * color )
{
    LSG;

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
        int colors[4] = {0, 0, 0, 255};
        char buffer[3] = {0, 0, 0};

        const char * s = lua_tostring( L, index );

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

        color->red   = colors[0];
        color->green = colors[1];
        color->blue  = colors[2];
        color->alpha = colors[3];
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
    if ( lua_type( L , n ) != LUA_TUSERDATA )
    {
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

void ClutterUtil::initialize_actor( lua_State * L, ClutterActor * actor, const char * metatable )
{
    // Metatables are static, so we don't need to free it
    g_object_set_data( G_OBJECT( actor ), "tp-metatable", ( gpointer )metatable );
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
    event->any.time = clutter_get_timestamp();
    event->any.flags = CLUTTER_EVENT_FLAG_SYNTHETIC;
    event->key.keyval = key_code;
    event->key.unicode_value = unicode;

    clutter_event_put( event );

    clutter_event_free( event );

    clutter_threads_leave();

#ifdef TP_CLUTTER_BACKEND_EGL

    // In the EGL backend, there is nothing pulling the events from
    // the event queue, so we force that by adding an idle source

    g_idle_add_full( G_PRIORITY_HIGH_IDLE, event_pump, NULL, NULL );

#endif
}

void ClutterUtil::inject_key_up( guint key_code, gunichar unicode )
{
    clutter_threads_enter();

    ClutterEvent * event = clutter_event_new( CLUTTER_KEY_RELEASE );
    event->any.stage = CLUTTER_STAGE( clutter_stage_get_default() );
    event->any.time = clutter_get_timestamp();
    event->any.flags = CLUTTER_EVENT_FLAG_SYNTHETIC;
    event->key.keyval = key_code;
    event->key.unicode_value = unicode;

    clutter_event_put( event );

    clutter_event_free( event );

    clutter_threads_leave();

#ifdef TP_CLUTTER_BACKEND_EGL

    // In the EGL backend, there is nothing pulling the events from
    // the event queue, so we force that by adding an idle source

    g_idle_add_full( G_PRIORITY_HIGH_IDLE, event_pump, NULL, NULL );

#endif
}

//-----------------------------------------------------------------------------
