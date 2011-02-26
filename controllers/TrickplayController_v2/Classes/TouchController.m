//
//  TouchController.m
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TouchController.h"


@implementation TouchController

@synthesize view;
@synthesize socketManager;

- (id)initWithView:aView socketManager:(SocketManager *)sockman {
    if (self = [super init]) {
        self.view = aView;
        self.socketManager = sockman;
        touchEventsAllowed = NO;
        clickEventsAllowed = YES;
        swipeSent = NO;
        keySent = NO;
        activeTouches = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return self;
}

- (void)sendKeyToTrickplay:(NSString *)thekey thecount:(NSInteger)thecount {
	if (socketManager)
	{
	    int index;	
		NSString *sentData = [NSString stringWithFormat:@"KP\t%@\n", thekey];
        
		for (index = 1; index <= thecount; index++) {
			[socketManager sendData:[sentData UTF8String]
                      numberOfBytes:[sentData length]];
		}
		
		keySent = YES;
	}
	//return NO;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([view isMultipleTouchEnabled]) {
        //NSMutableArray *newActiveTouches = [NSMutableArray arrayWithArray:[touches allObjects]];
        
    } else {
        UITouch *touch = [touches anyObject];
        startTouchPosition = [touch locationInView:view];
        currentTouchPosition = startTouchPosition;
        keySent = NO;
        NSLog(@"touches began");
        touchedTime = [NSDate timeIntervalSinceReferenceDate];
        if (socketManager && touchEventsAllowed) {
            NSString *sentTouchData = [NSString stringWithFormat:@"TD\t%f\t%f\t%f\t%f\n", 1, currentTouchPosition.x, currentTouchPosition.y, touchedTime];
            [socketManager sendData:[sentTouchData UTF8String] numberOfBytes:[sentTouchData length]];
        }
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    currentTouchPosition = [touch locationInView:view];
    
    if (socketManager && touchEventsAllowed) {
        NSString *sentTouchData = [NSString stringWithFormat:@"TM\t%f\t%f\t%f\t%f\n", 1, currentTouchPosition.x, currentTouchPosition.y, [NSDate timeIntervalSinceReferenceDate]];
        [socketManager sendData:[sentTouchData UTF8String] numberOfBytes:[sentTouchData length]];
    }
    
    if (keySent) return;
    
    int numSwipes = 1;    
    //Horizontal swipe
    // To be a swipe, direction of touch must be horizontal and long enough.
    //if (fabsf(startTouchPosition.x - currentTouchPosition.x) >= HORIZ_SWIPE_DRAG_MIN &&
    //    fabsf(startTouchPosition.y - currentTouchPosition.y) <= VERT_SWIPE_DRAG_MAX)
    if ((fabsf(startTouchPosition.x - currentTouchPosition.x) >= HORIZ_SWIPE_DRAG_MIN)) {
        if (touchedTime > 0) {
            NSLog(@"swipe speed horiz :%f ", [NSDate timeIntervalSinceReferenceDate] - touchedTime);
            if (touchedTime > 0) {
                NSLog(@"swipe speed horiz :%f ",[NSDate timeIntervalSinceReferenceDate]  - touchedTime);
                if (([NSDate timeIntervalSinceReferenceDate]  - touchedTime) < 0.05)
                {
                    //numSwipes = 3;
                }
                else if (([NSDate timeIntervalSinceReferenceDate]  - touchedTime) < 0.1)
                {
                    //numSwipes = 2;
                }
            }
            // It appears to be a swipe.
            if (startTouchPosition.x < currentTouchPosition.x)
            {
                //Send right key -  FF53
                NSLog(@"swipe right");
                keySent = YES;
                [self sendKeyToTrickplay:@"FF53" thecount:numSwipes];
            }
            else
            {
                //Send left key  - FF51
                NSLog(@"Swipe Left");
                keySent = YES;
                [self sendKeyToTrickplay:@"FF51" thecount:numSwipes];
            }
            swipeSent = YES;
        }
        //Vertical swipe
        //else if (fabsf(startTouchPosition.y - currentTouchPosition.y) >= HORIZ_SWIPE_DRAG_MIN &&
        //		 fabsf(startTouchPosition.x - currentTouchPosition.x) <= VERT_SWIPE_DRAG_MAX)
        else if ((fabsf(startTouchPosition.y - currentTouchPosition.y) >= VERT_SWIPE_DRAG_MIN))
        {
            if (touchedTime > 0)
            {
                NSLog(@"swipe speed vertical:%f ",[NSDate timeIntervalSinceReferenceDate]  - touchedTime);
                if (([NSDate timeIntervalSinceReferenceDate]  - touchedTime) < 0.05)
                {
                    //numSwipes = 3;
                }
                else if (([NSDate timeIntervalSinceReferenceDate]  - touchedTime) < 0.1)
                {
                    //numSwipes = 2;
                }
            }
            // It appears to be a vertical swipe.
            if (startTouchPosition.y < currentTouchPosition.y)
            {
                //Send down key -  FF54
                NSLog(@"swipe down");
                keySent = YES;
                
                [self sendKeyToTrickplay:@"FF54" thecount:numSwipes];
            }
            else
            {
                //Send up key  - FF52
                NSLog(@"Swipe up");
                keySent = YES;
                [self sendKeyToTrickplay:@"FF52" thecount:numSwipes];
            }
            swipeSent = YES;            
        }
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //Multi touch info:
	//http://developer.apple.com/iphone/library/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/EventHandling/EventHandling.html#//apple_ref/doc/uid/TP40007072-CH9-SW14
	//Send the TOUCHUP event if enabled
	if (socketManager && touchEventsAllowed)
	{
		NSString *sentTouchData = [NSString stringWithFormat:@"TU\t%f\t%f\t%f\t%f\n", 1, currentTouchPosition.x,currentTouchPosition.y,[NSDate timeIntervalSinceReferenceDate]];
		[socketManager sendData:[sentTouchData UTF8String] numberOfBytes:[sentTouchData length]];
	}
	
	if (!swipeSent)
	{
		
		//Send 'Enter' key since no swipe occured but they tapped the screen
		//Don't do this if the start/end points are too far apart
		if (fabsf(startTouchPosition.x - currentTouchPosition.x) <= TAP_DISTANCE_MAX &&
			fabsf(startTouchPosition.y - currentTouchPosition.y) <= TAP_DISTANCE_MAX)
		{
			//Tap occured, send <ENTER> key
			[self sendKeyToTrickplay:@"FF0D" thecount:1];
			//Send click event if click events are enabled
            /**  depricated!
			if (socketManager && clickEventsAllowed)
			{
				NSString *sentClickData = [NSString stringWithFormat:@"CK\t%f\t%f\t%f\n", currentTouchPosition.x,currentTouchPosition.y,[NSDate timeIntervalSinceReferenceDate]];
				[socketManager sendData:[sentClickData UTF8String] numberOfBytes:[sentClickData length]];
			}
            //*/
		}
		else
		{
			NSLog(@"no swipe sent, start.x,.y: (%f, %f)  current.x,.y: (%f, %f)",startTouchPosition.x, startTouchPosition.y, currentTouchPosition.x,currentTouchPosition.y);
		}
		
		
	}
	startTouchPosition.x = 0.0;
	startTouchPosition.y = 0.0;
	currentTouchPosition.x = 0.0;
	currentTouchPosition.y = 0.0;
	swipeSent = NO;
	keySent = NO;
	NSLog(@"touches ended");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    startTouchPosition.x = 0.0;
	startTouchPosition.y = 0.0;
	currentTouchPosition.x = 0.0;
	currentTouchPosition.y = 0.0;
	swipeSent = NO;
	keySent = NO;
}

/** depricated
- (void)startClicks {
    clickEventsAllowed = YES;
}

- (void)stopClicks {
    clickEventsAllowed = NO;
}
//*/

- (void)startTouches {
    touchEventsAllowed = YES;
}

- (void)stopTouches {
    touchEventsAllowed = NO;
}

- (void)dealloc {
    if (view) {
        [view release];
    }
    if (socketManager) {
        [socketManager release];
    }
    [super dealloc];
}

@end
