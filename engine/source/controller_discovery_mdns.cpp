#include <avahi-common/error.h>
#include <avahi-common/timeval.h>
#include <avahi-common/alternative.h>
#include <avahi-glib/glib-malloc.h>

#include "controller_discovery_mdns.h"
#include "util.h"

ControllerDiscoveryMDNS::ControllerDiscoveryMDNS( TPContext * context, const String & n, int _port , int _http_port )
    :
    poll( NULL ),
    server( NULL ),
    group( NULL ),
    name( n ),
    port( _port ),
    http_port( _http_port ),
    ready( false )
{
    avahi_set_allocator( avahi_glib_allocator() );

    poll = avahi_glib_poll_new( NULL, TRICKPLAY_PRIORITY );
    g_assert( poll );

    AvahiServerConfig config;
    avahi_server_config_init( &config );

    config.publish_workstation = 0;

    int error;

    server = avahi_server_new( avahi_glib_poll_get( poll ), &config, avahi_server_callback, this, &error );

    if ( !server )
    {
        g_warning( "FAILED TO CREATE AVAHI SERVER : %s", avahi_strerror( error ) );
    }
}

ControllerDiscoveryMDNS::~ControllerDiscoveryMDNS()
{
    if ( group )
    {
        avahi_s_entry_group_free( group );
    }

    if ( server )
    {
        avahi_server_free( server );
    }

    avahi_glib_poll_free( poll );
}

bool ControllerDiscoveryMDNS::is_ready() const
{
    return ready;
}

void ControllerDiscoveryMDNS::rename()
{
    char * new_name = avahi_alternative_service_name( name.c_str() );
    name = new_name;
    avahi_free( new_name );
}

void ControllerDiscoveryMDNS::create_service( AvahiServer * server )
{
    if ( !group )
    {
        group = avahi_s_entry_group_new( server, avahi_entry_group_callback, this );

        if ( !group )
        {
            g_warning( "FAILED TO CREATE AVAHI ENTRY GROUP : %s", avahi_strerror( avahi_server_errno( server ) ) );
        }
    }

    if ( group )
    {
        if ( avahi_s_entry_group_is_empty( group ) )
        {
            int ret = AVAHI_OK;

            while ( true )
            {
                // TODO: this could loop forever...maybe we should bail at some stage

                ret = avahi_server_add_service( server, group, AVAHI_IF_UNSPEC, AVAHI_PROTO_UNSPEC,
                                                AvahiPublishFlags( 0 ), name.c_str(), TP_REMOTE_MDNS_SERVICE, NULL, NULL, port, NULL );

                if ( ret == AVAHI_ERR_COLLISION )
                {
                    rename();
                }
                else
                {
                    break;
                }
            }

            if ( ret != AVAHI_OK )
            {
                g_warning( "FAILED TO ADD AVAHI SERVICE : %s", avahi_strerror( ret ) );
            }
            else
            {
                while ( true )
                {
                    // TODO: this could loop forever...maybe we should bail at some stage

                    ret = avahi_server_add_service( server, group, AVAHI_IF_UNSPEC, AVAHI_PROTO_UNSPEC,
                                                    AvahiPublishFlags( 0 ), name.c_str(), TP_HTTP_MDNS_SERVICE, NULL, NULL, http_port, NULL );

                    if ( ret == AVAHI_ERR_COLLISION )
                    {
                        rename();
                    }
                    else
                    {
                        break;
                    }
                }


                if ( ret != AVAHI_OK )
                {
                    g_warning( "FAILED TO ADD AVAHI SERVICE : %s", avahi_strerror( ret ) );
                }
                else
                {
					ret = avahi_s_entry_group_commit( group );

					if ( ret != AVAHI_OK )
					{
						g_warning( "FAILED TO COMMIT AVAHI SERVICE : %s", avahi_strerror( ret ) );
					}
                }
            }
        }
    }
}

void ControllerDiscoveryMDNS::avahi_server_callback( AvahiServer * server, AvahiServerState state, void * userdata )
{
    ControllerDiscoveryMDNS * self = ( ControllerDiscoveryMDNS * )userdata;

    switch ( state )
    {
        case AVAHI_SERVER_RUNNING:
        {
            self->create_service( server );
            break;
        }

        case AVAHI_SERVER_COLLISION:
        {
            char * new_name = avahi_alternative_host_name( avahi_server_get_host_name( server ) );

            (void)avahi_server_set_host_name( server, new_name );
            avahi_free( new_name );

            // TODO : check ret

            break;
        }

        case AVAHI_SERVER_REGISTERING:
        {
            if ( self->group )
            {
                avahi_s_entry_group_reset( self->group );
            }
            break;
        }

        case AVAHI_SERVER_FAILURE:
        {
            g_warning( "AVAHI SERVER FAILURE : %s", avahi_strerror( avahi_server_errno( server ) ) );
            break;
        }

        case AVAHI_SERVER_INVALID:
        {
            break;
        }
    }
}

void ControllerDiscoveryMDNS::avahi_entry_group_callback( AvahiServer * server, AvahiSEntryGroup * g, AvahiEntryGroupState state, void * userdata )
{
    ControllerDiscoveryMDNS * self = ( ControllerDiscoveryMDNS * )userdata;

    switch ( state )
    {
        case AVAHI_ENTRY_GROUP_ESTABLISHED:
            g_info( "AVAHI SERVICE '%s' ESTABLISHED", self->name.c_str() );
            self->ready = true;
            break;

        case AVAHI_ENTRY_GROUP_COLLISION:
            self->rename();
            self->create_service( server );
            break;

        case AVAHI_ENTRY_GROUP_FAILURE:
            g_warning( "AVAHI SERVICE FAILED" );
            break;

        case AVAHI_ENTRY_GROUP_UNCOMMITED:
            break;

        case AVAHI_ENTRY_GROUP_REGISTERING:
            break;
    }
}
