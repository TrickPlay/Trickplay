
#include "glib-object.h"

#include "signal_collector.h"
#include "lb.h"

SignalCollector::SignalCollector( lua_State * l )
    :
    L( l )
{
    g_debug( "CREATING SIGNAL COLLECTOR %p", this );
}

SignalCollector::~SignalCollector()
{
    g_debug( "DESTROYING SIGNAL COLLECTOR %p", this );

    // We need to disconnect all signals, because Lua is going away

    for ( InstanceMap::const_iterator it = instances.begin(); it != instances.end(); ++it )
    {
        for ( NameToHandlerMap::const_iterator nt = it->second.begin(); nt != it->second.end(); ++nt )
        {
            g_debug( "  DISCONNECTING %p %s %lu", it->first, nt->first.c_str(), nt->second );

            g_signal_handler_disconnect( it->first, nt->second );
        }

        // And we also detach our weak ref

        g_object_weak_unref( G_OBJECT( it->first ), instance_destroyed_notify, this );
    }
}

SignalCollector * SignalCollector::get( lua_State * L )
{
    LSG;

    SignalCollector * result = NULL;

    g_assert( L );
    lua_pushstring( L, "tp_signalcollector" );
    lua_rawget( L, LUA_REGISTRYINDEX );
    if ( lua_isnil( L, -1 ) )
    {
        lua_pop( L, 1 );
        result = new SignalCollector( L );

        new_signal_collector( L, result );
        lua_setfield( L, LUA_REGISTRYINDEX, "tp_signalcollector" );
    }
    else
    {
        result = *( SignalCollector ** )lua_touserdata( L, -1 );
        lua_pop( L, 1 );
    }
    g_assert( result );

    LSG_END( 0 );

    return result;
}

void SignalCollector::instance_destroyed_notify( gpointer data, GObject * instance )
{
    ( ( SignalCollector * )data )->instance_destroyed( instance );
}

void SignalCollector::instance_destroyed( gpointer instance )
{
    g_debug( "INSTANCE DESTROYED %p", instance );

    instances.erase( instance );
}

void SignalCollector::connect( const gchar * name, gpointer instance, const gchar * detailed_signal, GCallback handler, gpointer data )
{
    // See if we have any entries for this instance

    InstanceMap::iterator it = instances.find( instance );

    // If we don't..

    if ( it == instances.end() )
    {
        // We add a weak ref to it so we can be told when it goes away

        g_object_weak_ref( G_OBJECT( instance ), instance_destroyed_notify, this );

        // Inserts a new element in the instaces map and sets the iterator
        // to point to it

        it = instances.insert( std::make_pair( instance, NameToHandlerMap() ) ).first;
    }

    // The instance was found

    else
    {
        // Disconnect the old one

        disconnect( name, it );
    }

    // Connect the new signal

    gulong id = g_signal_connect( instance, detailed_signal, handler, data );

    g_debug( "CONNECTING %p %s %lu", instance, name, id );

    // Store it

    it->second[String( name )] = id;
}

void SignalCollector::disconnect( const gchar * name, gpointer instance )
{
    InstanceMap::iterator it = instances.find( instance );

    if ( it != instances.end() )
    {
        disconnect( name, it );
    }
}

void SignalCollector::connect_if( int condition, const gchar * name, gpointer instance, const gchar * detailed_signal, GCallback handler, gpointer data )
{
    if ( condition )
    {
        connect( name, instance, detailed_signal, handler, data );
    }
    else
    {
        disconnect( name, instance );
    }
}

void SignalCollector::disconnect( const gchar * name, const InstanceMap::iterator & it )
{
    NameToHandlerMap::iterator nt = it->second.find( String( name ) );

    if ( nt != it->second.end() )
    {
        g_debug( "DISCONNECTING %p %s %lu", it->first, name, nt->second );

        g_signal_handler_disconnect( it->first, nt->second );

        it->second.erase( nt );
    }
}

int SignalCollector::new_signal_collector( lua_State * L, SignalCollector * sc )
{
    static const char * SIGNAL_COLLECTOR_METATABLE = "SIGNAL_COLLECTOR_METATABLE";

    LSG;

    SignalCollector ** self( lb_new_self( L, SignalCollector * ) );
    *self = sc;

    luaL_newmetatable( L, SIGNAL_COLLECTOR_METATABLE );
    lua_pushstring( L, "type" );
    lua_pushstring( L, "signal_collector" );
    lua_rawset( L, -3 );
    const luaL_Reg meta_methods[] =
    {
        {"__gc", delete_signal_collector},
        {NULL, NULL}
    };
    luaL_register( L, NULL, meta_methods );
    lua_pushstring( L, "__index" );
    lua_pushvalue( L, -2 );
    lua_rawset( L, -3 );

    lua_setmetatable( L, -2 );

    return LSG_END( 1 );
}

int SignalCollector::delete_signal_collector( lua_State * L )
{
    delete lb_get_self( L, SignalCollector * );
    return 0;
}
