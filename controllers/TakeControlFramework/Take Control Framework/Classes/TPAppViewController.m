//
//  TPAppViewController.m
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TPAppViewController.h"
#import "TrickplayGroup.h"
#import "TrickplayScreen.h"
#import "AdvancedUIObjectManager.h"
#import "Extensions.h"

#import "ResourceManager.h"
#import "SocketManager.h"



#import "TouchController.h"
#import "CoreMotionController.h"
#import "AudioController.h"
#import "CameraViewController.h"
#import "VirtualRemoteViewController.h"
#import "GestureImageView.h"
#import "TVConnection.h"

#import "Protocols.h"

#import <uuid/uuid.h>
#import <VideoStreamer/VideoStreamer.h>

@interface TPAppViewControllerContext : TPAppViewController <SocketManagerDelegate, 
CommandInterpreterAppDelegate, CameraViewControllerDelegate,
UITextFieldDelegate, UIActionSheetDelegate,
UINavigationControllerDelegate, VirtualRemoteDelegate, VideoStreamerDelegate> {

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
    
    // This VideoStreamer object may be used to stream video via SIP from the iOS Device
    // to an outside SIP server or client. The camera cannot be accessed while a video
    // streamer exists and the video streamer is automatically destroyed when no longer
    // needed.
    VideoStreamer *videoStreamer;
    
    // The UIViewController for the virtual remote used to control the Television.
    VirtualRemoteViewController *virtualRemote;
    
    // YES if static graphics have been added to Take Control's views, NO otherwise.
    BOOL graphics;
    
    // The CoreMotionController is used to capture the motion of the device using the
    // accelerometer, gyroscope, magnetometer, and the calculation of device motion.
    CoreMotionController *coreMotionController;
    
    // The TouchController. All touch events sent to this delegate
    // for proper handling.
    id <ViewControllerTouchDelegate> touchDelegate;
    
    // The AdvancedUIObjectManager. Any asynchronous messages sent from Trickplay
    // that refer to the AdvancedUIObjectManager are sent there via this
    // delegate's protocol.
    id <AdvancedUIDelegate> advancedUIDelegate;
    
    id <TPAppViewControllerDelegate> delegate;
}

@property (retain) SocketManager *socketManager;

@property (nonatomic, assign) BOOL graphics;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) IBOutlet UITextField *theTextField;
@property (nonatomic, retain) IBOutlet UILabel *theLabel;
@property (nonatomic, retain) IBOutlet UIView *textView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;

@property (nonatomic, retain) id <ViewControllerTouchDelegate> touchDelegate;
@property (retain) id <AdvancedUIDelegate> advancedUIDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tvConnection:(TVConnection *)tvConnection delegate:(id <TPAppViewControllerDelegate>)delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tvConnection:(TVConnection *)tvConnection size:(CGSize)size delegate:(id <TPAppViewControllerDelegate>)delegate;

- (void)sendEvent:(NSString *)name JSON:(NSString *)JSON_string;

- (IBAction)hideTextBox:(id)sender;

- (void)checkShowVirtualRemote;

- (void)clearUI;
- (void)cleanViewController;
- (void)resetViewController;

@end




@implementation TPAppViewControllerContext


//@synthesize delegate;
//@synthesize version;
//@synthesize tvConnection;
@synthesize socketManager;

@synthesize graphics;
@synthesize loadingIndicator;
@synthesize theTextField;
@synthesize theLabel;
@synthesize textView;
@synthesize backgroundView;

@synthesize touchDelegate;
@synthesize advancedUIDelegate;

#pragma mark -
#pragma mark Property Getters/Setters

- (NSString *)version {
    NSString *retval = nil;
    @synchronized(self) {
        retval = [[version retain] autorelease];
    }
    return retval;
}

- (TVConnection *)tvConnection {
    TVConnection *retval = nil;
    @synchronized(self) {
        retval = [[tvConnection retain] autorelease];
    }
    return retval;
}

- (id <TPAppViewControllerDelegate>)delegate {
    id <TPAppViewControllerDelegate> val = nil;
    @synchronized(self) {
        val = delegate;
    }
    return val;
}

- (void)setDelegate:(id <TPAppViewControllerDelegate>)_delegate {
    @synchronized(self) {
        delegate = _delegate;
    }
}

#pragma mark -
#pragma mark Initialization

