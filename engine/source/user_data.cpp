
#include "stdlib.h"
#include "user_data.h"
#include "lb.h"
#include "util.h"
#include "profiler.h"
#include <string.h>

//=============================================================================

#define TP_LOG_DOMAIN   "USERDATA"
#define TP_LOG_ON       false
#define TP_LOG2_ON      false

#include "log.h"

//=============================================================================

UserData::Handle* UserData::Handle::make( UserData* user_data , gpointer user , GDestroyNotify user_destroy )
{
    g_assert( user_data );

    Handle* result = g_slice_new( Handle );

    tplog( "CREATING UD HANDLE %p : UD %p : MASTER : %p" , result , user_data , user_data->master );

    result->master = user_data->master;

    g_assert( result->master );

    g_object_ref( result->master );

    result->user = user;
    result->user_destroy = user_destroy;

    tplog2( "CREATED UD HANDLE" );

    return result;
}

UserData::Handle* UserData::Handle::make( lua_State* L , int index , gpointer user , GDestroyNotify user_destroy )
{
    return make( UserData::get( L , index ) , user , user_destroy );
}

void UserData::Handle::destroy( gpointer _handle )
{
    g_assert( _handle );

    Handle* handle = Handle::get( _handle );

    tplog( "DESTROYING UD HANDLE %p : MASTER %p" , handle , handle->master );

    if ( handle->user_destroy )
    {
        handle->user_destroy( handle->user );
    }

    g_object_unref( handle->master );

    g_slice_free( Handle , handle );

    tplog2( "DESTROYED UD HANDLE" );
}

lua_State* UserData::Handle::get_lua_state()
{
    UserData* ud = UserData::get( master );

    return ud ? ud->L : 0;
}

int UserData::Handle::invoke_callback( const char* name , int nresults )
{
    UserData* ud = UserData::get( master );

    return ud ? ud->invoke_callback( name , 0 , nresults ) : 0;
}

int UserData::Handle::invoke_callbacks( const char* name , int nresults , int default_ret )
{
    UserData* ud = UserData::get( master );

    return ud ? ud->invoke_callbacks( name , 0 , nresults , default_ret ) : 0;
}

//=============================================================================

#ifdef TP_PROFILING

class UserData::GCTag : public RefCounted
{
public:

    GCTag( UserData* _ud , const gchar* _comment )
        :
        udata( _ud ),
        master( _ud->get_master() ),
        client( _ud->get_client() ),
        comment( _comment )
    {
        const gchar* _type = _ud->get_type();

        type = _type ? _type : "<unknown>";

        if ( master )
        {
            ref();

            g_object_set_data_full( master , "tp-gctag" , this , master_destroyed );
        }
    }

    virtual ~GCTag()
    {
        //      g_debug( "[GCTAG] TAG DESTROYED %p (%p,%p,%s) : %s" , udata , master , client , type.c_str() , comment.c_str() );
    }

    static void master_destroyed( gpointer g )
    {
        GCTag* self = ( GCTag* ) g;

        g_debug( "[GCTAG] MASTER DESTROYED %p (%p,%p,%s) : %s" , self->udata , self->master , self->client , self->type.c_str() , self->comment.c_str() );

        self->unref();
    }

    void finalized()
    {
        g_debug( "[GCTAG] USER DATA FINALIZED %p (%p,%p,%s) : %s" , udata , master , client , type.c_str() , comment.c_str() );
    }

    UserData*   udata;
    GObject*    master;
    gpointer    client;
    String      type;
    String      comment;
};

#endif

//=============================================================================

