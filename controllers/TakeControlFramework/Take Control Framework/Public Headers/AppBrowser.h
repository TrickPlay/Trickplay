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
 * apps on a TV. They contain all necessary information to browse
 * apps and launch an app on the TV remotely.
 */

@interface AppInfo : NSObject {

@private
    // The name of the app.
    NSString *name;
    // The unique ID of the app.
    NSString *appID;
    // The app version number.
    NSString *version;
    // The app release number.
    NSString *releaseNumber;
}

@property (readonly) NSString *name;
@property (readonly) NSString *appID;
@property (readonly) NSString *version;
@property (readonly) NSString *releaseNumber; 

// Compare two AppInfo objects
- (BOOL)equals:(AppInfo *)appInfo;

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
 * a TVConnection object. However, an AppBrowser will only provide
 * usable information if its tvConnection property is set to a
 * TVConnection object that has an active connection.
 *
 * AppBrowser objects are NOT automatically updated. Calls must be
 * made to - refresh to guarentee up-to-date information. However,
 * the information should rarely change. If an app launches successfully
 * via the method - launchApp the AppBrowser will update the property
 * currentApp to reflect this change.
 */

@interface AppBrowser : NSObject

// The delegate
@property (assign) id <AppBrowserDelegate> delegate;
// An array where each element references an AppInfo Object representing
// a particular app available on the TV that this AppBrowser's
// tvConnection is connected to. Must first call - refreshAvaibleApps
// to populate this array.
@property (readonly) NSArray *availableApps;
// An AppInfo object refering to the app currently running on the TV
// that tvConnection is connected to.
@property (readonly) AppInfo *currentApp;
// The TVConnection object this AppBrowser uses to update its
// availableApps and currentApp.
@property (retain) TVConnection *tvConnection;

// Designated initializer. tvConnection and delegate may both be nil.
- (id)initWithTVConnection:(TVConnection *)tvConnection delegate:(id <AppBrowserDelegate>)delegate;
// Returns an autoreleased initialized AppBrowserViewControl which updates
// from this AppBrowser.
- (AppBrowserViewController *)getNewAppBrowserViewController;
// Method to asynchronously refresh the AppBrowser's availableApps and
// currentApp properties. This will also refresh the data in all
// AppBrowserViewController objects that reference this AppBrowser. The
// delegate will be informed when the currentApp property refreshes and
// the availableApps property refreshes separately.
- (void)refresh;
// Cancels all attempts to asynchronously refresh the values of
// availableApps and currentApp. Both availableApps and currentApp will
// maintain whatever values they have at the time the call to this method
// is made.
- (void)cancelRefresh;
// Attempts to asynchronously update the property currentApp to match the
// current Trickplay app that is running on the TV.
- (void)refreshCurrentApp;
// Attempts to asynchronously update the property availableApps with all
// available apps currently available on the Trickplay enabled TV.
- (void)refreshAvailableApps;
// Attempts to asynchronously launch an app on the TV. The caller must
// provide an AppInfo object to this method that was obtained from the
// list of apps in the availableApps property. This method will return
// on failure without error.
- (void)launchApp:(AppInfo *)app;


@end
