#ifndef __TRICKPLAY_STORAGE_REMOTE__
#define __TRICKPLAY_STORAGE_REMOTE__

extern "C"
{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}


#define REMOTE_DB "RemoteDB"

int remote_db_register(lua_State *L);

#endif __TRICKPLAY_STORAGE_REMOTE__
