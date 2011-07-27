//
//  TrickplayScreen.m
//  TrickplayController
//
//  Created by Rex Fenley on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayScreen.h"
#import "TrickplayUIElement.h"

@implementation TrickplayScreen

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"\n\nbegin\n\n");

    for (TrickplayUIElement *element in view.subviews) {
        [element handleTouchesBegan:touches];
    }
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"\n\nmoved\n\n");
    for (TrickplayUIElement *element in view.subviews) {
        [element handleTouchesMoved:touches];
    }
    [self.nextResponder touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"\n\nended\n\n");
    for (TrickplayUIElement *element in view.subviews) {
        [element handleTouchesEnded:touches];
    }
    [self.nextResponder touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"\n\ncancelled\n\n");
    for (TrickplayUIElement *element in view.subviews) {
        [element handleTouchesCancelled:touches];
    }
    [self.nextResponder touchesCancelled:touches withEvent:event];
}
//*/
- (void)handleTouchesBegan:(NSSet *)touches {
    
}
- (void)handleTouchesMoved:(NSSet *)touches {
    
}
- (void)handleTouchesEnded:(NSSet *)touches {
    
}
- (void)handleTouchesCancelled:(NSSet *)touches {
    
}

@end
