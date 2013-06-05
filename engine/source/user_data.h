#ifndef _TRICKPLAY_USER_DATA_H
#define _TRICKPLAY_USER_DATA_H

#include "glib.h"
#include "glib-object.h"

#include "lua.h"
#include "lauxlib.h"

#include <string>
#include <map>

struct UserData
{
    //.........................................................................
    // A handle to a user data takes a strong ref on the user data's master
    // object - therefore keeping everything alive as long as it is
    // outstanding.
    //
    // Handles have a destroy function, so it is easy to create one and put it
    // in the glib main loop. When you do that, always pass
    // UserData::Handle::destroy as the destroy notify for glib.
    //
    // You can also chain a different pointer and your own destroy notify to it.

    struct Handle
    {
        //.....................................................................
        // Create one from a user data you have.

        static Handle* make( UserData* user_data , gpointer user = 0 , GDestroyNotify user_destroy = 0 );

        //.....................................................................
        // Creates one from a user data on the stack.

        static Handle* make( lua_State* L , int index = 1 , gpointer user = 0 , GDestroyNotify user_destroy = 0 );

        //.....................................................................
        // Just a cast.

        inline static Handle* get( gpointer handle )
        {
            return ( Handle* ) handle;
        }

        //.....................................................................
        // Destroys one

        static void destroy( gpointer handle );

        //.....................................................................
        // Gets the user pointer. If the Lua state is gone, this pointer can
        // be invalid - because it was destroyed during the finalizer for the
        // proxy object.

        inline gpointer get_user()
        {
            return user;
        }

        //.....................................................................
        // Gets the user data associated with this handle. May return NULL if
        // the Lua state is gone.

        UserData* get_user_data()
        {
            return UserData::get( master );
        }

        //.....................................................................
        // Gets the Lua state for it. It can be NULL if the Lua state is gone

        lua_State* get_lua_state();

        //.....................................................................
        // A shortcut to invoke a callback using the handle. It doesn't take
        // arguments because it assumes the owner of the handle doesn't keep
        // the Lua state - and therefore cannot push arguments.

        int invoke_callback( const char* name , int nresults = 0 );
        int invoke_callbacks( const char* name , int nresults = 0 , int default_ret = 0 );

    private:

        GObject*        master;
        gpointer        user;
        GDestroyNotify  user_destroy;
    };

    //.........................................................................
    // Creates a new user data and sets its initial state. It is not complete
    // until you call initialize.

    static UserData* make( lua_State* L , const gchar* type );

    //.........................................................................
    // Initializes the user data with a newly created GObject which is used
    // as both the master and the client pointer. Returns that new GObject.

    gpointer initialize_empty( );

    //.........................................................................
    // Initialize the user data with the given client. This one creates a new
    // master GObject. Returns the client.

    gpointer initialize_with_client( gpointer client );

    //.........................................................................
    // This one uses the provided master ( which cannot be NULL ) as both the
    // master and the client. It does not create a new GObject to serve as the
    // master. Returns the master.
    //
    // This call assumes ownership of the GObject. If it is floating, it will
    // sink it.

    gpointer initialize_with_master( gpointer master );

    //.........................................................................
    // Does a few checks to ensure a UserData is sane after it has been
    // constructed and initialized. These checks may not be valid later in the
    // life of the user data.

    void check_initialized();

    //.........................................................................
    // Returns the client associated with it.

    inline static gpointer get_client( lua_State* L , int index = 1 )
    {
        return UserData::get( L , index )->client;
    }

    //.........................................................................

    inline GObject* get_master() const
    {
        return master;
    }

    //.........................................................................

    inline gpointer get_client( ) const
    {
        return client;
    }

    //.........................................................................

    inline const char* get_type() const
    {
        return type;
    }

    //.........................................................................

    static std::string describe( lua_State* L , int index );

    //.........................................................................
    // Gets the user data from the Lua stack given the index.

    inline static UserData* get( lua_State* L , int index = 1 )
    {
        g_assert( L );

        UserData* result = ( UserData* ) lua_touserdata( L , index );

        g_assert( result );

        return result;
    }

    inline static UserData* get_check( lua_State* L , int index = 1 )
    {
        g_assert( L );

        if ( ! lua_isuserdata( L , index ) )
        {
            return 0;
        }

        if ( sizeof( UserData ) != lua_rawlen( L , index ) )
        {
            return 0;
        }

        UserData* result = ( UserData* ) lua_touserdata( L , index );

        g_assert( result );

        return result;
    }

    inline static gpointer get_client_check( lua_State* L , int index = 1 )
    {
        UserData* ud = get_check( L , index );

        return ud ? ud->client : 0;
    }

    //.........................................................................
    // Gets the user data given a master object - can return NULL if the
    // user data/Lua state are gone.

    inline static UserData* get( GObject* master )
    {
        g_assert( master );

        return ( UserData* ) g_object_get_qdata( master , get_key_quark() );
    }

    //.........................................................................

    inline static UserData* get_from_client( gpointer client )
    {
        gpointer master = g_hash_table_lookup( get_client_map() , client );

        return master ? UserData::get( G_OBJECT( master ) ) : 0;
    }

    //.........................................................................
    // Pushes the Lua proxy onto the stack - whether it is weak or strong. If
    // it is weak and is about to be finalized, this can push a nil.

    void push_proxy();

    //.........................................................................
    // This is called when the Lua object is destroyed.

    static void finalize( lua_State* L , int index = 1 );

    //.........................................................................
    // Install a callback on this user data

