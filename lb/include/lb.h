#ifndef LB_H
#define LB_H

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

int lb_index(lua_State*L);
int lb_newindex(lua_State*L);
void lb_inherit(lua_State*L,const char*metatable);
void lb_set_props_from_table(lua_State*L);

#endif
