#ifndef __TRICKPLAY_STORAGE_LOCAL__
#define __TRICKPLAY_STORAGE_LOCAL__

extern "C"
{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}


#define LOCAL_DB "LocalDB"

int local_db_register(lua_State *L);

#endif __TRICKPLAY_STORAGE_LOCAL__
