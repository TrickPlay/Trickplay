#include "Storage-local.h"

#include "tcutil.h"
#include "tchdb.h"

#include <string.h>

TCHDB **pushlocaldb(lua_State *L, TCHDB *db)
{
	TCHDB **pdb = (TCHDB **)lua_newuserdata(L, sizeof(TCHDB *));
	*pdb = db;
	luaL_getmetatable(L, LOCAL_DB);
	lua_setmetatable(L, -2);

	return pdb;
}

TCHDB *tolocaldb(lua_State *L, int index)
{
	TCHDB **pdb = (TCHDB **)lua_touserdata(L, index);
	if (NULL == pdb) luaL_typerror(L, index, LOCAL_DB);

	return *pdb;
}

TCHDB *checklocaldb(lua_State *L, int index)
{
	TCHDB **pdb;
	luaL_checktype(L, index, LUA_TUSERDATA);
	pdb = (TCHDB **)luaL_checkudata(L, index, LOCAL_DB);
	if (NULL == pdb) luaL_typerror(L, index, LOCAL_DB);
	if (NULL == *pdb) luaL_error(L, "null local db");

	return *pdb;
}

static int LocalDB_new(lua_State *L)
{
	// TODO: retrieve initialization variables off the stack
	const char *db_name = luaL_checkstring(L, 1);
	if (NULL == db_name) return luaL_typerror(L, 1, "bad name");

	TCHDB *db;
	db = tchdbnew();

	// Set up optimization on the database:
	if(!tchdbtune(db, 0, -1, -1, 0))
	{
		return luaL_error(L, "Failed to tune DB: %s", tchdberrmsg(tchdbecode(db)));
	}

	if(!tchdbsetcache(db, 32768))
	{
		return luaL_error(L, "Failed to set cache for DB: %s", tchdberrmsg(tchdbecode(db)));
	}

	if(!tchdbopen(db, db_name, HDBOWRITER | HDBOREADER | HDBOCREAT))
	{
		return luaL_error(L, "Failed to open DB file: %s", tchdberrmsg(tchdbecode(db)));
	}

	// Push the db pointer as a userdata
	pushlocaldb(L, db);

	return 1;
}

static int LocalDB_get(lua_State *L)
{
	TCHDB *db = checklocaldb(L, 1);
	size_t key_len;
	const char *key = luaL_checklstring(L, 2, &key_len);
	if (NULL == key) return luaL_typerror(L, 2, "bad key");
	if (0 == key_len) return luaL_argerror(L, 2, "key length 0");

	int val_len;
	void *value = tchdbget(db, (const void *)key, key_len, &val_len);
	if(NULL == value)
	{
		lua_pushnil(L);
	} else {
		lua_pushlstring(L, (const char *)value, (size_t)val_len);
		free(value);
	}

	return 1;
}

static int LocalDB_put(lua_State *L)
{
	TCHDB *db = checklocaldb(L, 1);
	size_t key_len;
	const char *key = luaL_checklstring(L, 2, &key_len);
	if (NULL == key) return luaL_typerror(L, 2, "bad key");
	if (0 == key_len) return luaL_argerror(L, 2, "key length 0");

	size_t value_len;
	const char *value = luaL_checklstring(L, 3, &value_len);
	if (NULL == value) return luaL_typerror(L, 3, "bad value");
	if (0 == value_len) return luaL_argerror(L, 3, "value length 0");

   if(!tchdbput(db, (const void*)key, (int)key_len, (const void *)value, value_len))
   {
   	return luaL_error(L, "Failed to put (%s, %s): %s", key, value, tchdberrmsg(tchdbecode(db)));
   }

	return 0;
}

