#include "Network-curl.h"

#include <stdlib.h>
#include <string.h>

class write_aggregator
{

public:
	void *data;
	size_t data_len;
	write_aggregator *next;
	
	size_t get_length() const
	{
		if(NULL == data) return 0;
		return data_len + next->get_length();
	}

	void to_string(char *buffer) const
	{
		if(NULL != data) memcpy(buffer, data, data_len);
		if(NULL != next)
		{
			next->to_string(&buffer[data_len]);
		}
	}

	write_aggregator()
	{
		data = NULL;
		next = NULL;
		data_len = 0;
	}

	~write_aggregator()
	{
		if(data) free(data);
		if(next) delete next;
	}
};

static size_t write_data(void *buffer, size_t size, size_t nmemb, void *userp)
{
	write_aggregator *wa = (write_aggregator *)userp;
	while(wa->data != NULL)
	{
		wa = wa->next;
	}

	wa->data_len = size * nmemb;
	wa->data = malloc(wa->data_len);
	memcpy(wa->data, buffer, size * nmemb);
	wa->next = new write_aggregator;
	
	return size * nmemb;
}

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
	curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 1);
	curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
	curl_easy_setopt(curl, CURLOPT_AUTOREFERER, 1);
	curl_easy_setopt(curl, CURLOPT_USERAGENT, "Mozilla/5.0 (compatible; TrickPlay/1.0)");

	// Push the curl pointer as a userdata
	pushurlfetcher(L, curl);

	return 1;
}

static int URLFetcher_fetch(lua_State *L)
{
	CURL *curl = checkurlfetcher(L, 1);

	size_t url_len;
	const char *url = luaL_checklstring(L, 2, &url_len);
	if (NULL == url) return luaL_typerror(L, 2, "bad url");
	if (0 == url_len) return luaL_argerror(L, 2, "url length 0");

	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);

	write_aggregator *WA = new write_aggregator;
	curl_easy_setopt(curl, CURLOPT_WRITEDATA, WA);
	curl_easy_setopt(curl, CURLOPT_URL, url);

	curl_easy_perform(curl);

	size_t content_length = WA->get_length();
	char *content = (char *)malloc(content_length);
	WA->to_string(content);

	lua_pushlstring(L, content, content_length);

	free(content);
	delete(WA);

	return 1;
}

static int URLFetcher_gc(lua_State *L)
{
	CURL *curl = checkurlfetcher(L, 1);
	printf("goodbye URLFetcher (%p)\n", curl);
	curl_easy_cleanup(curl);
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
	{"fetch",       URLFetcher_fetch},
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
