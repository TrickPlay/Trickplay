//
//  AppBrowserController.h
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPAppViewController.h"

@protocol AppBrowserDelegate <NSObject>

@required
- (void)didReceiveAvailableAppsInfo:(NSArray *)info;
- (void)didReceiveCurrentAppInfo:(NSDictionary *)info;

@end

@interface AppBrowser : NSObject {
    id <AppBrowserDelegate> delegate;
    
    NSString *host;
    NSUInteger port;
    NSString *serviceName;
    
    // The delegates for the connections
    id <AppBrowserDelegate> fetchAppsDelegate;
    id <AppBrowserDelegate> currentAppDelegate;
    
    // Asynchronous URL connections for populating the table with
    // available apps and fetching information on the current
    // running app
    NSURLConnection *fetchAppsConnection;
    NSURLConnection *currentAppInfoConnection;
    
    // The data buffers for the connections
    NSMutableData *fetchAppsData;
    NSMutableData *currentAppData;
    
    NSMutableArray *appsAvailable;
    NSString *currentAppName;
}

- (void)setupService:(NSUInteger)port
            hostName:(NSString *)hostName
            serviceName:(NSString *)serviceName;
- (BOOL)startService;

- (BOOL)hasRunningApp;

- (NSDictionary *)getCurrentAppInfo;
- (void)getCurrentAppInfoWithDelegate:(id <AppBrowserDelegate>)delegate;
- (NSArray *)fetchApps;
- (void)getAvailableAppsInfoWithDelegate:(id <AppBrowserDelegate>)delegate;

- (void)launchApp:(NSDictionary *)appInfo;

// Exposed instance variables
@property (assign) id <AppBrowserDelegate> delegate;
@property (retain) NSMutableArray *appsAvailable;
@property (retain) NSString *currentAppName;

@property (retain) NSString *host;
@property (assign) NSUInteger port;
@property (retain) NSString *serviceName;

@end
