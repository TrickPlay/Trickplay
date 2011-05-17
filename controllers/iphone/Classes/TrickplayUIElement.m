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
 *
 * NOT A GETTER FUNCTION. Used to contruct frames for building AdvancedUI Objects.
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

#pragma mark -
#pragma mark Setters

/**
 * Set Position
 */

- (void)setPostionFromArgs:(NSDictionary *)args {
    NSArray *position = [args objectForKey:@"position"];
    NSNumber *x = nil, *y = nil, *z = nil;

    x = [args objectForKey:@"x"];
    y = [args objectForKey:@"y"];
    z = [args objectForKey:@"z"];

    if (position) {
        x = [position objectAtIndex:0];
        y = [position objectAtIndex:1];
        if ([position count] > 2) {
            z = [position objectAtIndex:2];
        }
    }
    if (z) {
        // TODO: this isn't working
        NSLog(@"z: %@", z);
        view.layer.zPosition = [z floatValue];
        //[view.layer setValue:z forKeyPath:@"transform.translation.z"];
        //NSLog(@"z after: %@", [view.layer valueForKeyPath:@"transform.translation.z"]);
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
 *
 * anchor point is a CGPoint{0.0 <= x <= 1.0, 0.0 <= y <= 1.0}
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
 *
 * rotates along anchor point, uses degrees
 */

- (void)setRotationsFromArgs:(NSDictionary *)args {
    if ([args objectForKey:@"x_rotation"]) {
        NSNumber *x_rotation = [(NSArray *)[args objectForKey:@"x_rotation"] objectAtIndex:0];
        x_rotation = [NSNumber numberWithFloat:[x_rotation floatValue] * M_PI/180.0];
        [view.layer setValue:x_rotation forKeyPath:@"transform.rotation.x"];
    }
    if ([args objectForKey:@"y_rotation"]) {
        NSNumber *y_rotation = [(NSArray *)[args objectForKey:@"y_rotation"] objectAtIndex:0];
        y_rotation = [NSNumber numberWithFloat:[y_rotation floatValue] * M_PI/180.0];
        [view.layer setValue:y_rotation forKeyPath:@"transform.rotation.y"];
    }
    if ([args objectForKey:@"z_rotation"]) {
        NSNumber *z_rotation = [(NSArray *)[args objectForKey:@"z_rotation"] objectAtIndex:0];
        z_rotation = [NSNumber numberWithFloat:[z_rotation floatValue] * M_PI/180.0];
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
 *
 * Clip creates a bounding box relative to this objects frame.origin
 * ((0.0, 0.0) upper left hand corner of screen). Nothing from the objects
 * view is drawn outside the bounding box and changing the view's position,
 * size, and anchor point has no affect on the bounding box.
 */

- (void)setClipFromArgs:(NSDictionary *)args {
    self.clip = [args objectForKey:@"clip"];
    
    if (clip) {
        NSLog(@"view: %@", self);
        CGFloat
        clip_x = [(NSNumber *)[clip objectAtIndex:0] floatValue],
        clip_y = [(NSNumber *)[clip objectAtIndex:1] floatValue],
        clip_w = [(NSNumber *)[clip objectAtIndex:2] floatValue],
        clip_h = [(NSNumber *)[clip objectAtIndex:3] floatValue];
        // create the bounding box
        
        /* for testing
        NSLog(@"clip before: %f, %f, %f, %f", self.layer.bounds.origin.x, self.layer.bounds.origin.y, self.layer.bounds.size.width, self.layer.bounds.size.height);
        NSLog(@"Frame before: %f, %f, %f, %f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        //*/
        
        self.bounds = CGRectMake(clip_x, clip_y, clip_w, clip_h);
        self.layer.position = CGPointMake(clip_x + clip_w/2.0, clip_y + clip_h/2.0);
        
        /* for testing
        NSLog(@"clip after: %f, %f, %f, %f", self.layer.bounds.origin.x, self.layer.bounds.origin.y, self.layer.bounds.size.width, self.layer.bounds.size.height);
        NSLog(@"Frame after: %f, %f, %f, %f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        //*/
        
        // clip the view to the bounding box
        self.clipsToBounds = YES;
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
    [self setClipFromArgs:args];
}

#pragma mark -
#pragma mark Getters

/**
 * Get Position
 */

- (void)getPositionIntoDictionary:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"position"]) {
        NSArray *position = [NSArray arrayWithObjects:[NSNumber numberWithFloat:view.layer.position.x], [NSNumber numberWithFloat:view.layer.position.y], [NSNumber numberWithFloat:view.layer.zPosition], nil];
        
        [dictionary setObject:position forKey:@"position"];
    }
    if ([dictionary objectForKey:@"x"]) {
        [dictionary setObject:[NSNumber numberWithFloat:view.layer.position.x] forKey:@"x"];
    }
    if ([dictionary objectForKey:@"y"]) {
        [dictionary setObject:[NSNumber numberWithFloat:view.layer.position.y] forKey:@"y"];
    }
    if ([dictionary objectForKey:@"z"]) {
        [dictionary setObject:[NSNumber numberWithFloat:view.layer.zPosition] forKey:@"z"];
    }
}

/**
 * Get Size
 */

- (void)getSizeIntoDictionary:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"size"]) {
        NSArray *size = [NSArray arrayWithObjects:[NSNumber numberWithFloat:view.layer.bounds.size.width], [NSNumber numberWithFloat:view.layer.bounds.size.height], nil];
        
        [dictionary setObject:size forKey:@"size"];
    }
    if ([dictionary objectForKey:@"w"] || [dictionary objectForKey:@"width"]) {
        [dictionary setObject:[NSNumber numberWithFloat:view.layer.bounds.size.width] forKey:@"w"];
        [dictionary setObject:[NSNumber numberWithFloat:view.layer.bounds.size.width] forKey:@"width"];
    }
    if ([dictionary objectForKey:@"h"] || [dictionary objectForKey:@"height"]) {
        [dictionary setObject:[NSNumber numberWithFloat:view.layer.bounds.size.height] forKey:@"h"];
        [dictionary setObject:[NSNumber numberWithFloat:view.layer.bounds.size.height] forKey:@"height"];
    }
}

