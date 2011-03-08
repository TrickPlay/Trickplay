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

@interface AppBrowserViewController : UIViewController <UITableViewDelegate, 
UITableViewDataSource> {
    NSString *hostName;
    NSInteger port;
    
    /*
    UIBarButtonItem *appShopButton;
    UIBarButtonItem *showcaseButton;
    UIToolbar *toolBar;
    */
     
    UITableView *theTableView;
    NSArray *appsAvailable;
    GestureViewController *gestureViewController;
    
    NSString *currentAppName;
}
/*
@property (nonatomic, retain) IBOutlet UIBarButtonItem *appShopButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *showcaseButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
*/
@property (retain) IBOutlet UITableView *theTableView;
@property (retain) NSArray *appsAvailable;
@property (nonatomic, retain) NSString *currentAppName;

- (IBAction) appShopButtonClick;
- (IBAction) showcaseButtonClick;
- (void)createGestureView;
- (BOOL)fetchApps;
- (void)setupService:(NSInteger)p
            hostname:(NSString *)h
            thetitle:(NSString *)n;

@end
