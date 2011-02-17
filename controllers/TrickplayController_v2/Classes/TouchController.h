//
//  TouchController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GestureViewController.h"

#define HORIZ_SWIPE_DRAG_MIN  25  //Was 20
#define VERT_SWIPE_DRAG_MAX    10
#define TAP_DISTANCE_MAX    4


@interface TouchController : NSObject <ViewControllerTouchDelegate> {
    BOOL clickEventsAllowed;
    BOOL touchEventsAllowed;
    
    CGPoint startTouchPosition;
    CGPoint currentTouchPosition;
    NSTimeInterval touchedTime;
    
    BOOL swipeSent;
    BOOL keySent;
    
    SocketManager *socketManager;
    UIView *view;
}

@property (retain) SocketManager *socketManager;
@property (retain) UIView *view;

- (id)initWithView:aView socketManager:(SocketManager *)sockman;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)sendKeyToTrickplay:(NSString *)thekey thecount:(NSInteger)thecount;

@end
