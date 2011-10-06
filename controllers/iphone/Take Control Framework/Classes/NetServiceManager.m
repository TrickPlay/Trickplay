//
//  NetServiceManager.m
//  Services-test
//
//  Created by Rex Fenley on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NetServiceManager.h"


@implementation NetServiceManager

@synthesize connectingServices;
@synthesize services;
@synthesize delegate;

/**
 * Initializes the NetServiceManager. Provide a delegate to callback to
 * with event triggers.
 *
 * @property aClient : a client that will receive callbacks upon NSNetService
 *                     and NSNetServiceBrowser events.
 */
-(id)initWithClientDelegate:(id <NetServiceManagerDelegate>)client {
    if ((self = [super init])) {
        delegate = client;
        connectingServices = [[NSMutableArray alloc] initWithCapacity:5];
        services = [[NSMutableArray alloc] initWithCapacity:5];
        netServiceBrowser = [[NSNetServiceBrowser alloc] init];
        netServiceBrowser.delegate = self;
    }
    
    return self;
}

#pragma mark -
#pragma mark Start/Stop Search/Services

- (void)stopServices {
    for (NSNetService *service in connectingServices) {
        [service stop];
    }
    [connectingServices removeAllObjects];
}

- (void)stop {
    [self stopServices];
    [netServiceBrowser stop];
    [services removeAllObjects];
}

- (void)start {
    [self stop];
    [netServiceBrowser searchForServicesOfType:@"_tp-remote._tcp" inDomain:@""];
}

#pragma mark -
#pragma mark NSNetServiceDelegate methods


// This should never be called, since we resolve with a timeout of 0.0, which means indefinite
- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"NetService did not resolve address");
    
    [service stop];
	[delegate didNotResolveService:service];
}

- (void)netServiceDidStop:(NSNetService *)service {
    if ([connectingServices containsObject:service]) {
        [connectingServices removeObject:service];
    }
    
    [delegate didStopService:service];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
	NSLog(@"NetService did resolve address");
    
    [service stop];    
    [self.delegate serviceResolved:service];
}

#pragma mark -
#pragma mark NSNetServiceBrowserDelegate methods


// Sent when browsing begins
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    NSLog(@"netServiceBrowser will search");
}

// Sent when browsing stops
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    NSLog(@"netServiceBrowser stopped search");
}

// Sent if browsing fails
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
             didNotSearch:(NSDictionary *)errorDict
{
    [self handleError:[errorDict objectForKey:NSNetServicesErrorCode]
               domain:[errorDict objectForKey:NSNetServicesErrorDomain]];
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
         didRemoveService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
	// If a service went away, stop resolving it if it's currently being resolved,
	// remove it from the list and update the table view if no more events are queued.
	[service stop];
	[self.services removeObject:service];
	
	// If moreComing is NO, it means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
	// When moreComing is set, we don't update the UI so that it doesn't 'flash'.
    NSLog(@"service [ %@ ] removed, more coming? %d", service, moreComing);
	if (!moreComing) {
		[delegate didRemoveService:service];
	}
}	


- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
	// If a service came online, add it to the list and update the table view
    // if no more events are queued.
	[self.services addObject:service];
	
	// If moreComing is NO, it means that there are no more messages
    // in the queue from the Bonjour daemon, so we should update the UI.
	// When moreComing is set, we don't update the UI so that it doesn't 'flash'.
    NSLog(@"service [ %@ ] found, more coming? %d", service, moreComing);
	if (!moreComing) {
		[delegate didFindService:service];
	}
}	


// Error Handling
- (void)handleError:(NSNumber *)error domain:(NSString *)domain {
    NSLog(@"An error occurred in NetworkManager. Error code = %@, in Domain %@", error, domain);
}

#pragma mark -
#pragma mark Deallocation

- (void)dealloc {
    NSLog(@"Net Service Manager dealloc");
    [self stopServices];
    if (connectingServices) {
        [connectingServices release];
    }
    for (NSNetService *service in services) {
        if (self == service.delegate) {
            service.delegate = nil;
        }
    }
    [services release];
    [netServiceBrowser stop];
    [netServiceBrowser release];
    [super dealloc];
}

@end