    static int set_callback( const char* name , lua_State* L , int index = -2 , int function_index = -1 );

    //.........................................................................
    // Check if there is at least one callback of type 'name' on this user data

    bool callback_attached( const char* name );

    //.........................................................................
    // Add callback with given name on this user data

    int add_callback( char* name , lua_State* L );

    //.........................................................................
    // Sets last callback with given name on this user data

    void set_last_callback( char* name , lua_State* L );

    //.........................................................................
    // Remove callback with given name and reference on this user data

    void remove_callback( char* name, lua_State* L );

    //.........................................................................
    // Invoke all callbacks with given name on this user data

    int invoke_callbacks( const char* name , int nargs , int nresults , int default_ret = 0 );

    //.........................................................................
    // Get last callback in list

    int get_last_callback( char* name , lua_State* L );

    //.........................................................................
    // Remove last callback in list

    GSList* remove_last_callback( char* name , lua_State* L );

    //.........................................................................
    // Retrieve a callback - will always push a value, nil or otherwise.

    static int get_callback( const char* name , lua_State* L , int index = -1 );

    //.........................................................................
    // Returns true if the given callback is attached to this user data.

    static int is_callback_attached( const char* name , lua_State* L , int index = -1 );

    //.........................................................................

    static void clear_callbacks( lua_State* L , int index = 1 );

    void clear_callbacks();

    //.........................................................................
    // This one looks up a user data given a client pointer and invokes the
    // given callback. It expects that nargs have been pushed on to the stack
    // already. In any case, it pops nargs.

    static int invoke_callback( gpointer client , const char* name , int nargs , int nresults, lua_State* L );
    static int invoke_callbacks( gpointer client , const char* name , int nargs , int nresults, lua_State* L , int default_ret = 0 );

    //.........................................................................
    // Same as above, but can be used when you already know the master object,
    // so it skips the client lookup.

    static int invoke_callback( GObject* master , const char* name , int nargs , int nresults, lua_State* L );
    static int invoke_callbacks( GObject* master , const char* name , int nargs , int nresults, lua_State* L , int default_ret = 0 );

    //.........................................................................
    // If you already have the user data pointer, you can call this one.

    int invoke_callback( const char* name , int nargs , int nresults );

    //.........................................................................

    static int invoke_global_callback( lua_State* L , const char* global , const char* name , int nargs , int nresults );
    static int invoke_global_callbacks( lua_State* L , const char* global , const char* name , int nargs , int nresults , int default_ret = 0 );

    //.........................................................................
    // Connect a signal handler to the master. We do this so that we can
    // track the connected handlers and disconnect them all when the proxy
    // object goes away.

    void connect_signal( const gchar* name, const gchar* detailed_signal, GCallback handler, gpointer data, int flags = 0 );

    void connect_signal_if( bool condition , const gchar* name, const gchar* detailed_signal, GCallback handler, gpointer data, int flags = 0 );

    //.........................................................................
    // Disconnect a signal by name

    void disconnect_signal( const gchar* name );

    //.........................................................................
    // Debugging.

    static void dump_cb( lua_State* L , int index = 1 );

    static void dump();

    bool gc_tag( const gchar* comment );

    lua_State* get_lua_state() { return L; }

private:

    friend struct Handle;

    GSList* remove_callback( GSList* link , GSList* list , char* name , lua_State* L );

    //.........................................................................

    inline static GHashTable* get_client_map()
    {
        static GHashTable* client_map = 0;

        if ( client_map == 0 )
        {
            client_map = g_hash_table_new( 0 , 0 );
        }

        g_assert( client_map );

        return client_map;
    }

    //.........................................................................

    inline static GQuark get_key_quark()
    {
        static const char* key = "_tp_master_data_";

        static GQuark key_quark = 0;

        if ( key_quark == 0 )
        {
            key_quark = g_quark_from_static_string( key );
        }

        return key_quark;
    }

    //.........................................................................
    // Non-static version.

    int get_callback( const char* name );

    //.........................................................................
    // This gets called when our toggle ref is the last one or is not. When it
    // is the last one, we switch our proxy ref to weak, so it can be collected.
    // When it is not the last one, we switch it to strong, so it is kept around.

    static void toggle_notify( UserData* self , GObject* master , gboolean is_last_ref );

    //.........................................................................

    void disconnect_all_signals();

    //.........................................................................

    lua_State*      L;

    //.........................................................................

    gchar*          type;

    //.........................................................................
    // The controlling GObject - if one is not provided, we create one. This
    // object will be alive at least until finalize is called on us, because
    // we have a ref to it. Once we are finalized, it can continue to remain
    // alive if someone else has a ref to it.

    GObject*        master;

    //.........................................................................
    // The user's pointer. His data is bolted here and is opaque to us.
    // We don't manage its life.

    gpointer        client;

    //.........................................................................
    // Flag for sanity checks.

    bool            initialized;

    //.........................................................................
    // A reference to the Lua object. We keep a weak reference all the time
    // and a strong one only when the toggle ref is not the last.

    int             weak_ref;

    int             strong_ref;

    //.........................................................................
    // A map to signals we have connected to the master. Each entry has our own
    // callback name and the signal handler id.

    typedef std::string String;

    typedef std::map< String , gulong > SignalMap;

    SignalMap*      signals;

    //.........................................................................

    //.........................................................................
    // maps callback names to lists of registered callbacks

    GHashTable*     callback_lists;

#ifdef TP_PROFILING

    class GCTag;

    GCTag*             gctag;

#endif
};


#endif
