//
//  TVBrowserController.h
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppBrowser.h"
#import "NetServiceManager.h"

@class TVBrowser;

@protocol TVBrowserDelegate <NSObject>

@required
- (void)tvBrowser:(TVBrowser *)browser serviceResolved:(NSNetService *)service;
- (void)tvBrowserDidNotResolveService:(TVBrowser *)browser;
- (void)tvBrowser:(TVBrowser *)browser didFindService:(NSNetService *)service;
- (void)tvBrowser:(TVBrowser *)browser didRemoveService:(NSNetService *)service;

@end


@interface TVBrowser : NSObject <NetServiceManagerDelegate> {
    // The netServiceManager informs the TVBrowser of mDNS broadcasts
    NetServiceManager *netServiceManager;
    
    // Name of the current TV; stores the name of the current service
    // used or nil if no service has been selected.
    NSString *currentTVName;
    
    id <TVBrowserDelegate> delegate;
}

// Exposed methods
- (id)initWithDelegate:(id <TVBrowserDelegate>)delegate;

- (NSArray *)getServices;
- (NSNetService *)getCurrentService;
- (void)startSearchForServices;
- (void)stopSearchForServices;
- (void)refreshServices;
- (void)resolveServiceAtIndex:(NSUInteger)index;


// Exposed instance variables
@property (nonatomic, retain) NSString *currentTVName;
@property (assign) id <TVBrowserDelegate> delegate;

@end
