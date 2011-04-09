//
//  TrickplayUIElement.m
//  TrickplayController
//
//  Created by Rex Fenley on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayUIElement.h"


@implementation TrickplayUIElement

@synthesize clip;
@synthesize view;

- (id)init {
    if ((self = [super init])) {
        is_scaled = NO;
        
        self.clip = nil;
    }
    
    return self;
}

/**
 * Returns a frame built from the x, y, width, and height in the args.
 */

- (CGRect)getFrameFromArgs:(NSDictionary *)args {
    //NSArray *position = [args objectForKey:@"position"];
    NSArray *size = [args objectForKey:@"size"];
    CGFloat x = 0.0, y = 0.0, width = 0.0, height = 0.0;
    /*
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
     */
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
    /*
    // Could instead manipulate the transformation matrix, but this works for now
    if ([args objectForKey:@"scale"]) {
        self.scale = [args objectForKey:@"scale"];
        width *= [(NSNumber *)[scale objectAtIndex:0] floatValue];
        height *= [(NSNumber *)[scale objectAtIndex:1] floatValue];
        is_scaled = !([[scale objectAtIndex:0] floatValue] == 1.0 && [[scale objectAtIndex:1] floatValue] == 1.0);
    }
    */
    
    return CGRectMake(x, y, width, height);
}

/**
 * Set Position
 */

- (void)setPostionFromArgs:(NSDictionary *)args {
    NSArray *position = [args objectForKey:@"position"];
    NSNumber *x = nil, *y = nil, *z = nil;
    
    if ([args objectForKey:@"x"]) {
        x = [args objectForKey:@"x"];
    }
    if ([args objectForKey:@"y"]) {
        y = [args objectForKey:@"y"];
    }
    if ([args objectForKey:@"z"]) {
        z = [args objectForKey:@"z"];
    }
    if (position) {
        x = [position objectAtIndex:0];
        y = [position objectAtIndex:1];
        if ([position count] > 2) {
            z = [position objectAtIndex:2];
        }
    }
    if (!x && !y) {
        return;
    }
    if (!x) {
        x = [NSNumber numberWithFloat:view.layer.position.x];
    }
    if (!y) {
        y = [NSNumber numberWithFloat:view.layer.position.y];
    }
    if (z) {
        view.layer.zPosition = [z floatValue];
    }
    
    view.layer.position = CGPointMake([x floatValue], [y floatValue]);
}


/**
 * Set the Size
 */

- (void)setSizeFromArgs:(NSDictionary *)args {
    NSArray *size = [args objectForKey:@"size"];
    NSNumber *width = nil, *height = nil;
    
    if ([args objectForKey:@"width"]) {
        width = [args objectForKey:@"width"];
    } else if ([args objectForKey:@"w"]) {
        width = [args objectForKey:@"w"];
    }
    
    if ([args objectForKey:@"height"]) {
        height = [args objectForKey:@"height"];
    } else if ([args objectForKey:@"h"]) {
        height = [args objectForKey:@"h"];
    }
    
    if (size) {
        width = [size objectAtIndex:0];
        height = [size objectAtIndex:1];
    }
    
    if (!width && !height) {
        return;
    }
    if (!width) {
        width = [NSNumber numberWithFloat:view.layer.bounds.size.width];
    }
    if (!height) {
        height = [NSNumber numberWithFloat:view.layer.bounds.size.height];
    }
    
    view.layer.bounds = CGRectMake(0.0, 0.0, [width floatValue], [height floatValue]);
}


/**
 * Anchor Point
 */

- (void)setAnchorPointFromArgs:(NSDictionary *)args {
    NSArray *anchorPoint = [args objectForKey:@"anchor_point"];
    if (!anchorPoint || [anchorPoint count] < 2) {
        return;
    }
    
    CGFloat
    x = [(NSNumber *)[anchorPoint objectAtIndex:0] floatValue],
    y = [(NSNumber *)[anchorPoint objectAtIndex:1] floatValue];
    
    view.layer.anchorPoint = CGPointMake(x, y);
}


/**
 * Scale the element
 */

- (void)setScaleFromArgs:(NSDictionary *)args {
    NSArray *layer_scale = [args objectForKey:@"scale"];
    if (!layer_scale || [layer_scale count] < 2) {
        return;
    }
    
    [view.layer setValue:(NSNumber *)[layer_scale objectAtIndex:0] forKeyPath:@"transform.scale.x"];
    [view.layer setValue:(NSNumber *)[layer_scale objectAtIndex:1] forKeyPath:@"transform.scale.y"];
    
    if ([layer_scale count] > 2) {
        [view.layer setValue:(NSNumber *)[layer_scale objectAtIndex:2] forKeyPath:@"transform.scale.z"];
    }
}


/**
 * Rotate the element
 */

- (void)setRotationsFromArgs:(NSDictionary *)args {
    if ([args objectForKey:@"x_rotation"]) {
        NSNumber *x_rotation = [(NSArray *)[args objectForKey:@"x_rotation"] objectAtIndex:0];
        [view.layer setValue:x_rotation forKeyPath:@"transform.roation.x"];
    }
    if ([args objectForKey:@"y_rotation"]) {
        NSNumber *y_rotation = [(NSArray *)[args objectForKey:@"y_rotation"] objectAtIndex:0];
        [view.layer setValue:y_rotation forKeyPath:@"transform.rotation.y"];
    }
    if ([args objectForKey:@"z_rotation"]) {
        NSNumber *z_rotation = [(NSArray *)[args objectForKey:@"z_rotation"] objectAtIndex:0];
        [view.layer setValue:z_rotation forKeyPath:@"transform.rotation.z"];
    }
}


/**
 * Set opacity
 */

- (void)setOpacityFromArgs:(NSDictionary *)args {
    if ([args objectForKey:@"opacity"]) {
        self.view.alpha = [(NSNumber *)[args objectForKey:@"opacity"] floatValue]/255.0;
    }
}


/**
 * Set a clip.
 */

- (void)setClipFromArgs:(NSDictionary *)args {
    self.clip = [args objectForKey:@"clip"];
    
    if (clip) {
        CGFloat
        clip_x = [(NSNumber *)[clip objectAtIndex:0] floatValue],
        clip_y = [(NSNumber *)[clip objectAtIndex:1] floatValue],
        clip_w = [(NSNumber *)[clip objectAtIndex:2] floatValue],
        clip_h = [(NSNumber *)[clip objectAtIndex:3] floatValue];
        // create the bounding box
        self.frame = CGRectMake(clip_x, clip_y, clip_w, clip_h);
        // adjust the view to the coordinate system of the bounding box
        
    }
}


/**
 * Since all these objects follow the UIElements Interface in Trickplay,
 * establish the values of all the UIElement properties for the object.
 */

- (void)setValuesFromArgs:(NSDictionary *)args {
    [self setPostionFromArgs:args];
    [self setSizeFromArgs:args];
    [self setAnchorPointFromArgs:args];
    [self setScaleFromArgs:args];
    [self setRotationsFromArgs:args];
    [self setOpacityFromArgs:args];
}


- (void)dealloc {
    self.view = nil;
    
    [super dealloc];
}

@end
