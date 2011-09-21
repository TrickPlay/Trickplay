//
//  TVBrowserController.h
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TVConnection;
@class TVBrowser;
@class TVBrowserViewController;




@protocol TVBrowserDelegate <NSObject>

@required
- (void)tvBrowser:(TVBrowser *)browser didFindService:(NSNetService *)service;
- (void)tvBrowser:(TVBrowser *)browser didRemoveService:(NSNetService *)service;

- (void)tvBrowser:(TVBrowser *)browser didEstablishConnection:(TVConnection *)connection newConnection:(BOOL)new;
- (void)tvBrowser:(TVBrowser *)browser didNotEstablishConnectionToService:(NSNetService *)service;

@end




@interface TVBrowser : NSObject {

@protected
    id <TVBrowserDelegate> delegate;
    id context;
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
