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
    if ((self = [super init])) {
        self.view = aView;
        self.socketManager = sockman;
        touchEventsAllowed = NO;
        swipeStarted = NO;
        swipeSent = NO;
        keySent = NO;
        activeTouches = CFDictionaryCreateMutable(NULL, 10, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        //activeTouches = [[NSMutableDictionary alloc] initWithCapacity:10];
        openFinger = 1;
        
        [view setMultipleTouchEnabled:NO];
    }
    
    return self;
}

- (void)sendKeyToTrickplay:(NSString *)thekey thecount:(NSInteger)thecount {
	if (socketManager && !touchEventsAllowed)
	{
	    int index;	
		NSString *sentData = [NSString stringWithFormat:@"KP\t%@\n", thekey];
        
		for (index = 1; index <= thecount; index++) {
			[socketManager sendData:[sentData UTF8String]
                      numberOfBytes:[sentData length]];
		}
		
		keySent = YES;
	}
}

- (void)resetTouches {
    CFDictionaryRemoveAllValues(activeTouches);
    //[activeTouches removeAllObjects];
    swipeStarted = NO;
    swipeSent = NO;
	keySent = NO;
    touchedTime = 0;
}

- (void)setMultipleTouch:(BOOL)val {
    view.multipleTouchEnabled = val;
    [self resetTouches];
}

//*
- (void)addTouch:(UITouch *)touch {
    CFDictionarySetValue(activeTouches, touch, (CFNumberRef)[NSNumber numberWithUnsignedInt:openFinger]);
    //[activeTouches setObject:[NSNumber numberWithInt:openFinger] forKey:touch];
    openFinger++;
}

- (BOOL)stillActive:(UITouch *)touch {
    return socketManager && CFDictionaryGetValue(activeTouches, touch);
}


/**
 * Returns whether or not the touch was sent.
 */
- (BOOL)sendTouch:(UITouch *)touch withCommand:(NSString *)command {
    if (![self stillActive:touch] || !touchEventsAllowed) {
        return NO;
    }
    
    // format: TD/TM/TU <finger> <x> <y>
    CGPoint currentTouchPosition = [touch locationInView:view];
    NSString *sentTouchData = [NSString stringWithFormat:@"%@\t%d\t%f\t%f\n", command, [(NSNumber *)CFDictionaryGetValue(activeTouches, touch) unsignedIntValue], currentTouchPosition.x, currentTouchPosition.y];
    //NSString *sentTouchData = [NSString stringWithFormat:@"%@\t%d\t%f\t%f\n", command, [(NSNumber *)[activeTouches objectForKey:touch] unsignedIntValue], currentTouchPosition.x, currentTouchPosition.y];
    //NSLog(@"sent touch data: '%@'", sentTouchData);
    [socketManager sendData:[sentTouchData UTF8String] numberOfBytes:[sentTouchData length]];
    
    return YES;
}
//*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touches began");

    keySent = NO;
    
    NSMutableArray *newActiveTouches = [NSMutableArray arrayWithArray:[touches allObjects]];
    int i;
    for (i = 0; i < [newActiveTouches count]; i++) {
        UITouch *touch = [newActiveTouches objectAtIndex:i];
        [self addTouch:touch];
        [self sendTouch:touch withCommand:@"TD"];
        
        startTouchPosition = [touch previousLocationInView:view];
    }

    //NSLog(@"multitouch = %d", view.multipleTouchEnabled);
    //NSLog(@"touches = %@", touches);
    if (!view.multipleTouchEnabled) {
        // leaving the name as a time interval incase in the future
        // we decide to include this data we'll know which var to use
        touchedTime = 1.0;//[NSDate timeIntervalSinceReferenceDate];
    } else {
        touchedTime = 0;
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSMutableArray *movedTouches = [NSMutableArray arrayWithArray:[touches allObjects]];
    int i;
    BOOL stillActive = YES;
    for (i = 0; i < [movedTouches count]; i++) {
        UITouch *touch = [movedTouches objectAtIndex:i];
        [self sendTouch:touch withCommand:@"TM"];
        if (![self stillActive:touch]) {
            stillActive = NO;
        }
    }
    
    if (![view isMultipleTouchEnabled] && touchedTime > 0 && stillActive) {
        UITouch *touch = [touches anyObject];
        if (keySent) return;
        
        if (!swipeStarted) {
            startTouchPosition = [touch previousLocationInView:view];
            swipeStarted = YES;
        }
    }
}

