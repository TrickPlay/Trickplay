//
//  GestureImageView.h
//  TrickplayController
//
//  Created by Rex Fenley on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GestureImageView;

@protocol GestureImageViewDelegate <NSObject>

@required
- (void)gestureImageViewDidTripleTap:(GestureImageView *)gestureImageView;

@end



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
    
    CGFloat extraXTranslation;
    CGFloat extraYTranslation;
    CGFloat extraXScale;
    CGFloat extraYScale;
    
    BOOL defaultOrientation;
    
    id <GestureImageViewDelegate> delegate;
}

@property (assign) CGFloat totalRotation;
@property (assign) CGFloat xScale;
@property (assign) CGFloat yScale;
@property (assign) CGFloat xTranslation;
@property (assign) CGFloat yTranslation;
@property (nonatomic, readonly) BOOL defaultOrientation;
@property (assign) id <GestureImageViewDelegate> delegate;

- (void)panImage:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)rotateImage:(UIRotationGestureRecognizer *)gestureRecognizer;
- (void)scaleImage:(UIPinchGestureRecognizer *)gestureRecognizer;
- (void)doubleTapImage:(UITapGestureRecognizer *)gestureRecognizer;
- (void)tripleTapImage:(UITapGestureRecognizer *)gestureRecognizer;

- (void)scaleImageTo:(CGFloat)scale;
- (void)rotateImageTo:(CGFloat)radians;
- (void)setPositionTo:(CGPoint)point;
- (void)resetImage;
- (void)flipImage;

@end
