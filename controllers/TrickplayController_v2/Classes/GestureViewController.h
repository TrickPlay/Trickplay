//
//  GestureViewController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketManager.h"


@interface GestureViewController : UIViewController <SocketManagerDelegate, 
CommandInterpreterDelegate> {
    SocketManager *socketManager;
    NSString *hostName;
    NSInteger port;
    
    UIActivityIndicatorView *loadingIndicator;
    UIImageView *backgroundView;
    
    NSMutableDictionary *resourceNames;
    //NSMutableDictionary *resources;
}

@property (retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;

- (void) setupService:(NSInteger)port
             hostname:(NSString *)hostName
             thetitle:(NSString *)name;

- (void) startService;

- (void)do_DR:(NSArray *)args;
- (void)do_UB:(NSArray *)args;
- (void)do_UG:(NSArray *)args;

- (void)clearUI;

@end
