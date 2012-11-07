#ifndef _TRICKPLAY_CLUTTER_UTIL_H
#define _TRICKPLAY_CLUTTER_UTIL_H

#define CLUTTER_VERSION_MIN_REQUIRED CLUTTER_VERSION_CUR_STABLE
#include "clutter/clutter.h"

#include "common.h"
#include "app.h"

namespace ClutterUtil
{
    // Notification handler for actors on opacity changes to show/hide as necessary
    void actor_opacity_notify( GObject * , GParamSpec * , ClutterActor * self );

    void actor_on_show(ClutterActor*actor,void*);
    void actor_on_hide(ClutterActor*actor,void*);


    // Checks if a clutter_actor, actor, can be added as a child of another clutter_actor, container
    bool is_qualified_child( ClutterActor * container , ClutterActor* actor );

    // Returns an actor created from the constructor function. It sinks
    // the original ref and then adds another, so you have to unref the
    // result.

    ClutterActor * make_actor( ClutterActor * ( constructor )() );

    // Pushes a clutter color as a table with 4 integers

    void push_clutter_color( lua_State * L, ClutterColor * color );

    // Converts the thing at index to a clutter geometry. Accepts a table 
    void to_clutter_geometry( lua_State * L, int index, ClutterGeometry * geometry );

    // Converts the thing at index to a clutter color. Accepts a table or a
    // string

    void to_clutter_color( lua_State * L, int index, ClutterColor * color );

    // Converts a string to a color

    ClutterColor string_to_color( const char * s );

    // Converts animation modes

    gulong to_clutter_animation_mode( const char * mode );

    // Safely casts to an actor

    ClutterActor * user_data_to_actor( lua_State * L, int n );

    // Safely casts to a timeline

    ClutterTimeline * user_data_to_timeline( lua_State * L, int n );

	// Safely casts to a animator

    ClutterAnimator * user_data_to_animator( lua_State * L, int n );

	// Safely casts to a constraint

    ClutterConstraint * user_data_to_constraint( lua_State * L , int n );

    // Sets properties from a table

    void set_props_from_table( lua_State * L, int table );

    // Figure out what kind of actor this is, from its metatable if possible
     const gchar * get_actor_type( ClutterActor * actor );

    // Adds metatable to an actor

    void initialize_actor( lua_State * L, ClutterActor * actor, const char * metatable );

    // Given an actor, pushes a Lua object for it

    void wrap_concrete_actor( lua_State * L, ClutterActor * actor );

    // Given a timeline, pushes a Lua object for it

    void wrap_timeline( lua_State * L , ClutterTimeline * timeline );

    void wrap_constraint( lua_State * L , ClutterConstraint * constraint );

    // Returns the metatable for an actor

    const char * get_actor_metatable( ClutterActor * actor );

    // Inject key_down event

    void inject_key_down( ClutterActor *stage, guint key_code, gunichar unicode , unsigned long int modifiers );

    void inject_key_up( ClutterActor *stage, guint key_code, gunichar unicode , unsigned long int modifiers );

    void inject_motion( ClutterActor *stage, gfloat x , gfloat y , unsigned long int modifiers );

    void inject_button_press( ClutterActor *stage, guint32 button , gfloat x , gfloat y , unsigned long int modifiers );

    void inject_button_release( ClutterActor *stage, guint32 button , gfloat x , gfloat y , unsigned long int modifiers );

    void inject_scroll( ClutterActor *stage, int direction , unsigned long int modifiers );

    // Convert stage coordinates into screen coordinates -- adjusts x,y in place
    void stage_coordinates_to_screen_coordinates( ClutterActor *stage, gdouble *x, gdouble *y );

    unsigned long int get_tp_modifiers( ClutterEvent * event );

    void push_event_modifiers( lua_State * L , ClutterEvent * event );

    void push_event_modifiers( lua_State * L , unsigned long int modifiers );

    void keep_alive( gpointer object , bool on );
};


#endif // _TRICKPLAY_CLUTTER_UTIL_H
