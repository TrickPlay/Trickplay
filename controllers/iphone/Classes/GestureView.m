//
//  GestureView.m
//  TrickplayRemote
//
//  Created by Kenny Ham on 1/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GestureView.h"
#import <Foundation/Foundation.h>
#import <Foundation/NSRunLoop.h>
#import <AudioToolbox/AudioToolbox.h>
//#import <NSApplication/NSApplication.h>

// Constant for the number of times per second (Hertz) to sample acceleration.
#define kAccelerometerFrequency         40  //Try 60 for high pass
#define kFilteringFactor				0.1
#define kMinEraseInterval				0.5
#define kEraseAccelerationThreshold		2.0

#define HORIZ_SWIPE_DRAG_MIN  25  //Was 20
#define VERT_SWIPE_DRAG_MAX    10
#define TAP_DISTANCE_MAX    4

@implementation GestureView

@synthesize mTouchedTime;
@synthesize waitingView;
@synthesize mStyleAlert;
@synthesize mTextField;
@synthesize backgroundView;
@synthesize mImageCollection;
@synthesize mAudioPlayer;
@synthesize mSoundLoopName;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.tag = 2;
	accelerationY = 0;
	accelerationX = 0;
	accelerationZ = 0;
	mAccelMode = 0;  //Don't send accelerometer events
	myAcceleration[0] = 0;
	myAcceleration[1] = 0;
	myAcceleration[2] = 0;
	mClickEventsAllowed = YES;
	mTouchEventsAllowed = NO;
	mAccelerationFrequency = kAccelerometerFrequency;
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];  //update 20 times/second
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
	//NSArray *runLoopModes = [NSArray arrayWithObjects:NSRunLoopCommonModes,NSDefaultRunLoopMode, nil]; 
	//[listenSocket setRunLoopModes:runLoopModes]; 
	
	//[listenSocket setRunLoopModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode,NSRunLoopCommonModes,nil]];
	connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    mSwipeSent = NO;
	mTryingToConnect = NO;
	multipleChoiceArray = [[NSMutableArray arrayWithObjects:nil] retain];
	mStyleAlert = [[UIActionSheet alloc] initWithTitle:@"TrickPlay Multiple Choice"
															delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
												   otherButtonTitles:nil];
	mTextField.delegate = self;
	mImageCollection = [[NSMutableArray alloc] init];
	


}

- (void)setupService:(NSInteger)port  hostname:(NSString *)hostname thetitle:(NSString *)thetitle
{
	if(port < 0 || port > 65535)
	{
		port = 0;
	}
	
	NSError *error = nil;
	self.title = thetitle;
	//if(![listenSocket acceptOnPort:port error:&error])
	//{
		//[self logError:FORMAT(@"Error starting server: %@", error)];
	//	return;
	//}
	mTryingToConnect = YES;
	[listenSocket connectToHost:hostname onPort:port error:&error ];
	NSTimer *atimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(onTimeout) userInfo:nil repeats:NO];
	[waitingView startAnimating];
	//[self logInfo:FORMAT(@"Echo server started on port %hu", [listenSocket localPort])];

}

