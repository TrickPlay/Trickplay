//
//  GestureViewController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ResourceManager.h"
#import "SocketManager.h"

@protocol GestureViewControllerSocketDelegate <NSObject>

@required
- (void)socketErrorOccurred;
- (void)streamEndEncountered;

@end

@protocol ViewControllerAccelerometerDelegate

@required
- (void)startAccelerometerWithFilter:(NSString *)filter interval:(float)interval;
- (void)pauseAccelerometer;

@end


// TODO: change this to a Category/Class Extension rather than Delegate
@protocol ViewControllerTouchDelegate

@required
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

/** depricated
- (void)startClicks;
- (void)stopClicks;
//*/
- (void)startTouches;
- (void)stopTouches;

@end



#import "TouchController.h"
#import "AccelerometerController.h"
#import "AudioController.h"


@interface GestureViewController : UIViewController <SocketManagerDelegate, 
CommandInterpreterDelegate, UITextFieldDelegate, UIActionSheetDelegate> {
    SocketManager *socketManager;
    NSString *hostName;
    NSInteger port;
    
    UIActivityIndicatorView *loadingIndicator;
    UITextField *theTextField;
    UIImageView *backgroundView;
    //NSMutableArray *displayedImageViews;
    
    NSMutableArray *multipleChoiceArray;
    UIActionSheet *styleAlert;
    
    ResourceManager *resourceManager;
    
    AudioController *audioController;
    
    id <ViewControllerTouchDelegate> touchDelegate;
    id <ViewControllerAccelerometerDelegate> accelDelegate;
    id <GestureViewControllerSocketDelegate> socketDelegate;
}

@property (retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) IBOutlet UITextField *theTextField;
@property (retain) IBOutlet UIImageView *backgroundView;

@property (nonatomic, retain) id <ViewControllerTouchDelegate> touchDelegate;
@property (nonatomic, retain) id <ViewControllerAccelerometerDelegate> accelDelegate;
@property (nonatomic, assign) id <GestureViewControllerSocketDelegate> socketDelegate;


- (void)setupService:(NSInteger)port
            hostname:(NSString *)hostName
            thetitle:(NSString *)name;

- (BOOL)startService;
- (BOOL)hasConnection;
- (void)sendKeyToTrickplay:(NSString *)thekey thecount:(NSInteger)thecount;

- (IBAction)hideTextBox:(id)sender;

- (void)clearUI;

- (void)clean;

- (void)exitTrickplayApp:(id)sender;

@end
