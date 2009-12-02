#ifndef __TRICKPLAY_NETWORK_CURL__
#define __TRICKPLAY_NETWORK_CURL__

extern "C"
{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "curl/curl.h"
}


#define URL_FETCHER "URLFetcher"

int url_fetcher_register(lua_State *L);

CURL **pushurlfetcher(lua_State *L, CURL *hash);
CURL *tourlfetcher(lua_State *L, int index);
CURL *checkcloudhash(lua_State *L, int index);

#endif __TRICKPLAY_NETWORK_CURL__
