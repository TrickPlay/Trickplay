//
//  GestureImageView.h
//  TrickplayController
//
//  Created by Rex Fenley on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface GestureImageView : UIImageView <UIGestureRecognizerDelegate> {
    UIRotationGestureRecognizer *rotationGesture;
    UIPinchGestureRecognizer *pinchGesture;
    UIPanGestureRecognizer *panGesture;
    UILongPressGestureRecognizer *longPressGesture;
    
    CGFloat totalRotation;
    CGFloat totalScale;
    CGFloat xTranslation;
    CGFloat yTranslation;
}

@property (assign) CGFloat totalRotation;
@property (assign) CGFloat totalScale;
@property (assign) CGFloat xTranslation;
@property (assign) CGFloat yTranslation;

- (void)panImage:(UIPanGestureRecognizer *)gesture;
- (void)rotateImage:(UIRotationGestureRecognizer *)gestureRecognizer;
- (void)scaleImage:(UIPinchGestureRecognizer *)gestureRecognizer;

@end
