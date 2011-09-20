//
//  TVBrowserController.h
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetServiceManager.h"
#import "TVConnection.h"
#import "TVBrowserViewController.h"

@class TVBrowser;

@protocol TVBrowserDelegate <NSObject>

@required
- (void)tvBrowser:(TVBrowser *)browser didFindService:(NSNetService *)service;
- (void)tvBrowser:(TVBrowser *)browser didRemoveService:(NSNetService *)service;

- (void)tvBrowser:(TVBrowser *)browser didEstablishConnection:(TVConnection *)connection newConnection:(BOOL)new;
- (void)tvBrowser:(TVBrowser *)browser didNotEstablishConnectionToService:(NSNetService *)service;

@end


@interface TVBrowser : NSObject <NetServiceManagerDelegate> {
    @private
    id <TVBrowserDelegate> delegate;
    
    // The netServiceManager informs the TVBrowser of mDNS broadcasts
    NetServiceManager *netServiceManager;
        
    NSMutableArray *tvConnections;
    NSMutableArray *connectedServices;
    NSMutableArray *viewControllers;
}

// Exposed instance variables
@property (assign) id <TVBrowserDelegate> delegate;

// Exposed methods
- (id)initWithDelegate:(id <TVBrowserDelegate>)delegate;

- (TVBrowserViewController *)createTVBrowserViewController;

- (NSArray *)getAllServices;
- (NSArray *)getConnectedServices;
- (NSArray *)getConnectingServices;
- (void)startSearchForServices;
- (void)stopSearchForServices;
- (void)refreshServices;
- (void)connectToService:(NSNetService *)service;

@end
