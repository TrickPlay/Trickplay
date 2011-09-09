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

@class TVBrowserViewController;

@protocol TVBrowserViewControllerDelegate <NSObject>

@required
- (void)tvBrowserViewController:(TVBrowserViewController *)viewController
                serviceResolved:(NSNetService *)service;
- (void)tvBrowserViewControllerDidNotResolveService;
- (void)tvBrowserViewController:(TVBrowserViewController *)viewController
               didSelectService:(NSNetService *)service
               isCurrentService:(BOOL)isCurrentService;

@end

@interface TVBrowserViewController : UITableViewController <UITableViewDelegate, 
UITableViewDataSource, UINavigationControllerDelegate,
TVBrowserDelegate> {
    // Orange dot that displays next to the current service
    UIView *currentTVIndicator;
    // Spins while a service is loading; disappears otherwise.
    UIActivityIndicatorView *loadingSpinner;
    
    // Refreshes the list of services
    UIBarButtonItem *refreshButton;
    
    TVBrowser *tvBrowser;
    
    id <TVBrowserViewControllerDelegate> delegate;
}

// Exposed methods
- (void)stopSearchForServices;
- (void)startSearchForServices;
- (void)reloadData;
- (void)refresh;

// Exposed properties
@property (retain) TVBrowser *tvBrowser;
@property (retain) NSString *currentTVName;
@property (assign) id <TVBrowserViewControllerDelegate> delegate;

@end
