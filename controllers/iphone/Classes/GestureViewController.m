//
//  GestureViewController.m
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GestureViewController.h"
#import "TrickplayGroup.h"
#import "TrickplayScreen.h"
#import "AdvancedUIObjectManager.h"

@implementation GestureViewController

@synthesize version;
@synthesize socketManager;

@synthesize loadingIndicator;
@synthesize theTextField;
@synthesize textView;
@synthesize backgroundView;

@synthesize touchDelegate;
@synthesize accelDelegate;
@synthesize socketDelegate;
@synthesize advancedUIDelegate;

/**
 * Establishes the host and port that will be used for the asynchronous socket
 * connection managed by GestureViewController's SocketManager.
 */
- (void)setupService:(NSInteger)p
            hostname:(NSString *)h
            thetitle:(NSString *)n {
    
    NSLog(@"GestureView Service Setup: %@ host: %@ port: %d", n, h, p);
    
    port = p;
    if (hostName) {
        [hostName release];
    }
    hostName = [h retain];
    http_port = nil;
}

/**
 * Sends an arbitrary newline to the async socket which will be ignored by
 * Trickplay. This fires every 100ms to keep the wireless transmitter of the
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
    [[NSRunLoop currentRunLoop] addTimer:socketTimer forMode:NSDefaultRunLoopMode];
    [socketTimer retain];
}

/**
 * This method begins by creating the SocketManager which handles communication
 * asynchronously with Trickplay. If the socket is successfully created and
 * the connection established then all the remaining managers and modules
 * for TakeControl are allocated and initialized to be used by the app.
 */
- (BOOL)startService {
    NSLog(@"GestureView Start Service");
    // Tell socket manager to create a socket and connect to the service selected
    socketManager = [[SocketManager alloc] initSocketStream:hostName
                                                       port:port
                                                   delegate:self
                                                   protocol:APP_PROTOCOL];
    
    if (![socketManager isFunctional]) {
        // If null then error connecting, back up to selecting services view
        [self.navigationController popToRootViewControllerAnimated:YES];
        NSLog(@"Could Not Establish Connection");
        return NO;
    }
    
    socketTimer = nil;
        
    viewDidAppear = NO;
    
    // Made a connection, let the service know!
	// Get the actual width and height of the available area
	CGRect mainframe = [[UIScreen mainScreen] applicationFrame];
	backgroundHeight = mainframe.size.height;
	backgroundHeight = backgroundHeight - 45;  //subtract the height of navbar
	backgroundWidth = mainframe.size.width;
    // Figure out if the device can use pcitures
    NSString *hasPictures = @"";
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] || [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        hasPictures = @"\tPS";
    }
    // Tell the service what this device is capable of
	NSData *welcomeData = [[NSString stringWithFormat:@"ID\t4.1\t%@\tKY\tAX\tTC\tMC\tSD\tUI\tUX\tTE%@\tIS=%dx%d\tUS=%dx%d\n", [UIDevice currentDevice].name, hasPictures, (NSInteger)backgroundWidth, (NSInteger)backgroundHeight, (NSInteger)backgroundWidth, (NSInteger)backgroundHeight] dataUsingEncoding:NSUTF8StringEncoding];
	[socketManager sendData:[welcomeData bytes] numberOfBytes:[welcomeData length]];
    
    // Manages resources created with declare_resource
    resourceManager = [[ResourceManager alloc] initWithSocketManager:socketManager];
    
    camera = nil;
	
    // For audio playback
    audioController = [[AudioController alloc] initWithResourceManager:resourceManager socketManager:socketManager];
    // Controls touches
    touchDelegate = [[TouchController alloc] initWithView:self.view socketManager:socketManager];
    // Controls Acceleration
    accelDelegate = [[AccelerometerController alloc] initWithSocketManager:socketManager];
    
    
    CGFloat
    width = backgroundWidth,
    height = backgroundHeight;
    // Viewport for AdvancedUI. This is actually a TrickplayGroup (emulates 'screen')
    // from Trickplay
    advancedView = [[TrickplayScreen alloc] initWithID:@"0" args:nil objectManager:nil];
    advancedView.delegate = (id <AdvancedUIScreenDelegate>)self;
    advancedView.frame = CGRectMake(0.0, 0.0, width, height);
    [self.view addSubview:advancedView];
    
    advancedUIDelegate = [[AdvancedUIObjectManager alloc] initWithView:advancedView resourceManager:resourceManager];
    advancedView.manager = (AdvancedUIObjectManager *)advancedUIDelegate;
    ((AdvancedUIObjectManager *)advancedUIDelegate).gestureViewController = self;
    
    // This is where the elements from UG (add_ui_image call) go
    CGRect frame = CGRectMake(0.0, 0.0, width, height);
    foregroundView = [[UIImageView alloc] initWithFrame:frame];
    [backgroundView addSubview:foregroundView];
    
    // the virtual remote for controlling the Television
    virtualRemote = [[VirtualRemoteViewController alloc] initWithNibName:@"VirtualRemoteViewController" bundle:nil];
    [self.view addSubview:virtualRemote.view];
    virtualRemote.delegate = self;
    
    graphics = NO;
    
    return YES;
}

