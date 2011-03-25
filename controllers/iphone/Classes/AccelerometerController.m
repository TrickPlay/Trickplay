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
        myAcceleration[1] = 0;
        myAcceleration[2] = 0;
        myAcceleration[3] = 0;
        accelFreq = ACCEL_FREQ_LOW;
    
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0/accelFreq)];
        [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    }
    
    return self;
}

- (void)startAccelerometerWithFilter:(NSString *)filter interval:(float)interval {
    if ([filter compare:@"L"] == NSOrderedSame) {
        accelMode = 1;
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:interval];
    } else if ([filter compare:@"H"] == NSOrderedSame) {
        accelMode = 2;
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:interval];
    }
}

- (void)pauseAccelerometer {
    accelMode = 0;
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
		accelerationX = acceleration.x * FILTERING_FACTOR + accelerationX * (1.0 - FILTERING_FACTOR);
		accelerationY = acceleration.y * FILTERING_FACTOR + accelerationY * (1.0 - FILTERING_FACTOR);
		accelerationZ = acceleration.z * FILTERING_FACTOR + accelerationZ * (1.0 - FILTERING_FACTOR);
		NSString *sentData = [NSString stringWithFormat:@"AX\t%f\t%f\t%f\n", accelerationX,accelerationY,accelerationZ];
		[socketManager sendData:[sentData UTF8String] numberOfBytes:[sentData length]];
		
		
	}
    // keep the raw reading, to use during calibrations
    //currentRawReading = atan2(accelerationY, accelerationX);
    //End of method 1
    else if (accelMode == 2) //high pass filter
	{
		//Method 2 for high pass filter
		UIAccelerationValue x, y, z;
        
        //Use a basic high-pass filter to remove the influence of the gravity
        myAcceleration[0] = acceleration.x * FILTERING_FACTOR + myAcceleration[0] * (1.0 - FILTERING_FACTOR);
        myAcceleration[1] = acceleration.y * FILTERING_FACTOR + myAcceleration[1] * (1.0 - FILTERING_FACTOR);
        myAcceleration[2] = acceleration.z * FILTERING_FACTOR + myAcceleration[2] * (1.0 - FILTERING_FACTOR);
        // Compute values for the three axes of the acceleromater
        x = acceleration.x - myAcceleration[0];
        y = acceleration.y - myAcceleration[1];
        z = acceleration.z - myAcceleration[2];
		NSString *sentData = [NSString stringWithFormat:@"AX\t%f\t%f\t%f\n", myAcceleration[0],myAcceleration[1],myAcceleration[2]];
		[socketManager sendData:[sentData UTF8String] numberOfBytes:[sentData length]];
		
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

- (void)dealloc {
    [UIAccelerometer sharedAccelerometer].delegate = nil;
    [socketManager release];
    [super dealloc];
}

@end
