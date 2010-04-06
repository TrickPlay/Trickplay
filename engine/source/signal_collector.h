#ifndef _TRICKPLAY_SIGNAL_COLLECTOR_H
#define _TRICKPLAY_SIGNAL_COLLECTOR_H

#include "common.h"

/*
    SignalCollector lets us centralize signals that we connect to glib objects.
    If disconnects the signals when the object is destroyed and also when
    the Lua state is destroyed. This lets us divorce glib (and therefore clutter)
    objects from Lua when Lua goes away.

    We install a user data in Lua that points to the signal collector and lets
    us delete it when Lua is closed.
*/

class SignalCollector
{
public:

    static SignalCollector * get( lua_State * L );

    void connect( const gchar * name, gpointer instance, const gchar * detailed_signal, GCallback handler, gpointer data );

    void disconnect( const gchar * name, gpointer instance );

    void connect_if( int condition, const gchar * name, gpointer instance, const gchar * detailed_signal, GCallback handler, gpointer data );

private:

    typedef std::map<String, gulong> 		NameToHandlerMap;
    typedef std::map<gpointer, NameToHandlerMap>	InstanceMap;

    SignalCollector( lua_State * l );

    ~SignalCollector();

    static void instance_destroyed_notify( gpointer data, GObject * instance );

    void instance_destroyed( gpointer instance );

    void disconnect( const gchar * name, const InstanceMap::iterator & it );

    static int new_signal_collector( lua_State * L, SignalCollector * sc );
    static int delete_signal_collector( lua_State * L );

    lua_State * L;
    InstanceMap	instances;
};

#endif // _TRICKPLAY_SIGNAL_COLLECTOR_H