- (id)init {
    return [self initWithNibName:nil bundle:nil tvConnection:nil size:CGSizeZero delegate:nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    [self release];
    return nil;
}

- (id)initWithTVConnection:(TVConnection *)_tvConnection {
    return [self initWithTVConnection:_tvConnection size:CGSizeZero delegate:nil];
}

- (id)initWithTVConnection:(TVConnection *)_tvConnection delegate:(id<TPAppViewControllerDelegate>)_delegate {
    return [self initWithNibName:@"TPAppViewController" bundle:nil tvConnection:_tvConnection size:CGSizeZero delegate:_delegate];
}

- (id)initWithTVConnection:(TVConnection *)_tvConnection size:(CGSize)size delegate:(id<TPAppViewControllerDelegate>)_delegate {
    return [self initWithNibName:@"TPAppViewController" bundle:nil tvConnection:_tvConnection size:size delegate:_delegate];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil tvConnection:nil size:CGSizeZero delegate:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tvConnection:(TVConnection *)_tvConnection delegate:(id <TPAppViewControllerDelegate>)_delegate {
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil tvConnection:_tvConnection size:CGSizeZero delegate:_delegate];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tvConnection:(TVConnection *)_tvConnection size:(CGSize)size delegate:(id <TPAppViewControllerDelegate>)_delegate {
    
    if (!nibBundleOrNil) {
        nibBundleOrNil = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@%@", [NSBundle mainBundle].bundlePath, @"/TakeControl.framework"]];
    }
    
    if (!_tvConnection || !_tvConnection.isConnected || !nibNameOrNil || [nibNameOrNil compare:@"TPAppViewController"] != NSOrderedSame || !nibBundleOrNil) {
        
        [self release];
        return nil;
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"TPAppView Start Service");
        
        self.view.autoresizesSubviews = YES;
        self.view.backgroundColor = [UIColor clearColor];
        
        // Load UIWebView initially so that Text objects which depend on it will
        // load faster
        UIWebView *tempWebView = [[UIWebView alloc] init];
        [tempWebView autorelease];
        
        self.delegate = _delegate;
        tvConnection = [_tvConnection retain];
        
        self.socketManager = tvConnection.socketManager;
        [socketManager setCommandInterpreterDelegate:self withProtocol:APP_PROTOCOL];
        socketManager.appViewController = self;
                
        socketTimer = nil;
        
        viewDidAppear = NO;
        
        // TODO: this _frame does not work without NSLog printing its
        // values for some retarded reason
        
        // Get the actual width and height of the available area
        /*
        if (!CGRectIsNull(_frame)) {
            //NSLog(@"width: %f, height: %f", self.view.frame.size.width, self.view.frame.size.height);
            //NSLog(@"width: %f, height: %f", _frame.size.width, _frame.size.height);
            backgroundHeight = _frame.size.height;
            backgroundWidth = _frame.size.width;
            self.view.layer.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
            backgroundView.layer.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
            NSLog(@"frame not null");
        } else {
            CGRect mainframe = [[UIScreen mainScreen] applicationFrame];
            backgroundHeight = mainframe.size.height;
            backgroundHeight = backgroundHeight - 44;
            backgroundWidth = mainframe.size.width;
            self.view.layer.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
            backgroundView.layer.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
            NSLog(@"frame is null");
        }
        NSLog(@"view: %@", self.view);
        NSLog(@"background: %@", backgroundView);
        NSLog(@"backgroundWidth, backgroundHeight: %f, %f", backgroundWidth, backgroundHeight);
        //*/
        backgroundWidth = size.width;
        backgroundHeight = size.height;
        
        // Figure out if the device can use pictures
        NSString *hasPictures = @"";
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] || [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            hasPictures = @"\tPS";
        }
        
        // Figure out fi the device has video streaming
        NSString *hasVideoStreaming = @"";
        if ([AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]) {
            hasVideoStreaming = @"\tSV";
        }
        
        // Retrieve the UUID or make a new one and save it
        NSData *deviceID;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSData *savedData = [userDefaults dataForKey:@"TakeControlID"];
        if (savedData) {
            deviceID = [NSData dataWithBytes:[savedData bytes] length:[savedData length]];
            NSLog(@"deviceID: %@", deviceID);
        } else {
            uuid_t generated_id;
            uuid_generate(generated_id);
            NSLog(@"generated: %s", generated_id);
            deviceID = [NSData dataWithBytes:generated_id length:16];
            [userDefaults setObject:deviceID forKey:@"TakeControlID"];
            NSLog(@"deviceID: %@", deviceID);
        }
        NSLog(@"deviceID: %@", deviceID);
        
        // Tell the service what this device is capable of
        NSData *welcomeData = [[NSString stringWithFormat:@"ID\t4.4\t%@\tKY\tAX\tFM\tTC\tMC\tSD\tUI\tUX\tVR\tTE%@%@\tIS=%dx%d\tUS=%dx%d\tID=%@\n", [UIDevice currentDevice].name, hasPictures, hasVideoStreaming, (NSInteger)backgroundWidth, (NSInteger)backgroundHeight, (NSInteger)backgroundWidth, (NSInteger)backgroundHeight, deviceID] dataUsingEncoding:NSUTF8StringEncoding];
        
        [socketManager sendData:[welcomeData bytes] numberOfBytes:[welcomeData length]];
        
        // Manages resources created with declare_resource
        resourceManager = [[ResourceManager alloc] initWithTVConnection:tvConnection];
        
        camera = nil;
        videoStreamer = nil;
        
        // For audio playback
        audioController = [[AudioController alloc] initWithResourceManager:resourceManager tvConnection:tvConnection];
        // Controls touches
        touchDelegate = [[TouchController alloc] initWithView:self.view socketManager:socketManager];
        // Controls Core Motion (Accelerometer, gyroscope, magnetometer, device motion)
        coreMotionController = [[CoreMotionController alloc] initWithSocketManager:socketManager];
        
        // Viewport for AdvancedUI. This is actually a TrickplayGroup (emulates 'screen')
        // from Trickplay
        advancedView = [[TrickplayScreen alloc] initWithID:@"0" args:nil objectManager:nil];
        advancedView.nextTouchResponder = self;
        advancedView.delegate = (id <AdvancedUIScreenDelegate>)self;
        advancedView.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
        [self.view addSubview:advancedView];
        
        advancedUIDelegate = [[AdvancedUIObjectManager alloc] initWithView:advancedView resourceManager:resourceManager];
        advancedView.manager = (AdvancedUIObjectManager *)advancedUIDelegate;
        ((AdvancedUIObjectManager *)advancedUIDelegate).appViewController = self;
        
        // This is where the elements from UG (add_ui_image call) go
        CGRect frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
        foregroundView = [[UIImageView alloc] initWithFrame:frame];
        [backgroundView addSubview:foregroundView];
        
        // the virtual remote for controlling the Television
        NSBundle *myBundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@%@", [NSBundle mainBundle].bundlePath, @"/TakeControl.framework"]];
        virtualRemote = [[VirtualRemoteViewController alloc] initWithNibName:@"VirtualRemoteViewController" bundle:myBundle];
        virtualRemote.view.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
        [self.view addSubview:virtualRemote.view];
        virtualRemote.delegate = self;
        
        graphics = NO;
        [touchDelegate setSwipe:graphics];
        
        self.title = tvConnection.connectedService.name;
    }
    
    return self;
}

#pragma mark -
#pragma mark Network Setup

/**
 * Sends an arbitrary newline to the async socket which will be ignored by
 * the TV. This fires every 100ms to keep the wireless transmitter of the
 * iOS device energized and <20ms ping. Otherwise connection speeds may drop
 * to >200ms ping.
 */
- (void)timerFireMethod:(NSTimer *)timer {
    [socketManager sendData:"\n" numberOfBytes:1];
}

/**
 * Creates and starts the timer for timerFireMethod:
 */
- (void)createTimer {
    socketTimer = [NSTimer timerWithTimeInterval:(NSTimeInterval).1 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:socketTimer forMode:NSDefaultRunLoopMode];
    [socketTimer retain];
}

#pragma mark -
#pragma mark Network Handling

/**
 * Used to confirm that the TPAppViewController has an async socket
 * connected to Trickplay.
 */
- (BOOL)hasConnection {
    return tvConnection != nil && socketManager != nil && [socketManager isFunctional];
}

/**
 * Called when a connection drops. Resets TPAppViewController and all its
 * subsequent modules and managers and destoys the SocketManager.
 */
- (void)handleDroppedConnection {
    // resets stuff
    [self do_RT:nil];
    self.socketManager = nil;
}

/**
 * Called when the SocketManager encounters an error then informs all view
 * controllers lower on the navigation stack of an error occurring.
 */
- (void)socketErrorOccurred {
    NSLog(@"Socket Error Occurred in TPAppView");
    [self handleDroppedConnection];
    // everything will get released from the navigation controller's delegate call
    // TODO: make sure this tpappviewcontroller is now inactive.
    if (self.delegate) {
        [self.delegate tpAppViewControllerNoLongerFunctional:self];
    }
}

/**
 * Called when the SocketManager closes its connection then informs all view
 * controllers lower on the navigation stack of the connection closing.
 */
- (void)streamEndEncountered {
    NSLog(@"Socket End Encountered in TPAppView");
    [self handleDroppedConnection];
    // everything will get released from the navigation controller's delegate call
    if (self.delegate) {
        [self.delegate tpAppViewControllerNoLongerFunctional:self];
    }
}

#pragma mark -
#pragma mark Sending to Server

/**
 * Sends an event of name "name" with arguments "JSON_string" to the server.
 */
- (void)sendEvent:(NSString *)name JSON:(NSString *)JSON_string {
    NSString *sentData = [NSString stringWithFormat:@"UI\t%@\t%@\n", name, JSON_string];
    [socketManager sendData:[sentData UTF8String] numberOfBytes:[sentData length]];
}

/**
 * Sends a key press over the asynch connection to Trickplay
 * (i.e. up key, down key, exit key)
 */
- (void)sendKeyToTrickplay:(NSString *)key count:(NSInteger)count
{
	if (socketManager)
	{
	    int index;	
		NSString *sentData = [NSString stringWithFormat:@"KP\t%@\n", key];
        
		for (index = 0; index < count; index++) {
			[socketManager sendData:[sentData UTF8String]  numberOfBytes:[sentData length]];
		}
    }
}

