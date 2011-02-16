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

@interface RootViewController : UITableViewController <UITableViewDelegate, 
UITableViewDataSource, UINavigationControllerDelegate,
NetServiceManagerDelegate> {
    UIWindow *window;
    //UINavigationController *navigationController;
    UIView *aTableView;
    NetServiceManager *netServiceManager;
    GestureViewController *gestureViewController;
}

- (void)serviceResolved:(NSNetService *)service;
- (void)reloadData;

@property (nonatomic, retain) IBOutlet UIWindow *window;
//@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UIView *aTableView;


@end