UserData* UserData::make( lua_State* L , const gchar* type )
{
    LSG;

    g_assert( L );

    UserData* result = ( UserData* ) lua_newuserdata( L , sizeof( UserData ) );

    g_assert( result );

    result->L = L;
    result->type = type ? g_strdup( type ) : 0;
    result->master = 0;
    result->client = 0;
    result->initialized = false;
    result->signals = 0;

#ifdef TP_PROFILING
    result->gctag = 0;
#endif

    // Duplicate the user data that is already on top of the stack and take a
    // strong reference to it.

    lua_pushvalue( L , -1 );

    result->strong_ref = lb_strong_ref( L );

    // Now take a weak ref

    lua_pushvalue( L , -1 );

    result->weak_ref = lb_weak_ref( L );

    g_assert( result->strong_ref != LUA_REFNIL && result->strong_ref != LUA_NOREF );
    g_assert( result->weak_ref != LUA_REFNIL && result->weak_ref != LUA_NOREF );

    tplog( "CREATED '%s' USER DATA %p" , result->type , result );

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
    tplog( "INITIALIZING '%s' UD %p : MASTER %p : CLIENT %p" , type , this , master , _client );

    // Make sure it only gets called once

    g_assert( ! initialized );

    initialized = true;

    //initialize callback list mapping

    callback_lists = g_hash_table_new( g_str_hash, g_str_equal );

    // If there is no master object, create one now

    if ( ! master )
    {
        master = G_OBJECT( g_object_new( G_TYPE_OBJECT , 0 ) );

        g_assert( master );

        tplog2( "  CREATED NEW MASTER %p" , master );
    }

    client = _client;

    if ( ! client )
    {
        client = master;

        tplog2( "  USING MASTER AS CLIENT" );
    }

    g_hash_table_insert( get_client_map() , client , master );

    // Add us to the master - so we can be reached through it while
    // we are alive.

    g_object_set_qdata( master , get_key_quark() , this );

    // The object should have at least one strong ref. We add our toggle ref.

    tplog2( "  ADDING MASTER TOGGLE REF" );

    g_object_add_toggle_ref( master , ( GToggleNotify ) toggle_notify , this );

    // Now, remove the strong ref

    // If this makes the toggle ref the last one, we should end up with a
    // weak ref to the Lua proxy - which means it can be collected.

    tplog2( "  REMOVING MASTER STRONG REF" );

    g_object_unref( master );

    tplog2( "INITIALIZED" );

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

void UserData::toggle_notify( UserData* self , GObject* master , gboolean is_last_ref )
{
    g_assert( self );
    g_assert( self->master == master );

    tplog( "TOGGLE PROXY REF FOR '%s' UD %p : MASTER %p : LAST = %s" , self->type , self , master , is_last_ref ? "TRUE" : "FALSE" );

    if ( is_last_ref )
    {
        // Switch to a weak ref to the proxy object

        if ( self->strong_ref == LUA_NOREF )
        {
            tplog( "  >>>>>>>>>> STRONG REF IS NOT THERE" );
            return;
        }

        // Remove the strong ref

        lb_strong_unref( self->L , self->strong_ref );

        // Set our state

        self->strong_ref = LUA_NOREF;

        tplog2( "  SWITCHED TO WEAK PROXY REF" );
    }
    else
    {
        // Switch to a strong ref to the proxy object

        g_assert( self->strong_ref == LUA_NOREF );

        // Get the value for the weak ref

        lb_weak_deref( self->L , self->weak_ref );

        if ( lua_isnil( self->L , -1 ) )
        {
            tplog( "  >>>>>>>>>> WEAK REF IS GONE!" );
            lua_pop( self->L, 1 );
            return;
        }

        // Create a strong ref to it - which pops it

        self->strong_ref = lb_strong_ref( self->L );

        g_assert( self->strong_ref != LUA_REFNIL && self->strong_ref != LUA_NOREF );

        tplog2( "  SWITCHED TO STRONG PROXY REF" );
    }
}

//.............................................................................

void unref_and_free_callback( gpointer value , gpointer data )
{
    int* refptr = ( int* ) value;
    lb_strong_unref( ( lua_State* ) data , *refptr );
    g_free( refptr );
}

void unref_and_free_callbacks( gpointer key , gpointer value , gpointer data )
{
    GSList* callback_list = ( GSList* ) value;
    g_slist_foreach( callback_list , unref_and_free_callback , data );
    g_slist_free( callback_list );
}

void UserData::finalize( lua_State* L , int index )
{
    UserData* self = UserData::get( L , index );

    tplog( "FINALIZING '%s' UD %p : MASTER %p : CLIENT %p" , self->type , self , self->master , self->client );

    // unreference callbacks and free callback_lists

    g_hash_table_foreach( self->callback_lists , unref_and_free_callbacks , L );
    g_hash_table_destroy( self->callback_lists );

    if ( self->master )
    {
        // Remove us from the master

        g_object_set_qdata( self->master , get_key_quark() , 0 );

        // Disconnect all signals

        self->disconnect_all_signals();

        // Remove the toggle ref, which should then free the master object
        // (Unless someone else still has a ref to it)

        tplog2( "  REMOVING TOGGLE REF" );

        g_object_remove_toggle_ref( self->master , ( GToggleNotify ) toggle_notify , self );
    }

    // Remove the client from the client map

    if ( self->client )
    {
        tplog2( "  REMOVING CLIENT %p" , self->client );

        g_hash_table_remove( get_client_map() , self->client );
    }

    lb_weak_unref( L , self->weak_ref );

    // Get rid of the type

    g_free( self->type );

    // Clear everything so double frees are easier to spot.

    self->L = ( lua_State* ) 0xDEADBEEF;
    self->type = ( gchar* ) 0xDEADBEEF;
    self->master = ( GObject* ) 0xDEADBEEF;
    self->client = ( gpointer ) 0xDEADBEEF;
    self->weak_ref = LUA_NOREF;
    self->strong_ref = LUA_NOREF;

#ifdef TP_PROFILING

    if ( self->gctag )
    {
        self->gctag->finalized();
        self->gctag->unref();
        self->gctag = 0;
    }

#endif

    tplog2( "FINALIZED" );
}

//.............................................................................

bool UserData::callback_attached( const char* name )
{
    return g_hash_table_lookup( callback_lists, name );
}

//.............................................................................

int UserData::set_callback( const char* name , lua_State* L , int index , int function_index )
{
    LSG;

    int me = abs_index( L , index );

    int fn = abs_index( L , function_index );

    lua_getuservalue( L , index );

    if ( lua_isnil( L , -1 ) )
    {
        lua_pop( L , 1 );

        lua_newtable( L );
        lua_pushvalue( L , -1 );
        lua_setuservalue( L , me );
    }

    lua_pushstring( L , name );
    lua_pushvalue( L , fn );
    lua_rawset( L , -3 );

    lua_pop( L , 1 );

    LSG_CHECK( 0 );

    return lua_isnil( L , fn );
}

//...............................................................................

int UserData::add_callback( char* name , lua_State* L )
{
    assert( !lua_isnil( L , -1 ) );

    int* ref = ( int* ) malloc( sizeof( int ) );
    *ref = lb_strong_ref( L );

    GSList* callback_list = ( GSList* ) g_hash_table_lookup( callback_lists , name );
    callback_list = g_slist_prepend( callback_list , ref );
    g_hash_table_insert( callback_lists , name ,  callback_list );

    return *ref;
}

//...............................................................................

void UserData::set_last_callback( char* name , lua_State* L )
{
    GSList* callback_list = ( GSList* ) g_hash_table_lookup( callback_lists , name );

    if ( callback_list )
    {
        callback_list = remove_last_callback( name , L );
    }

    if ( !lua_isnil( L , -1 ) )
    {
        int* ref = ( int* ) malloc( sizeof( int ) );
        *ref = lb_strong_ref( L );

        callback_list = g_slist_append( callback_list , ref );
        g_hash_table_insert( callback_lists , name ,  callback_list );
    }
}

//.............................................................................

int UserData::get_last_callback( char* name , lua_State* L )
{
    GSList* callback_list = ( GSList* ) g_hash_table_lookup( callback_lists, name );

    if ( callback_list )
    {
        int ref = *( int* ) g_slist_last( callback_list )->data;
        lb_strong_deref( L , ref );
    }
    else
    {
        lua_pushnil( L );
    }

    return 1;

}

//.............................................................................

gint find_ref( gconstpointer a , gconstpointer b )
{
    if ( *( int* ) a == *( int* ) b )
    {
        return 0;
    }

    return 1;
}

//.............................................................................

GSList* UserData::remove_callback( GSList* link , GSList* list , char* name , lua_State* L )
{
    int* refptr = ( int* ) link->data;
    lb_strong_unref( L , *refptr );
    g_free( refptr );
    list = g_slist_delete_link( list , link );
    g_hash_table_insert( callback_lists , name , list );
    return list;
}

//.............................................................................

void UserData::remove_callback( char* name, lua_State* L )
{
    int ref = lua_tonumber( L , -1 );
    lua_pop( L , 1 );

    GSList* callback_list = ( GSList* ) g_hash_table_lookup( callback_lists, name );
    GSList* found = NULL;

    if ( ( found = g_slist_find_custom( callback_list , &ref , find_ref ) ) )
    {
        remove_callback( found , callback_list , name , L );
    }
}

//.............................................................................

GSList* UserData::remove_last_callback( char* name , lua_State* L )
{
    GSList* callback_list = ( GSList* ) g_hash_table_lookup( callback_lists , name );
    GSList* last = g_slist_last( callback_list );

    if ( last )
    {
        callback_list = remove_callback( last , callback_list , name , L );
    }

    return callback_list;
}

//.............................................................................

int UserData::invoke_callbacks( const char* name , int nargs , int nresults , int default_ret )
{
    // does not make sense to aggregate callback results of more than 1 return value
    g_assert( nresults < 2 );
    g_assert( name );

    GSList* callback_list = ( GSList* ) g_hash_table_lookup( callback_lists, name );
    GSList* iter = NULL;

    int aggregate_result = default_ret;

    for ( iter = callback_list ; iter ; )
    {
        // save next element in case callback destroys itself
        GSList* next = iter->next;

        int ref = *( int* ) iter->data;

        // push callback on top of stack (above arguments)
        lb_strong_deref( L , ref );

        // if callback is null, clear stack and return 0
        if ( lua_isnil( L , -1 ) )
        {
            lua_pop( L , nargs + 1 );
            return 0;
        }

        // push self
        push_proxy();

        // push a copy of arguments on top of self
        for ( int i = 0 ; i < nargs ; ++i )
        {
            lua_pushvalue( L , - ( nargs + 2 ) );
        }

        if ( 0 != lua_pcall( L , nargs + 1 , nresults , 0 ) )
        {
            lua_error( L );
            // function does not return
        }

        if ( nresults > 0 )
        {
            // multiple callbacks do not allow for return types other than boolean
            // lua_toboolean returns 1 for any Lua value different from false and nil; otherwise it returns 0
            if ( default_ret == 1 )
            {
                aggregate_result &= !lua_isboolean( L , -1 ) || lua_toboolean( L , -1 );
            }
            else
            {
                aggregate_result |= lua_isboolean( L , -1 ) && lua_toboolean( L , -1 );
            }

            lua_pop( L , nresults );
        }

        iter = next;
    }

    lua_pop( L , nargs );

    if ( nresults > 0 )
    {
        lua_pushboolean( L , aggregate_result );
    }

    // success
    return 1;
}

//.............................................................................

int UserData::get_callback( const char* name )
{
    LSG;

    g_assert( name );

    push_proxy();

    lua_getuservalue( L , -1 );
    lua_remove( L , -2 );

    if ( ! lua_isnil( L , -1 ) )
    {
        lua_pushstring( L , name );
        lua_rawget( L , -2 );
        lua_remove( L , -2 );
    }

    LSG_CHECK( 1 );

    return 1;
}

//.............................................................................

int UserData::get_callback( const char* name , lua_State* L , int index )
{
    return UserData::get( L , index )->get_callback( name );
}

//.............................................................................

int UserData::is_callback_attached( const char* name , lua_State* L , int index )
{
    LSG;

    UserData::get_callback( name , L , index );

    int result = ! lua_isnil( L , -1 );

    lua_pop( L , 1 );

    LSG_END( 0 );

    return result;
}


//.............................................................................

void UserData::clear_callbacks( )
{
    push_proxy();
    clear_callbacks( L , -1 );
    lua_pop( L , 1 );
}

void UserData::clear_callbacks( lua_State* L , int index )
{
    index = abs_index( L , index );

    if ( ! lua_isnil( L , index ) )
    {
        lua_pushnil( L );
        lua_setuservalue( L , index );
    }
}

//.............................................................................

void UserData::push_proxy()
{
    if ( strong_ref != LUA_NOREF )
    {
        lb_strong_deref( L , strong_ref );
        g_assert( ! lua_isnil( L , -1 ) );
    }
    else
    {
        lb_weak_deref( L , weak_ref );
    }
}

//.............................................................................

int UserData::invoke_callback( const char* name , int nargs , int nresults )
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

    {
        // Move function to just before the arguments

        lua_insert( L , - ( nargs + 1 ) );

        // Push self

        push_proxy();

        // Move self to just before the arguments (and right after the function)

        lua_insert( L , - ( nargs + 1 ) );

        PROFILER( name, PROFILER_CALLS_TO_LUA );

        // callback : nargs

        lua_call( L , nargs + 1 , nresults );
    }

    LSG_CHECK( nresults - nargs );

    return 1;
}

