//
//  AccelerometerController.m
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccelerometerController.h"


@implementation AccelerometerController

- (id)initWithSocketManager:(SocketManager *)sockMan {
    if ((self = [super init])) {
        socketManager = [sockMan retain];
    
        accelerationX = 0;
        accelerationY = 0;
        accelerationZ = 0;
        accelMode = 0;      //Don't send accelerometer events
        myAcceleration[0] = 0;
        myAcceleration[1] = 0;
        myAcceleration[2] = 0;
        lastX = 0;
        lastY = 0;
        lastZ = 0;
        //filterConstant = 0;
        accelFreq = ACCEL_FREQ_LOW;
    
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0/accelFreq)];
        [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    }
    
    return self;
}

- (void)startAccelerometerWithFilter:(NSString *)filter interval:(float)interval {
    fprintf(stderr, "interval: %f", interval);
    if ([filter compare:@"L"] == NSOrderedSame) {
        accelMode = 1;
		filterConstant = interval/(interval + 1/CUTOFF_FREQ);
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:interval];
    } else if ([filter compare:@"H"] == NSOrderedSame) {
        accelMode = 2;
        filterConstant = (1/CUTOFF_FREQ)/(interval + 1/CUTOFF_FREQ);
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:interval];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)pauseAccelerometer {
    accelMode = 0;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration {
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
	if (accelMode == 1) //low pass filter
	{
		accelerationX = acceleration.x * filterConstant + accelerationX * (1.0 - filterConstant);
		accelerationY = acceleration.y * filterConstant + accelerationY * (1.0 - filterConstant);
		accelerationZ = acceleration.z * filterConstant + accelerationZ * (1.0 - filterConstant);
		NSString *sentData = [NSString stringWithFormat:@"AX\t%f\t%f\t%f\n", accelerationX,accelerationY,accelerationZ];
        NSLog(@"low pass data: %@", sentData);
		[socketManager sendData:[sentData UTF8String] numberOfBytes:[sentData length]];
	}
    // keep the raw reading, to use during calibrations
    //currentRawReading = atan2(accelerationY, accelerationX);
    //End of method 1
    else if (accelMode == 2) //high pass filter
	{
		//Method 2 for high pass filter

        //Use a basic high-pass filter to remove the influence of the gravity
        myAcceleration[0] = filterConstant * (myAcceleration[0] + acceleration.x - lastX);
        myAcceleration[1] = filterConstant * (myAcceleration[1] + acceleration.y - lastY);
        myAcceleration[2] = filterConstant * (myAcceleration[2] + acceleration.z - lastZ);

		NSString *sentData = [NSString stringWithFormat:@"AX\t%f\t%f\t%f\n", myAcceleration[0],myAcceleration[1],myAcceleration[2]];
        NSLog(@"high pass data: %@", sentData);
		[socketManager sendData:[sentData UTF8String] numberOfBytes:[sentData length]];
		
        //Compute the intensity of the current acceleration 
        //length = sqrt(x * x + y * y + z * z);
        // If device is shaken, do stuff.
        //if(length >= kEraseAccelerationThreshold) //&& (CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval)) {
        //[[mainViewController mainView] aFunction];
        //lastTime = CFAbsoluteTimeGetCurrent();
        //}
    }
    
    lastX = acceleration.x;
    lastY = acceleration.y;
    lastZ = acceleration.z;
    
	//NSLog([NSString stringWithFormat: @"acceleration (x,y): %f,%f ", accelerationX,accelerationY]);
    
}

- (void)dealloc {
    NSLog(@"AccelerometerController dealloc");
    
    [UIAccelerometer sharedAccelerometer].delegate = nil;
    [socketManager release];
    [super dealloc];
}

@end
