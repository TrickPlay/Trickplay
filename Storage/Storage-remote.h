#ifndef __TRICKPLAY_STORAGE_REMOTE__
#define __TRICKPLAY_STORAGE_REMOTE__

extern "C"
{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "tcrdb.h"
}


#define REMOTE_HASH "Remotehash"

int remote_hash_register(lua_State *L);

TCRDB **pushremotehash(lua_State *L, TCRDB *hash);
TCRDB *toremotehash(lua_State *L, int index);
TCRDB *checkremotehash(lua_State *L, int index);

#endif __TRICKPLAY_STORAGE_REMOTE__