/**
 * Sets the http port number used by Trickplay for sending app data, images,
 * and audio.
 */
- (void)setHTTPPort:(NSString *)my_http_port {
    if (http_port) {
        [http_port release];
    }
    http_port = [my_http_port retain];
    [socketManager setPort:[http_port integerValue]];
    [advancedUIDelegate setupServiceWithPort:port hostname:hostName];
}

/**
 * Used to confirm that the GestureViewController has an async socket
 * connected to Trickplay.
 */
- (BOOL)hasConnection {
    return socketManager != nil && [socketManager isFunctional];
}

/**
 * Called when a connection drops. Resets GestureViewController and all its
 * subsequent modules and managers and destoys the SocketManager.
 */
- (void)handleDroppedConnection {
    // resets stuff
    [self do_RT:nil];
    [socketManager release];
    socketManager = nil;
}

/**
 * Called when the SocketManager encounters an error then informs all view
 * controllers lower on the navigation stack of an error occurring.
 */
- (void)socketErrorOccurred {
    NSLog(@"Socket Error Occurred in GestureView");
    [self handleDroppedConnection];
    // everything will get released from the navigation controller's delegate call
    if (socketDelegate) {
        [socketDelegate socketErrorOccurred];
    }
}

/**
 * Called when the SocketManager closes its connection then informs all view
 * controllers lower on the navigation stack of the connection closing.
 */
- (void)streamEndEncountered {
    NSLog(@"Socket End Encountered in GestureView");
    [self handleDroppedConnection];
    // everything will get released from the navigation controller's delegate call
    if (socketDelegate) {
        [socketDelegate streamEndEncountered];
    }
}

/**
 * Sends a key press over the asynch connection to Trickplay
 * (i.e. up key, down key, exit key)
 */
- (void)sendKeyToTrickplay:(NSString *)thekey thecount:(NSInteger)thecount
{
	if (socketManager)
	{
	    int index;	
		NSString *sentData = [NSString stringWithFormat:@"KP\t%@\n", thekey];
        
		for (index = 1; index <= thecount; index++) {
			[socketManager sendData:[sentData UTF8String]  numberOfBytes:[sentData length]];
		}
    }
}

/**
 * Sends the 'escape' key keycode to Trickplay which should call exit() on
 * Trickplay's side.
 */
- (void)exitTrickplayApp:(id)sender {
    //Send Escape key to exit whatever app is currently running
	[self sendKeyToTrickplay:@"FF1B" thecount:1];
}


#pragma mark -
#pragma mark Handling Commands From Server


//--Welcome message

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
    self.version = [args objectAtIndex:0];
    if ([version floatValue] < 4.1) {
        NSLog(@"WARNING: Protocol Version is less than 4.1");
    }
    [self setHTTPPort:(NSString *)[args objectAtIndex:1]];
    // if controller ID then open a new socket for advanced UI
    if ([args count] > 2 && [args objectAtIndex:2]) {
        if (![advancedUIDelegate startServiceWithID:(NSString *)[args objectAtIndex:2]]) {
            [advancedUIDelegate release];
            advancedUIDelegate = nil;
        }
    }
}

