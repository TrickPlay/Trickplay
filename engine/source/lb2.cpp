
#include "lb2.h"

//.........................................................................

static const char * TP_WEAK_REFS_TABLE = "__TP_WEAK_REFS__";

//.........................................................................
// Like luaL_ref - takes the item at the top of the stack and adds
// a weak ref to it. It pops the item and returns the ref.

int lb2_weak_ref( lua_State * L )
{
    g_assert( L );

    LSG;

    lua_pushstring( L , TP_WEAK_REFS_TABLE );
    lua_rawget( L , LUA_REGISTRYINDEX );

    // The weak refs table does not yet exist, so we create it

    if ( lua_isnil( L , -1 ) )
    {
        lua_pop( L , 1 );

        // Create the table itself

        lua_newtable( L );

        // Create a metatable for it and set the mode

        lua_newtable( L );
        lua_pushstring( L , "__mode" );
        lua_pushstring( L , "v" );
        lua_rawset( L , -3 );

        // Set its metatable

        lua_setmetatable( L , -2 );

        // Put it in the registry

        lua_pushstring( L , TP_WEAK_REFS_TABLE );
        lua_pushvalue( L , -2 );
        lua_rawset( L , LUA_REGISTRYINDEX );
    }

    // At this point, we should have the thing to ref
    // at -2 and the weak refs table at -1

    LSG_CHECK(1);

    // Exchange the two items - weak refs table at -2 and thing at -1

    lua_insert( L , -2 );

    // Pops the thing and returns the ref

    int ref = luaL_ref( L , -2 );

    // Pop the table

    lua_pop( L , 1 );

    LSG_CHECK(-1);

    return ref;
}

//.........................................................................
// Like luaL_unref - takes the ref and removes it from the weak refs table.
// If the ref is not valid, it does nothing.

void lb2_weak_unref( lua_State * L , int ref )
{
    g_assert( L );

    if ( ref == LUA_NOREF || ref == LUA_REFNIL )
    {
        return;
    }

    LSG;

    lua_pushstring( L , TP_WEAK_REFS_TABLE );
    lua_rawget( L , LUA_REGISTRYINDEX );

    g_assert( ! lua_isnil( L , -1 ) );

    luaL_unref( L , -1 , ref );

    lua_pop( L , 1 );

    LSG_CHECK(0);
}

//.........................................................................
// Pushes the value pointed to by the weak ref. If the ref is not valid, it
// will push a nil.

void lb2_weak_deref( lua_State * L , int ref )
{
    g_assert( L );

    LSG;

    if ( ref == LUA_NOREF || ref == LUA_REFNIL )
    {
        lua_pushnil( L );
    }
    else
    {
        lua_pushstring( L , TP_WEAK_REFS_TABLE );
        lua_rawget( L , LUA_REGISTRYINDEX );

        g_assert( ! lua_isnil( L , -1 ) );

        // Get the value by index from the weak refs table

        lua_rawgeti( L , -1 , ref );

        // Get rid of the table

        lua_remove( L , -2 );
    }

    LSG_CHECK(1);
}

//.........................................................................
// Pushes the value pointed to by the strong ref. If the ref is not valid, it
// will push a nil.

void lb2_strong_deref( lua_State * L , int ref )
{
    g_assert( L );

    LSG;

    if ( ref == LUA_NOREF || ref == LUA_REFNIL )
    {
        lua_pushnil( L );
    }
    else
    {
        // Get the value by index from the registry

        lua_rawgeti( L , LUA_REGISTRYINDEX , ref );
    }

    LSG_CHECK(1);
}
