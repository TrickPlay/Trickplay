#ifndef __TRICKPLAY_STORAGE_CLOUD__
#define __TRICKPLAY_STORAGE_CLOUD__

extern "C"
{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}


#define CLOUD_DB "CloudDB"

int cloud_db_register(lua_State *L);

#endif __TRICKPLAY_STORAGE_CLOUD__
