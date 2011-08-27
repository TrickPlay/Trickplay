//
//  AppBrowserController.h
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPAppViewController.h"

@protocol AppBrowserControllerDelegate <NSObject>

@required
- (void)socketErrorOccurred;
- (void)streamEndEncountered;
- (void)didReceiveAvailableAppsInfo:(NSArray *)info;
- (void)didReceiveCurrentAppInfo:(NSDictionary *)info;

@end

@interface AppBrowserController : NSObject {
    id <AppBrowserControllerDelegate> delegate;
    id <AppBrowserControllerDelegate> fetchAppsDelegate;
    id <AppBrowserControllerDelegate> currentAppDelegate;
    
    NSMutableArray *appsAvailable;
    NSString *currentAppName;
    TPAppViewController *appViewController;
}

- (void)setupService:(NSInteger)p
            hostname:(NSString *)h
            thetitle:(NSString *)n;
- (BOOL)startService;

- (BOOL)hasRunningApp;

- (NSDictionary *)getCurrentAppInfo;
- (void)getCurrentAppInfoWithDelegate:(id <AppBrowserControllerDelegate>)delegate;
- (NSArray *)fetchApps;
- (void)getAvailableAppsInfoWithDelegate:(id <AppBrowserControllerDelegate>)delegate;

- (void)launchApp:(NSDictionary *)appInfo;

// Exposed instance variables
@property (assign) id <AppBrowserControllerDelegate> delegate;
@property (readonly) NSMutableArray *appsAvailable;
@property (readonly) NSString *currentAppName;
@property (assign) TPAppViewController *appViewController;

@end
