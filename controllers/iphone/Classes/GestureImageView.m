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
@synthesize xScale;
@synthesize yScale;
@synthesize xTranslation;
@synthesize yTranslation;

- (id)initWithImage:(UIImage *)image {
    if ((self = [super initWithImage:image])) {
        rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateImage:)];
        pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage:)];
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panImage:)];
        doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapImage:)];
        tripleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tripleTapImage:)];
        panGesture.delegate = self;
        rotationGesture.delegate = self;
        pinchGesture.delegate = self;
        doubleTapGesture.delegate = self;
        tripleTapGesture.delegate = self;
        doubleTapGesture.numberOfTapsRequired = 2;
        tripleTapGesture.numberOfTapsRequired = 3;
        
        [doubleTapGesture requireGestureRecognizerToFail:tripleTapGesture];
        
        [self addGestureRecognizer:rotationGesture];
        [self addGestureRecognizer:pinchGesture];
        [self addGestureRecognizer:panGesture];
        [self addGestureRecognizer:doubleTapGesture];
        [self addGestureRecognizer:tripleTapGesture];
        
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        
        totalRotation = 0;
        xScale = 1.0;
        yScale = 1.0;
        xTranslation = 0;
        yTranslation = 0;
    }

    return self;
}


- (void)panImage:(UIPanGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self.superview];
        self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
        xTranslation += translation.x;
        yTranslation += translation.y;
        
        [gestureRecognizer setTranslation:CGPointZero inView:self.superview];
    }
}


- (void)rotateImage:(UIRotationGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        self.transform = CGAffineTransformRotate(self.transform, gestureRecognizer.rotation * xScale/fabs(xScale));
        totalRotation += gestureRecognizer.rotation;
        
        gestureRecognizer.rotation = 0;
    }
}


- (void)scaleImage:(UIPinchGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        self.transform = CGAffineTransformScale(self.transform, gestureRecognizer.scale, gestureRecognizer.scale);
        xScale *= gestureRecognizer.scale;
        yScale *= gestureRecognizer.scale;
        
        gestureRecognizer.scale = 1;
    }
}


- (void)doubleTapImage:(UITapGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        self.transform = CGAffineTransformScale(self.transform, -1.0, 1.0);
        
        xScale *= -1.0;
    }
}


-(void)tripleTapImage:(UITapGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        
        // reset panning
        self.center = CGPointMake(self.center.x - xTranslation, self.center.y - yTranslation);
        xTranslation = 0;
        yTranslation = 0;
        
        // reset scale
        self.transform = CGAffineTransformScale(self.transform, fabs(1.0/xScale), 1.0/yScale);
        xScale = 1.0;
        yScale = 1.0;
        
        // reset rotation
        self.transform = CGAffineTransformRotate(self.transform, -totalRotation);
        totalRotation = 0;
        
        self.transform = CGAffineTransformIdentity;
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (gestureRecognizer == doubleTapGesture || otherGestureRecognizer == doubleTapGesture || gestureRecognizer == tripleTapGesture || otherGestureRecognizer == tripleTapGesture) {
        return NO;
    }
    
    return YES;
}


- (void)dealloc {
    NSLog(@"GestureImageView dealloc");
    [rotationGesture release];
    [pinchGesture release];
    [panGesture release];
    [doubleTapGesture release];
    [tripleTapGesture release];
    
    [super dealloc];
}

@end
