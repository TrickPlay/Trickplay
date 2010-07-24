#ifndef _TRICKPLAY_USER_DATA_H
#define _TRICKPLAY_USER_DATA_H

#include "glib.h"
#include "glib-object.h"

#include "common.h"

struct UserData
{
    //.........................................................................
    // Creates a new user data and sets it initial state. It is not complete
    // until you call initialize. It returns a pointer to its 'client'.

    static gpointer * make( lua_State * L );

    //.........................................................................
    // Returns the client associated with it.

    inline static gpointer get_client( lua_State * L , int index = 1 )
    {
        return UserData::get( L , index )->client;
    }

    //.........................................................................
    // Sets the master GObject to the one provided. This can only be done
    // once before the user data is initialized. Ownership of the master
    // object is transferred to us - so it should not be unrefed after you
    // call this.

    static void set_master( gpointer new_master , lua_State * L , int index = 1 );

    //.........................................................................
    // Sets up the rest of the user data - creating a master if one has not
    // been set already.

    static void initialize( lua_State * L , int index = 1 );

    //.........................................................................
    // This is called when the Lua object is destroyed.

    static void finalize( lua_State * L , int index = 1 );

    //.........................................................................
    //

    static int set_callback( const char * name , lua_State * L , int index = -2 , int function_index = -1 );

    static int get_callback( const char * name , lua_State * L , int index = -1 );

    static int is_callback_attached( const char * name , lua_State * L , int index = -1 );



    static int invoke_callback( gpointer client , const char * name , int nargs , int nresults, lua_State * L );


    static void dump_cb( lua_State * L , int index = 1 );

private:

    //.........................................................................
    // Gets the user data from the Lua stack given the index.

    inline static UserData * get( lua_State * L , int index )
    {
        g_assert( L );

        UserData * result = ( UserData * ) lua_touserdata( L , index );

        g_assert( result );

        g_assert( result->L == L );

        return result;
    }

    //.........................................................................

    inline static GHashTable * get_client_map()
    {
        static GHashTable * client_map = 0;

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
        static const char * key = "_tp_master_data_";

        static GQuark key_quark = 0;

        if ( key_quark == 0 )
        {
            key_quark = g_quark_from_static_string( key );
        }

        return key_quark;
    }

    //.........................................................................
    // Non-static version.

    int get_callback( const char * name );

    //.........................................................................
    // Pushes the Lua proxy onto the stack - whether it is weak or strong

    void deref_proxy();

    //.........................................................................
    // This gets called when our toggle ref is the last one or is not. When it
    // is the last one, we switch our proxy ref to weak, so it can be collected.
    // When it is not the last one, we switch it to strong, so it is kept around.

    static void toggle_notify( UserData * self , GObject * master , gboolean is_last_ref );

    //.........................................................................

    lua_State *     L;

    //.........................................................................
    // The controlling GObject - if one is not provided, we create one. This
    // object will be alive at least until finalize is called on us, because
    // we have a ref to it. Once we are finalized, it can continue to remain
    // alive if someone else has a ref to it.

    GObject *       master;

    //.........................................................................
    // The user's pointer. His data is bolted here and is opaque to us.
    // We don't manage its life.

    gpointer        client;

    //.........................................................................
    // Flag for sanity checks.

    bool            initialized;

    //.........................................................................
    // A reference to the Lua object. We flip this between a strong
    // reference and a weak reference. The only time it can go away
    // is when the Lua state goes away - in that case this object will
    // be uninstalled and deleted.

    int             proxy_ref;

    //.........................................................................
    // Whether the reference above is weak or strong, so we can toggle it

    enum RefType { STRONG , WEAK };

    RefType         proxy_ref_type;

    //.........................................................................
    // Callbacks

//    typedef std::map< String , int > CallbackMap;

//    CallbackMap *   callbacks;

    int callbacks_ref;
};


#endif
