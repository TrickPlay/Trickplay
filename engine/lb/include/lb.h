#ifndef _TRICKPLAY_LB_H
#define _TRICKPLAY_LB_H

#if defined(__GNUC__)
#define MIGHT_BE_UNUSED __attribute__((unused))
#else
#define MIGHT_BE_UNUSED
#endif

#include "user_data.h"
#include "assert.h"

//.........................................................................
// Like luaL_ref - takes the item at the top of the stack and adds
// a weak ref to it. It pops the item and returns the ref.

int lb_weak_ref( lua_State* L );

//.........................................................................
// Like luaL_unref - takes the ref and removes it from the weak refs table.
// If the ref is not valid, it does nothing.

void lb_weak_unref( lua_State* L , int ref );

//.........................................................................
// Pushes the value pointed to by the weak ref. If the ref is not valid, it
// will push a nil.

void lb_weak_deref( lua_State* L , int ref );

//.........................................................................

#define lb_strong_ref( L ) ( luaL_ref( L , LUA_REGISTRYINDEX ) )

#define lb_strong_unref( L , ref ) ( luaL_unref( L , LUA_REGISTRYINDEX , ref ) )

//.........................................................................
// Pushes the value pointed to by the strong ref. If the ref is not valid, it
// will push a nil.

void lb_strong_deref( lua_State* L , int ref );

//.........................................................................

#define lb_construct( t , p )           ( (t*) __ud__->initialize_with_client( p ) )

#define lb_construct_empty( )           ( (void) __ud__->initialize_empty( ) )

#define lb_construct_gobject( t , p )   ( (t*) __ud__->initialize_with_master( p ) )


#define lb_check_initialized()          ( __ud__->check_initialized() )


#define lb_get_self(L,t)                ( (t) UserData::get_client( L , 1 ) )


#define lb_finalize_user_data( L )      ( UserData::finalize( L , 1 ) )


#define lb_get_callback(L,self,name,metatable_on_top)               ( UserData::get_callback( name , L , -1 ) )

#define lb_set_callback(L,name)                                     ( UserData::set_callback( name , L ) )

#define lb_invoke_callback(L,self,metatable,name,nargs,nresults)    ( UserData::invoke_callback(self,name,nargs,nresults,L) )

#define lb_invoke_callbacks(L,self,metatable,name,nargs,nresults)   ( UserData::invoke_callbacks(self,name,nargs,nresults,L) )

#define lb_invoke_callbacks_r(L,self,metatable,name,nargs,nresults,default_ret) ( UserData::invoke_callbacks(self,name,nargs,nresults,L,default_ret) )

#define lb_callback_attached(L,self,name,index)                     ( UserData::is_callback_attached(name,L,index))

#define lb_clear_callbacks(L,index)                                 ( UserData::clear_callbacks( L , index ) )

//#define lb_wrap(L,self,metatable)    (assert(false),0)

int lb_index( lua_State* L );
int lb_newindex( lua_State* L );
void lb_inherit( lua_State* L, const char* metatable );
void lb_set_props_from_table( lua_State* L );
void lb_chain( lua_State* L, int index, const char* metatable );
bool lb_check_udata_type( lua_State* L, int index, const char* type, bool fail = true );
void* lb_get_udata_check( lua_State* L, int index, const char* type );

#define lb_checkany(L,i) (luaL_checkany(L,i),i)
#define lb_optany(L,i,d) (lua_isnone(L,i)?d:i)
#define lb_checktable(L,i) (luaL_checktype(L,i,LUA_TTABLE),i)
#define lb_opttable(L,i,d) (lua_istable(L,i)?i:d)
#define lb_checkfunction(L,i) (luaL_checktype(L,i,LUA_TFUNCTION),i)
#define lb_optfunction(L,i,d) (lua_isfunction(L,i)?i:d)

#define lb_checkudata(L,i) (luaL_checktype(L,i,LUA_TUSERDATA),i)
#define lb_optudata(L,i,d) ((lua_isuserdata(L,i)?i:d))

#define lb_optint(L,i,d) ((lua_tointeger(L,i)?lua_tointeger(L,i):(lua_isnumber(L,i)?0:d)))
#define lb_optnumber(L,i,d) ((lua_tonumber(L,i)?lua_tonumber(L,i):(lua_isnumber(L,i)?0:d)))
#define lb_optstring(L,i,d) ((lua_isstring(L,i)?lua_tostring(L,i):d))
#define lb_optbool(L,i,d) ((lua_isboolean(L,i)?lua_toboolean(L,i):d))
const char* lb_optlstring( lua_State* L, int narg, const char* def, size_t* len );

int lb_is_allowed( lua_State* L, const char* name );
void lb_allow( lua_State* L, const char* name );

// These macros help to ensure the Lua stack is in order when
// we leave a function

#define LSG             MIGHT_BE_UNUSED int _lsg_=lua_gettop(L)
#define LSG_CHECK(i)    (assert(_lsg_+(i)==lua_gettop(L)))
#define LSG_END(i)      (LSG_CHECK(i),(i))

//.........................................................................
// Lazy loading

#define LB_LAZY_LOAD    4224

// This function takes a name and a loading function - it will use this function
// to load the given global name when it is requested.

void lb_set_lazy_loader( lua_State* L, const char* name , lua_CFunction loader );

//.........................................................................

int lb_get_extra( lua_State* L );

int lb_set_extra( lua_State* L );

void lb_setglobal( lua_State* L , const char* name );

//.........................................................................

void lb_dump_table( lua_State* L );

#endif // _TRICKPLAY_LB_H
