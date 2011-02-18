//
//  NetServiceManager.m
//  Services-test
//
//  Created by Rex Fenley on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NetServiceManager.h"


@implementation NetServiceManager

@synthesize currentService;
@synthesize services;
@synthesize delegate;

/**
 * Initializes the NetServiceManager. Provide a delegate to callback to
 * with event triggers.
 *
 * @property aClient : a client that will receive callbacks upon NSNetService
 *                     and NSNetServiceBrowser events.
 */
-(id)initWithDelegate:(id)client{
    if (self = [super init])
    {
        delegate = client;
        currentService = nil;
        services = [[NSMutableArray alloc] init];
        netServiceBrowser = [[NSNetServiceBrowser alloc] init];
        netServiceBrowser.delegate = self;
        [netServiceBrowser searchForServicesOfType:@"_tp-remote._tcp" inDomain:@""];
    }
    
    return self;
}


- (void)stopCurrentService {
    if (currentService){
        [currentService stop];
    }
	currentService = nil;
}


//--------------- NSNetServiceDelegate methods ------------------


// This should never be called, since we resolve with a timeout of 0.0, which means indefinite
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"Current NetService did not resolve address");
    
	[self stopCurrentService];
	[delegate didNotResolveService];
}


- (void)netServiceDidResolveAddress:(NSNetService *)service {
    assert(service == currentService);
    // make sure the service is retained before stopped, else, deletion
	[service retain];
	[self stopCurrentService];
    
    // TODO: make sure we got all the connection information for the service so
    // check host and port #
	
	NSLog(@"Did resolve address");
    
    [[self delegate] serviceResolved:service];
	
    [service stop];
	[service release];
}



//--------------  NSNetServiceBrowserDelegate methods  -----------------


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
    [self handleError:[errorDict objectForKey:NSNetServicesErrorCode]];
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
         didRemoveService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
	// If a service went away, stop resolving it if it's currently being resolved,
	// remove it from the list and update the table view if no more events are queued.
	if (self.currentService && [service isEqual:currentService]) {
		[currentService stop];
        currentService = nil;
	}
	[self.services removeObject:service];
	
	// If moreComing is NO, it means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
	// When moreComing is set, we don't update the UI so that it doesn't 'flash'.
    NSLog(@"service removed, more coming? %d", moreComing);
	if (!moreComing) {
		[delegate reloadData];
	}
}	


- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
	// If a service came online, add it to the list and update the table view if no more events are queued.
	[self.services addObject:service];
	
	// If moreComing is NO, it means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
	// When moreComing is set, we don't update the UI so that it doesn't 'flash'.
    NSLog(@"service found, more coming? %d", moreComing);
	if (!moreComing) {
		[delegate reloadData];
	}
}	


// Error Handling
- (void)handleError:(NSNumber *)error {
    NSLog(@"An error occurred in NetworkManager. Error code = %@", error);
}


- (void)dealloc {
    NSLog(@"Net Service Manager dealloc");
    if (currentService) {
        [currentService stop];
        [currentService release];
    }
    [services release];
    [netServiceBrowser release];
    [super dealloc];
}

@end
