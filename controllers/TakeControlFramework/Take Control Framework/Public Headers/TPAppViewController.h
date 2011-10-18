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
@class TVConnection;

/**
 * The TPAppViewControllerDelegate Protocol informs the delegate if the
 * TPAppViewController is no longer functional and also provides a
 * mechanism for using the camera. 
 *
 * The TPAppViewController may lose functionality when an error occurs
 * communicating with the TV. The delegate should release ownership to the 
 * TPAppViewController provided by this method.
 *
 * Sometimes an app will request a user photo. If the delegate is set, it
 * will be responsible for presenting the camera as a ModalVieController
 * in a UIViewController.
 * Example:
 * - (void)tpAppViewController:(TPAppViewController *)tpAppViewController 
 *      wantsToPresentCamera:(UIViewController *)camera {
 *          // self is the RootViewController
 *          [self presentModalViewController:camera animated:YES]
 *      }
 *
 * It is important to properly present the camera from a UIViewController
 * or risk stalling the app.
 */

@protocol TPAppViewControllerDelegate <NSObject>

@required
- (void)tpAppViewControllerNoLongerFunctional:(TPAppViewController *)tpAppViewController;
- (void)tpAppViewController:(TPAppViewController *)tpAppViewController wantsToPresentCamera:(UIViewController *)camera;

@end


/**
 * Summary:
 *
 * The TPAppViewController class is the core component of the iOS app.
 * This class serves as the main interface for user interaction with their
 * Television as well as the main controller for all other modules, models,
 * and views in the app.
 *
 * This controller's view initializes with a virtual remote for controlling
 * the Television. Drawing graphics to TPAppViewController's view or activating
 * touch control removes the Virtual Remote from the view and gives the user
 * a blank view for adding graphics and AdvancedUI Objects to build custom UIs.
 * 
 * All user input travels through this class first. I.E. the Camera is
 * pushed into this UIViewController, Accelerometer and Touch UIEvents are
 * initialially captured by this UIViewController's view.
 *
 * All asynchronous socket communication with the TV is delegated as messages
 * to this class. This class serves as a port to which modules, managers, views,
 * and models for the iOS app receive messages from the Television and
 * through which these objects asynchronously send messages back to the Television.
 * 
 * Refer to TPAppViewController.xib for the TPAppViewController's view.
 *
 *
 * How To Use:
 * 
 * A TPAppViewController must be allocated using + alloc and then intialized using
 * - (id)initWithTVConnection:delegate:
 * The delegate may be nil but a TVConnection object must be provided and must
 * already be connected to a TV or the initializer will return nil. All communication
 * with the TV will happen automatically after initialization.
 *
 * This UIViewController is currently incompatible with Interface Builder.
 */

#define CAMERA_BUTTON_TITLE "Camera"
#define PHOTO_LIBRARY_BUTTON_TITLE "Photo Library"

@interface TPAppViewController : UIViewController <UITextFieldDelegate,
UIActionSheetDelegate, UINavigationControllerDelegate>

// The current version of the TV's communications Protocol.
@property (readonly) NSString *version;
// This object's TVConnection.
@property (readonly) TVConnection *tvConnection;
// This object's delegate.
@property (assign) id <TPAppViewControllerDelegate> delegate;

// The designated initialization method for this class. Must
// provide an active TVConnection object. The
// delegate may be set to nil. Returns nil on failure.
- (id)initWithTVConnection:(TVConnection *)tvConnection size:(CGSize)size delegate:(id <TPAppViewControllerDelegate>)delegate;
// Clears all UI objects from this TPAppViewController's view, but
// not any AdvancedUI objects. UI objects are created asynchronously.
- (void)clearUI;
// Clears all UI and AdvancedUI objects from this TPAppViewController's
// view.
- (void)cleanViewController;
// Resets all modules of this TPAppViewController and clears all elements
// from its view.
- (void)resetViewController;
// Sends an 'ESC' keypress to the TV which should force the TV to
// call exit().
- (void)exitTrickplayApp;
// Returns YES if this TPAppViewController has a TVConnection and
// the TVConnection is connected to a TV.
- (BOOL)hasConnection;
// Set the size of the View
- (void)setSize:(CGSize)size;
// Send any keypress to the TV any number of times. Must use
// key codes provided by Trickplay.
- (void)sendKeyToTrickplay:(NSString *)key count:(NSInteger)count;

@end



