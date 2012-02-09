#ifndef _TRICKPLAY_LUA_API_H
#define _TRICKPLAY_LUA_API_H

/*-----------------------------------------------------------------------------*/

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "trickplay/plugins/plugins.h"

/*-----------------------------------------------------------------------------*/
/*
 	Called when a Lua state is created for a new application. Should return
 	0 if successful.
*/

    typedef
	int
	(*TPLuaAPIOpen)(

			lua_State *	L,
			void * 		user_data);

/*-----------------------------------------------------------------------------*/
/*
    Called before the Lua state is closed for an application.
*/

    typedef
	void
	(*TPLuaAPIClose)(

			lua_State *	L,
			void * 		user_data);

/*-----------------------------------------------------------------------------*/

#define TP_LUA_API_OPEN				"tp_lua_api_open"
#define TP_LUA_API_CLOSE			"tp_lua_api_close"

/*-----------------------------------------------------------------------------*/


#endif /* _TRICKPLAY_LUA_API_H */
