#ifndef __TRICKPLAY_STORAGE_CLOUD__
#define __TRICKPLAY_STORAGE_CLOUD__

extern "C"
{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "tcrdb.h"
}


#define CLOUD_HASH "Cloudhash"

int cloud_hash_register(lua_State *L);

TCRDB **pushcloudhash(lua_State *L, TCRDB *hash);
TCRDB *tocloudhash(lua_State *L, int index);
TCRDB *checkcloudhash(lua_State *L, int index);

#endif __TRICKPLAY_STORAGE_CLOUD__