- (void)onTimeout
{
	@try {
		
  	   if ([connectedSockets count] == 0)
	   {
		   [listenSocket disconnect];
		   mAccelMode = 0;
		   [connectedSockets removeObject:listenSocket];
		   [self.navigationController popViewControllerAnimated:YES];    
		   [waitingView stopAnimating];
	   }
		mTryingToConnect = NO;
	}
	@catch (id theException1) {
	} 
	@finally {
	}	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	//Look at these examples:   
	//  http://developer.apple.com/iphone/library/samplecode/AccelerometerGraph/index.html
	//  http://developer.apple.com/iphone/library/samplecode/BubbleLevel/index.html
	//
	//X values:   
	//           -1 would be tilted all the way to the left so that it is vertical (90 deg left)
	//           +1 would be tilted all the way to the right so that the screen is facing to the right (90 deg right)
	//Y values:
	//           -1 would be when its upright screen facing you
	//           +1 would be upside down screen facing out
	//           0 would be flat on a table
	//Method 1 like the level application:
    // Use a basic low-pass filter to only keep the gravity in the accelerometer values for the X and Y axes
	if (mAccelMode == 1) //low pass filter
	{
		accelerationX = acceleration.x * kFilteringFactor + accelerationX * (1.0 - kFilteringFactor);
		accelerationY = acceleration.y * kFilteringFactor + accelerationY * (1.0 - kFilteringFactor);
		accelerationZ = acceleration.z * kFilteringFactor + accelerationZ * (1.0 - kFilteringFactor);
		NSData *sentData = [[NSString stringWithFormat:@"AX\t%f\t%f\t%f\n", accelerationX,accelerationY,accelerationZ] dataUsingEncoding:NSUTF8StringEncoding];
		[listenSocket writeData:sentData withTimeout:-1 tag:0];
		
		
	}
    // keep the raw reading, to use during calibrations
    //currentRawReading = atan2(accelerationY, accelerationX);
    //End of method 1
    else if (mAccelMode == 2) //high pass filter
	{
		//Method 2 for high pass filter
		UIAccelerationValue				length,
		 x,
		 y,
		 z;
	 
		 //Use a basic high-pass filter to remove the influence of the gravity
		 myAcceleration[0] = acceleration.x * kFilteringFactor + myAcceleration[0] * (1.0 - kFilteringFactor);
		 myAcceleration[1] = acceleration.y * kFilteringFactor + myAcceleration[1] * (1.0 - kFilteringFactor);
		 myAcceleration[2] = acceleration.z * kFilteringFactor + myAcceleration[2] * (1.0 - kFilteringFactor);
		 // Compute values for the three axes of the acceleromater
		 x = acceleration.x - myAcceleration[0];
		 y = acceleration.y - myAcceleration[0];
		 z = acceleration.z - myAcceleration[0];
		NSData *sentData = [[NSString stringWithFormat:@"AX\t%f\t%f\t%f\n", myAcceleration[0],myAcceleration[1],myAcceleration[2]] dataUsingEncoding:NSUTF8StringEncoding];
		[listenSocket writeData:sentData withTimeout:-1 tag:0];
		
		 //Compute the intensity of the current acceleration 
		 //length = sqrt(x * x + y * y + z * z);
		 // If device is shaken, do stuff.
		 //if(length >= kEraseAccelerationThreshold) //&& (CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval)) {
			//[[mainViewController mainView] aFunction];
			//lastTime = CFAbsoluteTimeGetCurrent();
		 //}
        
		
    }
	//NSLog([NSString stringWithFormat: @"acceleration (x,y): %f,%f ", accelerationX,accelerationY]);
   
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    // startTouchPosition is an instance variable
    startTouchPosition = [touch locationInView:self.view];
	currentTouchPosition = startTouchPosition;
	mKeySent = NO;
	NSLog(@"touches began");
	mTouchedTime = [NSDate timeIntervalSinceReferenceDate];
	//Send the TOUCHDOWN event if enabled
	if (([connectedSockets count] > 0) && mTouchEventsAllowed)
	{
		NSData *sentTouchData = [[NSString stringWithFormat:@"TOUCHDOWN\t%f\t%f\n", currentTouchPosition.x,currentTouchPosition.y] dataUsingEncoding:NSUTF8StringEncoding];
		[listenSocket writeData:sentTouchData withTimeout:-1 tag:0];
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
	UITouch *touch = [touches anyObject];
    currentTouchPosition = [touch locationInView:self.view];
	
	//Send the TOUCHMOVE event if enabled
	if (([connectedSockets count] > 0) && mTouchEventsAllowed)
	{
		NSData *sentTouchData = [[NSString stringWithFormat:@"TOUCHMOVE\t%f\t%f\n", currentTouchPosition.x,currentTouchPosition.y] dataUsingEncoding:NSUTF8StringEncoding];
		[listenSocket writeData:sentTouchData withTimeout:-1 tag:0];
	}
	
	
	if (mKeySent) return; //Don't send another keystroke with this gesture
	
	int numSwipes = 1;
	//Horizontal swipe
    // To be a swipe, direction of touch must be horizontal and long enough.
    //if (fabsf(startTouchPosition.x - currentTouchPosition.x) >= HORIZ_SWIPE_DRAG_MIN &&
    //    fabsf(startTouchPosition.y - currentTouchPosition.y) <= VERT_SWIPE_DRAG_MAX)
	if ((fabsf(startTouchPosition.x - currentTouchPosition.x) / fabsf(startTouchPosition.y - currentTouchPosition.y) > 2.0) &&
		(fabsf(startTouchPosition.x - currentTouchPosition.x) >= HORIZ_SWIPE_DRAG_MIN))
    {
		if (mTouchedTime > 0)
		{
			NSLog([NSString stringWithFormat:@"swipe speed horiz :%f ",[NSDate timeIntervalSinceReferenceDate]  - mTouchedTime]);
			if (([NSDate timeIntervalSinceReferenceDate]  - mTouchedTime) < 0.05)
			{
				//numSwipes = 3;
			}
			else if (([NSDate timeIntervalSinceReferenceDate]  - mTouchedTime) < 0.1)
			{
				//numSwipes = 2;
			}
			
		}
		
        // It appears to be a swipe.
        if (startTouchPosition.x < currentTouchPosition.x)
		{
			//Send right key -  FF53
			NSLog(@"swipe right");
			mKeySent = YES;
			[self sendKeyToTrickplay:@"FF53" thecount:numSwipes];
		}
        else
		{
			//Send left key  - FF51
			NSLog(@"Swipe Left");
			mKeySent = YES;
			[self sendKeyToTrickplay:@"FF51" thecount:numSwipes];
		}
		mSwipeSent = YES;
    }
	//Vertical swipe
	//else if (fabsf(startTouchPosition.y - currentTouchPosition.y) >= HORIZ_SWIPE_DRAG_MIN &&
	//		 fabsf(startTouchPosition.x - currentTouchPosition.x) <= VERT_SWIPE_DRAG_MAX)
	else if ((fabsf(startTouchPosition.y - currentTouchPosition.y) / fabsf(startTouchPosition.x - currentTouchPosition.x) > 2.0) &&
			 (fabsf(startTouchPosition.y - currentTouchPosition.y) >= HORIZ_SWIPE_DRAG_MIN))
	{
		if (mTouchedTime > 0)
		{
			NSLog([NSString stringWithFormat:@"swipe speed vertical:%f ",[NSDate timeIntervalSinceReferenceDate]  - mTouchedTime]);
			if (([NSDate timeIntervalSinceReferenceDate]  - mTouchedTime) < 0.05)
			{
				//numSwipes = 3;
			}
			else if (([NSDate timeIntervalSinceReferenceDate]  - mTouchedTime) < 0.1)
			{
				//numSwipes = 2;
			}
		}
		// It appears to be a vertical swipe.
        if (startTouchPosition.y < currentTouchPosition.y)
		{
			//Send down key -  FF54
			NSLog(@"swipe down");
			mKeySent = YES;
			
			[self sendKeyToTrickplay:@"FF54" thecount:numSwipes];
		}
        else
		{
			//Send up key  - FF52
			NSLog(@"Swipe up");
			mKeySent = YES;
			[self sendKeyToTrickplay:@"FF52" thecount:numSwipes];
		}
		mSwipeSent = YES;
		
	}
		
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //Multi touch info:
	//http://developer.apple.com/iphone/library/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/EventHandling/EventHandling.html#//apple_ref/doc/uid/TP40007072-CH9-SW14
	//Send the TOUCHUP event if enabled
	if (([connectedSockets count] > 0) && mTouchEventsAllowed)
	{
		NSData *sentTouchData = [[NSString stringWithFormat:@"TOUCHUP\t%f\t%f\n", currentTouchPosition.x,currentTouchPosition.y] dataUsingEncoding:NSUTF8StringEncoding];
		[listenSocket writeData:sentTouchData withTimeout:-1 tag:0];
	}
	
	if (!mSwipeSent)
	{
		
		//Send 'Enter' key since no swipe occured but they tapped the screen
		//Don't do this if the start/end points are too far apart
		if (fabsf(startTouchPosition.x - currentTouchPosition.x) <= TAP_DISTANCE_MAX &&
			fabsf(startTouchPosition.y - currentTouchPosition.y) <= TAP_DISTANCE_MAX)
		{
			//Tap occured, send <ENTER> key
			[self sendKeyToTrickplay:@"FF0D" thecount:1];
			//Send click event if click events are enabled
			if (([connectedSockets count] > 0) && mClickEventsAllowed)
			{
				NSData *sentClickData = [[NSString stringWithFormat:@"CLICK\t%f\t%f\n", currentTouchPosition.x,currentTouchPosition.y] dataUsingEncoding:NSUTF8StringEncoding];
				[listenSocket writeData:sentClickData withTimeout:-1 tag:0];
			}
		}
		else
		{
			NSLog([NSString stringWithFormat:@"no swipe sent, start.x,.y:%f , %f  current.x,.y:%f , %f",startTouchPosition.x,startTouchPosition.y,currentTouchPosition.x,currentTouchPosition.y]);
		}
		
		
	}
	startTouchPosition.x = 0.0;
	startTouchPosition.y = 0.0;
	currentTouchPosition.x = 0.0;
	currentTouchPosition.y = 0.0;
	mSwipeSent = NO;
	mKeySent = NO;
	NSLog(@"touches ended");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    startTouchPosition.x = 0.0;
	startTouchPosition.y = 0.0;
	currentTouchPosition.x = 0.0;
	currentTouchPosition.y = 0.0;
	mSwipeSent = NO;
	mKeySent = NO;
}

- (void)sendKeyToTrickplay:(NSString *)thekey thecount:(NSInteger)thecount
{
	if ([connectedSockets count] > 0)
	{
	    int index;	
		NSData *sentData = [[NSString stringWithFormat:@"K\t%@\n", thekey] dataUsingEncoding:NSUTF8StringEncoding];

		for (index = 1; index <= thecount; index++) {
			[listenSocket writeData:sentData withTimeout:-1 tag:0];
		}
		
		mKeySent = YES;
	}
	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	NSLog(@"Memory warning");
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	if ([connectedSockets count] == 0)
	{
		[connectedSockets addObject:newSocket];
	}
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	//[self logInfo:FORMAT(@"Accepted client %@:%hu", host, port)];
	NSData *welcomeData = [[NSString stringWithFormat:@"DEVICE\t1\t%@\tK\tAX\tCLICK=(320,410)\tTOUCH=(320,410)\tBACKGROUND=(320,410)\tPLAYSOUND\n",[UIDevice currentDevice].name ] dataUsingEncoding:NSUTF8StringEncoding];
	
	[connectedSockets addObject:sock];
	[sock writeData:welcomeData withTimeout:-1 tag:0];
	[waitingView stopAnimating];
	// We could call readDataToData:withTimeout:tag: here - that would be perfectly fine.
	// If we did this, we'd want to add a check in onSocket:didWriteDataWithTag: and only
	// queue another read if tag != WELCOME_MSG.
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	[sock readDataToData:[AsyncSocket LFData] withTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	@try {
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 1)];
	NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
	if(msg)
	{
		//NSLog(msg);
		msg = [ msg stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%C", 9] withString:@"<<TAB>>"];
		//NSLog(msg);
		if ([msg hasPrefix:@"START"])
		{
			NSArray *components = [msg componentsSeparatedByString:@"<<TAB>>"];
			if ([[components objectAtIndex:1] compare:@"AX"] == 0)
			{
				if ([[components objectAtIndex:2] compare:@"L"] == 0)
				{
					mAccelMode = 1;
					[[UIAccelerometer sharedAccelerometer] setUpdateInterval:[[components objectAtIndex:3] floatValue]];
				}
				else if ([[components objectAtIndex:2] compare:@"H"] == 0)
				{
					mAccelMode = 2;
					[[UIAccelerometer sharedAccelerometer] setUpdateInterval:[[components objectAtIndex:3] floatValue]];
				}
			}
			else if ([[components objectAtIndex:1] compare:@"TOUCH"] == 0)
			{
				mTouchEventsAllowed = YES;
			}
			else if ([[components objectAtIndex:1] compare:@"CLICK"] == 0)
			{
				mClickEventsAllowed = YES;
			}
			
		}
		else if ([msg hasPrefix:@"STOP"])
		{
			NSArray *components = [msg componentsSeparatedByString:@"<<TAB>>"];
			if ([[components objectAtIndex:1] compare:@"AX"] == 0)
			{
				mAccelMode = 0;
			}
			else if ([[components objectAtIndex:1] compare:@"TOUCH"] == 0)
			{
				mTouchEventsAllowed = NO;
			}
			else if ([[components objectAtIndex:1] compare:@"CLICK"] == 0)
			{
				mClickEventsAllowed = NO;
			}
			
		}
		else if ([msg hasPrefix:@"RESET"])
		{
			mAccelMode = 0;
		}
		else if ([msg hasPrefix:@"RESOURCE"])
		{
			//http://downloads.flashkit.com/soundfx/Ambience/Space/Space_-SLrec-7832/Space_-SLrec-7832_hifi.mp3
			NSArray *components = [msg componentsSeparatedByString:@"<<TAB>>"];
			[mImageCollection addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[components objectAtIndex:1], @"name", [components objectAtIndex:2], @"link", @"", @"scale", nil]];
			
		}
		else if ([msg hasPrefix:@"BACKGROUND"])
		{
			NSArray *components = [msg componentsSeparatedByString:@"<<TAB>>"];
			if ([mImageCollection count] > 0)
			{
				//Show the image
				int index;
				NSDictionary *itemAtIndex;
				for (index = 0;index < [mImageCollection count];index++)
				{
					itemAtIndex = (NSDictionary *)[mImageCollection objectAtIndex:index];
					if ([[itemAtIndex objectForKey:@"name"] compare:[components objectAtIndex:1]] == 0)
					{
						//[NSURL URLWithString:aURL]
						//NSData *data = [NSData dataWithContentsOfURL:url];
						//@"http://images.apple.com/home/images/ipad_headline_20100127.png"
						UIImage *tempImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[itemAtIndex objectForKey:@"link"]]]];
						backgroundView.image = tempImage;//[UIImage imageNamed:@"icon.png"];
					}
				}
				if ([components count] > 2)
				{
					//Scale or tile it if necessary
					//See if its scale or tile	
					if ([[components objectAtIndex:2] compare:@"SCALE"] == 0)
					{
					
					}
					else if ([[components objectAtIndex:2] compare:@"TILE"] == 0)
					{
					
					}
				}
			}
			
			
		}
		else if ([msg hasPrefix:@"PLAYSOUND"])
		{
			NSArray *components = [msg componentsSeparatedByString:@"<<TAB>>"];
			if ([mImageCollection count] > 0)
			{
				int index;
				NSDictionary *itemAtIndex;
				for (index = 0;index < [mImageCollection count];index++)
				{
					itemAtIndex = (NSDictionary *)[mImageCollection objectAtIndex:index];
					if ([[itemAtIndex objectForKey:@"name"] compare:[components objectAtIndex:1]] == 0)
					{
						[self playSoundFile:[itemAtIndex objectForKey:@"name"] filename:[itemAtIndex objectForKey:@"link"]];	
						
						if ([components count] > 2)
						{
							//Loop parameter
							NSString *loopvalue = [components objectAtIndex:2];
							[mImageCollection replaceObjectAtIndex:index withObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[itemAtIndex objectForKey:@"name"], @"name",loopvalue, @"loop",[itemAtIndex objectForKey:@"link"],@"link", nil]];
						}
						else {
							//Empty loop variable
							[mImageCollection replaceObjectAtIndex:index withObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[itemAtIndex objectForKey:@"name"], @"name",@"", @"loop",[itemAtIndex objectForKey:@"link"],@"link", nil]];
						}
						break;
					}
				}
				

			}
		}
		else if ([msg hasPrefix:@"STOPSOUND"])
		{
			[self.mAudioPlayer stop];
			[self.mAudioPlayer release];
			self.mAudioPlayer.delegate = nil;
			self.mAudioPlayer = nil;
			
		}
		else if ([msg hasPrefix:@"UI"])
		{
			//NSArray *components = [msg componentsSeparatedByString:@"\t"];
			//NSLog([NSString stringWithFormat:@"<span style=%Ccolor: red;%C>", 39,39]);
			//NSLog([NSString stringWithFormat:@"UI MC sent %C", 9]);
			
			//NSLog(msg);
			NSArray *components = [msg componentsSeparatedByString:@"<<TAB>>"];
			if ([[components objectAtIndex:1] compare:@"MC"] == 0)
			{
				//multiple choice alertview
				//<id>,<text> pairs
				int theindex = 2;
				NSString *windowtitle = @"TrickPlay Multiple Choice";
				//See if the MC_LABEL is in there, if so use it as the label for this box
				if ([[components objectAtIndex:2] compare:@"MC_LABEL"] == 0)
				{
					windowtitle = [components objectAtIndex:3];
					
					theindex = 4;  //Start the button items at index 4 
				}
				
				if (mStyleAlert != nil)
				{
					[mStyleAlert release];
					mStyleAlert = nil;
					mStyleAlert = [[UIActionSheet alloc] initWithTitle:windowtitle
								delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
				}
				mStyleAlert.title = windowtitle;
				[multipleChoiceArray removeAllObjects];
				while (theindex < [components count]) {
					//First one is <id>
					//Second is the text
					//Theindex is the id
					[multipleChoiceArray addObject:[components objectAtIndex:theindex]];
					[mStyleAlert addButtonWithTitle:[components objectAtIndex:theindex+1]];
					theindex = theindex + 2;
				}
				mStyleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
				//[styleAlert addButtonWithTitle:@"Cancel"]; 
				//[styleAlert showInView:self.view.superview];
				[mStyleAlert showInView:self.view];
				//[mStyleAlert release];
			}
			else if ([[components objectAtIndex:1] compare:@"EDIT"] == 0)
			{
				mTextField.hidden = NO;
			    [mTextField becomeFirstResponder];	
				//See if they passed in any text
				if ([components count] > 2)
				{
				    mTextField.text = [components objectAtIndex:2];
				}
				else {
					mTextField.text = @"";
				}
				NSTimer *atimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(onKeyboardDisplay) userInfo:nil repeats:NO];

			}
			else if ([[components objectAtIndex:1] compare:@"CLEAR"] == 0)
			{
				//Close the stylealert
				//[self actionSheet:nil clickedButtonAtIndex:10];
				[mTextField resignFirstResponder];
				mTextField.hidden = YES;
				NSLog(@"UI CLEAR occured");
				if (mStyleAlert != nil)
				{
				    [mStyleAlert dismissWithClickedButtonIndex:10 animated:YES];
				}
			}
		}
			
		//[self logMessage:msg];
	}
	else
	{
		//[self logError:@"Error converting received data into UTF-8 String"];
	}
	
	}
	@catch (id theException1) {
		NSLog(@"error occured reading data");
	} 
	@finally {
		
	}
	// Even if we were unable to write the incoming data to the log,
	// we're still going to echo it back to the client.
	//[sock writeData:data withTimeout:-1 tag:1];
	NSData *echoData = [@"ECHO\n" dataUsingEncoding:NSUTF8StringEncoding];
	[listenSocket writeData:echoData withTimeout:-1 tag:0];
}

