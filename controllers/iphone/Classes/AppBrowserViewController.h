//
//  AppBrowserViewController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YAJLiOS/YAJL.h>
#import "GestureViewController.h"

/**
 * The AppBrowserViewController lists apps available from a service.
 *
 * Queries Trickplay for its available apps via a URL Request using an
 * HTTP port (the port number is received from a welcome message which 
 * Trickplay sends to the App Browser's associated GestureViewController).
 * The data received from the URL Request is a JSON string containing a
 * list of apps avaible for the connected service. The AppBrowser then
 * lists these available apps in a UITableView so the user may select them;
 * starting the selected app on the television.
 *
 * Refer to AppBrowserViewController.xib for the AppBrowser's view.
 */

@interface AppBrowserViewController : UIViewController <UITableViewDelegate, 
UITableViewDataSource, GestureViewControllerSocketDelegate> {
    /*
    UIBarButtonItem *appShopButton;
    UIBarButtonItem *showcaseButton;
    UIToolbar *toolBar;
    */
    BOOL viewDidAppear;
     
    UITableView *theTableView;
    NSArray *appsAvailable;
    GestureViewController *gestureViewController;
    
    NSString *currentAppName;
    UIImageView *currentAppIndicator;
    
    BOOL pushingViewController;
    
    id <GestureViewControllerSocketDelegate> socketDelegate;
}

// Exposed properties
/*
@property (nonatomic, retain) IBOutlet UIBarButtonItem *appShopButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *showcaseButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
*/
@property (retain) IBOutlet UITableView *theTableView;
@property (retain) NSArray *appsAvailable;
@property (nonatomic, retain) NSString *currentAppName;
@property (nonatomic, assign) BOOL pushingViewController;

@property (nonatomic, assign) id <GestureViewControllerSocketDelegate> socketDelegate;

// Exposed methods
- (IBAction) appShopButtonClick;
- (IBAction) showcaseButtonClick;
- (void)createGestureViewWithPort:(NSInteger)p hostName:(NSString *)h;
- (NSDictionary *)getCurrentAppInfo;
- (BOOL)fetchApps;
- (void)setupService:(NSInteger)p
            hostname:(NSString *)h
            thetitle:(NSString *)n;
- (BOOL)hasRunningApp;
- (void)pushApp;

    // GestureViewControllerSocketDelegate methods
- (void)socketErrorOccurred;
- (void)streamEndEncountered;

@end
