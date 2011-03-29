//
//  GestureViewController.m
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GestureViewController.h"

@implementation GestureViewController

@synthesize loadingIndicator;
@synthesize theTextField;
@synthesize backgroundView;
@synthesize touchDelegate;
@synthesize accelDelegate;

- (void)setupService:(NSInteger)p
            hostname:(NSString *)h
            thetitle:(NSString *)n {
    
    NSLog(@"Service Setup: %@ host: %@ port: %d", n, h, p);
    
    port = p;
    if (hostName) {
        [hostName release];
    }
    hostName = [h retain];
}

- (BOOL)startService {
    // Tell socket manager to create a socket and connect to the service selected
    socketManager = [[SocketManager alloc] initSocketStream:hostName
                                                       port:port
                                                   delegate:self];
    
    if (!socketManager) {
        // If null then error connecting, back up to selecting services view
        [self.navigationController popViewControllerAnimated:YES];
        NSLog(@"Could Not Establish Connection");
        return NO;
    }
    
    // Made a connection, let the service know!
	// Get the actual width and height of the available area
	CGRect mainframe = [[UIScreen mainScreen] applicationFrame];
	NSInteger height = mainframe.size.height;
	height = height - 45;  //subtract the height of navbar
	NSInteger width = mainframe.size.width;
	NSData *welcomeData = [[NSString stringWithFormat:@"ID\t3\t%@\tKY\tAX\tCK\tTC\tMC\tSD\tUI\tTE\tIS=%dx%d\tUS=%dx%d\n", [UIDevice currentDevice].name, width, height, width, height ] dataUsingEncoding:NSUTF8StringEncoding];
	
    resourceManager = [[ResourceManager alloc] initWithSocketManager:socketManager];
	
    audioController = [[AudioController alloc] initWithResourceManager:resourceManager socketManager:socketManager];
    touchDelegate = [[TouchController alloc] initWithView:self.view socketManager:socketManager];
    accelDelegate = [[AccelerometerController alloc] initWithSocketManager:socketManager];
    [socketManager sendData:[welcomeData bytes] numberOfBytes:[welcomeData length]];
    
    //[loadingIndicator stopAnimating];
    
    return YES;
}


- (void)socketErrorOccurred {
    NSLog(@"Socket Error Occurred");
    // everything will get released from the navigation controller's delegate call
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)streamEndEncountered {
    // everything will get released from the navigation controller's delegate call
    [self.navigationController popToRootViewControllerAnimated:YES];
}

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

- (void)exitTrickplayApp:(id)sender {
    //Send Escape key to exit whatever app is currently running
	[self sendKeyToTrickplay:@"FF1B" thecount:1];
}


#pragma mark -
#pragma mark Handling Commands From Server

//------------------- Handling Commands From Server ------------------

//--Audio junk

- (void)do_SS:(NSArray *)args {
    NSMutableDictionary *audioInfo = [resourceManager getResourceInfo:[args objectAtIndex:0]];
    // Add the amount of times to loop this sound file to the info
    NSString *loopValue = [args objectAtIndex:1];
    [audioInfo setObject:loopValue forKey:@"loop"];
    
    [audioController playSoundFile:[audioInfo objectForKey:@"name"] filename:[audioInfo objectForKey:@"link"]];
}

//--Multiple Choice junk

- (void)do_MC:(NSArray *)args {
    NSString *windowtitle = [args objectAtIndex:0];
    //multiple choice alertview
    //<id>,<text> pairs
    unsigned theindex = 1;
    if (styleAlert != nil)
    {
        [styleAlert release];
        styleAlert = nil;
        styleAlert = [[UIActionSheet alloc] initWithTitle:windowtitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    }
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"Dismiss the alertview");
	if (buttonIndex < 5)
	{
		NSString *sentData = [NSString stringWithFormat:@"UI\t%@\n", [multipleChoiceArray objectAtIndex:buttonIndex]];
		[socketManager sendData:[sentData UTF8String]
                  numberOfBytes:[sentData length]];
	}
    
	
}

//--Text input stuff