//.............................................................................

int UserData::invoke_callbacks( GObject* master , const char* name , int nargs , int nresults, lua_State* L , int default_ret )
{
    g_assert( master );
    g_assert( L );

    LSG;

    // Now, we get the user data from the master object. If Lua has gone away,
    // it won't be there. (But neither will the master in the client map).

    UserData* self = UserData::get( master );

    if ( ! self )
    {
        lua_pop( L , nargs );

        LSG_CHECK( -nargs );

        return 0;
    }

    g_assert( L == self->L );

    return self->invoke_callbacks( name , nargs , nresults , default_ret );
}

int UserData::invoke_callback( GObject* master , const char* name , int nargs , int nresults, lua_State* L )
{
    g_assert( master );
    g_assert( L );

    LSG;

    // Now, we get the user data from the master object. If Lua has gone away,
    // it won't be there. (But neither will the master in the client map).

    UserData* self = UserData::get( master );

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

int UserData::invoke_callback( gpointer client , const char* name , int nargs , int nresults, lua_State* L )
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

int UserData::invoke_callbacks( gpointer client , const char* name , int nargs , int nresults, lua_State* L , int default_ret )
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

    return UserData::invoke_callbacks( G_OBJECT( master ) , name , nargs , nresults , L , default_ret );
}