/**
 * Sends the 'escape' key keycode to Trickplay which should call exit() on
 * Trickplay's side.
 */
- (void)exitTrickplayApp {
    [self sendKeyToTrickplay:@"FF1B" count:1];
}


#pragma mark -
#pragma mark Handling Commands From Server

#pragma mark -
#pragma mark Welcome Message

/**
 * WM = Welcome Message
 *
 * Executes when a Welcome Message is received from the server. Confirms that
 * the server successfully established a connection, is aware of the phones
 * capabilities (accelerometer, touch), and can now begin serving the client.
 *
 * Passes two or three arguments:
 *  0. Version of protocol the server supports. Should be > 4.1 or problems will
 *     happen.
 *  1. An HTTP port for HTTP requests. Mainly used for GETting resources.
 *  2. AdvancedUI Controller ID.
 */
- (void)do_WM:(NSArray *)args {
    version = [[args objectAtIndex:0] retain];
    if ([version floatValue] < 4.4) {
        NSLog(@"WARNING: Protocol Version is less than 4.4, please update Trickplay.");
    }
    
    //[tvConnection setHttp_port:[[args objectAtIndex:1] unsignedIntValue]];
    // if controller ID then open a new socket for advanced UI
    if ([args count] > 2 && [args objectAtIndex:2]) {
        [advancedUIDelegate setupServiceWithPort:tvConnection.port hostname:tvConnection.hostName];
        if (![advancedUIDelegate startServiceWithID:(NSString *)[args objectAtIndex:2]]) {
            [advancedUIDelegate release];
            advancedUIDelegate = nil;
        }
    }
}

#pragma mark -
#pragma mark Audio Playback Commands

/**
 * SS = Start Sound
 *
 * Starts playback of an audio clip downloaded from the server.
 * 
 * Passes two arguments:
 *  0. A dictionary of the audio snippet name and a URL path to it.
 *  1. The number of times to loop the playback, 0 for infinite.
 */
- (void)do_SS:(NSArray *)args {
    NSMutableDictionary *audioInfo = [resourceManager getResourceInfo:[args objectAtIndex:0]];
    // NSLog(@"Playing audio %@", audioInfo);
    // Add the amount of times to loop this sound file to the info
    NSString *loopValue = [args objectAtIndex:1];
    [audioInfo setObject:loopValue forKey:@"loop"];
    
    [audioController playSoundFile:[audioInfo objectForKey:@"name"] filename:[audioInfo objectForKey:@"link"]];
}

/**
 * PS = Pause Sound
 *
 * Stops Playback of a sound. Sends CA (Cancel Audio) event back to the server.
 *
 * No arguments.
 */
- (void)do_PS:(NSArray *)args {
    [audioController stopAudioPlayer];
    [audioController destroyAudioStreamer];
    NSString *sentData = [NSString stringWithFormat:@"UI\tCA"];
    [socketManager sendData:[sentData UTF8String] 
              numberOfBytes:[sentData length]];
}

#pragma mark -
#pragma mark Multiple Choice Command and Action Sheet Callback

/**
 * MC = Multiple Choice
 *
 * Presents a view of buttons to choose options from. The View looks like the
 * options given at the bottom of the TV screen during a game show.
 *
 * Passes N number of arguments
 *  0. A string given as a title to the view presenting the multiple choice options.
 *  1. The identifier string to return to the server when the first button is pressed.
 *  2. The title string on the first button.
 *  3. The identifier string to return to the server when the second button
 *     is pressed.
 *  4. The title string on the second button.
 *  5. ...
 */
