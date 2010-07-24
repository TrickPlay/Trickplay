
#include "app.h" // To get LSP

#include "lb2.h"

//.............................................................................

static DebugLog udlog( true );

//.............................................................................

gpointer * UserData::make( lua_State * L )
{
    LSG;

    g_assert( L );

    UserData * result = ( UserData * ) lua_newuserdata( L , sizeof( UserData ) );

    g_assert( result );

    result->L = L;
    result->master = 0;
    result->client = 0;
    result->initialized = false;
    result->callbacks_ref = LUA_NOREF;

    // Duplicate the user data that is already on top of the stack and take a
    // strong reference to it.

    lua_pushvalue( L , -1 );

    result->proxy_ref = lb2_strong_ref( L );
    result->proxy_ref_type = STRONG;

    g_assert( result->proxy_ref != LUA_REFNIL && result->proxy_ref != LUA_NOREF );

    udlog( "CREATED USER DATA %p" , result );

    LSG_CHECK( 1 );

    return & result->client;
}

//.............................................................................

void UserData::set_master( gpointer new_master , lua_State * L , int index )
{
    UserData * self = UserData::get( L , index );

    udlog( "SETTING MASTER FOR UD %p TO %p", self , new_master );

    g_assert( new_master );
    g_assert( G_IS_OBJECT( new_master ) );

    // This can only be called once. We fail if a master already exists

    g_assert( self->master == 0 );

    g_assert( ! self->initialized );

    self->master = G_OBJECT( new_master );

    // If the new master has a floating ref, we sink it now. If it is
    // not floating, it should have at least one ref and we assume
    // ownership of it.

    if ( g_object_is_floating( self->master ) )
    {
        g_object_ref_sink( self->master );
    }
}

//.............................................................................

void UserData::initialize( lua_State * L , int index )
{
    UserData * self = UserData::get( L , index );

    udlog( "INITIALIZING UD %p : MASTER %p : CLIENT %p" , self , self->master , self->client );

    // Make sure it only gets called once

    g_assert( ! self->initialized );

    self->initialized = true;

    g_assert( self->proxy_ref_type == STRONG );

    // If there is no master object, create one now

    if ( ! self->master )
    {
        self->master = G_OBJECT( g_object_new( G_TYPE_OBJECT , 0 ) );

        g_assert( self->master );

        udlog( "  CREATED NEW MASTER %p" , self->master );
    }
    else
    {
        udlog( "  USING MASTER %p" , self->master );
    }

    // Add the client to the client map, so we can get the master from
    // the client.

    if ( self->client )
    {
        g_hash_table_insert( get_client_map() , self->client , self->master );
    }

    // Add us to the master - so we can be reached through it while
    // we are alive.

    g_object_set_qdata( self->master , get_key_quark() , self );

    // The object should have at least one strong ref. We add our toggle ref.

    udlog( "  ADDING MASTER TOGGLE REF" );

    g_object_add_toggle_ref( self->master , ( GToggleNotify ) toggle_notify , self );

    // Now, remove the strong ref

    // If this makes the toggle ref the last one, we should end up with a
    // weak ref to the Lua proxy - which means it can be collected.

    udlog( "  REMOVING MASTER STRONG REF" );

    g_object_unref( self->master );

    udlog( "INITIALIZED" );
}

//.............................................................................

void UserData::toggle_notify( UserData * self , GObject * master , gboolean is_last_ref )
{
    udlog( "TOGGLE PROXY REF FOR UD %p : MASTER %p : LAST = %s" , self , master , is_last_ref ? "TRUE" : "FALSE" );

    g_assert( self );
    g_assert( self->master == master );

    if ( is_last_ref )
    {
        // Switch to a weak ref to the proxy object

        g_assert( self->proxy_ref_type == STRONG );

        // Get the value for the strong ref

        lb2_strong_deref( self->L , self->proxy_ref );

        g_assert( ! lua_isnil( self->L , -1 ) );

        // Create a weak ref to it - which pops it

        int weak_ref = lb2_weak_ref( self->L );

        g_assert( weak_ref != LUA_REFNIL && weak_ref != LUA_NOREF );

        // Remove the strong ref

        lb2_strong_unref( self->L , self->proxy_ref );

        // Set our state

        self->proxy_ref = weak_ref;

        self->proxy_ref_type = WEAK;

        udlog( "  SWITCHED TO WEAK PROXY REF" );
    }
    else
    {
        // Switch to a strong ref to the proxy object

        g_assert( self->proxy_ref_type == WEAK );

        // Get the value for the weak ref

        lb2_weak_deref( self->L , self->proxy_ref );

        g_assert( ! lua_isnil( self->L , -1 ) );

        // Create a strong ref to it - which pops it

        int strong_ref = lb2_strong_ref( self->L );

        g_assert( strong_ref != LUA_REFNIL && strong_ref != LUA_NOREF );

        // Remove the weak ref

        lb2_weak_unref( self->L , self->proxy_ref );

        // Set our state

        self->proxy_ref = strong_ref;

        self->proxy_ref_type = STRONG;

        udlog( "  SWITCHED TO STRONG PROXY REF" );
    }
}

