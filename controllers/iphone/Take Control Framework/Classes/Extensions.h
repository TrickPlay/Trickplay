//
//  Category.h
//  TrickplayController
//
//  Created by Rex Fenley on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVBrowserViewController.h"
#import "TVBrowser.h"
#import "AppBrowserViewController.h"
#import "AppBrowser.h"
#import "TPAppViewController.h"
#import "TVConnection.h"

@class SocketManager;


// Hidden Methods

@interface TVBrowserViewController()

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tvBrowser:(TVBrowser *)browser;

@end

@interface TVBrowser()

- (void)addViewController:(TVBrowserViewController *)viewController;
- (void)invalidateViewController:(TVBrowserViewController *)viewController;
- (void)invalidateTVConnection:(TVConnection *)connection;

@end

@interface TVConnection()

- (SocketManager *)socketManager;
- (void)setHttp_port:(NSUInteger)_port;
- (void)setTVBrowser:(TVBrowser *)tvBrowser;
- (void)setAppBrowser:(AppBrowser *)appBrowser;

@end

#pragma mark -
#pragma mark AppBrowser Extensions

@interface AppInfo()

- (id)initWithAppDictionary:(NSDictionary *)dictionary;

@end

@interface AppBrowserViewController()

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil appBrowser:(AppBrowser *)browser;

@end

@interface AppBrowser()

- (void)addViewController:(AppBrowserViewController *)viewController;
- (void)invalidateViewController:(AppBrowserViewController *)viewController;

- (void)setCurrentApp:(AppInfo *)_currentApp;
- (void)setAvailableApps:(NSMutableArray *)_availableApps;

@end

#pragma mark -
#pragma mark TPAppViewController

@interface TPAppViewController()

- (id)initWithTVConnection:(TVConnection *)tvConnection frame:(CGRect)frame delegate:(id<TPAppViewControllerDelegate>)delegate;

- (void)sendEvent:(NSString *)name JSON:(NSString *)JSON_string;

- (IBAction)hideTextBox:(id)sender;

- (void)advancedUIObjectAdded;
- (void)advancedUIObjectDeleted;
- (void)checkShowVirtualRemote;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) IBOutlet UITextField *theTextField;
@property (nonatomic, retain) IBOutlet UILabel *theLabel;
@property (nonatomic, retain) IBOutlet UIView *textView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;

@end





