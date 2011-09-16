//
//  TVBrowserController.m
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TVBrowser.h"
#import "Extensions.h"

@implementation TVBrowser

@synthesize delegate;

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<TVBrowserDelegate>)theDelegate {
    self = [super init];
    if (self) {
        tvConnections = [[NSMutableArray alloc] initWithCapacity:5];
        connectedServices = [[NSMutableArray alloc] initWithCapacity:5];
        viewControllers = [[NSMutableArray alloc] initWithCapacity:5];
        self.delegate = theDelegate;
        
        // Initialize the NSNetServiceBrowser stuff
        // The netServiceManager manages advertisements from service broadcasts
        netServiceManager = [[NetServiceManager alloc] initWithDelegate:self];
        
        [netServiceManager start];
    }
    
    return self;
}

#pragma mark -
#pragma mark TVBrowserViewController

- (TVBrowserViewController *)createTVBrowserViewController {
    TVBrowserViewController *viewController = [[TVBrowserViewController alloc] initWithNibName:@"TVBrowserViewController" bundle:nil tvBrowser:self];
        
    return viewController;
}

- (void)addViewController:(TVBrowserViewController *)viewController {
    [viewControllers addObject:[NSValue valueWithPointer:viewController]];
}

- (void)invalidateViewController:(TVBrowserViewController *)viewController {
    NSUInteger i;
    for (i = 0; i < viewControllers.count; i++) {
        TVBrowserViewController *_viewController = [[viewControllers objectAtIndex:i] pointerValue];
        if (viewController == _viewController) {
            break;
        }
    }
    
    if (viewController == [[viewControllers objectAtIndex:i] pointerValue]) {
        [viewControllers removeObjectAtIndex:i];
    }
}

- (void)viewControllersRefresh {
    for (unsigned int i = 0; i < viewControllers.count; i++) {
        TVBrowserViewController *viewController = [[viewControllers objectAtIndex:i] pointerValue];
        
        [viewController reloadData];
    }
}

#pragma mark -
#pragma mark Managing TVConnections

- (TVConnection *)getConnectionForService:(NSNetService *)service {
    for (unsigned int i = 0; i < tvConnections.count; i++) {
        TVConnection *connection = [[tvConnections objectAtIndex:i] pointerValue];
        if (service == connection.connectedService) {
            return connection;
        }
    }
    
    return nil;
}

- (void)invalidateTVConnection:(TVConnection *)tvConnection {
    NSUInteger i;
    for (i = 0; i < tvConnections.count; i++) {
        TVConnection *connection = [[tvConnections objectAtIndex:i] pointerValue];
        if (tvConnection == connection) {
            [connectedServices removeObject:tvConnection.connectedService];
            break;
        }
    }
    
    if (tvConnection == [[tvConnections objectAtIndex:i] pointerValue]) {
        [tvConnections removeObjectAtIndex:i];
    }
}

- (void)informOfSameConnection:(TVConnection *)tvConnection {
    [delegate tvBrowser:self didEstablishConnection:tvConnection];
}

- (void)informOfFailedService:(NSNetService *)service {
    [delegate tvBrowser:self DidNotEstablishConnectionToService:service];
}

- (void)connectToService:(NSNetService *)service {
    // If not a Trickplay service
    if ([netServiceManager.connectingServices containsObject:service]) {
        return;
    }
    
    if ([service.type compare:@"_tp-remote._tcp"] != NSOrderedSame || ![netServiceManager.services containsObject:service]) {
        [self performSelectorOnMainThread:@selector(informOfFailedService:) withObject:service waitUntilDone:NO];
        
        return;
    }
    
    TVConnection *connection = [self getConnectionForService:service];
    if (connection) {
        [self performSelectorOnMainThread:@selector(informOfSameConnection:) withObject:connection waitUntilDone:NO];
        
        return;
    }
    
    [netServiceManager.connectingServices addObject:service];
    [service setDelegate:netServiceManager];
    [service resolveWithTimeout:5.0];
    
    [self viewControllersRefresh];
}

#pragma mark -
#pragma mark Managing Broadcasted Services

/**
 * NetServiceManager delegate callback. Called when a connection may be established
 * to a service after the user selects a service they wish to connect to. Sends
 * the connection information to the AppBrowser which will pass said information
 * to classes to create a stream socket. Additionally, stores the service name
 * to the currentTVName.
 */
- (void)serviceResolved:(NSNetService *)service {
    NSLog(@"TVBrowser service resolved");
    
    TVConnection *connection = [[TVConnection alloc] initWithService:service delegate:nil];
    
    if (connection) {
        [connection setTVBrowser:self];
        [connectedServices addObject:service];
        [tvConnections addObject:[NSValue valueWithPointer:connection]];
    }
    
    if (delegate) {
        if (connection) {
            [delegate tvBrowser:self didEstablishConnection:connection];
        } else {
            [delegate tvBrowser:self DidNotEstablishConnectionToService:service];
        }
    }
    
    [self viewControllersRefresh];
}

/**
 * NetServiceManager delegate callback. Called when establishing a stream
 * socket to the service the user selected fails. Based on which ViewController
 * is at the top of the UINavigationController view controller stack it will
 * properly pop and deallocate these resources as the system regresses back
 * to the RootViewController.
 */
- (void)didNotResolveService:(NSNetService *)service {
    NSLog(@"TVBrowser did not resolve service");
    
    [self refreshServices];
    if (delegate) {
        [delegate tvBrowser:self DidNotEstablishConnectionToService:service];
    }
    
    [self viewControllersRefresh];
}

- (void)didStopService:(NSNetService *)service {
    // Nothing to do
}

- (void)didFindService:(NSNetService *)service {
    if (delegate) {
        [delegate tvBrowser:self didFindService:service];
    }
    
    [self viewControllersRefresh];
}

- (void)didRemoveService:(NSNetService *)service {
    if (delegate) {
        [delegate tvBrowser:self didRemoveService:service];
    }
    
    [self viewControllersRefresh];
}

- (void)startSearchForServices {
    [netServiceManager start];
}

- (void)stopSearchForServices {
    [netServiceManager stop];
}

- (void)refreshServices {
    [netServiceManager start];
}

#pragma mark -
#pragma mark Getters

- (NSArray *)getConnectedServices {
    return [[connectedServices retain] autorelease];
}

- (NSArray *)getConnectingServices {
    return netServiceManager.connectingServices;
}

- (NSArray *)getAllServices {
    return netServiceManager.services;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    NSLog(@"TVBrowser Dealloc");
    for (unsigned int i; i < tvConnections.count; i++) {
        TVConnection *connection = [[tvConnections objectAtIndex:i] pointerValue];
        [connection setTVBrowser:nil];
    }
    
    [tvConnections release];
    [connectedServices release];
    
    [viewControllers release];
    
    [netServiceManager stop];
    [netServiceManager release];
    netServiceManager = nil;
    
    self.delegate = nil;
    
    [super dealloc];
}

@end



