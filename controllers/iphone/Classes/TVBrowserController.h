//
//  TVBrowserController.h
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppBrowserController.h"
#import "NetServiceManager.h"

@protocol TVBrowserControllerDelegate <NSObject>

@required
- (void)socketErrorOccurred;
- (void)streamEndEncountered;
- (void)serviceResolved:(NSNetService *)service;
- (void)didNotResolveService;
- (void)appBrowserReady:(AppBrowserController *)appBrowser;
- (void)appBrowserInvalid:(AppBrowserController *)appBrowser;

@end


@interface TVBrowserController : NSObject {
    AppBrowserController *appBrowserController;
    NetServiceManager *netServiceManager;
    
    NSString *currentTVName;
    id <TVBrowserControllerDelegate> delegate;
}

// Exposed methods
- (id)initWithDelegate:(id <TVBrowserControllerDelegate>)delegate;

- (NSArray *)getServices;
- (NSNetService *)getCurrentService;
- (void)refreshServices;
- (void)resolveServiceAtIndex:(NSUInteger)index;


// Exposed instance variables
@property (retain) AppBrowserController *appBrowserController;
@property (nonatomic, retain) NSString *currentTVName;
@property (assign) id <TVBrowserControllerDelegate> delegate;

@end
