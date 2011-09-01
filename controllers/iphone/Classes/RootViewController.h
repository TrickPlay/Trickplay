//
//  RootViewController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetServiceManager.h"
#import "TPAppViewController.h"
#import "AppBrowserViewController.h"
#import "TVBrowserViewController.h"

/**
 * The RootViewController controls the root view of the over-arching
 * NavigationViewController for the TrickplayController app.
 *
 * Loads a TableViewController whose view lists possible TVs to connect to.
 * These TVs advertise their connection information via an mDNS service broadcast.
 * From here on the words TV and service will be used synonymously.
 *
 * Refer to RootViewController.xib for the Controller's View.
 */

@interface RootViewController : UIViewController <UINavigationControllerDelegate,
TPAppViewControllerSocketDelegate, AppBrowserViewControllerDelegate, TVBrowserViewControllerDelegate> {
    UIWindow *window;

    // Initialized to NO. Set to YES while the AppBrowser is in the course
    // of being pushed to the top of the navigation stack
    BOOL pushingAppBrowser;
    
    TVBrowserViewController *tvBrowserViewController;
    AppBrowserViewController *appBrowserViewController;
    
    UINavigationController *navigationController;
}

// Exposed methods
- (void)pushAppBrowser:(NSNotification *)notification;
- (void)serviceResolved:(NSNetService *)service;

// Exposed properties
@property (retain)IBOutlet UINavigationController *navigationController;
@property (retain) IBOutlet TVBrowserViewController *tvBrowserViewController;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