/**
 * Get Anchor Point
 */

- (void)getAnchorPointIntoDictionary:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"anchor_point"]) {
        NSArray *anchor_point = [NSArray arrayWithObjects:[NSNumber numberWithFloat:view.layer.anchorPoint.x], [NSNumber numberWithFloat:view.layer.anchorPoint.y], [NSNumber numberWithFloat:view.layer.anchorPointZ], nil];
        
        [dictionary setObject:anchor_point forKey:@"anchor_point"];
    }
}

/**
 * Get Scale
 */

- (void)getScaleIntoDictionary:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"scale"]) {
        NSArray *scale = [NSArray arrayWithObjects:[view.layer valueForKeyPath:@"transform.scale.x"], [view.layer valueForKeyPath:@"transform.scale.y"], [view.layer valueForKeyPath:@"transform.scale.z"], nil];
        
        [dictionary setObject:scale forKey:@"scale"];
    }
}

/**
 * Get Rotation
 */

- (void)getRotationIntoDictionary:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"x_rotation"]) {
        NSNumber *x_rotation = [NSNumber numberWithFloat:[[view.layer valueForKeyPath:@"transform.rotation.x"] floatValue] * 180.0/M_PI];
        
        [dictionary setObject:x_rotation forKey:@"x_rotation"];
    }
    if ([dictionary objectForKey:@"y_rotation"]) {
        NSNumber *y_rotation = [NSNumber numberWithFloat:[[view.layer valueForKeyPath:@"transform.rotation.y"] floatValue] * 180.0/M_PI];
        
        [dictionary setObject:y_rotation forKey:@"y_rotation"];
    }
    if ([dictionary objectForKey:@"z_rotation"]) {
        NSNumber *z_rotation = [NSNumber numberWithFloat:[[view.layer valueForKeyPath:@"transform.rotation.z"] floatValue] * 180.0/M_PI];
        
        [dictionary setObject:z_rotation forKey:@"z_rotation"];        
    }
}

/**
 * Get Opacity
 */

- (void)getOpacityIntoDictionary:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"opacity"]) {
        NSNumber *opacity = [NSNumber numberWithFloat:(view.alpha * 255.0)];
        
        [dictionary setObject:opacity forKey:@"opacity"];
    }
}

/**
 * Get Clip
 */

- (void)getClipIntoDictionary:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"clip"]) {
        CGFloat
        clip_x = self.bounds.origin.x,
        clip_y = self.bounds.origin.y,
        clip_w = self.bounds.size.width,
        clip_h = self.bounds.size.height;
        
        NSArray *clipBox = [NSArray arrayWithObjects:[NSNumber numberWithFloat:clip_x], [NSNumber numberWithFloat:clip_y], [NSNumber numberWithFloat:clip_w], [NSNumber numberWithFloat:clip_h], nil];
        
        [dictionary setObject:clipBox forKey:@"clip"];
    }
}