//.............................................................................

int UserData::invoke_global_callback( lua_State* L , const char* global , const char* name , int nargs , int nresults )
{
    g_assert( L );
    g_assert( global );

    int result = 0;

    lua_getglobal( L , global );

    if ( lua_isnil( L , -1 ) )
    {
        lua_pop( L , nargs + 1 );
        return 0;
    }

    UserData* ud = UserData::get( L , lua_gettop( L ) );

    if ( ! ud )
    {
        lua_pop( L , nargs + 1 );
        return 0;
    }

    lua_insert( L , - ( nargs + 1 ) );

    result = ud->invoke_callback( name , nargs , nresults );

    if ( result )
    {
        lua_remove( L , - ( nresults + 1 ) );
    }
    else
    {
        lua_pop( L , 1 );
    }

    return result;
}

int UserData::invoke_global_callbacks( lua_State* L , const char* global , const char* name , int nargs , int nresults , int default_ret )
{
    g_assert( L );
    g_assert( global );

    int result = 0;

    lua_getglobal( L , global );

    if ( lua_isnil( L , -1 ) )
    {
        lua_pop( L , nargs + 1 );
        return 0;
    }

    UserData* ud = UserData::get( L , lua_gettop( L ) );

    if ( ! ud )
    {
        lua_pop( L , nargs + 1 );
        return 0;
    }

    lua_insert( L , - ( nargs + 1 ) );

    result = ud->invoke_callbacks( name , nargs , nresults , default_ret );

    if ( result )
    {
        lua_remove( L , - ( nresults + 1 ) );
    }
    else
    {
        lua_pop( L , 1 );
    }

    return result;
}

