#ifndef _TRICKPLAY_LB2_H
#define _TRICKPLAY_LB2_H

#include "lb.h"
#include "user_data.h"

//.........................................................................
// Like luaL_ref - takes the item at the top of the stack and adds
// a weak ref to it. It pops the item and returns the ref.

int lb2_weak_ref( lua_State * L );

//.........................................................................
// Like luaL_unref - takes the ref and removes it from the weak refs table.
// If the ref is not valid, it does nothing.

void lb2_weak_unref( lua_State * L , int ref );

//.........................................................................
// Pushes the value pointed to by the weak ref. If the ref is not valid, it
// will push a nil.

void lb2_weak_deref( lua_State * L , int ref );

//.........................................................................

#define lb2_strong_ref( L ) ( luaL_ref( L , LUA_REGISTRYINDEX ) )

#define lb2_strong_unref( L , ref ) ( luaL_unref( L , LUA_REGISTRYINDEX , ref ) )

//.........................................................................
// Pushes the value pointed to by the strong ref. If the ref is not valid, it
// will push a nil.

void lb2_strong_deref( lua_State * L , int ref );

//.........................................................................

#undef lb_new_self

#undef lb_get_self


#define lb_construct( t , p )           ( (t*) __ud__->initialize_with_client( p ) )

#define lb_construct_empty( )           ( (void) __ud__->initialize_empty( ) )

#define lb_construct_gobject( t , p )   ( (t*) __ud__->initialize_with_master( p ) )


#define lb_check_initialized()          ( __ud__->check_initialized() )


#define lb_get_self(L,t)                ( (t) UserData::get_client( L , 1 ) )


#define lb_finalize_user_data( L )      ( UserData::finalize( L , 1 ) )


#define lb_get_callback(L,self,name,metatable_on_top)               ( UserData::get_callback( name , L , -1 ) )

#define lb_set_callback(L,self,name)                                ( UserData::set_callback( name , L ) )

#define lb_invoke_callback(L,self,metatable,name,nargs,nresults)    ( UserData::invoke_callback(self,name,nargs,nresults,L) )

#define lb_callback_attached(L,self,name,index)                     ( UserData::is_callback_attached(name,L,index))

#define lb_clear_callbacks(L)                                       ( UserData::clear_callbacks( L , 1 ) )

//.........................................................................

#endif // _TRICKPLAY_LB2_H
