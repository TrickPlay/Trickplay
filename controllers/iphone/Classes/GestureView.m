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
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>

// Constant for the number of times per second (Hertz) to sample acceleration.
#define kAccelerometerFrequency         40  //Try 60 for high pass
#define kFilteringFactor				0.1
#define kMinEraseInterval				0.5
#define kEraseAccelerationThreshold		2.0

#define HORIZ_SWIPE_DRAG_MIN  25  //Was 20
#define VERT_SWIPE_DRAG_MAX    10
#define TAP_DISTANCE_MAX    4
#define SOCKET_MODE_IPHONE4 1
#define SOCKET_MODE_LEGACY 2

@interface GestureView(PrivateInterface)
- (void)sendKeyToTrickplay:(NSString *)thekey thecount:(NSInteger)thecount;
- (void)ClearUIElements;
@end

@interface GestureView(AVAudioPlayerDelegates)
- (void)playSoundFile:(NSString *)resourcename filename:(NSString *)filename;
- (void)createAudioStreamer:(NSString *)audioURL;
- (void)destroyAudioStreamer;
@end

@implementation GestureView

@dynamic mSender;
@synthesize mTouchedTime;
@synthesize waitingView;
@synthesize mStyleAlert;
@synthesize mTextField;
@synthesize backgroundView;
@synthesize mResourceNameCollection;
@synthesize mAudioPlayer;
@synthesize mSoundLoopName;
@synthesize mResourceDataCollection;

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
	
	mSocketMode = SOCKET_MODE_LEGACY;
	
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
	mResourceNameCollection = [[NSMutableArray alloc] init];
	mResourceDataCollection = [[NSMutableArray alloc] init];

	UIBarButtonItem *exitItem = [[[UIBarButtonItem alloc]
									initWithTitle:NSLocalizedString(@"Exit", @"") style:UIBarButtonItemStyleBordered
									target:self action:@selector(exitAppAction:)] autorelease]; 
	self.navigationItem.rightBarButtonItem = exitItem;

	backgroundView.image = [UIImage imageNamed:@"background.png"];

}

- (void)exitAppAction:(id)sender
{
	//Send Escape key to exit whatever app is currently running
	[self sendKeyToTrickplay:@"FF1B" thecount:1];
}

- (void)setupService:(NSInteger)port  hostname:(NSString *)hostname thetitle:(NSString *)thetitle
{
	if(port < 0 || port > 65535)
	{
		port = 0;
	}
	
	NSError *error = nil;
	self.title = thetitle;
	
	mTryingToConnect = YES;
	if (mSocketMode == SOCKET_MODE_LEGACY)
	{
		[listenSocket connectToHost:hostname onPort:port error:&error ];
		//[self logInfo:FORMAT(@"Echo server started on port %hu", [listenSocket localPort])];
		[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(onTimeout) userInfo:nil repeats:NO];
		[waitingView startAnimating];
	}
	else {
		[NSStream getStreamsToHostNamed:hostname 
								   port:port 
							inputStream:&iStream
						   outputStream:&oStream];            
		[iStream retain];
		[oStream retain];
		
		[iStream setDelegate:self];
		[oStream setDelegate:self];
		
		[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
						   forMode:NSDefaultRunLoopMode];
		[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
						   forMode:NSDefaultRunLoopMode];
		
		[connectedSockets addObject:oStream];
		
		[oStream open];
		[iStream open];   
		
		CGRect mainframe = [[UIScreen mainScreen] applicationFrame];
		NSInteger theheight = mainframe.size.height;
		theheight = theheight - 45;  //subtract the height of navbar
		NSInteger thewidth = mainframe.size.width;
		
		NSString *welcomeData = [NSString stringWithFormat:@"ID\t2\t%@\tKY\tAX\tCK\tTC\tMC\tSD\tUI\tTE\tIS=%dx%d\tUS=%dx%d\n",[UIDevice currentDevice].name,thewidth,theheight,thewidth,theheight ];
		[self sendDataToSocket:welcomeData];
		
		[waitingView stopAnimating];
		
		//The connect process using this method does not have an "onConnect" method that I am aware of
		//So just assume the connection was made successfully
		
	}

	
	

}

