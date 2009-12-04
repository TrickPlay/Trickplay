#include "Storage-cloud.h"

TCRDB **pushclouddb(lua_State *L, TCRDB *db)
{
	TCRDB **pdb = (TCRDB **)lua_newuserdata(L, sizeof(TCRDB *));
	*pdb = db;
	luaL_getmetatable(L, CLOUD_DB);
	lua_setmetatable(L, -2);

	return pdb;
}

TCRDB *toclouddb(lua_State *L, int index)
{
	TCRDB **pdb = (TCRDB **)lua_touserdata(L, index);
	if (NULL == pdb) luaL_typerror(L, index, CLOUD_DB);

	return *pdb;
}

TCRDB *checkclouddb(lua_State *L, int index)
{
	TCRDB **pdb;
	luaL_checktype(L, index, LUA_TUSERDATA);
	pdb = (TCRDB **)luaL_checkudata(L, index, CLOUD_DB);
	if (NULL == pdb) luaL_typerror(L, index, CLOUD_DB);
	if (NULL == *pdb) luaL_error(L, "null cloud db");

	return *pdb;
}

static int CloudDB_new(lua_State *L)
{
	// TODO: retrieve initialization variables off the stack

	TCRDB *db;
	db = tcrdbnew();

	// Push the db pointer as a userdata
	pushclouddb(L, db);

	return 1;
}

static int CloudDB_gc(lua_State *L)
{
	printf("goodbye CloudDB (%p)\n", lua_touserdata(L, 1));
	return 0;
}

static int CloudDB_tostring(lua_State *L)
{
	lua_pushfstring(L, "CloudDB: %p", lua_touserdata(L, 1));
	return 1;
}

const luaL_reg CloudDB_meta[] =
{
	{"__gc",       CloudDB_gc},
	{"__tostring", CloudDB_tostring},
	{0, 0}
};

const luaL_reg CloudDB_methods[] =
{
	{"new",         CloudDB_new},
	{0, 0}
};

int cloud_db_register(lua_State *L)
{
	luaL_openlib(L, CLOUD_DB, CloudDB_methods, 0);
	luaL_newmetatable(L, CLOUD_DB);
	luaL_openlib(L, 0, CloudDB_meta, 0);
	lua_pushliteral(L, "__index");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pushliteral(L, "__metatable");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pop(L, 1);

	return 1;
}
