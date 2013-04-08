#ifndef _TRICKPLAY_CONTROLLER_DISCOVERY_UPNP_H
#define _TRICKPLAY_CONTROLLER_DISCOVERY_UPNP_H

#include <upnp/upnp.h>

#include "common.h"
#include "controller_server.h"

class ControllerDiscoveryUPnP : public ControllerServer::Discovery
{
public:

    ControllerDiscoveryUPnP( TPContext* context, const String& name, int port );

    ~ControllerDiscoveryUPnP();

    virtual bool is_ready() const;

private:

    static int upnp_device_callback( Upnp_EventType type , void* event , void* user );

    String controller_name;

    int controller_port;

    UpnpDevice_Handle device_handle;
    UpnpDevice_Handle device6_handle;
    UpnpDevice_Handle device6ulagua_handle;
};


#endif // _TRICKPLAY_CONTROLLER_DISCOVERY_UPNP_H