- (void)onTimeout
{
	@try {
		
  	   if ([connectedSockets count] == 0)
	   {
		   if (mSocketMode == SOCKET_MODE_LEGACY)
		   {
			   [listenSocket disconnect];
			   [connectedSockets removeObject:listenSocket];
		   }else {
			   [iStream close];
			   [oStream close];
			   [connectedSockets removeObjectAtIndex:0];
		   }

		   mAccelMode = 0;
		   
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

- (void)sendDataToSocket:(NSString *)sentData
{
    if (mSocketMode == SOCKET_MODE_LEGACY)
	{
		[listenSocket writeData:[sentData dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
	}
	else {
		//const uint8_t *str = (uint8_t *) [sentData cStringUsingEncoding:NSASCIIStringEncoding];
		const uint8_t *str = (uint8_t *) [sentData UTF8String];
		[oStream write:str maxLength:strlen((char*)str)]; 
		//[self writeToServer:str];
		
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
		NSString *sentData = [NSString stringWithFormat:@"AX\t%f\t%f\t%f\n", accelerationX,accelerationY,accelerationZ];
		[self sendDataToSocket:sentData];
		
		
	}
    // keep the raw reading, to use during calibrations
    //currentRawReading = atan2(accelerationY, accelerationX);
    //End of method 1
    else if (mAccelMode == 2) //high pass filter
	{
		//Method 2 for high pass filter
		UIAccelerationValue
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
		NSString *sentData = [NSString stringWithFormat:@"AX\t%f\t%f\t%f\n", myAcceleration[0],myAcceleration[1],myAcceleration[2]];
		[self sendDataToSocket:sentData];
		
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
		NSString *sentTouchData = [NSString stringWithFormat:@"TD\t%f\t%f\t%f\n", currentTouchPosition.x,currentTouchPosition.y,mTouchedTime];
		[self sendDataToSocket:sentTouchData];
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
	UITouch *touch = [touches anyObject];
    currentTouchPosition = [touch locationInView:self.view];
	
	//Send the TOUCHMOVE event if enabled
	if (([connectedSockets count] > 0) && mTouchEventsAllowed)
	{
		NSString *sentTouchData = [NSString stringWithFormat:@"TM\t%f\t%f\t%f\n", currentTouchPosition.x,currentTouchPosition.y,[NSDate timeIntervalSinceReferenceDate]];
		[self sendDataToSocket:sentTouchData];
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
			NSLog(@"swipe speed horiz :%f ",[NSDate timeIntervalSinceReferenceDate]  - mTouchedTime);
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
			NSLog(@"swipe speed vertical:%f ",[NSDate timeIntervalSinceReferenceDate]  - mTouchedTime);
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
		NSString *sentTouchData = [NSString stringWithFormat:@"TU\t%f\t%f\t%f\n", currentTouchPosition.x,currentTouchPosition.y,[NSDate timeIntervalSinceReferenceDate]];
		[self sendDataToSocket:sentTouchData];
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
				NSString *sentClickData = [NSString stringWithFormat:@"CK\t%f\t%f\t%f\n", currentTouchPosition.x,currentTouchPosition.y,[NSDate timeIntervalSinceReferenceDate]];
				[self sendDataToSocket:sentClickData];
			}
		}
		else
		{
			NSLog(@"no swipe sent, start.x,.y:%f , %f  current.x,.y:%f , %f",startTouchPosition.x,startTouchPosition.y,currentTouchPosition.x,currentTouchPosition.y);
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
		NSString *sentData = [NSString stringWithFormat:@"KP\t%@\n", thekey];

		for (index = 1; index <= thecount; index++) {
			[self sendDataToSocket:sentData];
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
	//[self logInfo:FORMAT(@"Accepted client %@:%hu", host, port)]; //320x410
	//Get the actual width and height of the available area
	CGRect mainframe = [[UIScreen mainScreen] applicationFrame];
	NSInteger theheight = mainframe.size.height;
	theheight = theheight - 45;  //subtract the height of navbar
	NSInteger thewidth = mainframe.size.width;
	NSData *welcomeData = [[NSString stringWithFormat:@"ID\t2\t%@\tKY\tAX\tCK\tTC\tMC\tSD\tUI\tTE\tIS=%dx%d\tUS=%dx%d\n",[UIDevice currentDevice].name,thewidth,theheight,thewidth,theheight ] dataUsingEncoding:NSUTF8StringEncoding];
	
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

//Socket read occured
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    
    switch(eventCode) {
        case NSStreamEventHasBytesAvailable:
        {
            if (data == nil) {
                data = [[NSMutableData alloc] init];
            }
            uint8_t buf[1024];
            unsigned int len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:1024];
            if(len) {    
                [data appendBytes:(const void *)buf length:len];
                int bytesRead;
                bytesRead += len;
            } else {
                NSLog(@"No data.");
            }
            
            NSString *str = [[NSString alloc] initWithData:data 
												  encoding:NSUTF8StringEncoding];
            NSLog(str);
		    [self onSocket:nil didReadData:[str dataUsingEncoding:NSUTF8StringEncoding] withTag:0];
            [str release];
            [data release];        
            data = nil;
        } break;
    }
}


- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	@try {
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 1)];
	NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
	if(msg)
	{
		//NSLog(msg);
//		msg = [ msg stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%C", 9] withString:@"<<TAB>>"];
		//NSLog(msg);
		if ([msg hasPrefix:@"SA"])
		{
			NSArray *components = [msg componentsSeparatedByString:@"\t"];
			
			if ([(NSString *)[components objectAtIndex:1] compare:@"L"] == 0)
			{
					mAccelMode = 1;
					[[UIAccelerometer sharedAccelerometer] setUpdateInterval:[[components objectAtIndex:2] floatValue]];
			}
			else if ([(NSString *)[components objectAtIndex:1] compare:@"H"] == 0)
			{
					mAccelMode = 2;
					[[UIAccelerometer sharedAccelerometer] setUpdateInterval:[[components objectAtIndex:2] floatValue]];
			}
			
		}
		else if ([msg hasPrefix:@"PA"])
		{
			mAccelMode = 0;
		}
		else if ([msg hasPrefix:@"SC"])
		{
			mClickEventsAllowed = YES;
		}
		else if ([msg hasPrefix:@"PC"])
		{
			mClickEventsAllowed = NO;
		}
		else if ([msg hasPrefix:@"ST"])
		{
			mTouchEventsAllowed = YES;
		}
		else if ([msg hasPrefix:@"PT"])
		{
			mTouchEventsAllowed = NO;
		}
		else if ([msg hasPrefix:@"RT"])  //Reset
		{
			mAccelMode = 0;
			[self ClearUIElements];
		}
		else if ([msg hasPrefix:@"DR"])
		{
			//http://downloads.flashkit.com/soundfx/Ambience/Space/Space_-SLrec-7832/Space_-SLrec-7832_hifi.mp3
			NSArray *components = [msg componentsSeparatedByString:@"\t"];
			[mResourceNameCollection addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[components objectAtIndex:1], @"name", [components objectAtIndex:2], @"link", @"", @"scale", nil]];
			//Download the asset to a local copy as a NSData
			//[[NSMutableData alloc] initWithLength:0];
			//	NSURLRequest *theRequest= [NSURLRequest requestWithURL:[NSURL URLWithString:aURL]];
			//  NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];

			//[mResourceDataCollection addObject:
		}
		else if ([msg hasPrefix:@"UB"])
		{
			NSArray *components = [msg componentsSeparatedByString:@"\t"];
			if ([mResourceNameCollection count] > 0)
			{
				//Show the image
				unsigned index;
				NSDictionary *itemAtIndex;
				for (index = 0;index < [mResourceNameCollection count];index++)
				{
					itemAtIndex = (NSDictionary *)[mResourceNameCollection objectAtIndex:index];
					if ([[itemAtIndex objectForKey:@"name"] compare:[components objectAtIndex:1]] == 0)
					{
						//[NSURL URLWithString:aURL]
						//NSData *data = [NSData dataWithContentsOfURL:url];
						//@"http://images.apple.com/home/images/ipad_headline_20100127.png"
						NSString *imageurl = [itemAtIndex objectForKey:@"link"];
						UIImage *tempImage;
						if ([imageurl hasPrefix:@"http:"] || [imageurl hasPrefix:@"https:"])
						{
							tempImage = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageurl]]] autorelease];
						}
						else {
							//Use the hostname and port to construct the url
							
							//NSString *urlstr = [itemAtIndex objectForKey:@"link"]
							tempImage = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/%@", [listenSocket connectedHost],[listenSocket connectedPort],[itemAtIndex objectForKey:@"link"]]]]] autorelease];
						}
						backgroundView.image = tempImage;
					}
				}				
			}
			
			
		}
		else if ([msg hasPrefix:@"UG"])
		{
			NSArray *components = [msg componentsSeparatedByString:@"\t"];
			if ([mResourceNameCollection count] > 0)
			{
				//Show the image
				unsigned index;
				NSDictionary *itemAtIndex;
				for (index = 0;index < [mResourceNameCollection count];index++)
				{
					itemAtIndex = (NSDictionary *)[mResourceNameCollection objectAtIndex:index];
					if ([[itemAtIndex objectForKey:@"name"] compare:[components objectAtIndex:1]] == 0)
					{
						//[NSURL URLWithString:aURL]
						//NSData *data = [NSData dataWithContentsOfURL:url];
						//@"http://images.apple.com/home/images/ipad_headline_20100127.png"
						NSString *imageurl = [itemAtIndex objectForKey:@"link"];
						UIImage *tempImage;
						if ([imageurl hasPrefix:@"http:"] || [imageurl hasPrefix:@"https:"])
						{
							tempImage = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageurl]]] autorelease];
						}
						else {
							//Use the hostname and port to construct the url
							
							//NSString *urlstr = [itemAtIndex objectForKey:@"link"]
							tempImage = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/%@", [listenSocket connectedHost],[listenSocket connectedPort],[itemAtIndex objectForKey:@"link"]]]]] autorelease];
						}
						// Now we have the image, we need to draw it
						CGFloat
							x = [[components objectAtIndex:2] floatValue],
							y = [[components objectAtIndex:3] floatValue],
							width = [[components objectAtIndex:4] floatValue],
							height = [[components	objectAtIndex:5] floatValue];
						
						// create a new bitmap image context
						//
						CGRect mainframe = [[UIScreen mainScreen] applicationFrame];

						UIGraphicsBeginImageContext(CGSizeMake(mainframe.size.width, mainframe.size.height));		
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
						[backgroundView.image drawInRect:CGRectMake(0,0,mainframe.size.width, mainframe.size.height)];
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
					}
				}
			}
			
			
		}
		else if ([msg hasPrefix:@"SS"])
		{
			NSArray *components = [msg componentsSeparatedByString:@"\t"];
			if ([mResourceNameCollection count] > 0)
			{
				unsigned index;
				NSDictionary *itemAtIndex;
				for (index = 0;index < [mResourceNameCollection count];index++)
				{
					itemAtIndex = (NSDictionary *)[mResourceNameCollection objectAtIndex:index];
                    NSString *soundname = [itemAtIndex objectForKey:@"name"];
					if ([soundname compare:[components objectAtIndex:1]] == 0)
					{
						NSString *soundurl = [itemAtIndex objectForKey:@"link"];
						[self playSoundFile:soundname filename:soundurl];	
					
						//Loop parameter
						NSString *loopvalue = [components objectAtIndex:2];
						[mResourceNameCollection replaceObjectAtIndex:index withObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:soundname, @"name",loopvalue, @"loop",soundurl,@"link", nil]];
						
						break;
					}
				}
				

			}
		}
		else if ([msg hasPrefix:@"PS"])
		{
			[self destroyAudioStreamer];
		}
		else if ([msg hasPrefix:@"CU"])
		{
			[self ClearUIElements];
		}
		else if ([msg hasPrefix:@"MC"])
		{
			NSArray *components = [msg componentsSeparatedByString:@"\t"];
			NSString *windowtitle = [components objectAtIndex:1];
			//multiple choice alertview
			//<id>,<text> pairs
			unsigned theindex = 2;
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
		else if ([msg hasPrefix:@"ET"])
		{
			NSArray *components = [msg componentsSeparatedByString:@"\t"];
			mTextField.hidden = NO;
			[mTextField becomeFirstResponder];	
			//See if they passed in any text
			//Label is at index 1
			if ([components count] > 2)
			{
				mTextField.text = [components objectAtIndex:2];
			}
			else {
				mTextField.text = @"";
			}
			[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(onKeyboardDisplay) userInfo:nil repeats:NO];
			
		}
		
			
		
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
	NSString *echoData = @"ECHO\n";
	[self sendDataToSocket:echoData];
}

