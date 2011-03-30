//
//  TouchController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GestureViewController.h"

#define HORIZ_SWIPE_DRAG_MIN  30
#define VERT_SWIPE_DRAG_MIN    30
#define TAP_DISTANCE_MAX    10


@interface TouchController : NSObject <ViewControllerTouchDelegate> {
    BOOL clickEventsAllowed; //depricated
    BOOL touchEventsAllowed;
    
    NSTimeInterval touchedTime;
    
    BOOL swipeSent;
    BOOL keySent;
    
    SocketManager *socketManager;
    UIView *view;
    
    CFMutableDictionaryRef activeTouches;
    //NSMutableDictionary *activeTouches;
    NSUInteger openFinger;
    
    CGPoint startTouchPosition;
    BOOL swipeStarted;
}

@property (retain) SocketManager *socketManager;
@property (retain) UIView *view;

- (id)initWithView:aView socketManager:(SocketManager *)sockman;

- (void)resetTouches;
- (void)setMultipleTouch:(BOOL)val;
- (void)addTouch:(UITouch *)touch;
- (BOOL)sendTouch:(UITouch *)touch withCommand:(NSString *)command;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)sendKeyToTrickplay:(NSString *)thekey thecount:(NSInteger)thecount;

@end