- (void)onKeyboardDisplay
{
	//NSArray *runLoopModes = [NSArray arrayWithObjects:NSRunLoopCommonModes,NSDefaultRunLoopMode,[NSRunLoop currentRunLoop], nil]; 
	//[listenSocket setRunLoopModes:runLoopModes];
	//NSRunLoop *aLoop = [NSRunLoop currentRunLoop];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"Dismiss the alertview");
    switch (buttonIndex)
    {
		//UI<tab><id>\n
        case 0: 
		{
		    NSData *sentData = [[NSString stringWithFormat:@"UI\t%@\n", [multipleChoiceArray objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding];
			[listenSocket writeData:sentData withTimeout:-1 tag:0];
		    break;
		}
		case 1: 
		{
		    NSData *sentData = [[NSString stringWithFormat:@"UI\t%@\n", [multipleChoiceArray objectAtIndex:1]] dataUsingEncoding:NSUTF8StringEncoding];
			[listenSocket writeData:sentData withTimeout:-1 tag:0];
		    break;
		}	
		case 2: 
		{
		    NSData *sentData = [[NSString stringWithFormat:@"UI\t%@\n", [multipleChoiceArray objectAtIndex:2]] dataUsingEncoding:NSUTF8StringEncoding];
			[listenSocket writeData:sentData withTimeout:-1 tag:0];
		    break;
		}
		case 3: 
		{
		    NSData *sentData = [[NSString stringWithFormat:@"UI\t%@\n", [multipleChoiceArray objectAtIndex:3]] dataUsingEncoding:NSUTF8StringEncoding];
			[listenSocket writeData:sentData withTimeout:-1 tag:0];
		    break;
		}
		case 4: 
		{
		    NSData *sentData = [[NSString stringWithFormat:@"UI\t%@\n", [multipleChoiceArray objectAtIndex:4]] dataUsingEncoding:NSUTF8StringEncoding];
			[listenSocket writeData:sentData withTimeout:-1 tag:0];
		    break;
		}
		 	
			
    }
			
			
	
	
}

- (IBAction)hideTextBox:(id)sender
{
	NSLog(@"textbox hidden");
	///Send the text to the socket  UI<TAB><The New Text>\n
	NSData *sentData = [[NSString stringWithFormat:@"UI\t%@\n", mTextField.text] dataUsingEncoding:NSUTF8StringEncoding];
	[listenSocket writeData:sentData withTimeout:-1 tag:0];
}

// this helps dismiss the keyboard when the "Done" button is clicked
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	
	
	[mTextField resignFirstResponder];
	//Do a search now
	mTextField.hidden = YES;
	
	//Once the results come back, we populate the table with the results
	return YES;   
	
	
}

//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    [mTextField resignFirstResponder];
//}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	NSLog(@"disconnected");
	//[self logInfo:FORMAT(@"Client Disconnected: %@:%hu", [sock connectedHost], [sock connectedPort])];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	if (mTryingToConnect) return;
	mAccelMode = 0;
	[waitingView stopAnimating];
	if ([connectedSockets count] > 0)
	{
		[connectedSockets removeObject:sock];
	}
	[self.navigationController popViewControllerAnimated:YES]; 
	//[self.navigationController popToRootViewControllerAnimated:YES];
	//[self dismissModalViewControllerAnimated:YES];
	//Tell the parent to remove this view
	//[mSender removeTheChildview];
}

