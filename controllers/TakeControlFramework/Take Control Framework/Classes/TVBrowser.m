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
#import "Protocols.h"

@interface TVBrowserContext : TVBrowser <NetServiceManagerDelegate, TVConnectionDidConnectDelegate> {
    
@protected
    // The netServiceManager informs the TVBrowser of mDNS broadcasts
    NetServiceManager *netServiceManager;
    
    NSMutableArray *tvConnections;
    NSMutableArray *connectedServices;
    NSMutableArray *viewControllers;
    
    // publicly exposed vars
    id <TVBrowserDelegate> delegate;
}

@property (nonatomic, readonly) NetServiceManager *netServiceManager;
@property (nonatomic, readonly) NSMutableArray *tvConnections;
@property (nonatomic, readonly) NSMutableArray *connectedServices;
@property (nonatomic, readonly) NSMutableArray *viewControllers;

- (void)addViewController:(TVBrowserViewController *)viewController;
- (void)invalidateViewController:(TVBrowserViewController *)viewController;
- (void)viewControllersRefresh;

- (TVConnection *)getConnectionForService:(NSNetService *)service;
- (void)invalidateTVConnection:(TVConnection *)tvConnection;

@end



@implementation TVBrowserContext

@synthesize netServiceManager;
@synthesize tvConnections;
@synthesize connectedServices;
@synthesize viewControllers;
//@synthesize delegate;

#pragma mark -
#pragma mark Property Getters/Setters

- (id <TVBrowserDelegate>)delegate {
    id <TVBrowserDelegate> val = nil;
    @synchronized(self) {
        val = delegate;
    }
    return val;
}

- (void)setDelegate:(id <TVBrowserDelegate>)_delegate {
    @synchronized(self) {
        delegate = _delegate;
    }
}

#pragma mark -
#pragma mark Initialization

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id <TVBrowserDelegate>)_delegate {
    self = [super init];
    if (self) {
        tvConnections = [[NSMutableArray alloc] initWithCapacity:5];
        connectedServices = [[NSMutableArray alloc] initWithCapacity:5];
        viewControllers = [[NSMutableArray alloc] initWithCapacity:5];
        
        delegate = _delegate;
        
        // Initialize the NSNetServiceBrowser stuff
        // The netServiceManager manages advertisements from service broadcasts
        netServiceManager = [[NetServiceManager alloc] initWithClientDelegate:self];
        
        [netServiceManager start];
    }
    
    return self;
}

#pragma mark -
#pragma mark TVBrowserViewController

- (TVBrowserViewController *)getNewTVBrowserViewController {
    NSBundle *myBundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@%@", [NSBundle mainBundle].bundlePath, @"/TakeControl.framework"]];
    
    TVBrowserViewController *viewController = [[[TVBrowserViewController alloc] initWithNibName:@"TVBrowserViewController" bundle:myBundle tvBrowser:self] autorelease];
    
    return viewController;
}

- (void)addViewController:(TVBrowserViewController *)viewController {
    [viewControllers addObject:[NSValue valueWithPointer:viewController]];
}

- (void)invalidateViewController:(TVBrowserViewController *)viewController {
    NSUInteger i;
    // Check that viewController is in the viewControllers array
    for (i = 0; i < viewControllers.count; i++) {
        TVBrowserViewController *_viewController = [[viewControllers objectAtIndex:i] pointerValue];
        if (viewController == _viewController) {
            break;
        }
    }
    
    // Remove the weak reference to the invalidating TVBrowserViewController
    if (viewControllers.count > i && viewController == [[viewControllers objectAtIndex:i] pointerValue]) {
        [viewControllers removeObjectAtIndex:i];
    } else {
        NSLog(@"WARNING: invalidated a TVBrowserViewController that is not registered");
    }
}

- (void)viewControllersRefresh {
    for (unsigned int i = 0; i < viewControllers.count; i++) {
        TVBrowserViewController *viewController = [[viewControllers objectAtIndex:i] pointerValue];
        
        [viewController reloadData];
    }
}

#pragma mark -
#pragma mark TVConnection Connection Delegate

