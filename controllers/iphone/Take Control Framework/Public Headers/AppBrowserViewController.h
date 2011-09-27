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
 * when the user selects a cell from the AppBrowserViewController which
 * refereces the delegate.
 */

@protocol AppBrowserViewControllerDelegate <NSObject>

- (void)appBrowserViewController:(AppBrowserViewController *)appBrowserViewController
                    didSelectApp:(AppInfo *)app
                    isCurrentApp:(BOOL)isCurrentApp;

@end


/**
 * The AppBrowserViewController extends the UIViewController class, adding
 * functionality where the cells list apps available on a TV the user
 * is connected to. The cells of the AppBrowserViewController are updated
 * by its appBrowser instance.
 *
 * An object of this class may be created by sending the
 * - (AppBrowserViewController *)createAppBrowserViewController message
 * to an AppBrowser object or may be created using alloc and initialized using
 * - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 * with nibNameOrNil equaling @"AppBrowserViewController. In the former case the
 * AppBrowser which created the AppBrowserViewController will be retained by
 * AppBrowserViewController. In the later case the AppBrowserViewController
 * will retain an internally created AppBrowser.
 */

@interface AppBrowserViewController : UIViewController <UITableViewDelegate, 
UITableViewDataSource>

// References the AppBrowserViewController's UITableView for displaying
// possible apps.
@property (retain) IBOutlet UITableView *tableView;
// This object's AppBrowser.
@property (readonly) AppBrowser *appBrowser;
// The object's delegeate.
@property (assign) id <AppBrowserViewControllerDelegate> delegate;

// Exposed methods
// Currently inactive.
- (IBAction) appShopButtonClick;
// Currently inactive.
- (IBAction) showcaseButtonClick;
// Calls - (void)refresh on the objects appBrowser instantiation.
- (void)refresh;

@end