static int LocalDB_del(lua_State *L)
{
	TCHDB *db = checklocaldb(L, 1);
	size_t key_len;
	const char *key = luaL_checklstring(L, 2, &key_len);
	if (NULL == key) return luaL_typerror(L, 2, "bad key");
	if (0 == key_len) return luaL_argerror(L, 2, "key length 0");

	if(!tchdbout(db, (const void *)key, (int)key_len))
	{
		return luaL_error(L, "Failed to delete (%s): %s", key, tchdberrmsg(tchdbecode(db)));
	}

	return 0;
}

static int LocalDB_nuke(lua_State *L)
{
	TCHDB *db = checklocaldb(L, 1);
	size_t confirm_len;
	const char *confirm = luaL_checklstring(L, 2, &confirm_len);
	if (NULL == confirm) return luaL_typerror(L, 2, "bad confirm string");
	if (0 == confirm_len) return luaL_argerror(L, 2, "confirm string length 0");
	if (strncmp("REALLY_NUKE", confirm, confirm_len))
	{
		return luaL_argerror(L, 2, "Will not nuke: bad confirm string");
	}

	if(!tchdbvanish(db))
	{
		return luaL_error(L, "Failed to nuke DB: %s", tchdberrmsg(tchdbecode(db)));
	}

	return 0;
}

static int LocalDB_begin(lua_State *L)
{
	TCHDB *db = checklocaldb(L, 1);
	if(!tchdbtranbegin(db))
	{
		return luaL_error(L, "Failed to begin transaction: %s", tchdberrmsg(tchdbecode(db)));
	}
	return 0;
}

static int LocalDB_commit(lua_State *L)
{
	TCHDB *db = checklocaldb(L, 1);
	if(!tchdbtrancommit(db))
	{
		return luaL_error(L, "Failed to commit transaction: %s", tchdberrmsg(tchdbecode(db)));
	}
	return 0;
}

static int LocalDB_abort(lua_State *L)
{
	TCHDB *db = checklocaldb(L, 1);
	if(!tchdbtranabort(db))
	{
		return luaL_error(L, "Failed to abort transaction: %s", tchdberrmsg(tchdbecode(db)));
	}
	return 0;
}

static int LocalDB_count(lua_State *L)
{
	TCHDB *db = checklocaldb(L, 1);
	uint64_t count = tchdbrnum(db);

	lua_pushinteger(L, count);

	return 1;
}

static int LocalDB_flush(lua_State *L)
{
	TCHDB *db = checklocaldb(L, 1);
	if(!tchdbsync(db))
	{
		luaL_error(L, "Failed to flush DB: %s", tchdberrmsg(tchdbecode(db)));
	}

	return 0;
}

static int LocalDB_gc(lua_State *L)
{
	TCHDB *db = checklocaldb(L, 1);
	tchdbdel(db);

	return 0;
}

static int LocalDB_tostring(lua_State *L)
{
	TCHDB *db = checklocaldb(L, 1);
	lua_pushfstring(L, "LocalDB: (%p) [%s] - %d records", db, tchdbpath(db), tchdbrnum(db));
	return 1;
}

const luaL_reg LocalDB_meta[] =
{
	{"__gc",       LocalDB_gc},
	{"__tostring", LocalDB_tostring},
	{0, 0}
};

const luaL_reg LocalDB_methods[] =
{
	{"new",         LocalDB_new},

	{"get",         LocalDB_get},
	{"put",         LocalDB_put},
	{"del",         LocalDB_del},

	{"nuke",        LocalDB_nuke},

	{"begin",       LocalDB_begin},
	{"commit",      LocalDB_commit},
	{"abort",       LocalDB_abort},

	{"flush",       LocalDB_flush},

	{"count",       LocalDB_count},

	{0, 0}
};

int local_db_register(lua_State *L)
{
	luaL_openlib(L, LOCAL_DB, LocalDB_methods, 0);
	luaL_newmetatable(L, LOCAL_DB);
	luaL_openlib(L, 0, LocalDB_meta, 0);
	lua_pushliteral(L, "__index");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pushliteral(L, "__metatable");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pop(L, 1);

	return 1;
}