/**
 * Brings up the text field, sets the text field as the focus, and the
 * user may enter text.
 */
- (void)do_ET:(NSArray *)args {
    theTextField.hidden = NO;
    [theTextField becomeFirstResponder];
    // see if trickplay passed any text
    if ([args count] > 1) {
        theTextField.text = [args objectAtIndex:1];
    } else {
        theTextField.text = @"";
    }
    [self.view bringSubviewToFront:theTextField];
}

/**
 * Send the data the user entered into the text field to Trickplay.
 * Then hide text field.
 */
- (IBAction)hideTextBox:(id)sender {
    NSLog(@"textbox hidden");
    NSString *sentData = [NSString stringWithFormat:@"UI\t%@\n", theTextField.text];
    [socketManager sendData:[sentData UTF8String] numberOfBytes:[sentData length]];
}

// UITextFieldDelegate method
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [theTextField resignFirstResponder];
    theTextField.hidden = YES;
    return YES;
}


//--Image related

- (void)do_DR:(NSArray *)args {
    NSLog(@"Declaring Resource");
    [args retain];
    
    [resourceManager declareResourceWithObject:[
                              NSMutableDictionary dictionaryWithObjectsAndKeys:[args objectAtIndex:0], @"name", [args objectAtIndex:1], @"link", @"", @"scale", nil
                              ]
                      forKey:[args objectAtIndex:0]
     ];
    
    [args release];
}

/**
 * Updating the bacground
 */
- (void)do_UB:(NSArray *)args {
    NSLog(@"Updating Background");
    [args retain];
    
    NSString *key = [args objectAtIndex:0];
    // If resource has been declared
    if ([resourceManager getResourceInfo:key]) {
        //**
        NSData *imageData = [resourceManager fetchResource:key];
        if (imageData) {
            UIImage *tempImage = [[[UIImage alloc] initWithData:imageData] autorelease];
            [loadingIndicator stopAnimating];
            NSLog(@"Creating background view");
            backgroundView.image = tempImage;
            //**for testing
            //backgroundView.image = [UIImage imageNamed:@"background.png"];
        }
        //*/
        /**
        UIImageView *newBackgroundView = [resourceManager fetchImageViewUsingResource:key frame:backgroundView.frame];
        [backgroundView removeFromSuperview];
        self.backgroundView = newBackgroundView;
        [self.view addSubview:backgroundView];
        [loadingIndicator stopAnimating];
        //*/
    }
    
    [args release];
}

/**
 * Update a graphics element
 */
- (void)do_UG:(NSArray *)args {
    NSLog(@"Updating Graphics");
    [args retain];
    
    NSString *key = [args objectAtIndex:0];
    // If resource has been declared
    if ([resourceManager getResourceInfo:key]) {
        CGFloat
        x = [[args objectAtIndex:1] floatValue],
        y = [[args objectAtIndex:2] floatValue],
        width = [[args objectAtIndex:3] floatValue],
        height = [[args	objectAtIndex:4] floatValue];
        CGRect frame = CGRectMake(x, y, width, height);
        UIImageView *newImageView = [resourceManager fetchImageViewUsingResource:key frame:frame];
        /**
        // Grab the image, make sure its there.
        NSData *imageData = [resourceManager fetchResource:key];
        if (!imageData) return;
        UIImage *tempImage = [[[UIImage alloc] initWithData:imageData] autorelease];
        // Now we have the image, we need to draw it
        NSLog(@"Drawing resource");
        CGFloat
        x = [[args objectAtIndex:1] floatValue],
        y = [[args objectAtIndex:2] floatValue],
        width = [[args objectAtIndex:3] floatValue],
        height = [[args	objectAtIndex:4] floatValue];
        
        UIImageView *newImageView = [[UIImageView alloc] initWithImage:tempImage];
        newImageView.frame = CGRectMake(x, y, width, height);
        //*/
        
        //[self.view addSubview:newImageView];
        // NOTE: Assumes backgroundView is only replaced in clearUI(),
        // hence, replace backgroundView.image, do not replace the entire View
        [backgroundView addSubview:newImageView];
        
        /*
        UIGraphicsBeginImageContext(CGSizeMake(backgroundView.bounds.size.width, backgroundView.bounds.size.height));		
        // get context
        //
        CGContextRef context = UIGraphicsGetCurrentContext();		
        
        // push context to make it current 
        // (need to do this manually because we are not drawing in a UIView)
        //
        UIGraphicsPushContext(context);								
        
        // drawing code comes here- look at CGContext reference
        // for available operations
        //
        // this example draws the inputImage into the context
        //
        [backgroundView.image drawInRect:CGRectMake(0,0,backgroundView.bounds.size.width, backgroundView.bounds.size.height)];
        [tempImage drawInRect:CGRectMake(x, y, width, height)];
        
        // pop context 
        //
        UIGraphicsPopContext();								
        
        // get a UIImage from the image context- enjoy!!!
        //
        UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // clean up drawing environment
        //
        UIGraphicsEndImageContext();
        
        backgroundView.image = outputImage;
        //*/
    }
    
    [args release];
}