- (BOOL)doSwipe:(CGPoint)currentTouchPosition {
    if (!swipeStarted) {
        return NO;
    }
    
    //Horizontal swipe
    // To be a swipe, direction of touch must be horizontal and long enough.
    if (fabsf(startTouchPosition.x - currentTouchPosition.x) > fabsf(startTouchPosition.y - currentTouchPosition.y) && fabsf(startTouchPosition.x - currentTouchPosition.x) >= HORIZ_SWIPE_DRAG_MIN) {
        // It appears to be a swipe.
        if (startTouchPosition.x < currentTouchPosition.x) {
            //Send right key -  FF53
            NSLog(@"swipe right");
            [self sendKeyToTrickplay:@"FF53" thecount:1];
        } else {
            //Send left key  - FF51
            NSLog(@"Swipe Left");
            [self sendKeyToTrickplay:@"FF51" thecount:1];
        }
        swipeSent = YES;
            
        return YES;
    }
    //Vertical swipe
    else if (fabsf(startTouchPosition.y - currentTouchPosition.y) >= VERT_SWIPE_DRAG_MIN) {
        // It appears to be a vertical swipe.
        if (startTouchPosition.y < currentTouchPosition.y) {
            //Send down key -  FF54
            NSLog(@"swipe down");
            [self sendKeyToTrickplay:@"FF54" thecount:1];
        } else {
            //Send up key  - FF52
            NSLog(@"Swipe up");
            [self sendKeyToTrickplay:@"FF52" thecount:1];
        }
        swipeSent = YES;
        
        return YES;
    }
    
    return NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSMutableArray *endedTouches = [NSMutableArray arrayWithArray:[touches allObjects]];
    int i;
    BOOL stillActive = YES;
    for (i = 0; i < [endedTouches count]; i++) {
        // send touch command to Trickplay
        UITouch *touch = [endedTouches objectAtIndex:i];
        [self sendTouch:touch withCommand:@"TU"];
        if (![self stillActive:touch]) {
            stillActive = NO;
        }
        // delete touch from active touches
        CFDictionaryRemoveValue(activeTouches, touch);
        //[activeTouches removeObjectForKey:touch];
    }
	
	if (![view isMultipleTouchEnabled] && !swipeSent && stillActive)
	{
		UITouch *touch = [touches anyObject];
        CGPoint currentTouchPosition = [touch locationInView:view];
        if (![self doSwipe:currentTouchPosition]) {
            //Send 'Enter' key since no swipe occured but they tapped the screen
            //Don't do this if the start/end points are too far apart
            if (fabsf(startTouchPosition.x - currentTouchPosition.x) <= TAP_DISTANCE_MAX &&
                fabsf(startTouchPosition.y - currentTouchPosition.y) <= TAP_DISTANCE_MAX) {
                //Tap occured, send <ENTER> key
                [self sendKeyToTrickplay:@"FF0D" thecount:1];
            } else {
                NSLog(@"no swipe sent, start.x,.y: (%f, %f)  current.x,.y: (%f, %f)",startTouchPosition.x, startTouchPosition.y, currentTouchPosition.x, currentTouchPosition.y);
            }
        }
	}

    swipeStarted = NO;
	swipeSent = NO;
	keySent = NO;
    touchedTime = 0;
	NSLog(@"touches ended");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touches cancelled");
	[self resetTouches];
    // TODO: tell trickplay the touches cancelled
}

- (void)startTouches {
    NSLog(@"start touches");
    touchEventsAllowed = YES;
}

- (void)stopTouches {
    NSLog(@"stop touches");
    touchEventsAllowed = NO;
}

- (void)reset {
    [self stopTouches];
    [self setMultipleTouch:NO];
}

- (void)dealloc {
    NSLog(@"TouchController dealloc");
    if (view) {
        [view release];
    }
    if (socketManager) {
        [socketManager release];
    }
    if (activeTouches) {
        CFRelease(activeTouches);
    }
    
    [super dealloc];
}

@end
