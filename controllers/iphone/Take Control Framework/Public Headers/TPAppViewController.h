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
 * TPAppViewController referencing the delegate is no longer functional.
 * This may occur when there is an error communicating with the TV.
 */

@protocol TPAppViewControllerDelegate <NSObject>

@required
- (void)tpAppViewControllerNoLongerFunctional:(TPAppViewController *)tpAppViewController;

@end


/**
 * Summary:
 *
 * The TPAppViewController class is the core component of the Take Control app.
 * This class serves as the main interface for user interaction with their
 * Television as well as the main controller for all other modules, models,
 * and views in the app.
 *
 * This controller's view intializes with a virtual remote for controlling
 * the Television. Drawing graphics to TPAppViewController's view or activating
 * touch control removes the Virtual Remote from the view and gives the user
 * a blank view for adding graphics and AdvancedUI Objects to build custom UIs.
 * 
 * All user input travels through this class first. I.E. the Camera is
 * pushed into this UIViewController, Accelerometer and Touch UIEvents are
 * initialially captured by this UIViewController's view.
 *
 * All asyncronous socket communication with Trickplay is delegated as messages
 * to this class. This class serves as a port to which modules, managers, views,
 * and models for the Take Control app receive messages from the Television and
 * through which these objects asynchronously send messages back to the Television.
 * 
 * Refer to TPAppViewController.xib for the TPAppViewController's view.
 *
 *
 * How To Use:
 * 
 * A TPAppViewController must be allocated using alloc and then intialized using
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

// The initialization method for this class. Must provide an active
// TVConnection object. The frame may be set to CGRectNull, but
// this is not recommended. The delegate may be set to nil.
- (id)initWithTVConnection:(TVConnection *)tvConnection frame:(CGRect)frame delegate:(id <TPAppViewControllerDelegate>)delegate;
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
- (void)exitTrickplayApp:(id)sender;
// Returns YES if this TPAppViewController has a TVConnection and
// the TVConnection is connected to a TV.
- (BOOL)hasConnection;
// Send any keypress to the TV any number of times. Must use
// key codes provided by Trickplay.
- (void)sendKeyToTrickplay:(NSString *)key count:(NSInteger)count;

@end



