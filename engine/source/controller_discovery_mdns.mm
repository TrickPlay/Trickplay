#include "controller_discovery_mdns.h"
#include "util.h"

static void MDNS_OSX_Callback (
   CFNetServiceRef theService,
   CFStreamError* error,
   void* info)
{
    g_info("MDNS %s REGISTERED", (char *)info);
}


ControllerDiscoveryMDNS::ControllerDiscoveryMDNS( TPContext * context, const String & n, int _port , int _http_port )
    :
    remote_service( NULL ),
    http_service( NULL ),
    name( NULL ),
    ready( false )
{
    name = CFStringCreateWithCString( NULL, n.c_str(), kCFStringEncodingUTF8 );

    remote_service = CFNetServiceCreate( NULL, CFSTR(""), CFSTR(TP_REMOTE_MDNS_SERVICE), name, _port );
    http_service = CFNetServiceCreate( NULL, CFSTR(""), CFSTR(TP_HTTP_MDNS_SERVICE), name, _http_port );

    CFNetServiceClientContext remoteContext = { 0, (void *)"REMOTE", NULL, NULL, NULL };
    CFNetServiceClientContext httpContext = { 0, (void *)"HTTP", NULL, NULL, NULL };

    CFNetServiceSetClient(remote_service, MDNS_OSX_Callback, &remoteContext);
    CFNetServiceSetClient(http_service, MDNS_OSX_Callback, &httpContext);

    CFNetServiceScheduleWithRunLoop(remote_service, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    CFNetServiceScheduleWithRunLoop(http_service, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);


    if (CFNetServiceRegisterWithOptions( remote_service, 0, NULL ) == false)
    {
        CFNetServiceUnscheduleFromRunLoop(remote_service, CFRunLoopGetCurrent(),kCFRunLoopCommonModes);
        CFNetServiceSetClient(remote_service, NULL, NULL);
        CFRelease(remote_service);
        remote_service = NULL;
        g_error("COULD NOT REGISTER MDNS SERVICE FOR REMOTE");
    }

    if (CFNetServiceRegisterWithOptions( http_service, 0, NULL ) == false)
    {
        CFNetServiceUnscheduleFromRunLoop(http_service, CFRunLoopGetCurrent(),kCFRunLoopCommonModes);
        CFNetServiceSetClient(http_service, NULL, NULL);
        CFRelease(http_service);
        http_service = NULL;
        g_error("COULD NOT REGISTER MDNS SERVICE FOR HTTP");
    }

}

ControllerDiscoveryMDNS::~ControllerDiscoveryMDNS()
{

    CFNetServiceCancel(remote_service);
    CFNetServiceCancel(http_service);
    CFRelease(remote_service);
    CFRelease(http_service);
    CFRelease(name);

}

bool ControllerDiscoveryMDNS::is_ready() const
{
    return ready;
}
