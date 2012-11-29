//
//  CoreMotionController.m
//  CoreMotionTests
//
//  Created by Evan Cann on 5/30/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "CoreMotionController.h"

@implementation CoreMotionController

- (id)initWithSocketManager:(SocketManager *)sockMan {
    if ((self = [super init])) {
        socketManager = [sockMan retain];
        
        //Init accelerometer variables
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
        
        //Init gyroscope variables
        rotationX = 0;
        rotationY = 0;
        rotationZ = 0;
        
        //Init magnetometer variables
        fieldX = 0;
        fieldY = 0;
        fieldZ = 0;
        
        //Init device motion variables
        roll = 0;
        pitch = 0;
        yaw = 0;
        
        //Create the NSOperationQueue to run CoreMotion
        motionQueue = [[NSOperationQueue mainQueue] retain];
        
        //Create a CMMotionManager to access accelerometer and gyroscope; set default update intervals
        motionManager = [[CMMotionManager alloc] init];
        motionManager.accelerometerUpdateInterval = (1.0/accelFreq);
        motionManager.gyroUpdateInterval = (1.0/accelFreq);
        motionManager.magnetometerUpdateInterval = (1.0/accelFreq);
        motionManager.deviceMotionUpdateInterval = (1.0/accelFreq);
    }
    
    return self;
}

#pragma mark -
#pragma mark Accelerometer Methods

- (void)startAccelerometerWithFilter:(NSString *)filter interval:(float)interval {
    fprintf(stderr, "interval: %f", interval);
    if ([filter compare:@"L"] == NSOrderedSame) {
        accelMode = 1;
		filterConstant = interval/(interval + 1/CUTOFF_FREQ);
        motionManager.accelerometerUpdateInterval = interval;
    } 
    else if ([filter compare:@"H"] == NSOrderedSame) {
        accelMode = 2;
        filterConstant = (1/CUTOFF_FREQ)/(interval + 1/CUTOFF_FREQ);
        motionManager.accelerometerUpdateInterval = interval;
    }
    
    //Tell the motion manager to start accelerometer updates in the motionQueue
    [motionManager startAccelerometerUpdatesToQueue:motionQueue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
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
            accelerationX = accelerometerData.acceleration.x * filterConstant + accelerationX * (1.0 - filterConstant);
            accelerationY = accelerometerData.acceleration.y * filterConstant + accelerationY * (1.0 - filterConstant);
            accelerationZ = accelerometerData.acceleration.z * filterConstant + accelerationZ * (1.0 - filterConstant);
            NSString *sentData = [NSString stringWithFormat:@"AX\t%f\t%f\t%f\n", accelerationX,accelerationY,accelerationZ];
            //NSLog(@"low pass data: %@", sentData);
            [socketManager sendData:[sentData UTF8String] numberOfBytes:[sentData length]];
        }
        // keep the raw reading, to use during calibrations
        //currentRawReading = atan2(accelerationY, accelerationX);
        //End of method 1
        else if (accelMode == 2) //high pass filter
        {
            //Method 2 for high pass filter
            
            //Use a basic high-pass filter to remove the influence of the gravity
            myAcceleration[0] = filterConstant * (myAcceleration[0] + accelerometerData.acceleration.x - lastX);
            myAcceleration[1] = filterConstant * (myAcceleration[1] + accelerometerData.acceleration.y - lastY);
            myAcceleration[2] = filterConstant * (myAcceleration[2] + accelerometerData.acceleration.z - lastZ);
            
            NSString *sentData = [NSString stringWithFormat:@"AX\t%f\t%f\t%f\n", myAcceleration[0],myAcceleration[1],myAcceleration[2]];
            //NSLog(@"high pass data: %@", sentData);
            [socketManager sendData:[sentData UTF8String] numberOfBytes:[sentData length]];
            
            //Compute the intensity of the current acceleration 
            //length = sqrt(x * x + y * y + z * z);
            // If device is shaken, do stuff.
            //if(length >= kEraseAccelerationThreshold) //&& (CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval)) {
            //[[mainViewController mainView] aFunction];
            //lastTime = CFAbsoluteTimeGetCurrent();
            //}
        }
        
        lastX = accelerometerData.acceleration.x;
        lastY = accelerometerData.acceleration.y;
        lastZ = accelerometerData.acceleration.z;
        
        //NSLog([NSString stringWithFormat: @"acceleration (x,y): %f,%f ", accelerationX,accelerationY]);

    }];
}

- (void)pauseAccelerometer {
    accelMode = 0;
    [motionManager stopAccelerometerUpdates];
}

#pragma mark -
#pragma mark Gyroscope Methods

- (void) startGyroscopeWithInterval:(float)interval { 
    fprintf(stderr, "interval: %f", interval);
    motionManager.gyroUpdateInterval = interval;
    
    //Tell the motion manager to start gyroscope updates in the motionQueue
    [motionManager startGyroUpdatesToQueue:motionQueue withHandler:^(CMGyroData *gyroData, NSError *error) {
        //Insert Gyroscope Handler code here!
        rotationX = gyroData.rotationRate.x;
        rotationY = gyroData.rotationRate.y;
        rotationZ = gyroData.rotationRate.z;
        
        NSString *sentData = [NSString stringWithFormat:@"GY\t%f\t%f\t%f\n", rotationX,rotationY,rotationZ];
        //NSLog(@"Gyro Data: %@", sentData);
        [socketManager sendData:[sentData UTF8String] numberOfBytes:[sentData length]];
    }];
}

- (void)pauseGyroscope {
    [motionManager stopGyroUpdates];
}

#pragma mark -
#pragma mark Magnetometer Methods

- (void) startMagnetometerWithInterval:(float)interval {
    fprintf(stderr, "interval: %f", interval);
    motionManager.magnetometerUpdateInterval = interval;
    
    //Tell the motion manager to start magnetometer updates in the motionQueue
    [motionManager startMagnetometerUpdatesToQueue:motionQueue withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
        //Insert Magnetometer Handler code here!
        fieldX = magnetometerData.magneticField.x;
        fieldY = magnetometerData.magneticField.y;
        fieldZ = magnetometerData.magneticField.z;
        
        NSString *sentData = [NSString stringWithFormat:@"MM\t%f\t%f\t%f\n", fieldX,fieldY,fieldZ];
        //NSLog(@"Magnet Data: %@", sentData);
        [socketManager sendData:[sentData UTF8String] numberOfBytes:[sentData length]];
    }];
}

- (void)pauseMagnetometer {
    [motionManager stopMagnetometerUpdates];
}

#pragma mark -
#pragma mark Device Motion Methods

- (void) startDeviceMotionWithInterval:(float)interval {
    fprintf(stderr, "interval: %f", interval);
    motionManager.deviceMotionUpdateInterval = interval;
    
    //Tell the motion manager to start device motion updates in the motionQueue
    [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical toQueue:motionQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {
        //Insert Device Motion Handler code here!
        roll = motion.attitude.roll;
        pitch = motion.attitude.pitch;
        yaw = motion.attitude.yaw;
        
        NSString *sentData = [NSString stringWithFormat:@"AT\t%f\t%f\t%f\n", roll,pitch,yaw];
        //NSLog(@"DevMo Data: %@", sentData);
        [socketManager sendData:[sentData UTF8String] numberOfBytes:[sentData length]];
    }];
}

- (void) pauseDeviceMotion {
    [motionManager stopDeviceMotionUpdates];
}


- (void) dealloc {
    [motionManager release];
    [motionQueue release], motionQueue = nil;
    [socketManager release];
    [super dealloc];
}

@end
