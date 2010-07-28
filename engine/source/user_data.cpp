
#include "user_data.h"
#include "lb.h"
#include "util.h"

//.............................................................................

static DebugLog udlog( true );

//=============================================================================

UserData::Handle * UserData::Handle::make( UserData * user_data , gpointer user , GDestroyNotify user_destroy )
{
    g_assert( user_data );

    Handle * result = g_slice_new( Handle );

    udlog( "CREATING UD HANDLE %p : UD %p : MASTER : %p" , result , user_data , user_data->master );

    result->master = user_data->master;

    g_assert( result->master );

    g_object_ref( result->master );

    result->user = user;
    result->user_destroy = user_destroy;

    udlog( "CREATED UD HANDLE" );

    return result;
}

UserData::Handle * UserData::Handle::make( lua_State * L , int index , gpointer user , GDestroyNotify user_destroy )
{
    return make( UserData::get( L , index ) , user , user_destroy );
}

void UserData::Handle::destroy( gpointer _handle )
{
    g_assert( _handle );

    Handle * handle = Handle::get( _handle );

    udlog( "DESTROYING UD HANDLE %p : MASTER %p" , handle , handle->master );

    if ( handle->user_destroy )
    {
        handle->user_destroy( handle->user );
    }

    g_object_unref( handle->master );

    g_slice_free( Handle , handle );

    udlog( "DESTROYED UD HANDLE" );
}

lua_State * UserData::Handle::get_lua_state()
{
    UserData * ud = UserData::get( master );

    return ud ? ud->L : 0;
}

int UserData::Handle::invoke_callback( const char * name , int nresults )
{
    UserData * ud = UserData::get( master );

    return ud ? ud->invoke_callback( name , 0 , nresults ) : 0;
}

//=============================================================================

UserData * UserData::make( lua_State * L )
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
    result->signals = 0;

    // Duplicate the user data that is already on top of the stack and take a
    // strong reference to it.

    lua_pushvalue( L , -1 );

    result->proxy_ref = lb_strong_ref( L );
    result->proxy_ref_type = STRONG;

    g_assert( result->proxy_ref != LUA_REFNIL && result->proxy_ref != LUA_NOREF );

    udlog( "CREATED USER DATA %p" , result );

    LSG_CHECK( 1 );

    return result;
}

//.............................................................................

gpointer UserData::initialize_empty()
{
    return UserData::initialize_with_client( 0 );
}

//.............................................................................

gpointer UserData::initialize_with_master( gpointer _master )
{
    udlog( "SETTING MASTER FOR UD %p TO %p", this , _master );

    g_assert( _master );

    g_assert( G_IS_OBJECT( _master ) );

    // This can only be called once. We fail if a master already exists

    g_assert( master == 0 );

    g_assert( ! initialized );

    master = G_OBJECT( _master );

    // If the new master has a floating ref, we sink it now. If it is
    // not floating, it should have at least one ref and we assume
    // ownership of it.

    if ( g_object_is_floating( master ) )
    {
        g_object_ref_sink( master );
    }

    return initialize_with_client( _master );
}

//.............................................................................

gpointer UserData::initialize_with_client( gpointer _client )
{
    udlog( "INITIALIZING UD %p : MASTER %p : CLIENT %p" , this , master , _client );

    // Make sure it only gets called once

    g_assert( ! initialized );

    initialized = true;

    g_assert( proxy_ref_type == STRONG );

    // If there is no master object, create one now

    if ( ! master )
    {
        master = G_OBJECT( g_object_new( G_TYPE_OBJECT , 0 ) );

        g_assert( master );

        udlog( "  CREATED NEW MASTER %p" , master );
    }

    client = _client;

    if ( ! client )
    {
        client = master;

        udlog( "  USING MASTER AS CLIENT" );
    }

    g_hash_table_insert( get_client_map() , client , master );

    // Add us to the master - so we can be reached through it while
    // we are alive.

    g_object_set_qdata( master , get_key_quark() , this );

    // The object should have at least one strong ref. We add our toggle ref.

    udlog( "  ADDING MASTER TOGGLE REF" );

    g_object_add_toggle_ref( master , ( GToggleNotify ) toggle_notify , this );

    // Now, remove the strong ref

    // If this makes the toggle ref the last one, we should end up with a
    // weak ref to the Lua proxy - which means it can be collected.

    udlog( "  REMOVING MASTER STRONG REF" );

    g_object_unref( master );

    udlog( "INITIALIZED" );

    return client;
}

//.............................................................................

