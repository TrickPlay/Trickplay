#include "Storage-remote.h"

TCRDB **pushremotehash(lua_State *L, TCRDB *hash)
{
	TCRDB **phash = (TCRDB **)lua_newuserdata(L, sizeof(TCRDB *));
	*phash = hash;
	luaL_getmetatable(L, REMOTE_HASH);
	lua_setmetatable(L, -2);

	return phash;
}

TCRDB *toremotehash(lua_State *L, int index)
{
	TCRDB **phash = (TCRDB **)lua_touserdata(L, index);
	if (NULL == phash) luaL_typerror(L, index, REMOTE_HASH);

	return *phash;
}

TCRDB *checkremotehash(lua_State *L, int index)
{
	TCRDB **phash;
	luaL_checktype(L, index, LUA_TUSERDATA);
	phash = (TCRDB **)luaL_checkudata(L, index, REMOTE_HASH);
	if (NULL == phash) luaL_typerror(L, index, REMOTE_HASH);
	if (NULL == *phash) luaL_error(L, "null remote hash");

	return *phash;
}

static int RemoteHash_new(lua_State *L)
{
	// TODO: retrieve initialization variables off the stack

	TCRDB *hash;
	hash = tcrdbnew();

	// Push the hash pointer as a userdata
	pushremotehash(L, hash);

	return 1;
}

static int RemoteHash_gc(lua_State *L)
{
	printf("goodbye RemoteHash (%p)\n", lua_touserdata(L, 1));
	return 0;
}

static int RemoteHash_tostring(lua_State *L)
{
	lua_pushfstring(L, "RemoteHash: %p", lua_touserdata(L, 1));
	return 1;
}

const luaL_reg RemoteHash_meta[] =
{
	{"__gc",       RemoteHash_gc},
	{"__tostring", RemoteHash_tostring},
	{0, 0}
};

const luaL_reg RemoteHash_methods[] =
{
	{"new",         RemoteHash_new},
	{0, 0}
};

int remote_hash_register(lua_State *L)
{
	luaL_openlib(L, REMOTE_HASH, RemoteHash_methods, 0);
	luaL_newmetatable(L, REMOTE_HASH);
	luaL_openlib(L, 0, RemoteHash_meta, 0);
	lua_pushliteral(L, "__index");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pushliteral(L, "__metatable");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pop(L, 1);

	return 1;
}
