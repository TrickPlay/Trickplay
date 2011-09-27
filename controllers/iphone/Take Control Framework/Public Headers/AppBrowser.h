//
//  AppBrowserController.h
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppBrowser;
@class AppBrowserViewController;
@class TVConnection;

/**
 * AppInfo objects are returned by the AppBrowser. They represent
 * apps on a TV. They contain all necessary information to launch
 * an app on the TV remotely.
 */

@interface AppInfo : NSObject {

@private
    // The name of the app.
    NSString *name;
    // The unique ID of the app.
    NSString *appID;
    // The app version number.
    NSNumber *version;
    // The app release number.
    NSNumber *releaseNumber;
}

@property (readonly) NSString *name;
@property (readonly) NSString *appID;
@property (readonly) NSNumber *version;
@property (readonly) NSNumber *releaseNumber; 

@end


/**
 * The AppBrowserDelegate Protocol provides methods to inform
 * the AppBrowser's delegate of receipt of app related information
 * from the TV. This includes when the AppBrowser discovers the
 * apps available to run on the TV and/or the app currently running
 * on the TV. This delegate is also informed when an app is remotely
 * launched to the TV successfully.
 */

@protocol AppBrowserDelegate <NSObject>

@required
- (void)appBrowser:(AppBrowser *)appBrowser didReceiveAvailableApps:(NSArray *)apps;
- (void)appBrowser:(AppBrowser *)appBrowser didReceiveCurrentApp:(AppInfo *)app;
- (void)appBrowser:(AppBrowser *)appBrowser newAppLaunched:(AppInfo *)app successfully:(BOOL)success;

@end


/**
 * The AppBrowser class provides methods and properties to investigate
 * the apps currently available and currently running on a TV. This
 * information may also be used to launch apps remotely on the TV
 * via the AppBrowser class' method - launchApp:(AppInfo *)app.
 *
 * An AppBrowser may be initialized with or without a delegate or
 * a TVConnection object. However, an AppBrowser will only function
 * with an active TVConnection object.
 */

@interface AppBrowser : NSObject

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