//--Resetting stuff

// TODO: Reset all modules to the initial state
- (void)do_RT:(NSArray *)args {
    [accelDelegate pauseAccelerometer];
    [self clearUI];
}

- (void)do_CU {
    [self clearUI];
}


//------------------ Stuff passed to AccelerometerController ------------

- (void)do_SA:(NSArray *)args {
    [accelDelegate startAccelerometerWithFilter:[args objectAtIndex:0] interval:[[args objectAtIndex:1] floatValue]];
}

- (void)do_PA:(NSArray *)args {
    [accelDelegate pauseAccelerometer];
}


//------------------ Stuff passed to TouchController --------------------
// TODO: Change this design pattern to use Categories/Class-Extensions
/** depricated
- (void)do_SC {
    [touchDelegate startClicks];
}
- (void)do_PC {
    [touchDelegate stopClicks];
}
//*/
- (void)do_ST {
    [touchDelegate startTouches];
}
- (void)do_PT {
    [touchDelegate stopTouches];
}
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

//-------------------- Other View stuff ------------------------

- (void)clean {
    [self clearUI];
    [resourceManager clean];
}

- (void)clearUI {
    NSLog(@"Clearing the UI");
    [theTextField resignFirstResponder];
	theTextField.hidden = YES;
    
    CGFloat
    x = self.view.frame.origin.x,
    y = self.view.frame.origin.y,
    width = self.view.frame.size.width,
    height = self.view.frame.size.height;
    
    UIImageView *newImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    newImageView.frame = CGRectMake(x, y, width, height);
    [backgroundView removeFromSuperview];
    self.backgroundView = newImageView;
    [self.view addSubview:backgroundView];
    [newImageView release];
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
    
    loadingIndicator.hidesWhenStopped = YES;
    //loadingIndicator.bounds = self.view.frame;
    loadingIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/3);
    [loadingIndicator startAnimating];
    
    //backgroundView.image = [UIImage imageNamed:@"background.png"];
    
    styleAlert = [[UIActionSheet alloc] initWithTitle:@"TrickPlay Multiple Choice"
                                             delegate:self cancelButtonTitle:nil
                               destructiveButtonTitle:nil
                                    otherButtonTitles:nil];
    
    multipleChoiceArray = [[NSMutableArray alloc] initWithCapacity:4];
    
    UIBarButtonItem *exitItem = [[[UIBarButtonItem alloc]
								  initWithTitle:NSLocalizedString(@"Exit", @"")
								  style:UIBarButtonItemStyleBordered
								  target:self action:@selector(exitTrickplayApp:)] autorelease]; 
	self.navigationItem.rightBarButtonItem = exitItem;
    
    //[self startService];
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    NSLog(@"Gesture View Controller dealloc");
    if (hostName) {
        [hostName release];
    }
    if (audioController) {
        [audioController release];
    }
    if (resourceManager) {
        [resourceManager release];
    }
    if (socketManager) {
        [socketManager release];
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
    [multipleChoiceArray release];
    [loadingIndicator release];
    [theTextField release];
    [backgroundView release];
    
    [super dealloc];
}


@end
