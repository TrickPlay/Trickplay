//
//  TVBrowserController.m
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TVBrowser.h"
#import "NetServiceManager.h"
#import "TVConnection.h"
#import "Extensions.h"

@interface TVBrowserContext : NSObject <NetServiceManagerDelegate> {
    @protected
    // The netServiceManager informs the TVBrowser of mDNS broadcasts
    NetServiceManager *netServiceManager;
    
    NSMutableArray *tvConnections;
    NSMutableArray *connectedServices;
    NSMutableArray *viewControllers;
    
    TVBrowser *tvBrowser;
}

@property (nonatomic, readonly) NetServiceManager *netServiceManager;
@property (nonatomic, readonly) NSMutableArray *tvConnections;
@property (nonatomic, readonly) NSMutableArray *connectedServices;
@property (nonatomic, readonly) NSMutableArray *viewControllers;

- (id)initWithTVBrowser:(TVBrowser *)tvBrowser;

- (void)addViewController:(TVBrowserViewController *)viewController;
- (void)invalidateViewController:(TVBrowserViewController *)viewController;
- (void)viewControllersRefresh;

- (TVConnection *)getConnectionForService:(NSNetService *)service;
- (void)invalidateTVConnection:(TVConnection *)tvConnection;

- (void)connectToService:(NSNetService *)service;

@end



@implementation TVBrowserContext

@synthesize netServiceManager;
@synthesize tvConnections;
@synthesize connectedServices;
@synthesize viewControllers;

- (id)init {
    [self initWithTVBrowser:nil];
}

- (id)initWithTVBrowser:(TVBrowser *)_tvBrowser {
    if (!_tvBrowser) {
        [self release];
        return nil;
    }
    
    self = [super init];
    if (self) {
        tvConnections = [[NSMutableArray alloc] initWithCapacity:5];
        connectedServices = [[NSMutableArray alloc] initWithCapacity:5];
        viewControllers = [[NSMutableArray alloc] initWithCapacity:5];
        tvBrowser = _tvBrowser;
        
        // Initialize the NSNetServiceBrowser stuff
        // The netServiceManager manages advertisements from service broadcasts
        netServiceManager = [[NetServiceManager alloc] initWithClientDelegate:self];
        
        [netServiceManager start];
    }
    
    return self;
}

#pragma mark -
#pragma mark TVBrowserViewController

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

// TODO: more secure method will prevent from 1 phone having 10+ connections to the same
// TV
- (TVConnection *)getConnectionForService:(NSNetService *)service {
    for (unsigned int i = 0; i < tvConnections.count; i++) {
        TVConnection *connection = [[tvConnections objectAtIndex:i] pointerValue];
        // TODO: need a more secure method of checking if its the current services
        if ([service.name compare:connection.connectedService.name] == NSOrderedSame) {
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
        [self viewControllersRefresh];
    }
}

- (void)informOfSameConnection:(TVConnection *)tvConnection {
    [tvBrowser.delegate tvBrowser:tvBrowser didEstablishConnection:tvConnection newConnection:NO];
}

- (void)informOfFailedService:(NSNetService *)service {
    [tvBrowser.delegate tvBrowser:tvBrowser didNotEstablishConnectionToService:service];
}

- (void)connectToService:(NSNetService *)service {
    // If not a Trickplay service
    if ([netServiceManager.connectingServices containsObject:service]) {
        return;
    }
    
    NSLog(@"Connect to service: %@ ; type: %@", service, service.type);
    
    if ([service.type compare:@"_tp-remote._tcp."] != NSOrderedSame || ![netServiceManager.services containsObject:service]) {
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
    
    TVConnection *connection = [[[TVConnection alloc] initWithService:service delegate:nil] autorelease];
    
    if (connection) {
        [connection setTVBrowser:tvBrowser];
        [connectedServices addObject:service];
        [tvConnections addObject:[NSValue valueWithPointer:connection]];
    }
    
    if (tvBrowser.delegate) {
        if (connection) {
            [tvBrowser.delegate tvBrowser:tvBrowser didEstablishConnection:connection newConnection:YES];
        } else {
            [tvBrowser.delegate tvBrowser:tvBrowser didNotEstablishConnectionToService:service];
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
    
    [tvBrowser refreshServices];
    if (tvBrowser.delegate) {
        [tvBrowser.delegate tvBrowser:tvBrowser didNotEstablishConnectionToService:service];
    }
    
    [self viewControllersRefresh];
}


- (void)didStopService:(NSNetService *)service {
    // Nothing to do
}

- (void)didFindService:(NSNetService *)service {
    if (tvBrowser.delegate) {
        [tvBrowser.delegate tvBrowser:tvBrowser didFindService:service];
    }
    
    [self viewControllersRefresh];
}

- (void)didRemoveService:(NSNetService *)service {
    if (tvBrowser.delegate) {
        [tvBrowser.delegate tvBrowser:tvBrowser didRemoveService:service];
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
#pragma mark Deallocation

- (void)dealloc {
    for (unsigned int i = 0; i < tvConnections.count; i++) {
        TVConnection *connection = [[tvConnections objectAtIndex:i] pointerValue];
        [connection setTVBrowser:nil];
    }
    
    [tvConnections release];
    [connectedServices release];
    
    [viewControllers release];
    
    [netServiceManager stop];
    [netServiceManager release];
    netServiceManager = nil;
    
    tvBrowser = nil;
    
    [super dealloc];
}

@end






@implementation TVBrowser

@synthesize delegate;

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<TVBrowserDelegate>)theDelegate {
    self = [super init];
    if (self) {
        context = [[TVBrowserContext alloc] initWithTVBrowser:self];
        if (!context) {
            [self release];
            return nil;
        }
        
        self.delegate = theDelegate;
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
    [(TVBrowserContext *)context addViewController:viewController];
}

- (void)invalidateViewController:(TVBrowserViewController *)viewController {
    [(TVBrowserContext *)context invalidateViewController:viewController];
}

- (void)viewControllersRefresh {
    [(TVBrowserContext *)context viewControllersRefresh];
}

#pragma mark -
#pragma mark Managing TVConnections

// TODO: more secure method will prevent from 1 phone having 10+ connections to the same
// TV
- (TVConnection *)getConnectionForService:(NSNetService *)service {
    return [(TVBrowserContext *)context getConnectionForService:service];
}

- (void)invalidateTVConnection:(TVConnection *)tvConnection {
    [(TVBrowserContext *)context invalidateTVConnection:tvConnection];
}

- (void)connectToService:(NSNetService *)service {
    [(TVBrowserContext *)context connectToService:service];
}

#pragma mark -
#pragma mark Managing Broadcasted Services

- (void)startSearchForServices {
    [(TVBrowserContext *)context startSearchForServices];
}

- (void)stopSearchForServices {
    [(TVBrowserContext *)context stopSearchForServices];
}

- (void)refreshServices {
    [(TVBrowserContext *)context refreshServices];
}

#pragma mark -
#pragma mark Getters

- (NSArray *)getConnectedServices {
    return [[((TVBrowserContext *)context).connectedServices retain] autorelease];
}

- (NSArray *)getConnectingServices {
    return ((TVBrowserContext *)context).netServiceManager.connectingServices;
}

- (NSArray *)getAllServices {
    return ((TVBrowserContext *)context).netServiceManager.services;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    NSLog(@"TVBrowser Dealloc");
    
    [context release];
    context = nil;
    self.delegate = nil;
    
    [super dealloc];
}

@end



