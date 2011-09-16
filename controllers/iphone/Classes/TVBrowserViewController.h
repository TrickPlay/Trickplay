//
//  TVBrowserViewController.h
//  TrickplayController
//
//  Created by Rex Fenley on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class TVBrowserViewController;
@class TVBrowser;

@protocol TVBrowserViewControllerDelegate <NSObject>

@required

- (void)tvBrowserViewController:(TVBrowserViewController *)tvBrowserViewController
               didSelectService:(NSNetService *)service;

@end


@interface TVBrowserViewController : UITableViewController <UITableViewDelegate, 
UITableViewDataSource, UINavigationControllerDelegate> {
    // Orange dot that displays next to the current service
    //UIView *currentTVIndicator;
    // Spins while a service is loading; disappears otherwise.
    UIActivityIndicatorView *loadingSpinner;
    
    // Refreshes the list of services
    UIBarButtonItem *refreshButton;
    
    TVBrowser *tvBrowser;
        
    id <TVBrowserViewControllerDelegate> delegate;
}

- (void)reloadData;
- (void)refresh;

@property (assign) id <TVBrowserViewControllerDelegate> delegate;
@property (readonly) TVBrowser *tvBrowser;

@end
