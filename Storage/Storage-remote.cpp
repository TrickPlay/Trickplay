#include "Storage-remote.h"

TCRDB **pushremotedb(lua_State *L, TCRDB *db)
{
	TCRDB **pdb = (TCRDB **)lua_newuserdata(L, sizeof(TCRDB *));
	*pdb = db;
	luaL_getmetatable(L, REMOTE_DB);
	lua_setmetatable(L, -2);

	return pdb;
}

TCRDB *toremotedb(lua_State *L, int index)
{
	TCRDB **pdb = (TCRDB **)lua_touserdata(L, index);
	if (NULL == pdb) luaL_typerror(L, index, REMOTE_DB);

	return *pdb;
}

TCRDB *checkremotedb(lua_State *L, int index)
{
	TCRDB **pdb;
	luaL_checktype(L, index, LUA_TUSERDATA);
	pdb = (TCRDB **)luaL_checkudata(L, index, REMOTE_DB);
	if (NULL == pdb) luaL_typerror(L, index, REMOTE_DB);
	if (NULL == *pdb) luaL_error(L, "null remote db");

	return *pdb;
}

static int RemoteDB_new(lua_State *L)
{
	// TODO: retrieve initialization variables off the stack

	TCRDB *db;
	db = tcrdbnew();

	// Push the db pointer as a userdata
	pushremotedb(L, db);

	return 1;
}

static int RemoteDB_gc(lua_State *L)
{
	printf("goodbye RemoteDB (%p)\n", lua_touserdata(L, 1));
	return 0;
}

static int RemoteDB_tostring(lua_State *L)
{
	lua_pushfstring(L, "RemoteDB: %p", lua_touserdata(L, 1));
	return 1;
}

const luaL_reg RemoteDB_meta[] =
{
	{"__gc",       RemoteDB_gc},
	{"__tostring", RemoteDB_tostring},
	{0, 0}
};

const luaL_reg RemoteDB_methods[] =
{
	{"new",         RemoteDB_new},
	{0, 0}
};

int remote_db_register(lua_State *L)
{
	luaL_openlib(L, REMOTE_DB, RemoteDB_methods, 0);
	luaL_newmetatable(L, REMOTE_DB);
	luaL_openlib(L, 0, RemoteDB_meta, 0);
	lua_pushliteral(L, "__index");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pushliteral(L, "__metatable");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pop(L, 1);

	return 1;
}