void UserData::check_initialized()
{
    g_assert( initialized );
    g_assert( L );
    g_assert( master );
    g_assert( client );
    g_assert( UserData::get( master ) == this );
    g_assert( g_hash_table_lookup( get_client_map() , client ) == master );
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

        lb_strong_deref( self->L , self->proxy_ref );

        g_assert( ! lua_isnil( self->L , -1 ) );

        // Create a weak ref to it - which pops it

        int weak_ref = lb_weak_ref( self->L );

        g_assert( weak_ref != LUA_REFNIL && weak_ref != LUA_NOREF );

        // Remove the strong ref

        lb_strong_unref( self->L , self->proxy_ref );

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

        lb_weak_deref( self->L , self->proxy_ref );

        g_assert( ! lua_isnil( self->L , -1 ) );

        // Create a strong ref to it - which pops it

        int strong_ref = lb_strong_ref( self->L );

        g_assert( strong_ref != LUA_REFNIL && strong_ref != LUA_NOREF );

        // Remove the weak ref

        lb_weak_unref( self->L , self->proxy_ref );

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

        // Disconnect all signals

        self->disconnect_all_signals();

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

    lb_strong_unref( L , self->callbacks_ref );

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

    lb_strong_deref( L , self->callbacks_ref );

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
        self->callbacks_ref = lb_strong_ref( L );

        LSG_CHECK( 0 );
    }

    // Now the callbacks table is at the top of the stack. We need to use our
    // proxy Lua object to get the table of functions.

    self->push_proxy();

    lua_rawget( L , -2 );

    if ( lua_isnil( L , -1  ) )
    {
        // The table of functions is not there, we have to create it

        lua_pop( L , 1 );

        lua_newtable( L );

        self->push_proxy();
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

    lb_strong_deref( L , callbacks_ref );

    // We don't have a callbacks table, so we just leave the nil on the stack

    if ( lua_isnil( L , -1 ) )
    {
        LSG_CHECK( 1 );
        return 1;
    }

    // We do have a callbacks table, fetch the functions table

    push_proxy();
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

void UserData::clear_callbacks( lua_State * L , int index )
{
    UserData * self = UserData::get( L , index );

    lb_strong_unref( L , self->callbacks_ref );

    self->callbacks_ref = LUA_NOREF;
}

//.............................................................................

void UserData::push_proxy()
{
    if ( proxy_ref_type == STRONG )
    {
        lb_strong_deref( L , proxy_ref );
    }
    else
    {
        lb_weak_deref( L , proxy_ref );
    }

    g_assert( ! lua_isnil( L , -1 ) );
}

//.............................................................................

int UserData::invoke_callback( const char * name , int nargs , int nresults )
{
    g_assert( name );

    LSG;

    // This will push the callback (or nil) onto the stack

    get_callback( name );

    if ( lua_isnil( L , -1 ) )
    {
        lua_pop( L , nargs + 1 );

        LSG_CHECK( -nargs );

        return 0;
    }

    // nargs : callback

    push_proxy();

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

//.............................................................................

int UserData::invoke_callback( GObject * master , const char * name , int nargs , int nresults, lua_State * L )
{
    g_assert( master );
    g_assert( L );

    LSG;

    // Now, we get the user data from the master object. If Lua has gone away,
    // it won't be there. (But neither will the master in the client map).

    UserData * self = UserData::get( master );

    if ( ! self )
    {
        lua_pop( L , nargs );

        LSG_CHECK( -nargs );

        return 0;
    }

    g_assert( L == self->L );

    return self->invoke_callback( name , nargs , nresults );
}

//.............................................................................

int UserData::invoke_callback( gpointer client , const char * name , int nargs , int nresults, lua_State * L )
{
    g_assert( client );

    LSG;

    // Using the client pointer, we get the master from the client map
    // If it is not there, we bail. Because of that, this cannot be called
    // before initialize.

    gpointer master = g_hash_table_lookup( get_client_map() , client );

    if ( ! master )
    {
        lua_pop( L , nargs );

        LSG_CHECK( -nargs );

        return 0;
    }

    return UserData::invoke_callback( G_OBJECT( master ) , name , nargs , nresults , L );
}

//.............................................................................

void UserData::connect_signal( const gchar * name, const gchar * detailed_signal, GCallback handler, gpointer data, int flags )
{
    g_assert( master );

    SignalMap::iterator it;

    if ( ! signals )
    {
        signals = new SignalMap;

        it = signals->end();
    }
    else
    {
        it = signals->find( name );
    }

    gulong id = g_signal_connect_data( master , detailed_signal , handler , data , 0 , GConnectFlags( flags ) );

    if ( it != signals->end() )
    {
        g_signal_handler_disconnect( master , it->second );

        it->second = id;
    }
    else
    {
        signals->insert( std::make_pair( name , id ) );
    }
}

//.............................................................................

void UserData::connect_signal_if( bool condition , const gchar * name, const gchar * detailed_signal, GCallback handler, gpointer data, int flags )
{
    g_assert( master );

    if ( condition )
    {
        connect_signal( name , detailed_signal , handler , data , flags );
    }
    else
    {
        disconnect_signal( name );
    }
}

//.............................................................................

void UserData::disconnect_signal( const gchar * name )
{
    g_assert( master );

    if ( signals )
    {
        SignalMap::iterator it = signals->find( name );

        if ( it != signals->end() )
        {
            g_signal_handler_disconnect( master , it->second );

            signals->erase( it );
        }
    }
}

//.............................................................................

void UserData::disconnect_all_signals()
{
    if ( signals )
    {
        for ( SignalMap::const_iterator it = signals->begin(); it != signals->end(); ++it )
        {
            g_signal_handler_disconnect( master , it->second );
        }

        delete signals;

        signals = 0;
    }
}

//.............................................................................

void UserData::dump_cb( lua_State * L , int index )
{
    int cb = UserData::get( L , index )->callbacks_ref;

    g_debug( "DUMPING CALLBACKS" );

    lb_strong_deref( L , cb );

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