//.............................................................................

void UserData::finalize( lua_State * L , int index )
{
    UserData * self = UserData::get( L , index );

    udlog( "FINALIZING UD %p : MASTER %p : CLIENT %p" , self , self->master , self->client );

    if ( self->master )
    {
        // Remove us from the master

        g_object_set_qdata( self->master , get_key_quark() , 0 );

        // Remove the toggle ref, which should then free the master object
        // (Unless someone else still has a ref to it)

        udlog( "  REMOVING TOGGLE REF" );

        g_object_remove_toggle_ref( self->master , ( GToggleNotify ) toggle_notify , self );
    }

    // Remove the client from the client map

    if ( self->client )
    {
        udlog( "  REMOVING CLIENT %p" , self->client );

        g_hash_table_remove( get_client_map() , self->client );
    }

    // Unref the callback table. We don't care if it is LUA_NOREF, because
    // luaL_unref will deal with it gracefully.

    udlog( "  CLEARING CALLBACKS" );

    lb2_strong_unref( L , self->callbacks_ref );

    // Clear everything so double frees are easier to spot.

    self->L = ( lua_State * ) 0xDEADBEEF;
    self->master = ( GObject * ) 0xDEADBEEF;
    self->client = ( gpointer ) 0xDEADBEEF;
    self->proxy_ref = LUA_NOREF;
    self->callbacks_ref = LUA_NOREF;

    udlog( "FINALIZED" );
}

//.............................................................................
// Copied from lauxlib.c

#define abs_index(L, i) ((i) > 0 || (i) <= LUA_REGISTRYINDEX ? (i) : lua_gettop(L) + (i) + 1)

//.............................................................................

/*

    If the functions reference the user data, they won't be collected. This is
    a known problem that is solved by Ephemerons in 5.2.

    http://www.inf.puc-rio.br/~roberto/docs/ry08-06.pdf


    callbacks_ref ( strong ) =
    {
        user data (weak) =
        {
            callback name 1 = function ,
            callback name 2 = function
        }
    }

*/

int UserData::set_callback( const char * name , lua_State * L , int index , int function_index )
{
    LSG;

    UserData * self = UserData::get( L , index );

    int fn = abs_index( L , function_index );

    lb2_strong_deref( L , self->callbacks_ref );

    if ( lua_isnil( L , -1 ) )
    {
        LSG;

        // The callbacks table does not exist, we need to create it

        // Get rid of the nil

        lua_pop( L , 1 );

        // Create the table

        // This table will have a single entry:
        // The key is a ref to our proxy, and it is weak
        // The value is a table of callbacks, where each key is the name and the value is the function

        lua_newtable( L );

        // Create a metatable for it so that the key is weak

        lua_newtable( L );
        lua_pushstring( L , "__mode" );
        lua_pushstring( L , "k" );
        lua_rawset( L , -3 );
        lua_setmetatable( L , -2 );

        // Get a ref to the table and save it

        lua_pushvalue( L , -1 );
        self->callbacks_ref = lb2_strong_ref( L );

        LSG_CHECK( 0 );
    }

    // Now the callbacks table is at the top of the stack. We need to use our
    // proxy Lua object to get the table of functions.

    self->deref_proxy();

    lua_rawget( L , -2 );

    if ( lua_isnil( L , -1  ) )
    {
        // The table of functions is not there, we have to create it

        lua_pop( L , 1 );

        lua_newtable( L );

        self->deref_proxy();
        lua_pushvalue( L , -2 );
        lua_rawset( L , -4 );
    }

    // Now, we have the callbacks table followed by the functions table

    lua_remove( L , -2 );

    // Only the functions table left on top


    int isnil = lua_isnil( L , fn );

    // Set the new function in the functions table

    lua_pushstring( L , name );
    lua_pushvalue( L , fn );
    lua_rawset( L , -3 );

    // Pop the functions table

    lua_pop( L , 1 );

    LSG_CHECK( 0 );

    return isnil;
}

