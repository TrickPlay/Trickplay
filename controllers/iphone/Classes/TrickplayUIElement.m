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
@synthesize ID;
@synthesize name;

- (id)initWithID:(NSString *)theID {
    if ((self = [super init])) {
        is_scaled = NO;
        
        self.clip = nil;
        self.ID = theID;
        self.name = nil;
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
 * Set the Name
 */

- (void)setNameFromArgs:(NSDictionary *)args {
    if ([args objectForKey:@"name"] && [[args objectForKey:@"name"] isKindOfClass:[NSString class]]) {
        self.name = [args objectForKey:@"name"];
    }
}

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
    [self setNameFromArgs:args];
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
 * Get Name
 */

- (void)get_name:(NSMutableDictionary *)dictionary {
    [dictionary setObject:self.name forKey:@"name"];
}

/**
 * Get Position
 */

- (void)get_position:(NSMutableDictionary *)dictionary {
    NSArray *position = [NSArray arrayWithObjects:[NSNumber numberWithFloat:view.layer.position.x], [NSNumber numberWithFloat:view.layer.position.y], [NSNumber numberWithFloat:view.layer.zPosition], nil];
        
    [dictionary setObject:position forKey:@"position"];
}

- (void)get_x:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithFloat:view.layer.position.x] forKey:@"x"];
}

- (void)get_y:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithFloat:view.layer.position.y] forKey:@"y"];
}

- (void)get_z:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithFloat:view.layer.zPosition] forKey:@"z"];
}

/**
 * Get Size
 */

- (void)get_size:(NSMutableDictionary *)dictionary {
    NSArray *size = [NSArray arrayWithObjects:[NSNumber numberWithFloat:view.layer.bounds.size.width], [NSNumber numberWithFloat:view.layer.bounds.size.height], nil];
        
    [dictionary setObject:size forKey:@"size"];
}

- (void)get_w:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithFloat:view.layer.bounds.size.width] forKey:@"w"];
}

- (void)get_width:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithFloat:view.layer.bounds.size.width] forKey:@"width"];
}

- (void)get_h:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithFloat:view.layer.bounds.size.height] forKey:@"h"];
}

- (void)get_height:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithFloat:view.layer.bounds.size.height] forKey:@"height"];
}

/**
 * Get Anchor Point
 */

- (void)get_anchor_point:(NSMutableDictionary *)dictionary {
    NSArray *anchor_point = [NSArray arrayWithObjects:[NSNumber numberWithFloat:view.layer.anchorPoint.x], [NSNumber numberWithFloat:view.layer.anchorPoint.y], [NSNumber numberWithFloat:view.layer.anchorPointZ], nil];
        
    [dictionary setObject:anchor_point forKey:@"anchor_point"];
}

/**
 * Get Scale
 */

- (void)get_scale:(NSMutableDictionary *)dictionary {
    NSArray *scale = [NSArray arrayWithObjects:[view.layer valueForKeyPath:@"transform.scale.x"], [view.layer valueForKeyPath:@"transform.scale.y"], [view.layer valueForKeyPath:@"transform.scale.z"], nil];
        
    [dictionary setObject:scale forKey:@"scale"];
}

/**
 * Get Rotation
 */

- (void)get_x_rotation:(NSMutableDictionary *)dictionary {
    NSNumber *x_rotation = [NSNumber numberWithFloat:[[view.layer valueForKeyPath:@"transform.rotation.x"] floatValue] * 180.0/M_PI];
        
    [dictionary setObject:x_rotation forKey:@"x_rotation"];
}

- (void)get_y_rotation:(NSMutableDictionary *)dictionary {
    NSNumber *y_rotation = [NSNumber numberWithFloat:[[view.layer valueForKeyPath:@"transform.rotation.y"] floatValue] * 180.0/M_PI];
        
    [dictionary setObject:y_rotation forKey:@"y_rotation"];
}

