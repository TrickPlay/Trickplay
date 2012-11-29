//
//  CoreMotionController.h
//  CoreMotionTests
//
//  Created by Evan Cann on 5/30/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "TPAppViewController.h"
#import "SocketManager.h"
#import "Protocols.h"

// Constant for the number of times per second (Hertz) to sample acceleration.
#define ACCEL_FREQ_LOW          40
#define FILTERING_FACTOR		0.5
#define MIN_ERASE_INTERVAL      0.5
#define ERASE_ACCEL_THRESHOLD   2.0
#define CUTOFF_FREQ             5.0

@interface CoreMotionController : NSObject {
    
    //Accelerometer variables
    double accelerationY;
    double accelerationX;
    double accelerationZ;
    double myAcceleration[3];
    double lastX, lastY, lastZ;
    double filterConstant;
    NSInteger accelMode;
    NSInteger accelFreq;
    
    //Gyroscope variables
    double rotationX;
    double rotationY;
    double rotationZ;
    
    //Magnetometer variables
    double fieldX;
    double fieldY;
    double fieldZ;
    
    //Device motion variables
    double roll;
    double pitch;
    double yaw;
    
    NSOperationQueue *motionQueue;
    CMMotionManager *motionManager;
    
    SocketManager *socketManager;
}

- (id)initWithSocketManager:(SocketManager *)sockMan;

- (void)startAccelerometerWithFilter:(NSString *)filter interval:(float)interval;
- (void)pauseAccelerometer;

- (void) startGyroscopeWithInterval:(float)interval;
- (void)pauseGyroscope;

- (void) startMagnetometerWithInterval:(float)interval;
- (void)pauseMagnetometer;

- (void) startDeviceMotionWithInterval:(float)interval;
- (void)pauseDeviceMotion;

@end