- (void)do_MC:(NSArray *)args {
    NSString *windowtitle = [args objectAtIndex:0];
    //multiple choice alertview
    //<id>,<text> pairs
    unsigned theindex = 1;
    
    if (styleAlert != nil) {
        [styleAlert dismissWithClickedButtonIndex:[styleAlert cancelButtonIndex] animated:YES];
        [styleAlert release];
        styleAlert = nil;
    }
    
    styleAlert = [[UIActionSheet alloc] initWithTitle:windowtitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    styleAlert.title = windowtitle;
    [multipleChoiceArray removeAllObjects];
    while (theindex < [args count]) {
        [multipleChoiceArray addObject:[args objectAtIndex:theindex]];
        [styleAlert addButtonWithTitle:[args objectAtIndex:theindex+1]];
        theindex += 2;
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [styleAlert addButtonWithTitle:@"Cancel"];
        styleAlert.cancelButtonIndex = styleAlert.numberOfButtons - 1;
    }
    
    styleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    //[styleAlert addButtonWithTitle:@"Cancel"]; 
    //[styleAlert showInView:self.view.superview];
    if (self.view.window && viewDidAppear) {
        [styleAlert showInView:self.view];
    }
}

/**
 * UIActionSheetDelegate callback called when a button is pressed on an action
 * sheet.
 *
 * Handles button presses for both the multiple choice action sheet and the
 * action sheet asking the user if they'd wish to use the camera or their photo
 * library when sending camera images from the phone to the server.
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet == styleAlert) {
        //NSLog(@"object: %@", [multipleChoiceArray objectAtIndex:buttonIndex]);
        if (buttonIndex < actionSheet.numberOfButtons && buttonIndex != actionSheet.cancelButtonIndex) {
            NSString *sentData = [NSString stringWithFormat:@"UI\tMC\t%@\n", [multipleChoiceArray objectAtIndex:buttonIndex]];
            [socketManager sendData:[sentData UTF8String]
                      numberOfBytes:[sentData length]];
        } else if (buttonIndex == actionSheet.cancelButtonIndex) {
            NSString *sentData = @"UI\tMC\tCancel\n";
            [socketManager sendData:[sentData UTF8String]
                      numberOfBytes:[sentData length]];
        }
        [styleAlert release];
        styleAlert = nil;
    } else if (actionSheet == cameraActionSheet) {
        if ([[cameraActionSheet buttonTitleAtIndex:buttonIndex] compare:[NSString stringWithUTF8String:CAMERA_BUTTON_TITLE]] == NSOrderedSame) {
            
            [camera startCamera];
            
        } else if ([[cameraActionSheet buttonTitleAtIndex:buttonIndex] compare:[NSString stringWithUTF8String:PHOTO_LIBRARY_BUTTON_TITLE]] == NSOrderedSame) {
            
            [camera openLibrary];
        } else if ([cameraActionSheet cancelButtonIndex] == buttonIndex) {
            [self canceledPickingImage];
        }
    }
}

#pragma mark -
#pragma mark Text Entry Command and Text Field Callbacks

/**
 * ET = Enter Text
 *
 * Brings up the text field, sets the text field as the focus, and the
 * user may enter text.
 *
 * Passes two arguments:
 *  0. A label used as a title to the text entry field. Used to inform the user
 *     of what they may be entering text for.
 *  1. The default text the text entry field starts with.
 */
- (void)do_ET:(NSArray *)args {
    textView.hidden = NO;
    theTextField.hidden = NO;
    [theTextField becomeFirstResponder];
    
    // see if trickplay passed any text
    theTextField.text = @"";
    theLabel.text = @"Enter Text";
    if (args.count > 0) {
        theLabel.text = [args objectAtIndex:0];
        if (args.count > 1) {
            theTextField.text = [args objectAtIndex:1];
        }
    }
    [theTextField selectAll:theTextField];
    [UIMenuController sharedMenuController].menuVisible = NO;
    // start editing
    [self.view bringSubviewToFront:textView];
    currentText = [theTextField.text retain];
}

/**
 * Send the data the user entered into the text field to the server.
 * Then hides text field.
 */
- (IBAction)hideTextBox:(id)sender {
    NSString *sentData = [NSString stringWithFormat:@"UI\tET\t%@\n", theTextField.text];
    [socketManager sendData:[sentData UTF8String] numberOfBytes:[sentData length]];
}

/**
 * UITextFieldDelegate method. Called after the user presses 'return' or 'enter'
 * on the devices virtual keyboard.
 *
 * Resigns the text entry field as first responder and hides it.
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [theTextField resignFirstResponder];
    theTextField.hidden = YES;
    textView.hidden = YES;
    return YES;
}

#pragma mark -
#pragma mark Declaring/Dropping Resource Commands

/**
 * DR = Declare Resource
 *
 * Informs the client of a URL to download a resource. Resources can be anything
 * but usually will be image data for graphics or audio data for audio playback.
 *
 * Passes three arguments:
 *  0. A "name" for the asset that will be used as a reference to the asset.
 *  1. A URL link to download the asset.
 *  2. A "group name" for the resource. Resources may be included into resource
 *     groups to assist deletion.
 */
- (void)do_DR:(NSArray *)args {
    NSLog(@"Declaring Resource");
    [args retain];
    
    // version 3.1 and higher have groups
    NSString *groupName = nil;
    if ([args count] > 2) {
        groupName = [args objectAtIndex:2];
    }
    
    
    [resourceManager declareResourceWithObject:[
                                                NSMutableDictionary dictionaryWithObjectsAndKeys:[args objectAtIndex:0], @"name", [args objectAtIndex:1], @"link", groupName, @"group", nil
                                                ]
                                        forKey:[args objectAtIndex:0]
     ];
    
    [args release];
}

/**
 * DG = Drop Resource Group
 *
 * Deletes a group of resources from the cache.
 *
 * One argument: The "group name" of the resource group.
 */
- (void)do_DG:(NSArray *)args {
    [resourceManager dropResourceGroup:(NSString *)[args objectAtIndex:0]];
}

#pragma mark -
#pragma mark Static Image Updating Commands

/**
 * Updating the background
 *
 * WARNING: Now Asynchronous
 */
- (void)do_UB:(NSArray *)args {
    NSLog(@"Updating Background");
    
    NSString *key = [args objectAtIndex:0];
    
    if ([resourceManager getResourceInfo:key]) {
        NSString *mode = nil;
        if (args.count > 1) {
            mode = [args objectAtIndex:1];
        }
        CGRect frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
        if (mode && [mode compare:@"C"] == NSOrderedSame) {
            
            frame = CGRectMake(0.0, 0.0, 0.0, 0.0);
        }
        AsyncImageView *newImageView = [resourceManager fetchImageViewUsingResource:key frame:frame];
        
        for (UIView *subview in [backgroundView subviews]) {
            if (subview != foregroundView) {
                [subview removeFromSuperview];
            }
        }
        
        [backgroundView addSubview:newImageView];
        [backgroundView sendSubviewToBack:newImageView];
        backgroundView.image = nil;
        backgroundView.backgroundColor = [UIColor blackColor];
        
        graphics = YES;
        if ([virtualRemote.view superview] && !virtualRemote.background.isHidden) {
            [virtualRemote.view removeFromSuperview];
        }
        [touchDelegate setSwipe:YES];
        
        if (mode && [mode compare:@"C"] == NSOrderedSame) {
            newImageView.centerToSuperview = YES;
        } else if (mode && [mode compare:@"T"] == NSOrderedSame) {
            [newImageView setTileWidth:YES height:YES];
        }
    }
}

/**
 * UG = Update Graphics
 *
 * Adds a graphics element specified by a resource name to the screen at a specific
 * position and size.
 *
 * Passes five arguments:
 *  0. Resource name
 *  1. x position.
 *  2. y position.
 *  3. width
 *  4. height
 */
- (void)do_UG:(NSArray *)args {
    NSLog(@"Updating Graphics");
    
    NSString *key = [args objectAtIndex:0];
    // If resource has been declared
    if ([resourceManager getResourceInfo:key]) {
        CGFloat
        x = [[args objectAtIndex:1] floatValue],
        y = [[args objectAtIndex:2] floatValue],
        width = [[args objectAtIndex:3] floatValue],
        height = [[args	objectAtIndex:4] floatValue];
        CGRect frame = CGRectMake(x, y, width, height);
        UIView *newImageView = [resourceManager fetchImageViewUsingResource:key frame:frame];
        
        [foregroundView addSubview:newImageView];
        graphics = YES;
        if ([virtualRemote.view superview] && !virtualRemote.background.isHidden) {
            [virtualRemote.view removeFromSuperview];
        }
        [touchDelegate setSwipe:YES];
    }
}

#pragma mark -
#pragma mark CoreMotion Controller Commands

/**
 * SA = Start Accelerometer
 *
 * Informs the AccelerometerController to begin sending accelerometer events to the
 * server at given intervals after being filtered by the specified filter.
 *
 * Passes two arguments:
 *  0. Filter type (lowpass, highpass)
 *  1. Interval between events (in milliseconds)
 */
- (void)do_SA:(NSArray *)args {
    [coreMotionController startAccelerometerWithFilter:[args objectAtIndex:0] interval:[[args objectAtIndex:1] floatValue]];
}

/**
 * PA = Pause Accelerometer
 *
 * Tells the AccelerometerController to stop sending accelerometer events to the
 * server.
 */
- (void)do_PA:(NSArray *)args {
    [coreMotionController pauseAccelerometer];
}


/**
 * SG = Start Gyroscope
 *
 * Informs the GyroscopeController to begin sending gyroscope events to the
 * server at given intervals.
 *
 * Passes one argument:
 *  0. Interval between events (in milliseconds)
 */
- (void)do_SGY:(NSArray *)args {
    [coreMotionController startGyroscopeWithInterval:[[args objectAtIndex:0] floatValue]];
}

/**
 * PG = Pause Gyroscope
 *
 * Tells the GyroscopeController to stop sending gyroscope events to the
 * server.
 */
- (void)do_PGY:(NSArray *)args {
    [coreMotionController pauseGyroscope];
}


/**
 * SM = Start Magnetometer
 *
 * Informs the MagnetometerController to begin sending magnetometer events to the
 * server at given intervals.
 *
 * Passes one argument:
 *  0. Interval between events (in milliseconds)
 */
- (void)do_SMM:(NSArray *)args {
    [coreMotionController startMagnetometerWithInterval:[[args objectAtIndex:0] floatValue]];
}

/**
 * PM = Pause Magnetometer
 *
 * Tells the MagnetometerController to stop sending magnetometer events to the
 * server.
 */
- (void)do_PMM:(NSArray *)args {
    [coreMotionController pauseMagnetometer];
}


/**
 * SD = Start DeviceMotion
 *
 * Informs the DeviceMotionController to begin sending DeviceMotion events to the
 * server at given intervals.
 *
 * Passes one argument:
 *  0. Interval between events (in milliseconds)
 */
- (void)do_SAT:(NSArray *)args {
    [coreMotionController startDeviceMotionWithInterval:[[args objectAtIndex:0] floatValue]];
}

/**
 * PD = Pause DeviceMotion
 *
 * Tells the DeviceMotionController to stop sending DeviceMotion events to the
 * server.
 */
- (void)do_PAT:(NSArray *)args {
    [coreMotionController pauseDeviceMotion];
}

#pragma mark -
#pragma mark Touch Controller Commands and Callbacks

/**
 * ST = Stop Touches
 *
 * Tells the TouchController to start sending touch events to the server. This
 * removes the VirtualRemote from the screen unless the VirtualRemote was initiated
 * by a call to controller:show_virtual_remote() (hence background of VR is hidden).
 */
- (void)do_ST {
    [touchDelegate startTouches];
    if (!virtualRemote.background.isHidden) {
        [virtualRemote.view removeFromSuperview];
    }
}

/**
 * PT = Pause Touches
 *
 * Tells the TouchController to stop sending touch events to the server.
 * This adds the VirtualRemote back to the screen if no graphics elements or
 * AdvancedUI Objects are currently added to the screen. If the VirtualRemote
 * was brought into view via controller:show_virtual_remote() then the
 * method corresponding to controller:hide_vitual_remote() (aka. do_HV) is first called
 * before restoring the VirtualRemote.
 */
- (void)do_PT {
    [touchDelegate stopTouches];
    [self checkShowVirtualRemote];
}

/**
 * Touch Event callbacks all passed to the TouchController object for handling.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [touchDelegate touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [touchDelegate touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [touchDelegate touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [touchDelegate touchesCancelled:touches withEvent:event];
}


#pragma mark -
#pragma mark Camera Commands and Methods

/**
 * PI = Pick Image
 *
 * Readies the CameraViewController and all its submodules to send an image
 * to the server.
 *
 * Passes 7 arguments
 *  0. The URL to POST the image to
 *  1. The width to scale the image to
 *  2. The height to scale the image to
 *  3. A boolean determining whether or not the user has access to scale, rotate,
 *     or translate the image
 *  4. Resource name of a possible mask to use to cover the camera view port when
 *     taking or editing an image.
 *  5. A label to inform the user of how he or she should be using the camera
 *  6. A label pasted on any button that when pushed cancels taking a photo
 */
- (void)do_PI:(NSArray *)args {
    NSLog(@"Submit Picture, args:%@", args);
    if ([self.navigationController visibleViewController] != self || !tvConnection || !tvConnection.hostName || videoStreamer) {
        [self canceledPickingImage];
        return;
    }
    // Start the camera in the background
    if (camera) {
        [camera release];
        camera = nil;
    }
    
    UIView *mask = nil;
    CGFloat width = 0.0, height = 0.0;
    BOOL editable = NO;
    NSString *cameraLabel = nil;
    NSString *cameraCancelLabel = nil;
    if ([args count] >= 3) {
        width = [args objectAtIndex:1] ? [[args objectAtIndex:1] floatValue] : 0.0;
        height = [args objectAtIndex:2] ? [[args objectAtIndex:2] floatValue] : 0.0;
        editable = [args objectAtIndex:3] ? [[args objectAtIndex:3] boolValue] : NO;
        
        if ([args objectAtIndex:4] && ([(NSString *)[args objectAtIndex:4] compare:@""] != NSOrderedSame)) {
            mask = [resourceManager fetchImageViewUsingResource:[args objectAtIndex:4] frame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        }
        
        if ([args objectAtIndex:5] && ([(NSString *)[args objectAtIndex:5] compare:@""] != NSOrderedSame)) {
            cameraLabel = [args objectAtIndex:5];
        } else {
            cameraLabel = @"Send Image to TV";
        }
        if ([args objectAtIndex:6] && ([(NSString *)[args objectAtIndex:6] compare:@""] != NSOrderedSame)) {
            cameraCancelLabel = [args objectAtIndex:6];
        } else {
            cameraCancelLabel = @"Cancel";
        }
    }
    camera = [[CameraViewController alloc] initWithView:self.view targetWidth:width targetHeight:height editable:editable mask:mask];
    
    [camera setupService:tvConnection.http_port host:tvConnection.hostName path:[args objectAtIndex:0] delegate:self];
    camera.titleLabel = cameraLabel;
    camera.cancelLabel = cameraCancelLabel;
    camera.navController = self.navigationController;
    
    // Use camera or photo library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO) {
        [camera startCamera];
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        [camera openLibrary];
    } else {
        // Give the user the option to choose Camera or Photo Library
        if (cameraActionSheet) {
            [cameraActionSheet release];
            cameraActionSheet = nil;
        }
        cameraActionSheet = [[UIActionSheet alloc] initWithTitle:camera.titleLabel delegate:self cancelButtonTitle:camera.cancelLabel destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithUTF8String:CAMERA_BUTTON_TITLE], [NSString stringWithUTF8String:PHOTO_LIBRARY_BUTTON_TITLE], nil];
        
        cameraActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [cameraActionSheet showInView:self.view];
    }
}