//.............................................................................

int UserData::get_callback( const char * name )
{
    LSG;

    g_assert( name );

    lb2_strong_deref( L , callbacks_ref );

    // We don't have a callbacks table, so we just leave the nil on the stack

    if ( lua_isnil( L , -1 ) )
    {
        LSG_CHECK( 1 );
        return 1;
    }

    // We do have a callbacks table, fetch the functions table

    deref_proxy();
    lua_rawget( L , -2 );

    lua_remove( L , -2 );

    if ( lua_isnil( L , -1 ) )
    {
        LSG_CHECK( 1 );
        return 1;
    }

    // We do have the functions table, get the function

    lua_pushstring( L , name );
    lua_rawget( L , -2 );

    lua_remove( L , -2 );

    LSG_CHECK( 1 );
    return 1;
}

//.............................................................................

int UserData::get_callback( const char * name , lua_State * L , int index )
{
    return UserData::get( L , index )->get_callback( name );
}

//.............................................................................

int UserData::is_callback_attached( const char * name , lua_State * L , int index )
{
    LSG;

    UserData::get_callback( name , L , index );

    int result = ! lua_isnil( L , -1 );

    lua_pop( L , 1 );

    LSG_END( 0 );

    return result;
}

//.............................................................................

void UserData::deref_proxy()
{
    if ( proxy_ref_type == STRONG )
    {
        lb2_strong_deref( L , proxy_ref );
    }
    else
    {
        lb2_weak_deref( L , proxy_ref );
    }

    g_assert( ! lua_isnil( L , -1 ) );
}

//.............................................................................

int UserData::invoke_callback( gpointer client , const char * name , int nargs , int nresults, lua_State * L )
{
    g_assert( client );
    g_assert( name );
    g_assert( L );

    LSG;

    // Using the client pointer, we get the master from the client map
    // If it is not there, we bail. Because of that, this cannot be called
    // before finalize.

    gpointer master = g_hash_table_lookup( get_client_map() , client );

    if ( ! master )
    {
        lua_pop( L , nargs );

        LSG_CHECK( -nargs );

        return 0;
    }

    // Now, we get the user data from the master object. If Lua has gone away,
    // it won't be there. (But neither will the master in the client map).

    UserData * self = ( UserData * ) g_object_get_qdata( G_OBJECT( master ) , get_key_quark() );

    if ( ! self )
    {
        lua_pop( L , nargs );

        LSG_CHECK( -nargs );

        return 0;
    }

    g_assert( L == self->L );

    // This will push the callback (or nil) onto the stack

    self->get_callback( name );

    if ( lua_isnil( L , -1 ) )
    {
        lua_pop( L , nargs + 1 );

        LSG_CHECK( -nargs );

        return 0;
    }

    // nargs : callback

    self->deref_proxy();

    // nargs : callback : proxy

    // Move the proxy before the arguments

    lua_insert( L , - ( nargs + 2 ) );

    // proxy : nargs : callback

    // Move the callback before the proxy

    lua_insert( L , - ( nargs + 2 ) );

    // callback : proxy : nargs

    lua_call( L , nargs + 1 , nresults );

    LSG_CHECK( nresults - nargs );

    return 1;
}


void UserData::dump_cb( lua_State * L , int index )
{
    int cb = UserData::get( L , index )->callbacks_ref;

    g_debug( "DUMPING CALLBACKS" );

    lb2_strong_deref( L , cb );

    if ( lua_isnil( L , -1 ) )
    {
        lua_pop( L , 1 );
        g_debug( "  NO CALLBACKS TABLE" );
        return;
    }

    lua_pushnil( L );

    if ( ! lua_next( L , -2 ) )
    {
        lua_pop( L , 1 );
        g_debug( "  NO ENTRY IN CALLBACKS TABLE" );
        return;
    }

    g_debug( "  USER DATA IS %p" , lua_touserdata( L , -2 ) );

    lua_remove( L , -2 );
    lua_remove( L , -2 );

    lua_pushnil( L );

    while( lua_next( L , -2 ) )
    {
        g_debug( "    %s : SET" , lua_tostring( L , -2 ) );
        lua_pop( L , 1 );
    }

    lua_pop( L , 1 );

    g_debug( "END OF CALLBACKS" );
}
