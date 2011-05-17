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

@protocol AdvancedUIDelegate <NSObject>

@required
- (void)createObject:(NSString *)JSON_String;
- (void)destroyObject:(NSString *)JSON_String;

@end


/**
 * The GestureViewControllerSocketDelegate recieves messages delegated
 * originally from the SocketManager which inform of either a socket
 * error or socket stream ending. The delegate is assumed to depend
 * on the socket in some way and must respond to these messages.
 *
 * Currently, only the AppBrowserViewController applies this protocol.
 */

@protocol GestureViewControllerSocketDelegate <NSObject>

@required
- (void)socketErrorOccurred;
- (void)streamEndEncountered;

@end


/**
 * The ViewControllerAccelerometerDelegate handles commands from Trickplay
 * to start or stop the devices accelerometer.
 *
 * Only the AccelerometerController class implements this protocol.
 */

@protocol ViewControllerAccelerometerDelegate

@required
- (void)startAccelerometerWithFilter:(NSString *)filter interval:(float)interval;
- (void)pauseAccelerometer;

@end


// TODO: look into changing this to a Category/Class Extension rather than Delegate

/**
 * The ViewControllerTouchDelegate handles commands from Trickplay to
 * enable/disable touch events. Likewise this delegate must inform
 * the GestureViewController of iOS touch events so these events can be
 * forwarded back to Trickplay.
 *
 * Only the TouchController class implements this protocol.
 */

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
#import "AdvancedUIObjectManager.h"
#import "CameraViewController.h"


@interface GestureViewController : UIViewController <SocketManagerDelegate, 
CommandInterpreterDelegate, CameraViewControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate> {
    SocketManager *socketManager;
    NSString *hostName;
    NSInteger port;
    NSString *http_port;
    NSString *version;
    
    UIActivityIndicatorView *loadingIndicator;
    UITextField *theTextField;
    UIImageView *backgroundView;
    NSInteger backgroundHeight;
    NSInteger backgroundWidth;
    
    NSMutableArray *multipleChoiceArray;
    UIActionSheet *styleAlert;
    
    ResourceManager *resourceManager;
    
    AudioController *audioController;
    
    CameraViewController *camera;
    
    id <ViewControllerTouchDelegate> touchDelegate;
    id <ViewControllerAccelerometerDelegate> accelDelegate;
    id <GestureViewControllerSocketDelegate> socketDelegate;
    id <AdvancedUIDelegate> advancedUIDelegate;
}

@property (nonatomic, retain) NSString *version;
@property (nonatomic, assign) SocketManager *socketManager;

@property (retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) IBOutlet UITextField *theTextField;
@property (retain) IBOutlet UIImageView *backgroundView;

@property (nonatomic, retain) id <ViewControllerTouchDelegate> touchDelegate;
@property (nonatomic, retain) id <ViewControllerAccelerometerDelegate> accelDelegate;
@property (nonatomic, assign) id <GestureViewControllerSocketDelegate> socketDelegate;
@property (nonatomic, retain) id <AdvancedUIDelegate> advancedUIDelegate;


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
