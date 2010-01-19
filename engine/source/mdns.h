#ifndef _TP_MDNS_H
#define _TP_MDNS_H

#include <string>

#include <avahi-core/core.h>
#include <avahi-core/publish.h>
#include <avahi-glib/glib-watch.h>

typedef std::string String;

class MDNS
{
public:
    
    MDNS();
    ~MDNS();
    
    bool is_ready() const;
    
private:
    
    void rename();
    
    void create_service(AvahiServer * server);

    static void avahi_server_callback(AvahiServer *server, AvahiServerState state, void *userdata);
    static void avahi_entry_group_callback(AvahiServer * server,AvahiSEntryGroup *g, AvahiEntryGroupState state, void *userdata);
    
    AvahiGLibPoll * 	poll;
    AvahiServer *       server;
    AvahiSEntryGroup * 	group;
    String 		name;
    bool		ready;
};

#endif