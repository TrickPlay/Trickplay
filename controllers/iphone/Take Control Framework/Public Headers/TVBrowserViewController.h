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

/**
 * The TVBrowserViewControllerDelegate Protocol informs the delegate 
 * when the user selects a cell from the TVBrowserViewController which
 * references the delegate.
 */

@protocol TVBrowserViewControllerDelegate <NSObject>

@required

- (void)tvBrowserViewController:(TVBrowserViewController *)tvBrowserViewController
               didSelectService:(NSNetService *)service;

@end


/**
 * Summary:
 *
 * The TVBrowserViewController is an extension of the UITableViewController class.
 * This class lists TVs on the local network that the user may connect to in a
 * UITableView. Selecting a TV in the UITableView sends an NSNetService to this class'
 * delegate referencing a possible connection to a Trickplay enabled TV over the
 * local network. Additionally, the TVBrowserViewController will inform its TVBrowser
 * instantiation of the selection and the TVBrowser will subsequently begin attempting
 * to connect to the TV.
 *
 *
 * How To Use:
 *
 * An autoreleased object of this class may be created from a TVBrowser via the
 * - getNewTVBrowserViewController message, where the new TVBrowserViewController
 * will reference and retain the TVBrowser which created it. If a TVBrowserViewController
 * is created using +alloc it must be initialized using:
 * - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 * with nibNameOrNil equaling @"TVBrowserViewController" and it will retain
 * its own TVBrowser.
 *
 * TVBrowserViewController Objects are compatible with Interface Builder.
 */

@interface TVBrowserViewController : UITableViewController <UITableViewDelegate, 
UITableViewDataSource, UINavigationControllerDelegate>

// The objects delegate.
@property (assign) id <TVBrowserViewControllerDelegate> delegate;
// The objects TVBrowser.
@property (readonly) TVBrowser *tvBrowser;

// Calls - (void)reloadData on its own UITableView which repopulates the
// TVBrowserViewController with data aquired by the tvBrowser insantiation.
- (void)reloadData;
// Calls - (void)refreshServices on the objects tvBrowser instantiation.
- (void)refresh;

@end