- (void)finishedPickingImage:(UIImage *)image {
    NSLog(@"Finished Picking Image");
    [self.view addSubview:[[[UIImageView alloc] initWithImage:image] autorelease]];
}

- (void)finishedSendingImage {
    NSLog(@"Finished Sending Image");
    [camera.view removeFromSuperview];
    [camera release];
    camera = nil;
}

- (void)canceledPickingImage {
    NSLog(@"Canceled Picking Image");
    NSString *sentData = [NSString stringWithFormat:@"UI\tCI\n"];
    [socketManager sendData:[sentData UTF8String] 
              numberOfBytes:[sentData length]];
    if (camera) {
        if (camera.view.superview) {
            [camera.view removeFromSuperview];
        }
        [camera release];
        camera = nil;
    }
}

- (void)wantsToPresentCamera:(UIViewController *)_camera {
    if (!delegate) {
        [camera release];
        camera = nil;
        [self canceledPickingImage];
        
        return;
    }
    [delegate tpAppViewController:self wantsToPresentCamera:_camera];
}

#pragma mark -
#pragma mark Video Streaming

// Video Streaming Server->Controller

/**
 * SVSC = Streaming Video Start Call
 *
 * Begins a SIP call to a specific address.
 *
 * Passes 1 argument
 *  0. The address to initiate a SIP call to
 */
