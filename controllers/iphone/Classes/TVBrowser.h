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

@protocol TVBrowserDelegate <NSObject>

@required
- (void)serviceResolved:(NSNetService *)service;
- (void)didNotResolveService;
- (void)didFindServices;

@end


@interface TVBrowser : NSObject {
    AppBrowser *appBrowser;
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
@property (retain) AppBrowser *appBrowser;
@property (nonatomic, retain) NSString *currentTVName;
@property (assign) id <TVBrowserDelegate> delegate;

@end
