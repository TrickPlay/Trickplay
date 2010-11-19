#ifndef _TRICKPLAY_CLUTTER_UTIL_H
#define _TRICKPLAY_CLUTTER_UTIL_H

#include "clutter/clutter.h"

#include "common.h"
#include "app.h"

namespace ClutterUtil
{
    // Notification handler for actors on opacity changes to show/hide as necessary
    void actor_opacity_notify( GObject * , GParamSpec * , ClutterActor * self );

    // Returns an actor created from the constructor function. It sinks
    // the original ref and then adds another, so you have to unref the
    // result.

    ClutterActor * make_actor( ClutterActor * ( constructor )() );

    // Pushes a clutter color as a table with 4 integers

    void push_clutter_color( lua_State * L, ClutterColor * color );

    // Converts the thing at index to a clutter color. Accepts a table or a
    // string

    void to_clutter_color( lua_State * L, int index, ClutterColor * color );

    // Converts animation modes

    gulong to_clutter_animation_mode( const char * mode );

    // Safely casts to an actor

    ClutterActor * user_data_to_actor( lua_State * L, int n );

    // Sets properties from a table

    void set_props_from_table( lua_State * L, int table );

    // Adds metatable to an actor

    void initialize_actor( lua_State * L, ClutterActor * actor, const char * metatable );

    // Given an actor, pushes a Lua object for it

    void wrap_concrete_actor( lua_State * L, ClutterActor * actor );

    // Returns the metatable for an actor

    const char * get_actor_metatable( ClutterActor * actor );

    // Inject key_down event

    void inject_key_down( guint key_code, gunichar unicode );

    void inject_key_up( guint key_code, gunichar unicode );

    // Convert stage coordinates into screen coordinates -- adjusts x,y in place
    void stage_coordinates_to_screen_coordinates( gdouble *x, gdouble *y );
};


#endif // _TRICKPLAY_CLUTTER_UTIL_H
