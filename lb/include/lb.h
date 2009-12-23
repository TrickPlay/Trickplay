#ifndef LB_H
#define LB_H

#include "glib.h"
#include "assert.h"

G_BEGIN_DECLS

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#define lb_new_self(L,t)    ((t*)lua_newuserdata(L,sizeof(t*)))
#define lb_get_self(L,t)    (*((t*)lua_touserdata(L,1)))

int lb_get_callback(lua_State*L,void*self,const char*name,int metatable_on_top);
int lb_set_callback(lua_State*L,void*self,const char*name);
int lb_invoke_callback(lua_State*L,void*self,const char*metatable,const char*name,int nargs,int nresults);
void lb_clear_callbacks(lua_State*L,void*self,const char*metatable);
int lb_callback_attached(lua_State*L,void*self,const char*name,int index);

void lb_store_weak_ref(lua_State*L,int udata,void*self);
int lb_wrap(lua_State*L,void*self,const char*metatable);

int lb_index(lua_State*L);
int lb_newindex(lua_State*L);
void lb_inherit(lua_State*L,const char*metatable);
void lb_set_props_from_table(lua_State*L);

#define lb_checktable(L,i) (luaL_checktype(L,i,LUA_TTABLE),i)
#define lb_opttable(L,i,d) (lua_istable(L,i)?i:d)
#define lb_checkfunction(L,i) (luaL_checktype(L,i,LUA_TFUNCTION),i)
#define lb_optfunction(L,i,d) (lua_isfunction(L,i)?i:d)

#define lb_checkudata(L,i) (luaL_checktype(L,i,LUA_TUSERDATA),i)
#define lb_optudata(L,i,d) ((lua_isuserdata(L,i)?i:d))

#define lb_optint(L,i,d) ((lua_tointeger(L,i)?lua_tointeger(L,i):(lua_isnumber(L,i)?0:d)))
#define lb_optnumber(L,i,d) ((lua_tonumber(L,i)?lua_tonumber(L,i):(lua_isnumber(L,i)?0:d)))
#define lb_optstring(L,i,d) ((lua_isstring(L,i)?lua_tostring(L,i):d))

// These macros help to ensure the Lua stack is in order when
// we leave a function

#define LSG             int _lsg_=lua_gettop(L)
#define LSG_END(i)      (assert(_lsg_+(i)==lua_gettop(L)),(i))

G_END_DECLS

#endif

