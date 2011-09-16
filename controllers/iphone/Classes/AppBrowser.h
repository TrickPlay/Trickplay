//
//  AppBrowserController.h
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVConnection.h"

@class AppBrowser;
@class AppBrowserViewController;


@interface AppInfo : NSObject {

    // TODO: Remember to add all the variables
    @private
    NSString *name;
    NSString *appID;
}

@property (readonly) NSString *name;
@property (readonly) NSString *appID;

@end



@protocol AppBrowserDelegate <NSObject>

@required
- (void)appBrowser:(AppBrowser *)appBrowser didReceiveAvailableApps:(NSArray *)apps;
- (void)appBrowser:(AppBrowser *)appBrowser didReceiveCurrentApp:(AppInfo *)app;
- (void)appBrowser:(AppBrowser *)appBrowser newAppLaunched:(AppInfo *)app successfully:(BOOL)success;

@end



@interface AppBrowser : NSObject {
    @public
    id <AppBrowserDelegate> delegate;
    
    TVConnection *tvConnection;
    
    NSMutableArray *availableApps;
    // The current app running on Trickplay
    AppInfo *currentApp;

    @private
    NSMutableArray *viewControllers;
    
    // Asynchronous URL connections for populating the table with
    // available apps and fetching information on the current
    // running app
    NSURLConnection *fetchAppsConnection;
    NSURLConnection *currentAppInfoConnection;
    
    // The data buffers for the connections
    NSMutableData *fetchAppsData;
    NSMutableData *currentAppData;
}

// Exposed instance variables
@property (assign) id <AppBrowserDelegate> delegate;
@property (readonly) NSMutableArray *availableApps;
@property (readonly) AppInfo *currentApp;
@property (retain) TVConnection *tvConnection;

- (id)initWithDelegate:(id <AppBrowserDelegate>)delegate;
- (id)initWithConnection:(TVConnection *)tvConnection delegate:(id <AppBrowserDelegate>)delegate;

- (AppBrowserViewController *)createAppBrowserViewController;

- (void)refresh;

//- (BOOL)hasRunningApp;

//- (NSDictionary *)getCurrentAppInfo;
- (void)refreshCurrentApp;
//- (void)getCurrentAppInfoWithDelegate:(id <AppBrowserDelegate>)delegate;
//- (NSArray *)getAvailableAppsInfo;
//- (void)getAvailableAppsInfoWithDelegate:(id <AppBrowserDelegate>)delegate;
- (void)refreshAvailableApps;
- (void)launchApp:(AppInfo *)app;


@end
