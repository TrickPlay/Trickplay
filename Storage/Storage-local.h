#ifndef __TRICKPLAY_STORAGE_LOCAL__
#define __TRICKPLAY_STORAGE_LOCAL__

extern "C"
{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "tcutil.h"
#include "tchdb.h"
}


#define LOCAL_HASH "Localhash"

int local_hash_register(lua_State *L);

TCHDB **pushlocalhash(lua_State *L, TCHDB *hash);
TCHDB *tolocalhash(lua_State *L, int index);
TCHDB *checklocalhash(lua_State *L, int index);

#endif __TRICKPLAY_STORAGE_LOCAL__
