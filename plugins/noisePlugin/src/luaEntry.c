
#include "trickplay/plugins/lua-api.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "perlinNoise.h"

/******************************************************************************
 * Forward declaration
 */

int getPerlinNoise( lua_State * );

/******************************************************************************
 * Initialize
 * Called by TrickPlay the first time this plug-in is loaded.
 */

void
tp_plugin_initialize( TPPluginInfo * info, const char * config ){

	/* Set some of the fields in the TPPluginInfo struct */
    strncpy( info->name, "TrickPlay OEM Plug-in Example", sizeof( info->name ) - 1 );
    strncpy( info->version, "1.0", sizeof( info->version ) - 1 );

    /* Initialize the noise data structures */
    init_noise();

}

/******************************************************************************
 * Open
 * Called whenever a new app is executed.
 */

int
tp_lua_api_open( lua_State * L, const char * app_id, void * user_data ){

	printf( "THIS PLUGIN IS BEING OPENED FOR APP '%s'\n", app_id );

	/* Array of the plug-in's Lua Interface */
	struct luaL_Reg noiseAPI[] = {
		// Lua Interfaces    C Functions
		// ----------------  ---------------
		{ "getPerlinNoise",  getPerlinNoise },
		{ NULL, NULL } 						/* end of array */
	};

	/* Register the Lua interface functions */
	lua_pushglobaltable( L );
	luaL_setfuncs( L, noiseAPI, 0 );
	lua_pop( L, 1 );

	/* Return SUCCESS value */
	return( 0 );

}

/******************************************************************************
 * Close
 * Called when an app is shutting down.
 */

void
tp_lua_api_close( lua_State * L, const char * app_id, void * user_data ){

	printf( "THIS PLUGIN IS BEING CLOSED FOR APP '%s'\n", app_id );
}

/******************************************************************************
 * Shutdown
 * Called by TrickPlay before this plug-in is unloaded.
 */

void
tp_plugin_shutdown( void * user_data ){

    /* Nothing to do, but we could free resources associated with user_data. */
}

/*****************************************************************************/
/* Lua interface function to C plug-in library */

int
getPerlinNoise( lua_State *L ){

	double x = luaL_checknumber( L, 1 );
	double y = luaL_checknumber( L, 2 );
	double z = luaL_checknumber( L, 3 );

	/* Call pnoise() function, pushing return value onto Lua state */
	lua_pushnumber( L, pnoise( x, y, z ) );

	/* Returning single value */
	return( 1 );

} /* getPerlinNoise() */

/*****************************************************************************/

