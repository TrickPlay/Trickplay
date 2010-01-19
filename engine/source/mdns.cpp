
#include "mdns.h"

#include <avahi-common/error.h>
#include <avahi-common/timeval.h>
#include <avahi-common/alternative.h>
#include <avahi-glib/glib-malloc.h>

MDNS::MDNS()
:
    poll(NULL),
    client(NULL),
    group(NULL),
    name("TrickPlay"),
    ready(false)
{
    avahi_set_allocator(avahi_glib_allocator());

    poll=avahi_glib_poll_new(NULL,G_PRIORITY_DEFAULT);
    g_assert(poll);
    
    int error;

    client=avahi_client_new(avahi_glib_poll_get(poll),AvahiClientFlags(0),avahi_client_callback,this,&error);
    
    if (!client)
    {
        g_warning("FAILED TO CREATE AVAHI CLIENT : %s",avahi_strerror(error));
    }
}

MDNS::~MDNS()
{
    if (group)
    {
        avahi_entry_group_free(group);
    }

    if (client)
    {
        avahi_client_free(client);
    }

    avahi_glib_poll_free(poll);
}

bool MDNS::is_ready() const
{
    return ready;
}

void MDNS::rename()
{
    char * new_name=avahi_alternative_service_name(name.c_str());
    name=new_name;
    avahi_free(new_name);
}

void MDNS::create_service(AvahiClient * client)
{
    if (!group)
    {
        group=avahi_entry_group_new(client,avahi_entry_group_callback,this);
        
        if (!group)
        {
            g_warning("FAILED TO CREATE AVAHI ENTRY GROUP : %s",avahi_strerror(avahi_client_errno(client)));
        }
    }
    
    if (group)
    {
        if (avahi_entry_group_is_empty(group))
        {
            int ret=AVAHI_OK;
            
            while(true)
            {
                // TODO: this could loop forever...maybe we should bail at some stage
                
                // TODO: the port is hardwired

                ret = avahi_entry_group_add_service(group,AVAHI_IF_UNSPEC,AVAHI_PROTO_UNSPEC,
                    AvahiPublishFlags(0),name.c_str(),"_tp-remote._tcp",NULL,NULL,8008,NULL);
                
                if (ret==AVAHI_ERR_COLLISION)
                {
                    rename();
                }
                else
                {
                    break;
                }
            }
            
            if (ret!=AVAHI_OK)
            {
                g_warning("FAILED TO ADD AVAHI SERVICE : %s",avahi_strerror(ret));
            }
            else
            {
                ret = avahi_entry_group_commit(group);
                
                if (ret!=AVAHI_OK)
                {
                    g_warning("FAILED TO COMMIT AVAHI SERVICE : %s",avahi_strerror(ret));
                }
            }
        }
    }
}

void MDNS::avahi_client_callback(AvahiClient *client, AvahiClientState state, void *userdata)
{
    MDNS * self=(MDNS*)userdata;

    switch (state)
    {
        case AVAHI_CLIENT_S_RUNNING:
        {
            self->create_service(client);
            break;
        }
        
        case AVAHI_CLIENT_S_COLLISION:
        case AVAHI_CLIENT_S_REGISTERING:
        {
            if (self->group)
                avahi_entry_group_reset(self->group);
            break;
        }
        
        case AVAHI_CLIENT_FAILURE:
        {
            g_warning("AVAHI CLIENT FAILURE : %s",avahi_strerror(avahi_client_errno(client)));
            break;    
        }
        
        case AVAHI_CLIENT_CONNECTING:
        {
            break;
        }
    }	
}

void MDNS::avahi_entry_group_callback(AvahiEntryGroup *g, AvahiEntryGroupState state, void *userdata)
{
    MDNS * self=(MDNS*)userdata;

    switch(state)
    {
        case AVAHI_ENTRY_GROUP_ESTABLISHED:
            g_debug("AVAHI SERVICE '%s' ESTABLISHED",self->name.c_str());
            self->ready=true;
            break;
        
        case AVAHI_ENTRY_GROUP_COLLISION:
            self->rename();
            self->create_service(avahi_entry_group_get_client(g));
            break;
        
        case AVAHI_ENTRY_GROUP_FAILURE:
            g_warning("AVAHI SERVICE FAILED");
            break;
        
        case AVAHI_ENTRY_GROUP_UNCOMMITED:
            break;
        
        case AVAHI_ENTRY_GROUP_REGISTERING:
            break;
    }
}