- (void)do_SVSC:(NSArray *)args {
    NSLog(@"Streaming Video Start Call");
    if ([self.navigationController visibleViewController] != self) {
        NSLog(@"Could not start Streaming Video Call, app is not visible on device");
        NSString *sentData = [NSString stringWithFormat:@"SVCF\t%@\t%@\n", [args objectAtIndex:0], @"Streaming Video failed, app is not visible on device"];
        [socketManager sendData:[sentData UTF8String] 
                  numberOfBytes:[sentData length]];
        return;
    }
    // Check the arguments
    if (args.count < 1) {
        NSLog(@"Could not start Streaming Video Call, no address provided!");
        NSString *sentData = [NSString stringWithFormat:@"SVCF\t<NOTHING>\t%@\n", @"Streaming Video failed can not connect, invalid address provided"];
        [socketManager sendData:[sentData UTF8String] 
                  numberOfBytes:[sentData length]];
        return;
    }
    // Make sure that the camera is not in use first. (Camera should destroy itself when not in use)
    if (camera) {
        NSLog(@"Could not start Streaming Video Call, the Camera is currently in use!");
        // Send Streaming Video Call Failed <address> <reason>
        NSString *sentData = [NSString stringWithFormat:@"SVCF\t%@\t%@\n", [args objectAtIndex:0], @"Streaming Video can not connect, camera is currently in use"];
        [socketManager sendData:[sentData UTF8String] 
                  numberOfBytes:[sentData length]];
        return;
    }
    // Make sure there isn't already a Streaming Video session
    if (videoStreamer) {
        NSLog(@"Could not start Streaming Video Call, Streaming Video currently in session");
        NSString *sentData = [NSString stringWithFormat:@"SVCF\t%@\t%@\n", [args objectAtIndex:0], @"Streaming Video can not connect, call is currently in session"];
        [socketManager sendData:[sentData UTF8String] 
                  numberOfBytes:[sentData length]];
        return;
    }
    
    VideoStreamerContext *context = [[[VideoStreamerContext alloc] initWithUserName:@"phone" password:@"1234" remoteAddress:[args objectAtIndex:0] serverPort:5060 clientPort:50160] autorelease];
    if (!context) {
        NSLog(@"Could not start Streaming Video Call, invalid address provided!");
        NSString *sentData = [NSString stringWithFormat:@"SVCF\t%@\t%@\n", [args objectAtIndex:0], @"Streaming Video can not connect, invalid address provided"];
        [socketManager sendData:[sentData UTF8String] 
                  numberOfBytes:[sentData length]];
        return;
    }
    videoStreamer = [[VideoStreamer alloc] initWithContext:context delegate:self];
    if (!videoStreamer) {
        NSLog(@"Could not start Streaming Video Call, VideoStreamer failed to launch on Device");
        NSString *sentData = [NSString stringWithFormat:@"SVCF\t%@\t%@\n", [args objectAtIndex:0], @"Streaming Video module failed to launch on device"];
        [socketManager sendData:[sentData UTF8String] 
                  numberOfBytes:[sentData length]];
        return;
    }
    videoStreamer.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.5];
    [videoStreamer startChat];
    [delegate tpAppViewController:self wantsToPresentCamera:videoStreamer];
}

/**
 * SVEC = Streaming Video End Call
 *
 * Ends a call in progress to a specific address, or abort the calline sequence
 * if the call is not yet connected.
 *
 * Passes 1 argument
 *  0. The address of the call the TV wants to end
 */
- (void)do_SVEC:(NSArray *)args {
    NSLog(@"Streaming Video End Call");

    [videoStreamer endChat];
}

/**
 * SVSS = Streaming Video Send Status
 *
 * Sends a Streaming Video Call Status (SVCS) event ASAP to indicate the current state
 * of the streaming video system.
 */
- (void)do_SVSS {
    NSLog(@"Streaming Video Send Status");
    NSString *sentData;
    if (videoStreamer) {
        if (videoStreamer.status == CONNECTED) {
            sentData = [NSString stringWithFormat:@"SVCS\tCONNECTED\t%@\n", videoStreamer.streamerContext.fullAddress];
        } else if(videoStreamer.status == INITIATING) {
            sentData = @"SVCS\tWAIT\tWAIT\n";
        } else {
            sentData = @"SVCS\tREADY\tREADY\n";
        }
    } else {
        sentData = @"SVCS\tREADY\tREADY\n";
    }
    [socketManager sendData:[sentData UTF8String] 
              numberOfBytes:[sentData length]];
}

// TODO: If in any way the video streamer is destroyed, pass cancel message back to TrickPlay

- (void)videoStreamerInitiatingChat:(id)_videoStreamer {
    
}

- (void)videoStreamerChatStarted:(id)_videoStreamer {
    NSLog(@"Streaming Video Call Connected");
    NSString *sentData = [NSString stringWithFormat:@"SVCC\t%@\n", videoStreamer.streamerContext.fullAddress];
    [socketManager sendData:[sentData UTF8String] numberOfBytes:[sentData length]];
}

- (void)videoStreamer:(VideoStreamer *)_videoStreamer chatEndedWithInfo:(NSString *)reason networkCode:(enum NETWORK_TERMINATION_CODE)code {
    
    NSLog(@"Streaming Video Call Ended: %@", reason);
    
    NSString *sentData;
    switch (code) {
        case CALL_ENDED_BY_CALLEE:
            sentData = [NSString stringWithFormat:@"SVCE\t%@\tCALLEE\n", videoStreamer.streamerContext.fullAddress];
            break;
        case CALL_ENDED_BY_CALLER:
            sentData = [NSString stringWithFormat:@"SVCE\t%@\tCALLER\n", videoStreamer.streamerContext.fullAddress];
            break;
        case CALL_FAILED:
            sentData = [NSString stringWithFormat:@"SVCF\t%@\t%@\n", videoStreamer.streamerContext.fullAddress, reason];
            break;
        case CALL_DROPPED:
            sentData = [NSString stringWithFormat:@"SVCD\t%@\t%@\n", videoStreamer.streamerContext.fullAddress, reason];
            break;
            
        default:
            sentData = [NSString stringWithFormat:@"SVCE\t%@\tCALLEE\n", videoStreamer.streamerContext.fullAddress];
            break;
    }
    
    [videoStreamer dismissViewControllerAnimated:YES completion:^(void){
        NSLog(@"VideoStreamer dismissed");
        [videoStreamer release];
        videoStreamer = nil;
    }];
}

#pragma mark -
#pragma mark Modal Virtual Remote

/**
 * SV = Show Virtual Remote
 *
 * Displays a popup VirtualRemote with trasparent background
 * if neither the virtual remote or camera are currently displayed.
 */
- (void)do_SV {
    if (![virtualRemote parentViewController] && ![virtualRemote.view superview]) {
        virtualRemote.background.hidden = YES;
        [self.view addSubview:virtualRemote.view];
        [touchDelegate setSwipe:NO];
    }
}

/**
 * HD = Hide Virtual Remote
 *
 * Hides the popup VirtualRemote.
 */
- (void)do_HV {
    if ([virtualRemote.view superview] && virtualRemote.background.isHidden) {
        [virtualRemote.view removeFromSuperview];
        virtualRemote.background.hidden = NO;
        [touchDelegate setSwipe:YES];
    }
}

- (void)checkShowVirtualRemote {
    if (!graphics && advancedView.view.subviews.count == 0 && !((TouchController *)touchDelegate).touchEventsAllowed) {
        [self do_HV];
        [self.view addSubview:virtualRemote.view];
        [touchDelegate setSwipe:NO];
    }
}

#pragma mark -
#pragma mark Cleaning/Clearing/Resetting Views

// TODO: Reset all modules to the initial state
/**
 * RT = Reset
 *
 * Resets everything. Deletes all graphics and objects.
 *
 * Passes no arguments.
 */