- (void)tvConnection:(TVConnection *)tvConnection didConnectToService:(NSNetService *)service {
    [tvConnection setTVBrowser:self];
    [connectedServices addObject:service];
    [tvConnections addObject:[NSValue valueWithPointer:tvConnection]];
    
    if (delegate) {
        [delegate tvBrowser:self didEstablishConnection:tvConnection newConnection:YES];
    }
    
    [self viewControllersRefresh];
}

- (void)tvConnection:(TVConnection *)tvConnection didNotConnectToService:(NSNetService *)service {
    if (delegate) {
        [delegate tvBrowser:self didNotEstablishConnectionToService:service];
    }
    
    [self viewControllersRefresh];
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
    
    if (tvConnections.count > i && tvConnection == [[tvConnections objectAtIndex:i] pointerValue]) {
        [tvConnections removeObjectAtIndex:i];
        [self viewControllersRefresh];
    } else {
        NSLog(@"WARNING: invalidated a TVConnection that is not registered");
    }
}

- (void)informOfSameConnection:(TVConnection *)tvConnection {
    [delegate tvBrowser:self didEstablishConnection:tvConnection newConnection:NO];
}

- (void)informOfFailedService:(NSNetService *)service {
    [delegate tvBrowser:self didNotEstablishConnectionToService:service];
}

- (void)connectToService:(NSNetService *)service {
    // If not a Trickplay service
    if ([netServiceManager.connectingServices containsObject:service]) {
        return;
    }
    
    NSLog(@"Connect to service: %@ ; type: %@", service, service.type);
    
    //if ([service.type compare:@"_tp-remote._tcp."] != NSOrderedSame || ![netServiceManager.services containsObject:service]) {
    if ([service.type compare:@"_trickplay-http._tcp."] != NSOrderedSame || ![netServiceManager.services containsObject:service]) {
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
    connection.connectionDelegate = self;
    /*
    if (connection) {
        [connection setTVBrowser:self];
        [connectedServices addObject:service];
        [tvConnections addObject:[NSValue valueWithPointer:connection]];
    }
    
    if (delegate) {
        if (connection) {
            [delegate tvBrowser:self didEstablishConnection:connection newConnection:YES];
        } else {
            [delegate tvBrowser:self didNotEstablishConnectionToService:service];
        }
    }
    
    [self viewControllersRefresh];
    //*/
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
        [delegate tvBrowser:self didNotEstablishConnectionToService:service];
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
#pragma mark Deallocation

- (void)dealloc {
    NSLog(@"TVBrowser Dealloc");
    
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
    
    [super dealloc];
}

@end






@implementation TVBrowser

#pragma mark -
#pragma mark Allocation

+ (id)alloc {
    if ([self isEqual:[TVBrowser class]]) {
        NSZone *temp = [self zone];
        [self release];
        return [TVBrowserContext allocWithZone:temp];
    } else {
        return [super alloc];
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    if ([self isEqual:[TVBrowser class]]) {
        return [TVBrowserContext allocWithZone:zone];
    } else {
        return [super allocWithZone:zone];
    }
}

#pragma mark -
#pragma mark Initialization

- (id)initWithDelegate:(id <TVBrowserDelegate>)theDelegate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark TVBrowserViewController

- (TVBrowserViewController *)getNewTVBrowserViewController {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)addViewController:(TVBrowserViewController *)viewController {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)invalidateViewController:(TVBrowserViewController *)viewController {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)viewControllersRefresh {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark Managing TVConnections

// TODO: more secure method will prevent from 1 phone having 10+ connections to the same
// TV
- (TVConnection *)getConnectionForService:(NSNetService *)service {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)invalidateTVConnection:(TVConnection *)tvConnection {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)connectToService:(NSNetService *)service {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark Managing Broadcasted Services

- (void)startSearchForServices {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)stopSearchForServices {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)refreshServices {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark Getters/Setters

- (NSArray *)getConnectedServices {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSArray *)getConnectingServices {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSArray *)getAllServices {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (id <TVBrowserDelegate>)delegate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setDelegate:(id <TVBrowserDelegate>)delegate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark Memory Management

/*
- (void)dealloc {
    NSLog(@"TVBrowser Dealloc");
    
    [super dealloc];
}
*/

@end



