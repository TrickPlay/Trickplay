//
//  AppBrowserViewController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YAJLiOS/YAJL.h>
#import "AppBrowser.h"

@protocol AppBrowserViewControllerDelegate <AppBrowserDelegate>

- (void)appBrowserViewController:(AppBrowserViewController *)appBrowserViewController
                    didSelectApp:(AppInfo *)app
                    isCurrentApp:(BOOL)isCurrentApp;

@end

/**
 * The AppBrowserViewController lists apps available from a service.
 *
 * Queries Trickplay for its available apps via a URL Request using an
 * HTTP port (the port number is received from a welcome message which 
 * Trickplay sends to the App Browser's associated TPAppViewController).
 * The data received from the URL Request is a JSON string containing a
 * list of apps avaible for the connected service. The AppBrowser then
 * lists these available apps in a UITableView so the user may select them;
 * starting the selected app on the television.
 *
 * Refer to AppBrowserViewController.xib for the AppBrowser's view.
 */
@interface AppBrowserViewController : UIViewController <UITableViewDelegate, 
UITableViewDataSource> {
    @private
    /*
    UIBarButtonItem *appShopButton;
    UIBarButtonItem *showcaseButton;
    UIToolbar *toolBar;
    */
     
    UITableView *tableView;
    // Spins while a app data is loading; disappears otherwise.
    UIActivityIndicatorView *loadingSpinner;
    
    // Refreshes the list of apps
    UIBarButtonItem *refreshButton;
    
    // Orange dot indicating which app is the current app
    UIImageView *currentAppIndicator;
    
    AppBrowser *appBrowser;
    
    id <AppBrowserViewControllerDelegate> delegate;
}

// Exposed properties
/*
@property (nonatomic, retain) IBOutlet UIBarButtonItem *appShopButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *showcaseButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
*/
@property (retain) IBOutlet UITableView *tableView;
@property (readonly) AppBrowser *appBrowser;
@property (assign) id <AppBrowserViewControllerDelegate> delegate;

// Exposed methods
- (IBAction) appShopButtonClick;
- (IBAction) showcaseButtonClick;
- (void)refresh;

@end
