//
//  GestureViewController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketManager.h"

// TODO: change this to a Category/Class Extension rather than Delegate
@protocol ViewControllerTouchDelegate

@required
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)startClicks;
- (void)stopClicks;
- (void)startTouches;
- (void)stopTouches;
@end



@interface GestureViewController : UIViewController <SocketManagerDelegate, 
CommandInterpreterDelegate> {
    SocketManager *socketManager;
    NSString *hostName;
    NSInteger port;
    
    UIActivityIndicatorView *loadingIndicator;
    UIImageView *backgroundView;
    
    NSMutableDictionary *resourceNames;
    //NSMutableDictionary *resources;
    
    id <ViewControllerTouchDelegate> touchDelegate;
}

@property (retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;

@property (nonatomic, retain) id <ViewControllerTouchDelegate> touchDelegate;


- (void) setupService:(NSInteger)port
             hostname:(NSString *)hostName
             thetitle:(NSString *)name;

- (void) startService;
- (void)sendKeyToTrickplay:(NSString *)thekey thecount:(NSInteger)thecount;

- (void)do_DR:(NSArray *)args;
- (void)do_UB:(NSArray *)args;
- (void)do_UG:(NSArray *)args;

- (void)clearUI;

- (void)exitTrickplayApp:(id)sender;

@end
