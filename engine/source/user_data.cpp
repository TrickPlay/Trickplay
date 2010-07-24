
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
    result->callbacks = 0;

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

    // Delete the callback map

    if ( self->callbacks )
    {
        udlog( "  CLEARING CALLBACKS" );

        // TODO : we should unref the functions

        delete self->callbacks;
    }

    // Clear everything so double frees are easier to spot.

    self->L = ( lua_State * ) 0xDEADBEEF;
    self->master = ( GObject * ) 0xDEADBEEF;
    self->client = ( gpointer ) 0xDEADBEEF;
    self->proxy_ref = LUA_NOREF;
    self->callbacks = ( CallbackMap * ) 0xDEADBEEF;

    udlog( "FINALIZED" );
}

//.............................................................................

int UserData::set_callback( const char * name , lua_State * L , int index , int function_index )
{
    LSG;

    UserData * self = UserData::get( L , index );

    if ( 0 == self->callbacks )
    {
        self->callbacks = new CallbackMap;
    }

    int isnil = lua_isnil( L , function_index );

    CallbackMap::iterator it = self->callbacks->find( name );

    // If it already exists

    if ( it != self->callbacks->end() )
    {
        // unref the old one

        lb2_strong_unref( L , it->second );

        // If it is being unset, we remove it

        if ( isnil )
        {
            self->callbacks->erase( it );
        }

        // Otherwise, we set it to the new one

        else
        {
            lua_pushvalue( L , function_index );

            it->second = lb2_strong_ref( L );
        }
    }
    else if ( ! isnil )
    {
        lua_pushvalue( L , function_index );

        self->callbacks->insert( std::make_pair( name , lb2_strong_ref( L ) ) );
    }

    LSG_CHECK( 0 );

    return isnil;
}

//.............................................................................

int UserData::get_callback( const char * name )
{
    g_assert( name );

    if ( 0 == callbacks )
    {
        lua_pushnil( L );
    }
    else
    {
        CallbackMap::const_iterator it = callbacks->find( name );

        if ( it == callbacks->end() )
        {
            lua_pushnil( L );
        }
        else
        {
            lb2_strong_deref( L , it->second );
        }
    }

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