- (void)ClearUIElements
{
	[mTextField resignFirstResponder];
	mTextField.hidden = YES;
	NSLog(@"UI CLEAR occured");
	if (mStyleAlert != nil)
	{
		[mStyleAlert dismissWithClickedButtonIndex:10 animated:YES];
	}
	//Clear the background and revert to default trickplay logo
	backgroundView.image = [UIImage imageNamed:@"background.png"];
	
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
	if (buttonIndex < 5)
	{
		NSString *sentData = [NSString stringWithFormat:@"UI\t%@\n", [multipleChoiceArray objectAtIndex:buttonIndex]];
		[self sendDataToSocket:sentData];
	}
    
	
}

- (IBAction)hideTextBox:(id)sender
{
	NSLog(@"textbox hidden");
	///Send the text to the socket  UI<TAB><The New Text>\n
	NSString *sentData = [NSString stringWithFormat:@"UI\t%@\n", mTextField.text];
	[self sendDataToSocket:sentData];
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
	[self ClearUIElements];
	if ([connectedSockets count] > 0)
	{
		[connectedSockets removeObject:sock];
	}
	[self.navigationController popViewControllerAnimated:YES]; 
	
}

- (void)removeServiceFromCollection
{
	[waitingView stopAnimating];
	mTryingToConnect = NO;
	mAccelMode = 0;
	[mResourceNameCollection removeAllObjects];
	[mResourceDataCollection removeAllObjects];
	if ([connectedSockets count] > 0)
	{
		[listenSocket disconnect];
	}
}

