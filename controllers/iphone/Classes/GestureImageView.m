//
//  GestureImageView.m
//  TrickplayController
//
//  Created by Rex Fenley on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GestureImageView.h"


@implementation GestureImageView


- (id)initWithImage:(UIImage *)image {
    if ((self = [super initWithImage:image])) {
        rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateImage:)];
        pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage)];
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panImage:)];
        panGesture.delegate = self;
        longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(presentResetControl:)];
        
        [self addGestureRecognizer:rotationGesture];
        [self addGestureRecognizer:pinchGesture];
        [self addGestureRecognizer:panGesture];
        [self addGestureRecognizer:longPressGesture];
        
        self.userInteractionEnabled = YES;
    }

    return self;
}


- (void)panImage:(UIPanGestureRecognizer *)gestureRecognizer {
    NSLog(@"Panning");
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self.superview];
        self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
        [gestureRecognizer setTranslation:CGPointZero inView:self.superview];
    }
}


- (void)dealloc {
    [rotationGesture release];
    [pinchGesture release];
    [panGesture release];
    [longPressGesture release];
}

@end
