//
//  TakeControlAgainViewController.h
//  TakeControlAgain
//
//  Created by Rex Fenley on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPAppViewController.h"
#import "AppBrowserViewController.h"
#import "AppBrowser.h"
#import "TVBrowserViewController.h"
#import "TVBrowser.h"
#import "TVConnection.h"

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

@interface TakeControlAgainViewController : UIViewController <UINavigationControllerDelegate,
TPAppViewControllerDelegate, TVConnectionDelegate,
TVBrowserViewControllerDelegate, TVBrowserDelegate,
AppBrowserViewControllerDelegate, AppBrowserDelegate> {
    NSUInteger refreshCount;
    
    // Initialized to NO. Set to YES while the AppBrowser is in the course
    // of being pushed to the top of the navigation stack
    BOOL pushingAppBrowser;
    
    // YES if the NavigationViewController is in the middle of animating
    // pushing the TPAppViewController or if the visible view is the
    // TPAppViewController. Initialized to NO and set back to NO
    // when the AppBrowserViewController (self) calls viewDidAppear.
    BOOL pushingAppViewController;
    
    TVBrowserViewController *tvBrowserViewController;
    AppBrowserViewController *appBrowserViewController;
    TPAppViewController *appViewController;
    
    UINavigationController *navigationController;
}

// Exposed properties
@property (retain) UINavigationController *navController;
@property (retain) TVBrowserViewController *tvBrowserViewController;

// Exposed methods
- (void)pushAppBrowser;
- (void)destroyAppBrowserViewController;
- (void)createTPAppViewControllerWithConnection:(TVConnection *)connection;
- (void)pushTPAppViewController;
- (void)destroyTPAppViewController;

@end

