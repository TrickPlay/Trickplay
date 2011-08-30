//
//  TVBrowserViewController.h
//  TrickplayController
//
//  Created by Rex Fenley on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetServiceManager.h"
#import "TPAppViewController.h"
#import "AppBrowserViewController.h"
#import "TVBrowser.h"

@interface TVBrowserViewController : UITableViewController <UITableViewDelegate, 
UITableViewDataSource, UINavigationControllerDelegate,
TPAppViewControllerSocketDelegate, NetServiceManagerDelegate,
AppBrowserDelegate, TVBrowserDelegate> {
    UIWindow *window;
    
    
    // Orange dot that displays next to the current service
    UIView *currentTVIndicator;
    // Spins while a service is loading; disappears otherwise.
    UIActivityIndicatorView *loadingSpinner;
    // Refreshes the list of services
    UIBarButtonItem *refreshButton;
    // Initialized to NO. Set to YES while the AppBrowser is in the course
    // of being pushed to the top of the navigation stack
    BOOL pushingAppBrowser;
    
    AppBrowserViewController *appBrowserViewController;
    
    TVBrowser *tvBrowser;
}

// Exposed methods
- (void)pushAppBrowser:(NSNotification *)notification;
- (void)serviceResolved:(NSNetService *)service;
- (void)reloadData;
- (void)refresh;

// Exposed properties
@property (retain) TVBrowser *tvBrowser;

@end
