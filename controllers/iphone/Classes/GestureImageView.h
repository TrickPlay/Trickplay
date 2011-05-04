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
}

- (void)panImage:(UIPanGestureRecognizer *)gesture;

@end
