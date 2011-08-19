//
//  RootViewController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetServiceManager.h"
#import "GestureViewController.h"
#import "AppBrowserViewController.h"

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

@interface RootViewController : UITableViewController <UITableViewDelegate, 
UITableViewDataSource, UINavigationControllerDelegate,
GestureViewControllerSocketDelegate, NetServiceManagerDelegate,
AppBrowserDelegate> {
    UIWindow *window;

    // Name of the current TV; stores the name of the current service
    // used or nil if no service has been selected.
    NSString *currentTVName;
    // Orange dot that displays next to the current service
    UIView *currentTVIndicator;
    // Spins while a service is loading; disappears otherwise.
    UIActivityIndicatorView *loadingSpinner;
    // Refreshes the list of services
    UIBarButtonItem *refreshButton;
    // Initialized to NO. Set to YES while the AppBrowser is in the course
    // of being pushed to the top of the navigation stack
    BOOL pushingAppBrowser;
    
    NetServiceManager *netServiceManager;
    AppBrowserViewController *appBrowserViewController;
}

// Exposed methods
- (void)pushAppBrowser:(NSNotification *)notification;
- (void)serviceResolved:(NSNetService *)service;
- (void)reloadData;
- (void)refresh;

// Exposed properties
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (retain) NSString *currentTVName;

@end
