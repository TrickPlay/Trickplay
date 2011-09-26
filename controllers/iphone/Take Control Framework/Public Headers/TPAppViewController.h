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
 * The TPAppViewControllerDelegate
 */

@protocol TPAppViewControllerDelegate <NSObject>

@required
- (void)tpAppViewControllerNoLongerFunctional:(TPAppViewController *)tpAppViewController;

@end


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

#define CAMERA_BUTTON_TITLE "Camera"
#define PHOTO_LIBRARY_BUTTON_TITLE "Photo Library"

@interface TPAppViewController : UIViewController <UITextFieldDelegate,
UIActionSheetDelegate, UINavigationControllerDelegate>

@property (readonly) NSString *version;
@property (readonly) TVConnection *tvConnection;
@property (assign) id <TPAppViewControllerDelegate> delegate;

- (id)initWithTVConnection:(TVConnection *)tvConnection;
- (id)initWithTVConnection:(TVConnection *)tvConnection delegate:(id <TPAppViewControllerDelegate>)delegate;
- (void)clearUI;
- (void)clean;
- (void)exitTrickplayApp:(id)sender;
- (BOOL)hasConnection;
- (void)sendKeyToTrickplay:(NSString *)key count:(NSInteger)count;

@end