//.............................................................................

void UserData::connect_signal( const gchar* name, const gchar* detailed_signal, GCallback handler, gpointer data, int flags )
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

void UserData::connect_signal_if( bool condition , const gchar* name, const gchar* detailed_signal, GCallback handler, gpointer data, int flags )
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

void UserData::disconnect_signal( const gchar* name )
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
            if ( g_signal_handler_is_connected( master , it->second ) )
            {
                g_signal_handler_disconnect( master , it->second );
            }
        }

        delete signals;

        signals = 0;
    }
}

//.............................................................................

void UserData::dump_cb( lua_State* L , int index )
{
#if 0

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

    while ( lua_next( L , -2 ) )
    {
        g_debug( "    %s : SET" , lua_tostring( L , -2 ) );
        lua_pop( L , 1 );
    }

    lua_pop( L , 1 );

    g_debug( "END OF CALLBACKS" );
#endif
}


void UserData::dump()
{
#ifndef TP_PRODUCTION

    GHashTable* client_map = get_client_map();

    GHashTableIter it;

    g_hash_table_iter_init( & it , client_map );

    gpointer client;
    gpointer master;

    while ( g_hash_table_iter_next( & it , & client , & master ) )
    {
        UserData* ud = UserData::get( G_OBJECT( master ) );

        g_info( "%p : %p : %s" , master , client , ud->type );
    }

#endif
}

bool UserData::gc_tag( const gchar* comment )
{

#ifdef TP_PROFILING

    if ( 0 == gctag )
    {
        gctag = new GCTag( this , comment );

        return true;
    }

#endif

    return false;
}

std::string UserData::describe( lua_State* L , int index )
{
    if ( UserData* ud = get_check( L , index ) )
    {
        return Util::format( "%s (m:%p,c:%p,l:%p)" , ud->type , ud->master , ud->client , lua_topointer( L , index ) );
    }

    return Util::format( "%p" , lua_topointer( L , index ) );
}
