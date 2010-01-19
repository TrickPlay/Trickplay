#ifndef _TP_MDNS_H
#define _TP_MDNS_H

#include <string>

#include <avahi-client/client.h>
#include <avahi-client/publish.h>
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
    
    void create_service(AvahiClient * client);

    static void avahi_client_callback(AvahiClient *client, AvahiClientState state, void *userdata);
    static void avahi_entry_group_callback(AvahiEntryGroup *g, AvahiEntryGroupState state, void *userdata);
    
    AvahiGLibPoll * 	poll;
    AvahiClient *   	client;
    AvahiEntryGroup * 	group;
    String 		name;
    bool		ready;
};

#endif