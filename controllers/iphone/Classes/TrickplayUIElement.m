//
//  TrickplayUIElement.m
//  TrickplayController
//
//  Created by Rex Fenley on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayUIElement.h"


@implementation TrickplayUIElement

@synthesize scale;
@synthesize view;

- (id)init {
    if ((self = [super init])) {
        x = 0.0, y = 0.0, width = 0.0, height = 0.0;
        is_scaled = NO;
        self.scale = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0], [NSNumber numberWithFloat:1.0], nil];
    }
    
    return self;
}

/**
 * Returns a frame built from the x, y, width, and height in the args.
 */

- (CGRect)getFrameFromArgs:(NSDictionary *)args {
    NSArray *position = [args objectForKey:@"position"];
    NSArray *size = [args objectForKey:@"size"];
    
    if ([args objectForKey:@"x"]) {
        x = [(NSNumber *)[args objectForKey:@"x"] floatValue];
    }
    if ([args objectForKey:@"y"]) {
        y = [(NSNumber *)[args objectForKey:@"y"] floatValue];
    }
    if (position) {
        x = [(NSNumber *)[position objectAtIndex:0] floatValue];
        y = [(NSNumber *)[position objectAtIndex:1] floatValue];
    }
    if ([args objectForKey:@"width"]) {
        width = [(NSNumber *)[args objectForKey:@"width"] floatValue];
    }
    if ([args objectForKey:@"w"]) {
        width = [(NSNumber *)[args objectForKey:@"w"] floatValue];
    }
    if ([args objectForKey:@"height"]) {
        height = [(NSNumber *)[args objectForKey:@"height"] floatValue];
    }
    if ([args objectForKey:@"h"]) {
        height = [(NSNumber *)[args objectForKey:@"h"] floatValue];
    }
    if (size) {
        width = [(NSNumber *)[size objectAtIndex:0] floatValue];
        height = [(NSNumber *)[size objectAtIndex:1] floatValue];
    }
    // Could instead manipulate the transformation matrix, but this works for now
    if ([args objectForKey:@"scale"]) {
        self.scale = [args objectForKey:@"scale"];
        width *= [(NSNumber *)[scale objectAtIndex:0] floatValue];
        height *= [(NSNumber *)[scale objectAtIndex:1] floatValue];
        is_scaled = !([[scale objectAtIndex:0] floatValue] == 1.0 && [[scale objectAtIndex:1] floatValue] == 1.0);
    }
    
    return CGRectMake(x, y, width, height);
}


/**
 * Since all these objects follow the UIElements Interface in Trickplay,
 * establish the values of all the UIElement properties for the object.
 */

- (void)setValuesWithArgs:(NSDictionary *)args {
    // x, y, position, w/width, h/height, size, scale
    view.frame = [self getFrameFromArgs:args];
    // opacity
    if ([args objectForKey:@"opacity"]) {
        view.alpha = [[args objectForKey:@"opacity"] floatValue]/255.0;
    }
}


- (void)dealloc {
    self.scale = nil;
    self.view = nil;
    
    [super dealloc];
}

@end
