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
@synthesize tableView;

/**
 * Initializes the NetServiceManager. Provide a UITableView to list the services.
 * and a client to callback to with event triggers.
 *
 * @property aTableView : a UITableView to list the services provided by Bonjour.
 * @property aClient : a client that will receive callbacks upon NSNetService
 *                     and NSNetServiceBrowser events.
 */
-(id)init:(UITableView *)aTableView client:(id)aClient{
    if (self = [super init])
    {
        client = aClient;
        tableView = aTableView;
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
    [currentService release];
	currentService = nil;
}


//--------------- NSNetServiceDelegate methods ------------------


// This should never be called, since we resolve with a timeout of 0.0, which means indefinite
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    fprintf(stderr, "Current NetService did not resolve address\n");
    
	[self stopCurrentService];
	[tableView reloadData];
}


- (void)netServiceDidResolveAddress:(NSNetService *)service {
    // make sure the service is retained before stopped, else, deletion
	[service retain];
	[self stopCurrentService];
    
    // TODO: make sure we got all the connection information for the service so
    // check host and port #
	
	NSLog(@"Did resolve address");
    
    [client serviceResolved:service];
	
    [service stop];
	[service release];
}



//--------------  NSNetServiceBrowserDelegate methods  -----------------


// Sent when browsing begins
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    fprintf(stderr, "netServiceBrowser will search\n");
}

// Sent when browsing stops
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    fprintf(stderr, "netServiceBrowser stopped search\n");
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
		[self stopCurrentService];
	}
	[self.services removeObject:service];
	
	// If moreComing is NO, it means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
	// When moreComing is set, we don't update the UI so that it doesn't 'flash'.
    fprintf(stderr, "service removed, more coming? %d\n", moreComing);
	if (!moreComing) {
		[self.tableView reloadData];
	}
}	


- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
	// If a service came online, add it to the list and update the table view if no more events are queued.
	[self.services addObject:service];
	
	// If moreComing is NO, it means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
	// When moreComing is set, we don't update the UI so that it doesn't 'flash'.
    fprintf(stderr, "service found, more coming? %d\n", moreComing);
	if (!moreComing) {
		[self.tableView reloadData];
	}
}	


// Error Handling
- (void)handleError:(NSNumber *)error {
    NSLog(@"An error occurred in NetworkManager. Error code = %d", [error intValue]);
}


- (void)dealloc {
    [self stopCurrentService];
    [services release];
    [netServiceBrowser release];
    [super dealloc];
}

@end
