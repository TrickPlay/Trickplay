//
//  GestureImageView.m
//  TrickplayController
//
//  Created by Rex Fenley on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GestureImageView.h"


@implementation GestureImageView

@synthesize totalRotation;
@synthesize totalScale;
@synthesize xTranslation;
@synthesize yTranslation;

- (id)initWithImage:(UIImage *)image {
    if ((self = [super initWithImage:image])) {
        rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateImage:)];
        pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage:)];
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panImage:)];
        panGesture.delegate = self;
        //longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(presentResetControl:)];
        
        [self addGestureRecognizer:rotationGesture];
        [self addGestureRecognizer:pinchGesture];
        [self addGestureRecognizer:panGesture];
        //[self addGestureRecognizer:longPressGesture];
        
        self.userInteractionEnabled = YES;
        
        totalRotation = 0;
        totalScale = 1.0;
        xTranslation = 0;
        yTranslation = 0;
    }

    return self;
}


- (void)panImage:(UIPanGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self.superview];
        self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
        //self.transform = CGAffineTransformTranslate(self.transform, translation.x, translation.y);
        xTranslation += translation.x;
        yTranslation += translation.y;
        
        [gestureRecognizer setTranslation:CGPointZero inView:self.superview];
    }
}


- (void)rotateImage:(UIRotationGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        self.transform = CGAffineTransformRotate(self.transform, gestureRecognizer.rotation);
        totalRotation += gestureRecognizer.rotation;
        
        gestureRecognizer.rotation = 0;
    }
}


- (void)scaleImage:(UIPinchGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        self.transform = CGAffineTransformScale(self.transform, gestureRecognizer.scale, gestureRecognizer.scale);
        totalScale *= gestureRecognizer.scale;
        
        gestureRecognizer.scale = 1;
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


- (void)dealloc {
    NSLog(@"GestureImageView dealloc");
    [rotationGesture release];
    [pinchGesture release];
    [panGesture release];
    [longPressGesture release];
    
    [super dealloc];
}

@end
