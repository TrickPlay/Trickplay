//
//  AccelerometerController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GestureViewController.h"

// Constant for the number of times per second (Hertz) to sample acceleration.
#define ACCEL_FREQ_LOW          40  //Try 60 for high pass
#define FILTERING_FACTOR		0.1
#define MIN_ERASE_INTERVAL      0.5
#define ERASE_ACCEL_THRESHOLD   2.0

@interface AccelerometerController : NSObject <ViewControllerAccelerometerDelegate,
UIAccelerometerDelegate> {
    UIAccelerationValue accelerationY;
    UIAccelerationValue accelerationX;
    UIAccelerationValue accelerationZ;
    UIAccelerationValue myAcceleration[3];
    NSInteger accelMode;
    NSInteger accelFreq;
    
    SocketManager *socketManager;
}

- (id)initWithSocketManager:(SocketManager *)sockMan;

- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration;

@end
