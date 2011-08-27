//
//  AppBrowserViewController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YAJLiOS/YAJL.h>
#import "TPAppViewController.h"

@protocol AppBrowserDelegate <NSObject>

@required
// If nil then didn't recieve data
- (void)didReceiveAvailableAppsInfo:(NSArray *)info;
- (void)didReceiveCurrentAppInfo:(NSDictionary *)info;

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
UITableViewDataSource, TPAppViewControllerSocketDelegate> {
    /*
    UIBarButtonItem *appShopButton;
    UIBarButtonItem *showcaseButton;
    UIToolbar *toolBar;
    */
    BOOL viewDidAppear;
     
    UITableView *theTableView;
    // Spins while a app data is loading; disappears otherwise.
    UIActivityIndicatorView *loadingSpinner;
    // An array of JSON strings containing information of apps available
    // on the Television/Trickplay
    NSMutableArray *appsAvailable;
    TPAppViewController *appViewController;
    
    // Name of the current app running on Trickplay
    NSString *currentAppName;
    // Orange dot indicating which app is the current app
    UIImageView *currentAppIndicator;
    
    // YES if the NavigationViewController is in the middle of animating
    // pushing the TPAppViewController or if the visible view is the
    // TPAppViewController. Initialized to NO and set back to NO
    // when the AppBrowserViewController (self) calls viewDidAppear.
    BOOL pushingViewController;
    
    // Asynchronous URL connections for populating the table with
    // available apps and fetching information on the current
    // running app
    NSURLConnection *fetchAppsConnection;
    NSURLConnection *currentAppInfoConnection;
    
    // The data buffers for the connections
    NSMutableData *fetchAppsData;
    NSMutableData *currentAppData;
    
    // The delegates for the connections
    id <AppBrowserDelegate> fetchAppsDelegate;
    id <AppBrowserDelegate> currentAppDelegate;
    
    // Refers to the RootViewController; informs the view controller
    // if a socket having an error or closing/ending
    id <TPAppViewControllerSocketDelegate> socketDelegate;
}

// Exposed properties
/*
@property (nonatomic, retain) IBOutlet UIBarButtonItem *appShopButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *showcaseButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
*/
@property (retain) IBOutlet UITableView *theTableView;
@property (retain) NSMutableArray *appsAvailable;
@property (nonatomic, retain) NSString *currentAppName;
@property (nonatomic, assign) BOOL pushingViewController;
@property (nonatomic, assign) TPAppViewController *appViewController;

@property (nonatomic, assign) id <TPAppViewControllerSocketDelegate> socketDelegate;

// Exposed methods
- (IBAction) appShopButtonClick;
- (IBAction) showcaseButtonClick;
- (void)createTPAppViewWithPort:(NSInteger)p hostName:(NSString *)h;
- (NSDictionary *)getCurrentAppInfo;
- (NSArray *)fetchApps;
- (void)getAvailableAppsInfoWithDelegate:(id<AppBrowserDelegate>)delegate;
- (void)getCurrentAppInfoWithDelegate:(id <AppBrowserDelegate>)delegate;
- (void)setupService:(NSInteger)p
            hostname:(NSString *)h
            thetitle:(NSString *)n;
- (BOOL)hasRunningApp;
- (void)pushApp;

// TPAppViewControllerSocketDelegate methods
- (void)socketErrorOccurred;
- (void)streamEndEncountered;

@end