- (void)setTheParent:(id)sender
{
	mSender = sender;
}

#pragma mark AVAudioPlayer delegate methods



- (void)sendSoundStatusMessage:(NSString *)resource message:(NSString *)message
{
	//NSData *sentData = [[NSString stringWithFormat:@"SOUND\t%@\t%@\n", resource, message] dataUsingEncoding:NSUTF8StringEncoding];
	//[listenSocket writeData:sentData withTimeout:-1 tag:0];
}

- (void)playSoundFile:(NSString *)resourcename filename:(NSString *)filename
{
	//Might need to stop an existing sound loop possibly
	mSoundLoopName = resourcename;
	
	
	if ([filename hasPrefix:@"http:"] || [filename hasPrefix:@"https:"])
	{
		//NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:filename ofType: @"mp3"];
		//NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
		//self.mAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
		[self createAudioStreamer:filename];
	}
	else
	{
		[self createAudioStreamer:[NSString stringWithFormat:@"http://%@:%d/%@", [listenSocket connectedHost],[listenSocket connectedPort],filename]];
		//NSURL *fileURL = [NSURL URLWithString:];
		//self.mAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
		//NSLog([fileURL absoluteString]);
	}
	//self.mAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[itemAtIndex objectForKey:@"link"]] error:nil]; 
	
	
	
}



- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
		
	}
	else if ([streamer isPlaying])
	{
		
	}
	else if ([streamer isIdle])
	{
		//[self destroyStreamer];
		NSDictionary *itemAtIndex;
		unsigned index;
		for (index = 0;index < [mResourceNameCollection count];index++)
		{
			itemAtIndex = (NSDictionary *)[mResourceNameCollection objectAtIndex:index];
			if ([(NSString *)[itemAtIndex objectForKey:@"name"] compare:mSoundLoopName] == 0)
			{
				//Found it
				if ([(NSString *)[itemAtIndex objectForKey:@"loop"] compare:@"0"] == 0) {
					//Play it again Sam, forever
					[self playSoundFile:[itemAtIndex objectForKey:@"name"] filename:[itemAtIndex objectForKey:@"link"]];
				}
				else
				{
					NSInteger loopvalue = [[itemAtIndex objectForKey:@"loop"] intValue];
					
					if (loopvalue > 1)
					{
						
						[self sendSoundStatusMessage:[itemAtIndex objectForKey:@"name"] message:[NSString stringWithFormat: @"LOOP_COMPLETE=%d", loopvalue]];
						loopvalue = loopvalue - 1;
						NSString *loopvalStr = [NSString stringWithFormat: @"%d", loopvalue];
						[self playSoundFile:[itemAtIndex objectForKey:@"name"] filename:[itemAtIndex objectForKey:@"link"]];
						//Finite # of loops, get the number of loops left and reset that number
						[mResourceNameCollection replaceObjectAtIndex:index withObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[itemAtIndex objectForKey:@"name"], @"name",loopvalStr, @"loop",[itemAtIndex objectForKey:@"link"],@"link", nil]];					
						
					}
					else
					{
						//Last loop, end the sound
						[self sendSoundStatusMessage:[itemAtIndex objectForKey:@"name"] message:@"COMPLETE"];
						[self destroyAudioStreamer];
					}
				}
				
				break;
			}
		} //End of imagecollection for
		
	}
}
- (void)createAudioStreamer:(NSString *)audioURL
{
	if (streamer)
	{
        [self destroyAudioStreamer];
	}
	
	NSURL *url = [NSURL URLWithString:audioURL];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
	 selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:streamer];
	[streamer start];
}
- (void)destroyAudioStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:streamer];
		
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}

- (void)dealloc {
	[self destroyAudioStreamer];
	if (mSocketMode == SOCKET_MODE_LEGACY)
	{
	    [listenSocket disconnect];
	    [listenSocket release];
	}
	else {
		[iStream release];
		[oStream release];
		
		if (iStream) CFRelease(iStream);
		if (oStream) CFRelease(oStream);
	}

	[connectedSockets release];
	[mStyleAlert release];
	[backgroundView release];
    [super dealloc];
}


@end
