//
//  RootViewController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetServiceManager.h"
#import "GestureViewController.h"
#import "AppBrowserViewController.h"

@interface RootViewController : UITableViewController <UITableViewDelegate, 
UITableViewDataSource, UINavigationControllerDelegate,
NetServiceManagerDelegate> {
    UIWindow *window;
    //UINavigationController *navigationController;
    NetServiceManager *netServiceManager;
    GestureViewController *gestureViewController;
    AppBrowserViewController *appBrowserViewController;
}

- (void)pushAppBrowser:(NSNotification *)notification;

- (void)serviceResolved:(NSNetService *)service;
- (void)reloadData;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