- (void)removeServiceFromCollection
{
	[waitingView stopAnimating];
	mTryingToConnect = NO;
	mAccelMode = 0;
	[mImageCollection removeAllObjects];
	if ([connectedSockets count] > 0)
	{
		[listenSocket disconnect];
		//[connectedSockets removeObjectAtIndex:0];
	}
}

- (void)setTheParent:(id)sender
{
	mSender = sender;
}

#pragma mark AVAudioPlayer delegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag == NO)
        NSLog(@"Playback finished unsuccessfully");
	else
	{
		NSLog(@"playback finished");
	}
    [player setCurrentTime:0.];
	//See if the loop variable is set to repeat
    //mSoundLoopIndex
	NSDictionary *itemAtIndex;
	int index;
	for (index = 0;index < [mImageCollection count];index++)
	{
		itemAtIndex = (NSDictionary *)[mImageCollection objectAtIndex:index];
		if ([[itemAtIndex objectForKey:@"name"] compare:mSoundLoopName] == 0)
		{
			//Found it
			if ([[itemAtIndex objectForKey:@"loop"] length] == 0)
			{
				//Don't loop it, just send the COMPLETE message
				[self sendSoundStatusMessage:[itemAtIndex objectForKey:@"name"] message:@"COMPLETE"];
				[self.mAudioPlayer release];
				self.mAudioPlayer.delegate = nil;
				self.mAudioPlayer = nil;
			}
			else if ([[itemAtIndex objectForKey:@"loop"] rangeOfString:@"LOOP="].length > 0)
			{
				NSInteger loopvalue = [[[itemAtIndex objectForKey:@"loop"] stringByReplacingOccurrencesOfString:@"LOOP=" withString:@""] intValue];
			    if (loopvalue > 0)
				{
					
					[self sendSoundStatusMessage:[itemAtIndex objectForKey:@"name"] message:[NSString stringWithFormat: @"LOOP_COMPLETE=%d", loopvalue]];
					loopvalue = loopvalue - 1;
					NSString *loopvalStr = [NSString stringWithFormat: @"LOOP=%d", loopvalue];
					
					//Finite # of loops, get the number of loops left and reset that number
					[mImageCollection replaceObjectAtIndex:index withObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[itemAtIndex objectForKey:@"name"], @"name",loopvalStr, @"loop",[itemAtIndex objectForKey:@"link"],@"link", nil]];					
				    [self playSoundFile:[itemAtIndex objectForKey:@"name"] filename:[itemAtIndex objectForKey:@"link"]];
				}
				else
				{
				    //Last loop, end the sound
					[self sendSoundStatusMessage:[itemAtIndex objectForKey:@"name"] message:@"COMPLETE"];
					[self.mAudioPlayer release];
					self.mAudioPlayer.delegate = nil;
					self.mAudioPlayer = nil;
				}
			}
			else {
				//Play it again Sam
				[self playSoundFile:[itemAtIndex objectForKey:@"name"] filename:[itemAtIndex objectForKey:@"link"]];
			}

			
			break;
		}
	}
	
	
	
	
}