/**
 * Getter function
 */

- (NSDictionary *)getValuesFromArgs:(NSDictionary *)properties {
    NSMutableDictionary *JSON_Dictionary = [NSMutableDictionary dictionaryWithDictionary:properties];
    
    [self getPositionIntoDictionary:JSON_Dictionary];
    [self getSizeIntoDictionary:JSON_Dictionary];
    [self getAnchorPointIntoDictionary:JSON_Dictionary];
    [self getScaleIntoDictionary:JSON_Dictionary];
    [self getRotationIntoDictionary:JSON_Dictionary];
    [self getOpacityIntoDictionary:JSON_Dictionary];
    [self getClipIntoDictionary:JSON_Dictionary];
    
    return JSON_Dictionary;
}


#pragma mark -
#pragma mark Function handling

- (NSString *)doHide {
    self.hidden = YES;
    return @"[true]";
}

- (NSString *)doHideAll {
    self.hidden = YES;
    for (UIView *child in [self.view subviews]) {
        child.hidden = YES;
    }
    return @"[true]";
}

- (NSString *)doShow {
    self.hidden = NO;
    return @"[true]";
}

- (NSString *)doShowAll {
    self.hidden = NO;
    for (UIView *child in [self.view subviews]) {
        child.hidden = NO;
    }
    return @"[true]";
}

- (NSString *)doMoveBy_dx:(CGFloat)dx dy:(CGFloat)dy {
    CGFloat x = view.layer.position.x + dx;
    CGFloat y = view.layer.position.y + dy;
    
    view.layer.position = CGPointMake(x, y);
    return @"[true]";
}

- (NSString *)doUnparent {
    [self removeFromSuperview];
    return @"[true]";
}

- (NSString *)doRaise {
    if (!self.superview) {
        return @"[false]";
    }
    
    BOOL raiseSelf = NO;
    for (UIView *child in [self.superview subviews]) {
        if (raiseSelf) {
            [self.superview insertSubview:self aboveSubview:child];
            break;
        }
        if (child == self) {
            raiseSelf = YES;
        }
    }
    
    return @"[true]";
}

- (NSString *)doRaiseToTop {
    if (!self.superview) {
        return @"[false]";
    }
    
    [self.superview bringSubviewToFront:self];
    return @"[true]";
}

- (NSString *)doLower {
    if (!self.superview) {
        return @"[false]";
    }
    
    UIView *previous = nil;
    for (UIView *child in [self.superview subviews]) {
        if (child == self) {
            if (previous) {
                [self.superview insertSubview:self belowSubview:previous];
            }
            break;
        }
        
        previous = child;
    }
    return @"[true]";
}

- (NSString *)doLowerToBottom {
    if (!self.superview) {
        return @"[false]";
    }
    
    [self.superview sendSubviewToBack:self];
    return @"true";
}

- (void)doMoveAnchorPoint {
    
}

#pragma mark -
#pragma mark New Protocol

- (NSString *)callMethod:(NSString *)method withArgs:(NSArray *)args {
    NSString *result = nil;
    if ([method compare:@"hide"] == NSOrderedSame) {
        result = [self doHide];
    } else if ([method compare:@"hide_all"] == NSOrderedSame) {
        result = [self doHideAll];
    } else if ([method compare:@"show"] == NSOrderedSame) {
        result = [self doShow];
    } else if ([method compare:@"show_all"] == NSOrderedSame) {
        result = [self doShowAll];
    } else if ([method compare:@"move_by"] == NSOrderedSame) {
        result = [self doMoveBy_dx:[[args objectAtIndex:0] floatValue] dy:[[args objectAtIndex:1] floatValue]];
    } else if ([method compare:@"unparent"] == NSOrderedSame) {
        result = [self doUnparent];
    } else if ([method compare:@"raise"] == NSOrderedSame) {
        [self doRaise];
    } else if ([method compare:@"raise_to_top"] == NSOrderedSame) {
        [self doRaiseToTop];
    } else if ([method compare:@"lower"] == NSOrderedSame) {
        [self doLower];
    } else if ([method compare:@"lower_to_bottom"] == NSOrderedSame) {
        [self doLowerToBottom];
    }
    
    return result;
}


- (void)dealloc {
    self.view = nil;
    self.clip = nil;
    
    if ([self superview]) {
        [self removeFromSuperview];
    }
    
    [super dealloc];
}

@end
