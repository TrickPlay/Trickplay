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
    UITapGestureRecognizer *doubleTapGesture;
    UITapGestureRecognizer *tripleTapGesture;
    
    CGFloat totalRotation;
    CGFloat xScale;
    CGFloat yScale;
    CGFloat xTranslation;
    CGFloat yTranslation;
}

@property (assign) CGFloat totalRotation;
@property (assign) CGFloat xScale;
@property (assign) CGFloat yScale;
@property (assign) CGFloat xTranslation;
@property (assign) CGFloat yTranslation;

- (void)panImage:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)rotateImage:(UIRotationGestureRecognizer *)gestureRecognizer;
- (void)scaleImage:(UIPinchGestureRecognizer *)gestureRecognizer;
- (void)doubleTapImage:(UITapGestureRecognizer *)gestureRecognizer;
- (void)tripleTapImage:(UITapGestureRecognizer *)gestureRecognizer;

@end
