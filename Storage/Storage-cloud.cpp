#include "Storage-cloud.h"

TCRDB **pushcloudhash(lua_State *L, TCRDB *hash)
{
	TCRDB **phash = (TCRDB **)lua_newuserdata(L, sizeof(TCRDB *));
	*phash = hash;
	luaL_getmetatable(L, CLOUD_HASH);
	lua_setmetatable(L, -2);

	return phash;
}

TCRDB *tocloudhash(lua_State *L, int index)
{
	TCRDB **phash = (TCRDB **)lua_touserdata(L, index);
	if (NULL == phash) luaL_typerror(L, index, CLOUD_HASH);

	return *phash;
}

TCRDB *checkcloudhash(lua_State *L, int index)
{
	TCRDB **phash;
	luaL_checktype(L, index, LUA_TUSERDATA);
	phash = (TCRDB **)luaL_checkudata(L, index, CLOUD_HASH);
	if (NULL == phash) luaL_typerror(L, index, CLOUD_HASH);
	if (NULL == *phash) luaL_error(L, "null cloud hash");

	return *phash;
}

static int CloudHash_new(lua_State *L)
{
	// TODO: retrieve initialization variables off the stack

	TCRDB *hash;
	hash = tcrdbnew();

	// Push the hash pointer as a userdata
	pushcloudhash(L, hash);

	return 1;
}

static int CloudHash_gc(lua_State *L)
{
	printf("goodbye CloudHash (%p)\n", lua_touserdata(L, 1));
	return 0;
}

static int CloudHash_tostring(lua_State *L)
{
	lua_pushfstring(L, "CloudHash: %p", lua_touserdata(L, 1));
	return 1;
}

const luaL_reg CloudHash_meta[] =
{
	{"__gc",       CloudHash_gc},
	{"__tostring", CloudHash_tostring},
	{0, 0}
};

const luaL_reg CloudHash_methods[] =
{
	{"new",         CloudHash_new},
	{0, 0}
};

int cloud_hash_register(lua_State *L)
{
	luaL_openlib(L, CLOUD_HASH, CloudHash_methods, 0);
	luaL_newmetatable(L, CLOUD_HASH);
	luaL_openlib(L, 0, CloudHash_meta, 0);
	lua_pushliteral(L, "__index");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pushliteral(L, "__metatable");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pop(L, 1);

	return 1;
}
