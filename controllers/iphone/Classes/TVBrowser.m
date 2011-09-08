//
//  TVBrowserController.m
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TVBrowser.h"

@implementation TVBrowser

@synthesize currentTVName;
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithDelegate:(id<TVBrowserDelegate>)theDelegate {
    self = [super init];
    if (self) {
        delegate = theDelegate;
        self.currentTVName = nil;
        // Initialize the NSNetServiceBrowser stuff
        // The netServiceManager manages advertisements from service broadcasts
        if (!netServiceManager) {
            netServiceManager = [[NetServiceManager alloc] initWithDelegate:self];
        }
        [netServiceManager start];
    }
    
    return self;
}

#pragma mark -
#pragma mark - Managing Broadcasted Services

- (void)resolveServiceAtIndex:(NSUInteger)index {
    netServiceManager.currentService = [[self getServices] objectAtIndex:index];
    [netServiceManager.currentService setDelegate:netServiceManager];
    
    [netServiceManager.currentService resolveWithTimeout:5.0];
}

/**
 * NetServiceManager delegate callback. Called when a connection may be established
 * to a service after the user selects a service they wish to connect to. Sends
 * the connection information to the AppBrowser which will pass said information
 * to classes to create a stream socket. Additionally, stores the service name
 * to the currentTVName.
 */
- (void)serviceResolved:(NSNetService *)service {
    NSLog(@"RootViewController serviceResolved");
    [netServiceManager stop];
    self.currentTVName = [service name];
    if (delegate) {
        [delegate tvBrowser:self serviceResolved:service];
    }
}

/**
 * NetServiceManager delegate callback. Called when establishing a stream
 * socket to the service the user selected fails. Based on which ViewController
 * is at the top of the UINavigationController view controller stack it will
 * properly pop and deallocate these resources as the system regresses back
 * to the RootViewController.
 */
- (void)didNotResolveService {
    NSLog(@"RootViewController didNotResolveService");
    
    [self refreshServices];
    if (delegate) {
        [delegate tvBrowserDidNotResolveService:self];
    }
}

- (void)didFindService:(NSNetService *)service {
    [delegate tvBrowser:self didFindService:service];
}

- (void)didRemoveService:(NSNetService *)service {
    [delegate tvBrowser:self didRemoveService:service];
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

- (NSNetService *)getCurrentService {
    return netServiceManager.currentService;
}


- (NSArray *)getServices {
    return netServiceManager.services;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    NSLog(@"TVBrowser Dealloc");
    
    [netServiceManager stop];
    [netServiceManager release];
    netServiceManager = nil;
    
    self.currentTVName = nil;
    self.delegate = nil;
    
    [super dealloc];
}

@end



