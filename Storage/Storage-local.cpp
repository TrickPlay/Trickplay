#include "Storage-local.h"

TCHDB **pushlocalhash(lua_State *L, TCHDB *hash)
{
	TCHDB **phash = (TCHDB **)lua_newuserdata(L, sizeof(TCHDB *));
	*phash = hash;
	luaL_getmetatable(L, LOCAL_HASH);
	lua_setmetatable(L, -2);

	return phash;
}

TCHDB *tolocalhash(lua_State *L, int index)
{
	TCHDB **phash = (TCHDB **)lua_touserdata(L, index);
	if (NULL == phash) luaL_typerror(L, index, LOCAL_HASH);

	return *phash;
}

TCHDB *checklocalhash(lua_State *L, int index)
{
	TCHDB **phash;
	luaL_checktype(L, index, LUA_TUSERDATA);
	phash = (TCHDB **)luaL_checkudata(L, index, LOCAL_HASH);
	if (NULL == phash) luaL_typerror(L, index, LOCAL_HASH);
	if (NULL == *phash) luaL_error(L, "null local hash");

	return *phash;
}

static int LocalHash_new(lua_State *L)
{
	// TODO: retrieve initialization variables off the stack
	const char *db_name = luaL_checkstring(L, 1);
	if (NULL == db_name) return luaL_typerror(L, 1, "bad name");

	TCHDB *hash;
	hash = tchdbnew();
	if(!tchdbopen(hash, db_name, HDBOWRITER | HDBOREADER | HDBOCREAT | HDBOTSYNC))
	{
		return luaL_error(L, "Failed to open DB file");
	}

	// Push the hash pointer as a userdata
	pushlocalhash(L, hash);

	return 1;
}

static int LocalHash_get(lua_State *L)
{
	TCHDB *hash = checklocalhash(L, 1);
	size_t key_len;
	const char *key = luaL_checklstring(L, 2, &key_len);
	if (NULL == key) return luaL_typerror(L, 2, "bad key");
	if (0 == key_len) return luaL_argerror(L, 2, "key length 0");

	int val_len;
	void *value = tchdbget(hash, (const void *)key, key_len, &val_len);
	if(NULL == value)
	{
		lua_pushnil(L);
	} else {
		lua_pushlstring(L, (const char *)value, (size_t)val_len);
		free(value);
	}

	return 1;
}

static int LocalHash_put(lua_State *L)
{
	TCHDB *hash = checklocalhash(L, 1);
	size_t key_len;
	const char *key = luaL_checklstring(L, 2, &key_len);
	if (NULL == key) return luaL_typerror(L, 2, "bad key");
	if (0 == key_len) return luaL_argerror(L, 2, "key length 0");

	size_t value_len;
	const char *value = luaL_checklstring(L, 3, &value_len);
	if (NULL == value) return luaL_typerror(L, 3, "bad value");
	if (0 == value_len) return luaL_argerror(L, 3, "value length 0");

   if(!tchdbput(hash, (const void*)key, key_len, (const void *)value, value_len))
   {
   	return luaL_error(L, "Failed to put (%s, %s)", key, value);
   }

	return 0;
}

static int LocalHash_gc(lua_State *L)
{
	printf("goodbye LocalHash (%p)\n", lua_touserdata(L, 1));
	return 0;
}

static int LocalHash_tostring(lua_State *L)
{
	lua_pushfstring(L, "LocalHash: %p", lua_touserdata(L, 1));
	return 1;
}

const luaL_reg LocalHash_meta[] =
{
	{"__gc",       LocalHash_gc},
	{"__tostring", LocalHash_tostring},
	{0, 0}
};

const luaL_reg LocalHash_methods[] =
{
	{"new",         LocalHash_new},
	{"get",         LocalHash_get},
	{"put",         LocalHash_put},
	{0, 0}
};

int local_hash_register(lua_State *L)
{
	luaL_openlib(L, LOCAL_HASH, LocalHash_methods, 0);
	luaL_newmetatable(L, LOCAL_HASH);
	luaL_openlib(L, 0, LocalHash_meta, 0);
	lua_pushliteral(L, "__index");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pushliteral(L, "__metatable");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pop(L, 1);

	return 1;
}
