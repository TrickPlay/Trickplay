//
//  TPAppViewController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class TPAppViewController;

/**
 * The AdvancedUIDelegate protocol implemented by AdvancedUIObjectManager
 * registers a delegate which is passed asyncronous calls made for AdvancedUI.
 * (Given that the TPAppViewController is the only object which utilizes
 * asynchronous socket communication with Trickplay, it is the only object
 * which has one of these delgates.)
 *
 * The calls currently available include informing the AdvancedUIObjectManager
 * of the host and port to use for its socket connection, starting this connection,
 * and cleaning (involves deleting objects and reseting values).
 */

@protocol AdvancedUIDelegate <NSObject>

@required
- (void)setupServiceWithPort:(NSUInteger)p
                    hostname:(NSString *)h;
- (BOOL)startServiceWithID:(NSString *)ID;

- (void)clean;

@end


/**
 * The TPAppViewControllerSocketDelegate recieves messages delegated
 * originally from the SocketManager which inform of either a socket
 * error or socket stream ending. The delegate is assumed to depend
 * on the socket in some way and must respond to these messages.
 *
 * The AppBrowserViewController and RootViewController both apply this protocol.
 */

@protocol TPAppViewControllerDelegate <NSObject>

@required
- (void)tpAppViewControllerNoLongerFunctional:(TPAppViewController *)tpAppViewController;

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


/**
 * The ViewControllerTouchDelegate handles commands from Trickplay to
 * enable/disable touch events. Likewise this delegate must inform
 * the TPAppViewController of iOS touch events so these events can be
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

- (void)startTouches;
- (void)stopTouches;

- (void)setSwipe:(BOOL)allowed;

- (void)reset;

@end



#import "TouchController.h"
#import "AccelerometerController.h"
#import "AudioController.h"
#import "CameraViewController.h"
#import "VirtualRemoteViewController.h"
#import "GestureImageView.h"
#import "TVConnection.h"

/**
 * The TPAppViewController class is the core component of the Take Control app.
 * This class serves as the main interface for user interaction with their
 * Television as well as the main controller for all other modules, models,
 * and views in the app.
 *
 * After establishing a connection with Trickplay and selecting an app Take Control
 * pushes the TPAppViewController to the top of the NavigationViewController
 * stack. This controller's view intializes with a virtual remote for controlling
 * the Television. Drawing graphics to this view or activating touch control
 * removes the VirtualRemote from the view and gives the user a blank view for
 * which they can add graphics and AdvancedUI objects to build custom UIs.
 * 
 * All user input and devices go through this class first. I.E. the Camera is
 * pushed in from this ViewController, Accelerometer and Touch events are
 * initialially captured by this ViewController's view before being delegated
 * to the AccelerometerController and TouchController objects respectively.
 *
 * All asyncronous socket communication with Trickplay is delegated as messages
 * to this class. This class serves as a port to which modules, managers, views,
 * and models for the Take Control app receive messages from the Television and
 * through which these objects asynchronously send messages back to the Television.
 * 
 * Refer to TPAppViewController.xib for the TPAppViewController's view.
 */

@class TrickplayScreen;
@class TrickplayGroup;
@class AdvancedUIObjectManager;

#define CAMERA_BUTTON_TITLE "Camera"
#define PHOTO_LIBRARY_BUTTON_TITLE "Photo Library"

@class ResourceManager;
@class SocketManager;

@interface TPAppViewController : UIViewController <SocketManagerDelegate, 
CommandInterpreterAppDelegate, CameraViewControllerDelegate,
UITextFieldDelegate, UIActionSheetDelegate,
UINavigationControllerDelegate, VirtualRemoteDelegate> {
    @private
    
    BOOL viewDidAppear;
    
    // Manages the asynchronous socket the TPAppViewController communicates
    // to Trickplay with
    SocketManager *socketManager;
    // The Connection
    TVConnection *tvConnection;
    // Current version of the app
    NSString *version;
    
    // A timer that when firing calls timerFiredMethod:
    NSTimer *socketTimer;
    
    // Displays itself and spins when the TPAppViewController first loads.
    // This is rarely seen on anything but the oldest iPods.
    UIActivityIndicatorView *loadingIndicator;
    // TextField for entering text; used when Trickplay requests text input
    // with controller:enter_text(string label, string text) call from Trickplay.
    UITextField *theTextField;
    NSString *currentText;
    UILabel *theLabel;
    // Black border around theTextField
    UIView *textView;
    // Displays the background which the developer may change with the
    // controller:set_ui_background(string resource, string mode) call
    // from Trickplay. Also has foregroundView as the top subview.
    UIImageView *backgroundView;
    // The Root view tree for all graphics added via the
    // controller:set_ui_image(string resource, int x, int y, int width,
    // int height) call from Trickplay.
    UIImageView *foregroundView;
    // The usable height of the screen; screen size - navigation bar height
    CGFloat backgroundHeight;
    // The usable width of the screen; currently the whole screen width
    CGFloat backgroundWidth;
    
    // Holds choices for the styleAlert UIActionSheet.
    NSMutableArray *multipleChoiceArray;
    // An action sheet that may be prompted via the
    // controller:show_multiple_choice(string label, ...) call from Trickplay
    UIActionSheet *styleAlert;
    
    // If the iOS Device has a camera then when Trickplay requests an image
    // the device will prompt the user with this action sheet first asking
    // if the user wishes to select on image from their Picture Library or
    // use the Camera to take a new photo.
    UIActionSheet *cameraActionSheet;
    
    // The root view for the view tree which contains all AdvancedUI Objects
    // (i.e. any object which is a subclass of TrickplayUIElement).
    TrickplayScreen *advancedView;
    
    // Manages all cached resources such as images and audio clips sent from
    // Trickplay to Take Control.
    ResourceManager *resourceManager;
    
    // Used to play and pause audio clips sent from Trickplay to Take Control.
    AudioController *audioController;
    
    // The over-arching view controller for all camera functionality including
    // selecting images from the photo library, taking images with the camera,
    // and editing the images to be sent Trickplay.
    CameraViewController *camera;
    
    // The UIViewController for the virtual remote used to control the Television.
    VirtualRemoteViewController *virtualRemote;
    
    // YES if static graphics have been added to Take Control's views, NO otherwise.
    BOOL graphics;
    
    // The TouchController. All touch events sent to this delegate
    // for proper handling.
    id <ViewControllerTouchDelegate> touchDelegate;
    // The AccelerometerController. All accelerometer events sent to this delegate
    // for proper handling.
    id <ViewControllerAccelerometerDelegate> accelDelegate;
    // Used to inform of a non-functional TPAppViewController.
    // Generally this happens when the connection breaks.
    id <TPAppViewControllerDelegate> delegate;
    // The AdvancedUIObjectManager. Any asynchronous messages sent from Trickplay
    // that refer to the AdvancedUIObjectManager are sent there via this
    // delegate's protocol.
    id <AdvancedUIDelegate> advancedUIDelegate;
}

@property (readonly) NSString *version;
@property (readonly) TVConnection *tvConnection;
@property (assign) id <TPAppViewControllerDelegate> delegate;

- (id)initWithTVConnection:(TVConnection *)tvConnection;
- (id)initWithTVConnection:(TVConnection *)tvConnection delegate:(id <TPAppViewControllerDelegate>)delegate;
- (void)clearUI;
- (void)clean;
- (void)exitTrickplayApp:(id)sender;
- (BOOL)hasConnection;
- (void)sendKeyToTrickplay:(NSString *)thekey thecount:(NSInteger)thecount;

@end



