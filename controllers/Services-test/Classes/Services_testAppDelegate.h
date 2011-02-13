//
//  Services_testAppDelegate.h
//  Services-test
//
//  Created by Rex Fenley on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetServiceManager.h"
#import "GestureViewController.h"

@interface Services_testAppDelegate : NSObject <UIApplicationDelegate,
UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate,
NetServiceManagerDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
    UITableView *aTableView;
    NetServiceManager *netServiceManager;
    GestureViewController *gestureViewController;
}

- (void)serviceResolved:(NSNetService *)service;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UITableView *aTableView;


@end

