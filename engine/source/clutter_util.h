#ifndef _TRICKPLAY_CLUTTER_UTIL_H
#define _TRICKPLAY_CLUTTER_UTIL_H

#include "clutter/clutter.h"

#include "common.h"
#include "app.h"

namespace ClutterUtil
{
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

    //--------------------------------------------------------------------------
    // This lets us bolt on a table of user data

    class Extra
    {
    public:

        // Creates a new table, takes a ref on it and leaves it
        // on the stack

        Extra( lua_State * L );

        // Takes a ref on a table that is already on the stack
        // and leaves it on the stack

        Extra( lua_State * L, int t );

        // Releases the ref
        // This may happen after the lua state is closed, because extra is bolted
        // on to a GObject...so we protect against that by using a lua state
        // proxy and checking that it is still good.

        ~Extra();

        // Pushes the referenced table onto the stack

        void push_table();

        // GDestroyNotify for it

        static void destroy( gpointer a );

    private:

        Extra()
        {}

        Extra( const Extra & )
        {}

        LuaStateProxy *	lsp;
        int		table_ref;
    };

};


#endif // _TRICKPLAY_CLUTTER_UTIL_H
