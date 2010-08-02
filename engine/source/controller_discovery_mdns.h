#ifndef _TRICKPLAY_CONTROLLER_DISCOVERY_MDNS_H
#define _TRICKPLAY_CONTROLLER_DISCOVERY_MDNS_H

#include <avahi-core/core.h>
#include <avahi-core/publish.h>
#include <avahi-glib/glib-watch.h>

#include "common.h"
#include "controller_server.h"

class ControllerDiscoveryMDNS : public ControllerServer::Discovery
{
public:

    ControllerDiscoveryMDNS( TPContext * context, const String & name, int port );

    ~ControllerDiscoveryMDNS();

    virtual bool is_ready() const;

private:

    void rename();

    void create_service( AvahiServer * server );

    static void avahi_server_callback( AvahiServer * server, AvahiServerState state, void * userdata );
    static void avahi_entry_group_callback( AvahiServer * server, AvahiSEntryGroup * g, AvahiEntryGroupState state, void * userdata );

    AvahiGLibPoll *     poll;
    AvahiServer *       server;
    AvahiSEntryGroup *  group;
    String              name;
    bool                ready;
    int                 port;
};

#endif // _TRICKPLAY_CONTROLLER_DISCOVERY_MDNS_H
