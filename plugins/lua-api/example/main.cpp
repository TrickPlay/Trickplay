
#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "trickplay/plugins/lua-api.h"

/******************************************************************************
 * Initialize
 * Called by TrickPlay the first time this plugin is loaded.
 */

extern "C"
void
tp_plugin_initialize( TPPluginInfo * info , const char * config )
{
    strncpy( info->name , "TrickPlay LUA API Example" , sizeof( info->name ) - 1 );
    strncpy( info->version , "1.0" , sizeof( info->version ) - 1 );
}

/******************************************************************************
 * foo
 * A function we will add to Lua.
 */

static int foo( lua_State * L )
{
	int top = lua_gettop( L );

	if ( 0 == top )
	{
		return luaL_error( L , "This is a failure from a plugin." );
	}

	printf( "'foo' was called with %d argument(s)\n" , top );

	return 0;
}

/******************************************************************************
 * Open
 * Called whenever a new app is executed.
 * On the top of the stack is the app's id (string).
 */

extern "C"
int
tp_lua_api_open( lua_State * L , void * user_data )
{
	printf( "THIS PLUGIN IS BEING OPENED FOR APP '%s'\n" , lua_tostring( L , -1 ) );

	/* Add a global function called 'foo' */

	lua_pushcfunction( L , foo );
	lua_setglobal( L , "foo" );

	return 0;
}

/******************************************************************************
 * Close
 * Called when an app is shutting down.
 * On the top of the stack is the app's id (string).
 */

extern "C"
void
tp_lua_api_close( lua_State * L , void * user_data )
{
	printf( "THIS PLUGIN IS BEING CLOSED FOR APP '%s'\n" , lua_tostring( L , -1 ) );
}

/******************************************************************************
 * Shutdown
 * Called by TrickPlay before this plugin is unloaded.
 */

extern "C"
void
tp_plugin_shutdown( void * user_data )
{
    /* Nothing to do - but we could free resources associated with user data. */
}

/*****************************************************************************/



