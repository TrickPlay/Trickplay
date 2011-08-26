//
//  TVBrowserController.m
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TVBrowserController.h"

@implementation TVBrowserController

@synthesize appBrowserController;
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

- (id)initWithDelegate:(id<TVBrowserControllerDelegate>)theDelegate {
    self = [super init];
    if (self) {
        delegate = theDelegate;
        self.currentTVName = nil;
        self.appBrowserController = nil;
        // Initialize the NSNetServiceBrowser stuff
        // The netServiceManager manages advertisements from service broadcasts
        if (!netServiceManager) {
            netServiceManager = [[NetServiceManager alloc] initWithDelegate:self];
        }
    }
    
    return self;
}

- (NSArray *)getServices {
    return netServiceManager.services;
}

- (void)resolveServiceAtIndex:(NSUInteger)index {
    netServiceManager.currentService = [[self getServices] objectAtIndex:index];
    [netServiceManager.currentService setDelegate:netServiceManager];
    
    [netServiceManager.currentService resolveWithTimeout:5.0];
}

#pragma mark -
#pragma mark AppBrowserViewControllerSocketDelegate stuff

/**
 * Generic operations to perform when the network fails. Includes deallocating
 * other view controllers and their resources and restarting the NetServiceManager
 * which will then begin browsing for advertised services.
 */
- (void)handleSocketProblems {    
    if (appBrowserController) {
        [appBrowserController release];
        appBrowserController = nil;
        [currentTVName release];
        currentTVName = nil;
    }
    
    [netServiceManager start];
}

/**
 * GestureViewControllerSocketDelegate callback called from AppBrowserViewController
 * when an error occurs over the network.
 */
- (void)socketErrorOccurred {
    NSLog(@"Socket Error Occurred in Root");
    
    [self handleSocketProblems];
    if (delegate) {
        [delegate socketErrorOccurred];
    }
}

/**
 * GestureViewControllerSocketDelegate callback called from AppBrowserViewController
 * when the stream socket closes.
 */
- (void)streamEndEncountered {
    NSLog(@"Socket End Encountered in Root");
    
    [self handleSocketProblems];
    if (delegate) {
        [delegate streamEndEncountered];
    }
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
    [appBrowserController setupService:[service port] hostname:[service hostName] thetitle:[service name]];
    self.currentTVName = [service name];
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
}

- (void)refreshServices {
    
}

- (NSNetService *)getCurrentService {
    return netServiceManager.currentService;
}

@end
