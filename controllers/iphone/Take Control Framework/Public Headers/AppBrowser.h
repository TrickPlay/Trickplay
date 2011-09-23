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

@private
    NSString *name;
    NSString *appID;
    NSNumber *version;
    NSNumber *releaseNumber;
}

@property (readonly) NSString *name;
@property (readonly) NSString *appID;
@property (readonly) NSNumber *version;
@property (readonly) NSNumber *releaseNumber; 

@end



@protocol AppBrowserDelegate <NSObject>

@required
- (void)appBrowser:(AppBrowser *)appBrowser didReceiveAvailableApps:(NSArray *)apps;
- (void)appBrowser:(AppBrowser *)appBrowser didReceiveCurrentApp:(AppInfo *)app;
- (void)appBrowser:(AppBrowser *)appBrowser newAppLaunched:(AppInfo *)app successfully:(BOOL)success;

@end



@interface AppBrowser : NSObject {

@protected
    id <AppBrowserDelegate> delegate;
    id context;
}

// Exposed instance variables
@property (assign) id <AppBrowserDelegate> delegate;
@property (readonly) NSArray *availableApps;
@property (readonly) AppInfo *currentApp;
@property (retain) TVConnection *tvConnection;

- (id)initWithDelegate:(id <AppBrowserDelegate>)delegate;
- (id)initWithConnection:(TVConnection *)tvConnection delegate:(id <AppBrowserDelegate>)delegate;

- (AppBrowserViewController *)createAppBrowserViewController;

- (void)refresh;
- (void)cancelRefresh;
- (void)refreshCurrentApp;
- (void)refreshAvailableApps;
- (void)launchApp:(AppInfo *)app;


@end
