#include "Network-curl.h"

CURL **pushurlfetcher(lua_State *L, CURL *curl)
{
	CURL **pcurl = (CURL **)lua_newuserdata(L, sizeof(CURL *));
	*pcurl = curl;
	luaL_getmetatable(L, URL_FETCHER);
	lua_setmetatable(L, -2);

	return pcurl;
}

CURL *tourlfetcher(lua_State *L, int index)
{
	CURL **pcurl = (CURL **)lua_touserdata(L, index);
	if (NULL == pcurl) luaL_typerror(L, index, URL_FETCHER);

	return *pcurl;
}

CURL *checkurlfetcher(lua_State *L, int index)
{
	CURL **pcurl;
	luaL_checktype(L, index, LUA_TUSERDATA);
	pcurl = (CURL **)luaL_checkudata(L, index, URL_FETCHER);
	if (NULL == pcurl) luaL_typerror(L, index, URL_FETCHER);
	if (NULL == *pcurl) luaL_error(L, "null url fetcher");

	return *pcurl;
}

static int URLFetcher_new(lua_State *L)
{
	// TODO: retrieve initialization variables off the stack

	CURL *curl = curl_easy_init();

	// Push the curl pointer as a userdata
	pushurlfetcher(L, curl);

	return 1;
}

static int URLFetcher_gc(lua_State *L)
{
	printf("goodbye URLFetcher (%p)\n", lua_touserdata(L, 1));
	return 0;
}

static int URLFetcher_tostring(lua_State *L)
{
	lua_pushfstring(L, "URLFetcher: %p", lua_touserdata(L, 1));
	return 1;
}

const luaL_reg URLFetcher_meta[] =
{
	{"__gc",       URLFetcher_gc},
	{"__tostring", URLFetcher_tostring},
	{0, 0}
};

const luaL_reg URLFetcher_methods[] =
{
	{"new",         URLFetcher_new},
	{0, 0}
};

int url_fetcher_register(lua_State *L)
{
	luaL_openlib(L, URL_FETCHER, URLFetcher_methods, 0);
	luaL_newmetatable(L, URL_FETCHER);
	luaL_openlib(L, 0, URLFetcher_meta, 0);
	lua_pushliteral(L, "__index");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pushliteral(L, "__metatable");
	lua_pushvalue(L, -3);
	lua_rawset(L, -3);
	lua_pop(L, 1);

	return 1;
}