//--Audio junk

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
    [audioController destroyAudioStreamer];
    NSString *sentData = [NSString stringWithFormat:@"UI\tCA"];
    [socketManager sendData:[sentData UTF8String] 
              numberOfBytes:[sentData length]];
}

//--Multiple Choice junk

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
    
    if (styleAlert != nil)
    {
        [styleAlert release];
        styleAlert = nil;
    }
    
    styleAlert = [[UIActionSheet alloc] initWithTitle:windowtitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    
    styleAlert.title = windowtitle;
    [multipleChoiceArray removeAllObjects];
    while (theindex < [args count]) {
        //First one is <id>
        //Second is the text
        //Theindex is the id
        [multipleChoiceArray addObject:[args objectAtIndex:theindex]];
        [styleAlert addButtonWithTitle:[args objectAtIndex:theindex+1]];
        theindex = theindex + 2;
    }
    styleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    //[styleAlert addButtonWithTitle:@"Cancel"]; 
    //[styleAlert showInView:self.view.superview];
    [styleAlert showInView:self.view];
    //[styleAlert release];    
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
        NSLog(@"Dismiss the alertview");
        if (buttonIndex < 5) {
            NSString *sentData = [NSString stringWithFormat:@"UI\t%@\n", [multipleChoiceArray objectAtIndex:buttonIndex]];
            [socketManager sendData:[sentData UTF8String]
                  numberOfBytes:[sentData length]];
        }
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

//-------------------Text input stuff---------------------

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
    if ([args count] > 1) {
        theTextField.text = [args objectAtIndex:1];
    } else {
        theTextField.text = @"";
    }
    [theTextField selectAll:theTextField];
    [UIMenuController sharedMenuController].menuVisible = NO;
    // start editing
    [self.view bringSubviewToFront:textView];
}

/**
 * Send the data the user entered into the text field to the server.
 * Then hides text field.
 */
- (IBAction)hideTextBox:(id)sender {
    NSLog(@"textbox hidden");
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


//----------------------Graphics related----------------------

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

/**
 * Updating the background
 *
 * WARNING: CANNOT USE WITH ADVANCED UI
 */
- (void)do_UB:(NSArray *)args {
    NSLog(@"Updating Background");
    
    NSString *key = [args objectAtIndex:0];
    
    if ([resourceManager getResourceInfo:key]) {
        CGFloat
        width = self.view.frame.size.width,
        height = self.view.frame.size.height;
        CGRect frame = CGRectMake(0.0, 0.0, width, height);
        UIView *newImageView = [resourceManager fetchImageViewUsingResource:key frame:frame];
        
        for (UIView *subview in [backgroundView subviews]) {
            if (subview != foregroundView) {
                [subview removeFromSuperview];
            }
        }
        
        [backgroundView addSubview:newImageView];
        [backgroundView sendSubviewToBack:newImageView];

        [virtualRemote.view removeFromSuperview];
        graphics = YES;
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
        [virtualRemote.view removeFromSuperview];
        graphics = YES;
    }
}


//--------------------Resetting stuff-------------------

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
    [accelDelegate pauseAccelerometer];
    [touchDelegate reset];
    [styleAlert dismissWithClickedButtonIndex:[styleAlert cancelButtonIndex] animated:NO];
    [cameraActionSheet dismissWithClickedButtonIndex:[cameraActionSheet cancelButtonIndex] animated:NO];
    [self clearUI];
    [advancedUIDelegate clean];
    [resourceManager clean];
    [self.view addSubview:virtualRemote.view];
    graphics = NO;
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


//------------------ Stuff passed to AccelerometerController ------------

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
    [accelDelegate startAccelerometerWithFilter:[args objectAtIndex:0] interval:[[args objectAtIndex:1] floatValue]];
}

/**
 * PA = Pause Accelerometer
 *
 * Tells the AccelerometerController to stop sending accelerometer events to the
 * server.
 */
- (void)do_PA:(NSArray *)args {
    [accelDelegate pauseAccelerometer];
}