- (void)get_z_rotation:(NSMutableDictionary *)dictionary {
    NSNumber *z_rotation = [NSNumber numberWithFloat:[[view.layer valueForKeyPath:@"transform.rotation.z"] floatValue] * 180.0/M_PI];
        
    [dictionary setObject:z_rotation forKey:@"z_rotation"];
}

/**
 * Get Opacity
 */

- (void)get_opacity:(NSMutableDictionary *)dictionary {
    NSNumber *opacity = [NSNumber numberWithFloat:(view.alpha * 255.0)];
        
    [dictionary setObject:opacity forKey:@"opacity"];
}

/**
 * Get Clip
 */

- (void)get_clip:(NSMutableDictionary *)dictionary {
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
    
    for (NSString *property in [properties allKeys]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"get_%@:", property]);
    
        if ([TrickplayUIElement instancesRespondToSelector:selector]) {
            [self performSelector:selector withObject:JSON_Dictionary];
        } else {
            [JSON_Dictionary removeObjectForKey:property];
        }
    }
     
    return JSON_Dictionary;
}


#pragma mark -
#pragma mark Function handling

- (id)do_hide:(NSArray *)args {
    self.hidden = YES;
    return [NSNumber numberWithBool:YES];
}

- (id)do_hide_all:(NSArray *)args {
    self.hidden = YES;
    for (UIView *child in [self.view subviews]) {
        child.hidden = YES;
    }
    return [NSNumber numberWithBool:YES];
}

- (id)do_show:(NSArray *)args {
    self.hidden = NO;
    return [NSNumber numberWithBool:YES];
}

- (id)do_show_all:(NSArray *)args {
    self.hidden = NO;
    for (UIView *child in [self.view subviews]) {
        child.hidden = NO;
    }
    return [NSNumber numberWithBool:YES];;
}

- (id)do_move_by:(NSArray *)args {
    CGFloat x = view.layer.position.x + [[args objectAtIndex:0] floatValue];
    CGFloat y = view.layer.position.y + [[args objectAtIndex:1] floatValue];
    
    view.layer.position = CGPointMake(x, y);
    return [NSNumber numberWithBool:YES];
}

- (id)do_unparent:(NSArray *)args {
    [self removeFromSuperview];
    return [NSNumber numberWithBool:YES];
}

- (id)do_raise:(NSArray *)args {
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
    
    return [NSNumber numberWithBool:raiseSelf];
}

- (id)do_raise_to_top:(NSArray *)args {
    if (!self.superview) {
        return [NSNumber numberWithBool:NO];
    }
    
    [self.superview bringSubviewToFront:self];
    return [NSNumber numberWithBool:YES];
}

- (id)do_lower:(NSArray *)args {
    if (!self.superview) {
        return [NSNumber numberWithBool:NO];
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
    return [NSNumber numberWithBool:YES];
}

- (id)do_lower_to_bottom:(NSArray *)args {
    if (!self.superview) {
        return [NSNumber numberWithBool:NO];
    }
    
    [self.superview sendSubviewToBack:self];
    return [NSNumber numberWithBool:YES];
}

- (id)do_move_anchor_point:(NSArray *)args {
    if (!([args count] >= 2)) {
        return [NSNumber numberWithBool:NO];
    }
    
    CGFloat
    x = [[args objectAtIndex:0] floatValue],
    y = [[args objectAtIndex:1] floatValue];
    
    view.layer.anchorPoint = CGPointMake(x, y);
    return [NSNumber numberWithBool:YES]; 
}

#pragma mark -
#pragma mark New Protocol

- (id)callMethod:(NSString *)method withArgs:(NSArray *)args {
    id result = nil;
        
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"do_%@:", method]);
        
    if ([TrickplayUIElement instancesRespondToSelector:selector]) {
        result = [self performSelector:selector withObject:args];
    }
    
    return result;
}


- (void)dealloc {
    self.view = nil;
    self.clip = nil;
    self.ID = nil;
    self.name = nil;
    
    if ([self superview]) {
        [self removeFromSuperview];
    }
    
    [super dealloc];
}

@end
