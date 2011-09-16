//
//  Category.h
//  TrickplayController
//
//  Created by Rex Fenley on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVBrowser.h"
#import "TVBrowserViewController.h"
#import "AppBrowserViewController.h"
#import "TPAppViewController.h"

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

@end

@interface AppInfo()

- (id)initWithAppDictionary:(NSDictionary *)dictionary;

@end

#pragma mark -
#pragma mark AppBrowser Extensions

@interface AppBrowserViewController()

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil appBrowser:(AppBrowser *)browser;

@end

@interface AppBrowser()

- (void)addViewController:(AppBrowserViewController *)viewController;
- (void)invalidateViewController:(AppBrowserViewController *)viewController;

@end

#pragma mark -
#pragma mark TPAppViewController

@interface TPAppViewController()

- (void)startService;

@end