- (void)do_RT:(NSArray *)args {
    [audioController destroyAudioStreamer];
    [coreMotionController pauseAccelerometer];
    [coreMotionController pauseGyroscope];
    [coreMotionController pauseMagnetometer];
    [coreMotionController pauseDeviceMotion];
    [touchDelegate reset];
    [styleAlert dismissWithClickedButtonIndex:[styleAlert cancelButtonIndex] animated:NO];
    [styleAlert release];
    styleAlert = nil;
    [cameraActionSheet dismissWithClickedButtonIndex:[cameraActionSheet cancelButtonIndex] animated:NO];
    [self cleanViewController];
    [self dismissModalViewControllerAnimated:NO];
    [self do_HV];
    [self.view addSubview:virtualRemote.view];
    graphics = NO;
    [touchDelegate setSwipe:graphics];
    
    NSMutableDictionary *JSON_dic = [NSMutableDictionary dictionaryWithCapacity:2];
    [JSON_dic setObject:@"reset_hard" forKey:@"event"];
    [self sendEvent:@"UX" JSON:[JSON_dic JSONString]];
}

- (void)resetViewController {
    [self do_RT:nil];
}

/**
 * CU = Clear UI
 *
 * Clears the screen of all graphics objects not created by AdvancedUI, resets the
 * background, removes the camera/multiple choice/text entry if currently on the
 * screen, adds the virtual remote if no AdvancedUI objects are on the screen.
 */
- (void)do_CU {
    [self clearUI];
}

- (void)cleanViewController {
    [self clearUI];
    [advancedUIDelegate clean];
    [resourceManager clean];
}

- (void)advancedUIObjectAdded {
    if ([virtualRemote.view superview] && !virtualRemote.background.isHidden) {
        [virtualRemote.view removeFromSuperview];
    }
    [touchDelegate setSwipe:YES];
}

- (void)advancedUIObjectDeleted {
    [self checkShowVirtualRemote];
}

- (void)clearUI {
    NSLog(@"Clearing the UI");
    [theTextField resignFirstResponder];
	theTextField.hidden = YES;
    textView.hidden = YES;
    
    [styleAlert dismissWithClickedButtonIndex:[styleAlert cancelButtonIndex] animated:NO];
    [styleAlert release];
    styleAlert = nil;
    
    [cameraActionSheet dismissWithClickedButtonIndex:[cameraActionSheet cancelButtonIndex] animated:NO];
    
    if (camera) {
        [camera release];
        camera = nil;
    }
    
    if (videoStreamer) {
        videoStreamer.delegate = nil;
        [videoStreamer endChat];
        [videoStreamer release];
        videoStreamer = nil;
    }
    
    /*
     backgroundView.image = [UIImage imageNamed:@"background.png"];
     for (UIView *subview in backgroundView.subviews) {
     [subview removeFromSuperview];
     }
     //*/
    
    //*
    UIImageView *newImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    newImageView.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
    [foregroundView removeFromSuperview];
    for (UIView *subview in [foregroundView subviews]) {
        [subview removeFromSuperview];
    }
    [backgroundView removeFromSuperview];
    self.backgroundView = newImageView;
    [self.view addSubview:backgroundView];
    [self.view sendSubviewToBack:backgroundView];
    
    [newImageView release];
    
    [backgroundView addSubview:foregroundView];
    graphics = NO;
    
    [self checkShowVirtualRemote];
    //*/
}

