#ifndef _TRICKPLAY_CONTROLLER_DISCOVERY_MDNS_H
#define _TRICKPLAY_CONTROLLER_DISCOVERY_MDNS_H

#include "common.h"
#include "controller_server.h"

#if !defined(CLUTTER_WINDOWING_OSX)
#include <avahi-core/core.h>
#include <avahi-core/publish.h>
#include <avahi-glib/glib-watch.h>
#else
#include <CoreServices/CoreServices.h>
#endif

#define TP_REMOTE_MDNS_SERVICE "_tp-remote._tcp"
#define TP_HTTP_MDNS_SERVICE "_trickplay-http._tcp"


class ControllerDiscoveryMDNS : public ControllerServer::Discovery
{
public:

    ControllerDiscoveryMDNS( TPContext * context, const String & name, int port , int http_port );

    ~ControllerDiscoveryMDNS();

    virtual bool is_ready() const;

private:

#if !defined(CLUTTER_WINDOWING_OSX)
    void rename();

    void create_service( AvahiServer * server );

    static void avahi_server_callback( AvahiServer * server, AvahiServerState state, void * userdata );
    static void avahi_entry_group_callback( AvahiServer * server, AvahiSEntryGroup * g, AvahiEntryGroupState state, void * userdata );

    AvahiGLibPoll *     poll;
    AvahiServer *       server;
    AvahiSEntryGroup *  group;
#else
    CFNetServiceRef        remote_service;
    CFNetServiceRef        http_service;
#endif

#if !defined(CLUTTER_WINDOWING_OSX)
    String              name;
#else
    CFStringRef         name;
#endif
    bool                ready;
};

#endif // _TRICKPLAY_CONTROLLER_DISCOVERY_MDNS_H
