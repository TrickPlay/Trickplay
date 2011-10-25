//
//  AppBrowserViewController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppBrowser;
@class AppBrowserViewController;
@class AppInfo;

/**
 * The AppBrowserViewControllerDelegate Protocol informs the delegate
 * when the user selects a cell from the AppBrowserViewController.
 */

@protocol AppBrowserViewControllerDelegate <NSObject>

- (void)appBrowserViewController:(AppBrowserViewController *)appBrowserViewController
                    didSelectApp:(AppInfo *)app
                    isCurrentApp:(BOOL)isCurrentApp;

@end


/**
 * The AppBrowserViewController extends the UIViewController class.
 * This view controller's view contains a UITableView for displaying
 * a list of apps available on the TV the device is connected to.
 * Every AppBrowserViewController maintains a reference to an AppBrowser,
 * which it uses to update its UITableView.
 *
 * An autoreleased object of this class may be retrieved by sending the
 * – getNewAppBrowserViewController message to an AppBrowser object or
 * a new object may be created using + alloc and initialized using
 * – initWithNibName:bundle: with the nib name @“AppBrowserViewController”.
 * In the former case the AppBrowser which created the
 * AppBrowserViewController will be retained by AppBrowserViewController.
 * In the later case the AppBrowserViewController will retain an
 * internally created AppBrowser and set its appBrowser property to this
 * instance.
 */

@interface AppBrowserViewController : UIViewController <UITableViewDelegate, 
UITableViewDataSource, UINavigationControllerDelegate>

// References the AppBrowserViewController's UITableView for displaying
// possible apps.
@property (retain) IBOutlet UITableView *tableView;
// This object's AppBrowser.
@property (readonly) AppBrowser *appBrowser;
// The object's delegeate.
@property (assign) id <AppBrowserViewControllerDelegate> delegate;

// Use this to initialize
- (id)init;
// Exposed methods
// Currently inactive.
- (IBAction) appShopButtonClick;
// Currently inactive.
- (IBAction) showcaseButtonClick;
// Calls - (void)refresh on the objects appBrowser instantiation.
- (void)refresh;

@end