#pragma mark -
#pragma mark View Handling

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"TPAppView loaded!");
    
    // Get the actual width and height of the available area
    /*
    CGRect mainframe = self.view.frame;
    backgroundHeight = mainframe.size.height;
    backgroundWidth = mainframe.size.width;
    */
    /*
    backgroundView.layer.bounds = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
    for (UIView *view in backgroundView.subviews) {
        view.layer.bounds = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
    }
    advancedView.layer.bounds = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
    foregroundView.layer.bounds = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
    virtualRemote.view.layer.bounds = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight + 144.0);
    */
    textView.layer.cornerRadius = 10.0;
    textView.layer.borderColor = [UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:100.0/255.0 alpha:1.0].CGColor;
    textView.layer.borderWidth = 7.0;
    
    loadingIndicator.hidesWhenStopped = YES;
    //loadingIndicator.bounds = self.view.frame;
    loadingIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/3);
    [loadingIndicator startAnimating];
    
    //backgroundView.image = [UIImage imageNamed:@"background.png"];
    
    if (!multipleChoiceArray) {
        multipleChoiceArray = [[NSMutableArray alloc] initWithCapacity:4];
    }
    
    UIBarButtonItem *exitItem = [[[UIBarButtonItem alloc] 
                                  initWithTitle:NSLocalizedString(@"Exit", @"")
                                  style:UIBarButtonItemStyleBordered
								  target:self action:@selector(exitTrickplayApp)] autorelease]; 
	self.navigationItem.rightBarButtonItem = exitItem;
    
    [loadingIndicator stopAnimating];
    
    currentText = nil;
    
    
    //NSLog(@"background: %@", backgroundView);
    /*
     CATransform3D transform = CATransform3DIdentity;
     transform.m34 = 1.0/-2000;
     self.view.layer.transform = transform;
     */
    //[self startService];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    NSLog(@"TPAppViewController Unload");
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.loadingIndicator = nil;
    
    if (styleAlert) {
        [styleAlert dismissWithClickedButtonIndex:[styleAlert cancelButtonIndex] animated:NO];
        [styleAlert release];
        styleAlert = nil;
    }
    
    multipleChoiceArray = [[NSMutableArray alloc] initWithCapacity:4];
    if (multipleChoiceArray) {
        [multipleChoiceArray release];
        multipleChoiceArray = nil;
    }
    
    self.theTextField = nil;
    self.theLabel = nil;
    self.textView = nil;
    if (currentText) {
        [currentText release];
        currentText = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Get the actual width and height of the available area
    /*
    CGRect mainframe = self.view.frame;
    backgroundHeight = mainframe.size.height;
    backgroundWidth = mainframe.size.width;
    */
    /*
    backgroundView.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
    for (UIView *view in backgroundView.subviews) {
        view.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
    }
    advancedView.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
    foregroundView.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
    virtualRemote.view.frame = CGRectMake(0.0, 0.0, backgroundWidth+140, backgroundHeight);
    */
    
    [loadingIndicator stopAnimating];
    viewDidAppear = YES;
    [self performSelectorOnMainThread:@selector(createTimer) withObject:nil waitUntilDone:YES];
    
    if (theTextField.isFirstResponder) {
        theTextField.text = currentText;
        [theTextField selectAll:theTextField];
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    
    if (styleAlert) {
        [styleAlert showInView:self.view];
    }
    
    if ([delegate respondsToSelector:@selector(tpAppViewControllerDidAppear:)]) {
        [delegate tpAppViewControllerDidAppear:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([delegate respondsToSelector:@selector(tpAppViewControllerDidDisappear:)]) {
        [delegate tpAppViewControllerDidDisappear:self];
    }
}

- (void)setSize:(CGSize)size {
    backgroundWidth = size.width;
    backgroundHeight = size.height;
    
    backgroundView.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
    for (UIView *view in backgroundView.subviews) {
        if ([view isKindOfClass:[AsyncImageView class]] && ((AsyncImageView *)view).centerToSuperview) {
            UIImage *image = ((AsyncImageView *)view).image;
            view.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
            view.center = CGPointMake(fabsf(view.superview.center.x), fabsf(view.superview.center.y));
        } else {
            view.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
        }
    }
    
    advancedView.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
    foregroundView.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
    virtualRemote.view.frame = CGRectMake(0.0, 0.0, backgroundWidth, backgroundHeight);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setSize:CGSizeMake(backgroundWidth, backgroundHeight)];
    //*/
    textView.layer.cornerRadius = 10.0;
    textView.layer.borderColor = [UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:100.0/255.0 alpha:1.0].CGColor;
    textView.layer.borderWidth = 7.0;
    
    loadingIndicator.hidesWhenStopped = YES;
    //loadingIndicator.bounds = self.view.frame;
    loadingIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/3);
    [loadingIndicator startAnimating];
    
    if ([delegate respondsToSelector:@selector(tpAppViewControllerWillAppear:)]) {
        [delegate tpAppViewControllerWillAppear:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    viewDidAppear = NO;
    if (styleAlert) {
        [styleAlert dismissWithClickedButtonIndex:[styleAlert cancelButtonIndex] animated:NO];
        [styleAlert release];
        styleAlert = nil;
    }
    
    if (socketTimer) {
        [socketTimer invalidate];
        [socketTimer release];
        socketTimer = nil;
    }
    
    if ([delegate respondsToSelector:@selector(tpAppViewControllerWillDisappear:)]) {
        [delegate tpAppViewControllerWillDisappear:self];
    }
}
//*/

//*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}
//*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark -
#pragma mark Deallocation

- (void)dealloc {
    NSLog(@"TPAppViewController dealloc");
    [self do_RT:nil];
    
    if (version) {
        [version release];
    }
    if (audioController) {
        [audioController release];
    }
    if (advancedView) {
        [advancedView do_unparent:nil];
        [advancedView release];
    }
    if (advancedUIDelegate) {
        [(AdvancedUIObjectManager *)advancedUIDelegate release];
    }
    if (resourceManager) {
        [resourceManager release];
    }
    if (socketManager) {
        socketManager.appViewController = nil;
        [socketManager setCommandInterpreterDelegate:nil withProtocol:APP_PROTOCOL];
        [socketManager release];
    }
    if (tvConnection) {
        [tvConnection release];
        tvConnection = nil;
    }
    if (touchDelegate) {
        [(TouchController *)touchDelegate release];
    }
    if (coreMotionController) {
        [coreMotionController release];
    }
    if (styleAlert) {
        [styleAlert dismissWithClickedButtonIndex:[styleAlert cancelButtonIndex] animated:NO];
        [styleAlert release];
    }
    if (cameraActionSheet) {
        [cameraActionSheet dismissWithClickedButtonIndex:[cameraActionSheet cancelButtonIndex] animated:NO];
        [cameraActionSheet release];
    }
    if (camera) {
        [camera release];
    }
    if (videoStreamer) {
        videoStreamer.delegate = nil;
        [videoStreamer endChat];
        [videoStreamer release];
        videoStreamer = nil;
    }
    if (virtualRemote) {
        [virtualRemote release];
        virtualRemote = nil;
    }
    if (multipleChoiceArray) {
        [multipleChoiceArray release];
    }
    if (socketTimer) {
        [socketTimer invalidate];
        [socketTimer release];
        socketTimer = nil;
    }
    [loadingIndicator release];
    [theTextField release];
    [textView release];
    [foregroundView release];
    [backgroundView release];
    
    [super dealloc];
}

@end




#pragma mark -
#pragma mark -
#pragma mark -
#pragma mark -
/*
@interface TPAppViewControllerPlaceHolder : TPAppViewController
@end

@implementation TPAppViewControllerPlaceHolder

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tvConnection:(TVConnection *)_tvConnection delegate:(id<TPAppViewControllerDelegate>)_delegate {
    
    NSZone *temp = [self zone];
    [self release];
    return [[TPAppViewControllerContext allocWithZone:temp] initWithNibName:nibNameOrNil bundle:nibBundleOrNil tvConnection:_tvConnection delegate:_delegate];
}

@end
*/
#pragma mark -
#pragma mark -
#pragma mark -
#pragma mark -




@implementation TPAppViewController

#pragma mark -
#pragma mark Allocation

+ (id)alloc {
    if ([self isEqual:[TPAppViewController class]]) {
        NSZone *temp = [self zone];
        [self release];
        return [TPAppViewControllerContext allocWithZone:temp];
    } else {
        return [super alloc];
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    if ([self isEqual:[TPAppViewController class]]) {
        return [TPAppViewControllerContext allocWithZone:zone];
    } else {
        return [super allocWithZone:zone];
    }
}

#pragma mark -
#pragma mark Getters/Setters

- (void)setSize:(CGSize)size {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setTvConnection:(TVConnection *)_tvConnection {
    if ([self isKindOfClass:[TPAppViewControllerContext class]]) {
        ((TPAppViewControllerContext *)self).tvConnection = _tvConnection;
    }
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *)version {
    if ([self isKindOfClass:[TPAppViewControllerContext class]]) {
        return ((TPAppViewControllerContext *)self).version;
    }
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (TVConnection *)tvConnection {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (id <TPAppViewControllerDelegate>)delegate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setDelegate:(id <TPAppViewControllerDelegate>)delegate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark init methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    [self release];
    return nil;
}

- (id)initWithTVConnection:(TVConnection *)_tvConnection {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (id)initWithTVConnection:(TVConnection *)_tvConnection
                  delegate:(id<TPAppViewControllerDelegate>)_delegate {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (id)initWithTVConnection:(TVConnection *)tvConnection size:(CGSize)size delegate:(id<TPAppViewControllerDelegate>)delegate {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark Forwarded Methods

- (void)clearUI {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)cleanViewController {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)resetViewController {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)exitTrickplayApp {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (BOOL)hasConnection {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)sendKeyToTrickplay:(NSString *)key count:(NSInteger)count {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark Hidden Forwarded methods

- (void)sendEvent:(NSString *)name JSON:(NSString *)JSON_string {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (IBAction)hideTextBox:(id)sender {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)advancedUIObjectAdded {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}
- (void)advancedUIObjectDeleted {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}
- (void)checkShowVirtualRemote {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark Hidden Forwarded Properties

- (UIActivityIndicatorView *)loadingIndicator {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setLoadingIndicator:(UIActivityIndicatorView *)loadingIndicator {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (UITextField *)theTextField {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setTheTextField:(UITextField *)theTextField {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (UILabel *)theLabel {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setTheLabel:(UILabel *)theLabel {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (UIView *)textView {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setTextView:(UIView *)textView {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (UIImageView *)backgroundView {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setBackgroundView:(UIImageView *)backgroundView {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark View Handling

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/**
- (void)viewDidLoad {
    [(TPAppViewControllerContext *)self viewDidLoad];
}

- (void)viewDidUnload {
    [(TPAppViewControllerContext *)self viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [(TPAppViewControllerContext *)self viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [(TPAppViewControllerContext *)self viewWillDisappear:animated];
}
 */
//*/

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}
*/

#pragma mark -
#pragma mark Deallocation
/*
- (void)dealloc {
    NSLog(@"TPAppViewController dealloc");
    //self.delegate = nil;
    //[context release];
    //context = nil;
    
    [super dealloc];
}
*/


@end