//------------------ Stuff passed to TouchController --------------------

/**
 * ST = Stop Touches
 *
 * Tells the TouchController to start sending touch events to the server. This
 * removes the VirtualRemote from the screen.
 */
- (void)do_ST {
    [touchDelegate startTouches];
    [virtualRemote.view removeFromSuperview];
}

/**
 * PT = Pause Touches
 *
 * Tells the TouchController to stop sending touch events to the server.
 * This adds the VirtualRemote back to the screen if no graphics elements or
 * AdvancedUI Objects are currently added to the screen.
 */
- (void)do_PT {
    [touchDelegate stopTouches];
    if (!graphics) {
        [self.view addSubview:virtualRemote.view];
    }
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


//-------------------- Camera stuff ----------------------------

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
 *  6. A label pasted on any button that when pushed cancels taking a photo.
 */
- (void)do_PI:(NSArray *)args {
    NSLog(@"Submit Picture, args:%@", args);
    if ([self.navigationController visibleViewController] != self) {
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
        
        if ([args objectAtIndex:4] && ([args objectAtIndex:4] != @"")) {
            //TODO: may need to subtract from height
            mask = [resourceManager fetchImageViewUsingResource:[args objectAtIndex:4] frame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        }
        
        if ([args objectAtIndex:5] && ([args objectAtIndex:5] != @"")) {
            cameraLabel = [args objectAtIndex:5];
        } else {
            cameraLabel = @"Send Image to TV";
        }
        if ([args objectAtIndex:6] && ([args objectAtIndex:6] != @"")) {
            cameraCancelLabel = [args objectAtIndex:6];
        } else {
            cameraCancelLabel = @"Cancel";
        }
    }
    camera = [[CameraViewController alloc] initWithView:self.view targetWidth:width targetHeight:height editable:editable mask:mask];
    
    [camera setupService:[socketManager port] host:hostName path:[args objectAtIndex:0] delegate:self];
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

//-------------------- Super Advanced UI stuff (depricated) -----------------

- (void)do_UX:(NSArray *)args {
    //NSArray *JSON_Array = [[args objectAtIndex:1] yajl_JSON];
    
    /*
    if ([(NSString *)[args objectAtIndex:0] compare:@"CREATE"] == NSOrderedSame) {
        [advancedUIDelegate createObjects:JSON_Array];
    } else if ([(NSString *)[args objectAtIndex:0] compare:@"DESTROY"] == NSOrderedSame) {
        [advancedUIDelegate destroyObjects:JSON_Array];
    } else if ([(NSString *)[args objectAtIndex:0] compare:@"SET"] == NSOrderedSame) {
        [advancedUIDelegate setValuesForObjects:JSON_Array];
    }
    */
}

//---------------------------------------------------------------------------

- (void)sendEvent:(NSString *)name JSON:(NSString *)JSON_string {
    //NSLog(@"\n\nJSON_string: %@", JSON_string);
    NSString *sentData = [NSString stringWithFormat:@"UI\t%@\t%@\n", name, JSON_string];
    //NSLog(@"sent data: %@", sentData);
    [socketManager sendData:[sentData UTF8String] numberOfBytes:[sentData length]];
    //fprintf(stderr, "\n%s\n\n",[sentData UTF8String]);
}

//-------------------- Other View stuff ------------------------

- (void)clean {
    [self clearUI];
    [advancedUIDelegate clean];
    [resourceManager clean];
}

- (void)clearUI {
    NSLog(@"Clearing the UI");
    [theTextField resignFirstResponder];
	theTextField.hidden = YES;
    textView.hidden = YES;
    
    if (camera) {
        [camera release];
        camera = nil;
    }
    
    /*
    backgroundView.image = [UIImage imageNamed:@"background.png"];
    for (UIView *subview in backgroundView.subviews) {
        [subview removeFromSuperview];
    }
    //*/
    
    //*
    CGFloat
    x = self.view.frame.origin.x,
    y = self.view.frame.origin.y,
    width = self.view.frame.size.width,
    height = self.view.frame.size.height;
    
    UIImageView *newImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    newImageView.frame = CGRectMake(x, y, width, height);
    [foregroundView removeFromSuperview];
    for (UIView *subview in [foregroundView subviews]) {
        [subview removeFromSuperview];
    }
    [backgroundView removeFromSuperview];
    self.backgroundView = newImageView;
    [self.view addSubview:backgroundView];
    [self.view sendSubviewToBack:backgroundView];
    
    [newImageView release];
    
    if (advancedView.subviews.count == 0) {
        [self.view addSubview:virtualRemote.view];
        graphics = NO;
    }

    [backgroundView addSubview:foregroundView];
    //*/
}

- (void)object_added {
    if ([virtualRemote.view superview]) {
        [virtualRemote.view removeFromSuperview];
    }
    graphics = YES;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"GestureView loaded!");
    
    textView.layer.cornerRadius = 10.0;
    textView.layer.borderColor = [UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:100.0/255.0 alpha:1.0].CGColor;
    textView.layer.borderWidth = 10.0;
    
    loadingIndicator.hidesWhenStopped = YES;
    //loadingIndicator.bounds = self.view.frame;
    loadingIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/3);
    [loadingIndicator startAnimating];
    
    //backgroundView.image = [UIImage imageNamed:@"background.png"];
    
    if (!styleAlert) {
        styleAlert = [[UIActionSheet alloc]
                      initWithTitle:@"TrickPlay Multiple Choice"
                      delegate:self cancelButtonTitle:nil
                               destructiveButtonTitle:nil
                                    otherButtonTitles:nil];
    }
    
    if (!multipleChoiceArray) {
        multipleChoiceArray = [[NSMutableArray alloc] initWithCapacity:4];
    }
    
    
    UIBarButtonItem *exitItem = [[[UIBarButtonItem alloc] 
                                  initWithTitle:NSLocalizedString(@"Exit", @"")
                                  style:UIBarButtonItemStyleBordered
								  target:self action:@selector(exitTrickplayApp:)] autorelease]; 
	self.navigationItem.rightBarButtonItem = exitItem;
    
    [loadingIndicator stopAnimating];
    
    /*
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0/-2000;
    self.view.layer.transform = transform;
    */
    //[self startService];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!socketManager) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    viewDidAppear = YES;
    [self performSelectorOnMainThread:@selector(createTimer) withObject:nil waitUntilDone:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (socketTimer) {
        [socketTimer invalidate];
        [socketTimer release];
        socketTimer = nil;
    }
}
//*/

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    NSLog(@"GestureViewController Unload");
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.loadingIndicator = nil;
    
    if (styleAlert) {
        [styleAlert release];
        styleAlert = nil;
    }
    
    multipleChoiceArray = [[NSMutableArray alloc] initWithCapacity:4];
    if (multipleChoiceArray) {
        [multipleChoiceArray release];
        multipleChoiceArray = nil;
    }
}


- (void)dealloc {
    NSLog(@"Gesture View Controller dealloc");
    if (version) {
        [version release];
    }
    if (hostName) {
        [hostName release];
    }
    if (http_port) {
        [http_port release];
    }
    if (audioController) {
        [audioController release];
    }
    if (advancedUIDelegate) {
        [(AdvancedUIObjectManager *)advancedUIDelegate release];
    }
    if (resourceManager) {
        [resourceManager release];
    }
    if (socketManager) {
        [socketManager release];
        socketManager.delegate = nil;
    }
    if (touchDelegate) {
        [(TouchController *)touchDelegate release];
    }
    if (accelDelegate) {
        [(AccelerometerController *)accelDelegate release];
    }
    if (styleAlert) {
        [styleAlert release];
    }
    if (cameraActionSheet) {
        [cameraActionSheet dismissWithClickedButtonIndex:[cameraActionSheet cancelButtonIndex] animated:NO];
        [cameraActionSheet release];
    }
    if (camera) {
        [camera release];
    }
    if (virtualRemote) {
        [virtualRemote release];
        virtualRemote = nil;
    }
    if (multipleChoiceArray) {
        [multipleChoiceArray release];
    }
    if (advancedView) {
        [advancedView release];
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