- (void)sendSoundStatusMessage:(NSString *)resource message:(NSString *)message
{
	NSData *sentData = [[NSString stringWithFormat:@"SOUND\t%@\t%@\n", resource, message] dataUsingEncoding:NSUTF8StringEncoding];
	[listenSocket writeData:sentData withTimeout:-1 tag:0];
}

- (void)playSoundFile:(NSString *)resourcename filename:(NSString *)filename
{
	//Might need to stop an existing sound loop possibly
	mSoundLoopName = resourcename;
	
	if (self.mAudioPlayer != nil)
	{
		[self.mAudioPlayer release];
		self.mAudioPlayer.delegate = nil;
		self.mAudioPlayer = nil;
	}
	NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:filename ofType: @"mp3"];
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
	self.mAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	//self.mAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[itemAtIndex objectForKey:@"link"]] error:nil]; 
	
	[self.mAudioPlayer prepareToPlay];
	[self.mAudioPlayer setDelegate: self];
	[self.mAudioPlayer play];
	
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"ERROR IN DECODE: %@\n", error); 
}

// we will only get these notifications if playback was interrupted
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    // the object has already been paused,    we just need to update UI
    //[self updateViewForPlayerState];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    //[self startPlayback];
}


- (void)dealloc {
	[listenSocket disconnect];
	[listenSocket release];
	[connectedSockets release];
	[mStyleAlert release];
	[backgroundView release];
    [super dealloc];
}


@end
