//
//  TrickplayUIElement.m
//  TrickplayController
//
//  Created by Rex Fenley on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayUIElement.h"
#import "TrickplayRectangle.h"
#import "TrickplayText.h"
#import "TrickplayTextHTML.h"
#import "TrickplayImage.h"
#import "TrickplayGroup.h"

@implementation TrickplayUIElement

/*
@synthesize x_scale;
@synthesize y_scale;
@synthesize z_scale;
@synthesize x_rotation;
@synthesize y_rotation;
@synthesize z_rotation;
 */

@synthesize clip;
@synthesize view;
@synthesize ID;
@synthesize name;
@synthesize manager;
@synthesize timeLine;

@synthesize x_position;
@synthesize y_position;
@synthesize z_position;
@synthesize w_size;
@synthesize h_size;
@synthesize x_scale;
@synthesize y_scale;
@synthesize z_scale;
@synthesize x_rotation;
@synthesize y_rotation;
@synthesize z_rotation;
@synthesize x_rot_point;
@synthesize y_rot_point;
@synthesize z_rot_point;
@synthesize opacity;

- (id)initWithID:(NSString *)theID objectManager:(AdvancedUIObjectManager *)objectManager {
    if ((self = [super init])) {
        activeTouches = CFDictionaryCreateMutable(NULL, 10, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        touchNumber = 0;
        
        /*
        self.x_scale = [NSNumber numberWithFloat:1.0];
        self.y_scale = [NSNumber numberWithFloat:1.0];
        self.z_scale = [NSNumber numberWithFloat:1.0];
        self.x_rotation = [NSNumber numberWithFloat:0.0];
        self.y_rotation = [NSNumber numberWithFloat:0.0];
        self.z_rotation = [NSNumber numberWithFloat:0.0];
         */
        x_position = 0.0;
        y_position = 0.0;
        z_position = 0.0;
        w_size = 0.0;
        h_size = 0.0;
        x_scale = 1.0;
        y_scale = 1.0;
        z_scale = 1.0;
        x_rotation = 0.0;
        y_rotation = 0.0;
        z_rotation = 0.0;
        x_anchor = 0.0;
        y_anchor = 0.0;
        opacity = 1.0;
        
        animations = [[NSMutableDictionary alloc] initWithCapacity:20];
        self.timeLine = nil;
        
        self.manager = objectManager;
        
        self.clip = nil;
        self.ID = theID;
        self.name = nil;
        
        self.frame = [[UIScreen mainScreen] applicationFrame];
        self.layer.anchorPoint = CGPointMake(0.0, 0.0);
        self.layer.position = CGPointMake(0.0, 0.0);
        
        clip_x = self.frame.origin.x;
        clip_y = self.frame.origin.y;
        clip_w = self.frame.size.width;
        clip_h = self.frame.size.height;
    }
    
    return self;
}

#pragma mark -
#pragma Touch Event Handling



// TODO: Give this its own TouchController
// (i.e. Generalize the TouchController Class)


- (void)addTouch:(UITouch *)touch {
    CFDictionarySetValue(activeTouches, touch, (CFNumberRef)[NSNumber numberWithUnsignedInt:touchNumber]);
    //[activeTouches setObject:[NSNumber numberWithInt:openFinger] forKey:touch];
    touchNumber++;
}

- (void)removeTouch:(UITouch *)touch {
    CFDictionaryRemoveValue(activeTouches, touch);
}

- (void)sendTouches:(NSArray *)touches withState:(NSString *)state {
    //NSLog(@"touch sent");
    NSMutableDictionary *JSON_dic = [[NSMutableDictionary alloc] initWithCapacity:10];
    NSMutableArray *touchNumbers = [[NSMutableArray alloc] initWithCapacity:10];
    for (UITouch *touch in touches) {
        [touchNumbers addObject:(NSNumber *)CFDictionaryGetValue(activeTouches, touch)];
    }
    
    if ([touchNumbers count] > 0) {
        [JSON_dic setObject:state forKey:@"state"];
        [JSON_dic setObject:ID forKey:@"id"];
        [JSON_dic setObject:touchNumbers forKey:@"touch_id_list"];
        [JSON_dic setObject:@"touch" forKey:@"event"];
    
        [manager.gestureViewController sendEvent:@"UX" JSON:[JSON_dic yajl_JSONString]];
    }
    [touchNumbers release];
    [JSON_dic release];
}

- (void)handleTouchesBegan:(NSSet *)touches {
    //NSLog(@"handle touches began: %@", self);
    if (manager && manager.gestureViewController) {
        CFMutableArrayRef newTouches = (CFMutableArrayRef)[[NSMutableArray alloc] initWithCapacity:10];
        for (UITouch *touch in [touches allObjects]) {
            CGFloat
            x = [touch locationInView:self].x,
            y = [touch locationInView:self].y,
            x_sub = [touch locationInView:view].x,
            y_sub = [touch locationInView:view].y;
            
            // check that its within clipping range
            if (x >= self.bounds.origin.x
                && x <= self.bounds.size.width
                && y >= self.bounds.origin.y
                && y <= self.bounds.size.height
                // check that its within object range
                && x_sub >= view.bounds.origin.x
                && x_sub <= view.bounds.size.width
                && y_sub >= view.bounds.origin.y
                && y_sub <= view.bounds.size.height) {
                
                CFArrayAppendValue(newTouches, touch);
                [self addTouch:touch];
            }
        }
        if (((NSArray *)newTouches).count > 0) {
            [self sendTouches:(NSArray *)newTouches withState:@"down"];
        }
        CFRelease(newTouches);
    }
}

- (void)handleTouchesMoved:(NSSet *)touches {
    if (manager && manager.gestureViewController) {
        CFMutableArrayRef newTouchesIn = (CFMutableArrayRef)[[NSMutableArray alloc] initWithCapacity:10];
        CFMutableArrayRef newTouchesOut = (CFMutableArrayRef)[[NSMutableArray alloc] initWithCapacity:10];
        for (UITouch *touch in [touches allObjects]) {
            if (CFDictionaryGetValue(activeTouches, touch)) {
                CGFloat
                x = [touch locationInView:self].x,
                y = [touch locationInView:self].y,
                x_sub = [touch locationInView:view].x,
                y_sub = [touch locationInView:view].y;
                // check that its within clipping range
                if (x >= self.bounds.origin.x
                    && x <= self.bounds.size.width
                    && y >= self.bounds.origin.y
                    && y <= self.bounds.size.height
                    // check that its within object range
                    && x_sub >= view.bounds.origin.x
                    && x_sub <= view.bounds.size.width
                    && y_sub >= view.bounds.origin.y
                    && y_sub <= view.bounds.size.height) {
                    
                    CFArrayAppendValue(newTouchesIn, touch);
                } else {
                    CFArrayAppendValue(newTouchesOut, touch);
                }
            }
        }
        if (((NSArray *)newTouchesIn).count > 0) {
            [self sendTouches:(NSArray *)newTouchesIn withState:@"moved_inside"];
        }
        if (((NSArray *)newTouchesOut).count > 0) {
            [self sendTouches:(NSArray *)newTouchesOut withState:@"moved_outside"];
        }
        CFRelease(newTouchesIn);
        CFRelease(newTouchesOut);
    }
}

- (void)handleTouchesEnded:(NSSet *)touches {
    if (manager && manager.gestureViewController) {
        CFMutableArrayRef newTouchesIn = (CFMutableArrayRef)[[NSMutableArray alloc] initWithCapacity:10];
        CFMutableArrayRef newTouchesOut = (CFMutableArrayRef)[[NSMutableArray alloc] initWithCapacity:10];
        for (UITouch *touch in [touches allObjects]) {
            if (CFDictionaryGetValue(activeTouches, touch)) {
                CGFloat
                x = [touch locationInView:self].x,
                y = [touch locationInView:self].y,
                x_sub = [touch locationInView:view].x,
                y_sub = [touch locationInView:view].y;
                // check that its within clipping range
                if (x >= self.bounds.origin.x
                    && x <= self.bounds.size.width
                    && y >= self.bounds.origin.y
                    && y <= self.bounds.size.height
                    // check that its within object range
                    && x_sub >= view.bounds.origin.x
                    && x_sub <= view.bounds.size.width
                    && y_sub >= view.bounds.origin.y
                    && y_sub <= view.bounds.size.height) {
                    
                    CFArrayAppendValue(newTouchesIn, touch);
                } else {
                    CFArrayAppendValue(newTouchesOut, touch);
                }
            }
        }
        if (((NSArray *)newTouchesIn).count > 0) {
            [self sendTouches:(NSArray *)newTouchesIn withState:@"ended_inside"];
        }
        if (((NSArray *)newTouchesOut).count > 0) {
            [self sendTouches:(NSArray *)newTouchesOut withState:@"ended_outside"];
        }
        CFRelease(newTouchesIn);
        CFRelease(newTouchesOut);
    }
    
    for (UITouch *touch in [touches allObjects]) {
        [self removeTouch:touch];
    }
}

- (void)handleTouchesCancelled:(NSSet *)touches {
    if (manager && manager.gestureViewController) {
        CFMutableArrayRef newTouches = (CFMutableArrayRef)[[NSMutableArray alloc] initWithCapacity:10];
        for (UITouch *touch in [touches allObjects]) {
            if (CFDictionaryGetValue(activeTouches, touch)) {
                CFArrayAppendValue(newTouches, touch);
            }
        }
        if (((NSArray *)newTouches).count > 0) {
            [self sendTouches:(NSArray *)newTouches withState:@"cancelled"];
        }
        CFRelease(newTouches);
    }
    
    for (UITouch *touch in [touches allObjects]) {
        [self removeTouch:touch];
    }
}

#pragma mark -
#pragma Useful functions

/**
 * Returns a frame built from the x, y, width, and height in the args.
 *
 * NOT A GETTER FUNCTION. Used to contruct frames for building AdvancedUI Objects.
 */

- (CGRect)getFrameFromArgs:(NSDictionary *)args {
    NSArray *size = [args objectForKey:@"size"];
    CGFloat x = 0.0, y = 0.0, width = 0.0, height = 0.0;
    
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
    
    return CGRectMake(x, y, width, height);
}

/////// not a function from Trickplay, just a helper method
- (NSMutableDictionary *)createObjectJSONFromObject:(TrickplayUIElement *)object {
    NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    [objectDictionary setObject:object.ID forKey:@"id"];
    if ([object isKindOfClass:[TrickplayRectangle class]]) {
        [objectDictionary setObject:@"Rectangle" forKey:@"type"];
    } else if ([object isKindOfClass:[TrickplayImage class]]) {
        [objectDictionary setObject:@"Image" forKey:@"type"];
    } else if ([object isKindOfClass:[TrickplayTextHTML class]]) {
        [objectDictionary setObject:@"Text" forKey:@"type"];
    } else if ([object isKindOfClass:[TrickplayGroup class]]) {
        [objectDictionary setObject:@"Group" forKey:@"type"];
    }
    
    return objectDictionary;
}
///////////////////////////

- (CGFloat)get_x_prime {
    return (x_rot_point + x_position) - x_rot_point*cos(z_rotation) + y_rot_point*sin(z_rotation);
}

- (CGFloat) get_x_prime_half:(CGFloat)z_rot_initial {
    CGFloat z_rot_half = (CGFloat)0.5*(z_rot_initial + z_rotation);    
    return (x_rot_point + x_position) - x_rot_point*cos(z_rot_half) + y_rot_point*sin(z_rot_half);
}

- (CGFloat)get_y_prime {
    return (y_rot_point + y_position) - x_rot_point*sin(z_rotation) - y_rot_point*cos(z_rotation);
}

- (CGFloat)get_y_prime_half:(CGFloat)z_rot_initial {
    CGFloat z_rot_half = (CGFloat)0.5*(z_rot_initial + z_rotation);
    return (y_rot_point + y_position) - x_rot_point*sin(z_rot_half) - y_rot_point*cos(z_rot_half);
}

- (CGFloat)get_bezier_middle_point_x:(CGFloat)x_initial :(CGFloat)z_rot_initial {
    return 2*[self get_x_prime_half:z_rot_initial] - .5*(x_initial + [self get_x_prime]);
}

- (CGFloat)get_bezier_middle_point_y:(CGFloat)y_initial :(CGFloat)z_rot_initial {
    return 2*[self get_y_prime_half:z_rot_initial] - .5*(y_initial + [self get_y_prime]);
}

/**
 * The most important function of them all
 */

- (void)rotate_and_translate {
    CGFloat x_prime = [self get_x_prime];
    CGFloat y_prime = [self get_y_prime];
    
    self.layer.position = CGPointMake(x_prime, y_prime);
}

#pragma mark -
#pragma mark Setters

/**
 * Set the Name
 */

- (void)set_name:(NSDictionary *)args {
    if ([args objectForKey:@"name"] && [[args objectForKey:@"name"] isKindOfClass:[NSString class]]) {
        self.name = [args objectForKey:@"name"];
    }
}

/**
 * Set Position
 */

- (void)set_position:(NSDictionary *)args {
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
        self.layer.zPosition = [z floatValue];
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0/-2000;
        self.layer.transform = CATransform3DConcat(self.layer.transform, transform);
        //view.layer.transform = CATransform3DMakeTranslation(0.0, 0.0, [z floatValue]);
        //[view.layer setValue:z forKeyPath:@"transform.translation.z"];
        //NSLog(@"z after: %@", [view.layer valueForKeyPath:@"transform.translation.z"]);
    }
    if (!x && !y) {
        return;
    }
    
    if (x) {
        x_position = [x floatValue];
    }
    if (y) {
        y_position = [y floatValue];
    }
    
    [self rotate_and_translate];
}

- (void)set_x:(NSDictionary *)args {
    [self set_position:args];
}

- (void)set_y:(NSDictionary *)args {
    [self set_position:args];
}

- (void)set_z:(NSDictionary *)args {
    if ([args objectForKey:@"z"]) {
        //view.layer.transform = CATransform3DMakeTranslation(0.0, 0.0, [[args objectForKey:@"z"] floatValue]);
        self.layer.zPosition = [[args objectForKey:@"z"] floatValue];
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0/-2000;
        self.layer.transform = CATransform3DConcat(self.layer.transform, transform);
    }
}

- (void)set_depth:(NSDictionary *)args {
    if ([args objectForKey:@"depth"]) {
        self.layer.zPosition = [[args objectForKey:@"depth"] floatValue];
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0/-2000;
        self.layer.transform = CATransform3DConcat(self.layer.transform, transform);
    }
}


/**
 * Set the Size
 */

- (void)set_size:(NSDictionary *)args {
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
        //width = [NSNumber numberWithFloat:view.bounds.size.width];
    }
    if (!height) {
        height = [NSNumber numberWithFloat:view.layer.bounds.size.height];
        //height = [NSNumber numberWithFloat:view.bounds.size.height];
    }
    
    w_size = [width floatValue];
    h_size = [height floatValue];
    
    view.bounds = CGRectMake(0.0, 0.0, [width floatValue], [height floatValue]);
    
    [view setNeedsDisplay];
}

- (void)set_w:(NSDictionary *)args {
    [self set_size:args];
}

- (void)set_h:(NSDictionary *)args {
    [self set_size:args];
}

- (void)set_width:(NSDictionary *)args {
    [self set_size:args];
}

- (void)set_height:(NSDictionary *)args {
    [self set_size:args];
}


/**
 * Anchor Point
 *
 * anchor point is a CGPoint{0.0 <= x <= 1.0, 0.0 <= y <= 1.0}
 */

- (void)set_anchor {
    CGFloat
    x = (x_anchor + view.layer.position.x)/self.bounds.size.width,
    y = (y_anchor + view.layer.position.y)/self.bounds.size.height;
    
    self.layer.anchorPoint = CGPointMake(x, y);
}

- (void)set_anchor_point:(NSDictionary *)args {
    if (![[args objectForKey:@"anchor_point"] isKindOfClass:[NSArray class]]) {
        return;
    }
    NSArray *anchorPoint = [args objectForKey:@"anchor_point"];
    if (!anchorPoint || [anchorPoint count] < 2) {
        return;
    }
    
    //NSLog(@"anchor_x: %f, anchor_y: %f", [(NSNumber *)[anchorPoint objectAtIndex:0] floatValue], [(NSNumber *)[anchorPoint objectAtIndex:1] floatValue]);
    //NSLog(@"view.layer.position.x: %f; view.layer.position.y: %f", view.layer.position.x, view.layer.position.y);
    
    x_anchor = [(NSNumber *)[anchorPoint objectAtIndex:0] floatValue];
    y_anchor = [(NSNumber *)[anchorPoint objectAtIndex:1] floatValue];
    
    [self set_anchor];
}


/**
 * Scale the element
 */

- (void)set_scale:(NSDictionary *)args {
    if (![[args objectForKey:@"scale"] isKindOfClass:[NSArray class]]) {
        return;
    }
    NSArray *layer_scale = [args objectForKey:@"scale"];
    if (!layer_scale || [layer_scale count] < 2) {
        return;
    }
    
    /*
    self.x_scale = [layer_scale objectAtIndex:0];
    self.y_scale = [layer_scale objectAtIndex:1];
    
    [view.layer setValue:x_scale forKeyPath:@"transform.scale.x"];
    [view.layer setValue:y_scale forKeyPath:@"transform.scale.y"];
    
    if ([layer_scale count] > 2) {
        self.z_scale = [layer_scale objectAtIndex:2];
        [view.layer setValue:z_scale forKeyPath:@"transform.scale.z"];
    }
     */

    x_scale = [[layer_scale objectAtIndex:0] floatValue];
    y_scale = [[layer_scale objectAtIndex:1] floatValue];
    
    [self.layer setValue:[NSNumber numberWithFloat:x_scale] forKeyPath:@"transform.scale.x"];
    [self.layer setValue:[NSNumber numberWithFloat:y_scale] forKeyPath:@"transform.scale.y"];
}

/**
 * Rotate the element
 *
 * rotates along anchor point, uses degrees
 */

- (void)set_x_rotation:(NSDictionary *)args {
    if ([args objectForKey:@"x_rotation"]) {
        id arg = [args objectForKey:@"x_rotation"];
        id x_rot = nil;
        if ([arg isKindOfClass:[NSNumber class]]) {
            x_rot = arg;
        } else if ([arg isKindOfClass:[NSArray class]]) {
            x_rot = [(NSArray *)arg objectAtIndex:0];
        } else {
            return;
        }
        if (![x_rot isKindOfClass:[NSNumber class]]) {
            return;
        }
        x_rot = [NSNumber numberWithFloat:[x_rot floatValue] * M_PI/180.0];
        [self.layer setValue:x_rot forKeyPath:@"transform.rotation.x"];
        x_rotation = [x_rot floatValue];
        
        [self rotate_and_translate];
    }
}

- (void)set_y_rotation:(NSDictionary *)args {
    if ([args objectForKey:@"y_rotation"]) {
        id arg = [args objectForKey:@"y_rotation"];
        id y_rot = nil;
        if ([arg isKindOfClass:[NSNumber class]]) {
            y_rot = arg;
        } else if ([arg isKindOfClass:[NSArray class]]) {
            y_rot = [(NSArray *)arg objectAtIndex:0];
        } else {
            return;
        }
        if (![y_rot isKindOfClass:[NSNumber class]]) {
            return;
        }
        y_rot = [NSNumber numberWithFloat:[y_rot floatValue] * M_PI/180.0];
        [self.layer setValue:y_rot forKeyPath:@"transform.rotation.y"];
        y_rotation = [y_rot floatValue];
        
        [self rotate_and_translate];
    }
}

- (void)set_z_rotation:(NSDictionary *)args {
    if ([args objectForKey:@"z_rotation"]) {
        id arg = [args objectForKey:@"z_rotation"];
        id z_rot = nil;
        if ([arg isKindOfClass:[NSNumber class]]) {
            z_rot = arg;
            x_rot_point = 0.0;
            y_rot_point = 0.0;
        } else if ([arg isKindOfClass:[NSArray class]]) {
            z_rot = [(NSArray *)arg objectAtIndex:0];
            if ([arg count] >= 2) {
                x_rot_point = [[(NSArray *)arg objectAtIndex:1] floatValue];
                y_rot_point = [[(NSArray *)arg objectAtIndex:2] floatValue];
            }
        } else {
            return;
        }
        if (![z_rot isKindOfClass:[NSNumber class]]) {
            return;
        }
        z_rot = [NSNumber numberWithFloat:[z_rot floatValue] * M_PI/180.0];
        [self.layer setValue:z_rot forKeyPath:@"transform.rotation.z"];
        z_rotation = [z_rot floatValue];
        
        [self rotate_and_translate];
    }
}




/**
 * Set opacity
 */

- (void)set_opacity:(NSDictionary *)args {
    id theOpacity = [args objectForKey:@"opacity"];
    if (theOpacity && [theOpacity isKindOfClass:[NSNumber class]]) {
        self.view.alpha = [(NSNumber *)[args objectForKey:@"opacity"] floatValue]/255.0;
        opacity = self.view.alpha;
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

- (void)set_clip:(NSDictionary *)args {
    if (![[args objectForKey:@"clip"] isKindOfClass:[NSArray class]]) {
        return;
    }
    self.clip = [args objectForKey:@"clip"];
    
    if (clip.count > 3) {
        clip_x = [(NSNumber *)[clip objectAtIndex:0] floatValue];
        clip_y = [(NSNumber *)[clip objectAtIndex:1] floatValue];
        clip_w = [(NSNumber *)[clip objectAtIndex:2] floatValue];
        clip_h = [(NSNumber *)[clip objectAtIndex:3] floatValue];
        // create the bounding box
        
        /* for testing
        NSLog(@"clip before: %f, %f, %f, %f", self.layer.bounds.origin.x, self.layer.bounds.origin.y, self.layer.bounds.size.width, self.layer.bounds.size.height);
        NSLog(@"Frame before: %f, %f, %f, %f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        //*/
        
        self.bounds = CGRectMake(0.0, 0.0, clip_w, clip_h);
        view.layer.position = CGPointMake(-clip_x, -clip_y);
        [self set_anchor];
        [self rotate_and_translate];
        //self.layer.position = CGPointMake(clip_x + clip_w/2.0, clip_y + clip_h/2.0);
        
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
    NSLog(@"ERROR: method setValuesFromArgs:(NSDictionary *) must be overwritten");
}

#pragma mark -
#pragma mark Deleter

/**
 * Delete Clip
 */

- (void)delete_clip {
    self.clipsToBounds = NO;
}

- (void)deleteValuesFromArgs:(NSDictionary *)args {
    NSLog(@"ERROR: method deleteValuesFromArgs:(NSDictionary *) must be overwritten");
}

#pragma mark -
#pragma mark Getters

/**
 * Get GID
 */

- (void)get_gid:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithLong:[ID longLongValue]] forKey:@"gid"];
}

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
    NSArray *position = [NSArray arrayWithObjects:[NSNumber numberWithFloat:x_position], [NSNumber numberWithFloat:y_position], [NSNumber numberWithFloat:self.layer.zPosition], nil];
        
    [dictionary setObject:position forKey:@"position"];
}

- (void)get_x:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithFloat:x_position] forKey:@"x"];
}

- (void)get_y:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithFloat:y_position] forKey:@"y"];
}

- (void)get_z:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithFloat:self.layer.zPosition] forKey:@"z"];
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
    NSArray *anchor_point = [NSArray arrayWithObjects:[NSNumber numberWithFloat:x_anchor], [NSNumber numberWithFloat:y_anchor], [NSNumber numberWithFloat:self.layer.anchorPointZ], nil];
        
    [dictionary setObject:anchor_point forKey:@"anchor_point"];
}

/**
 * Get Scale
 */

- (void)get_scale:(NSMutableDictionary *)dictionary {
    NSArray *scale = [NSArray arrayWithObjects:[self.layer valueForKeyPath:@"transform.scale.x"], [self.layer valueForKeyPath:@"transform.scale.y"], [self.layer valueForKeyPath:@"transform.scale.z"], nil];
        
    [dictionary setObject:scale forKey:@"scale"];
}

/**
 * Get Rotation
 */

- (void)get_x_rotation:(NSMutableDictionary *)dictionary {
    NSNumber *x_rot = [NSNumber numberWithFloat:[[self.layer valueForKeyPath:@"transform.rotation.x"] floatValue] * 180.0/M_PI];
        
    [dictionary setObject:x_rot forKey:@"x_rotation"];
}

- (void)get_y_rotation:(NSMutableDictionary *)dictionary {
    NSNumber *y_rot = [NSNumber numberWithFloat:[[self.layer valueForKeyPath:@"transform.rotation.y"] floatValue] * 180.0/M_PI];
        
    [dictionary setObject:y_rot forKey:@"y_rotation"];
}

- (void)get_z_rotation:(NSMutableDictionary *)dictionary {
    NSNumber *z_rot = [NSNumber numberWithFloat:[[self.layer valueForKeyPath:@"transform.rotation.z"] floatValue] * 180.0/M_PI];
        
    [dictionary setObject:z_rot forKey:@"z_rotation"];
}

/**
 * is Scaled
 */

- (void)get_is_scaled:(NSMutableDictionary *)dictionary {
    BOOL truf = !( (x_scale == 1.0) && (y_scale == 1.0) && (z_scale == 1.0) );
    
    [dictionary setObject:[NSNumber numberWithBool:truf] forKey:@"is_scaled"];
}

/**
 * is Rotated
 */

- (void)get_is_rotated:(NSMutableDictionary *)dictionary {
    BOOL truf = !( (x_rotation == 0.0) && (y_rotation == 0.0) && (z_rotation == 0.0) );
    
    [dictionary setObject:[NSNumber numberWithBool:truf] forKey:@"is_rotated"];
}

/**
 * Get Opacity
 */

- (void)get_opacity:(NSMutableDictionary *)dictionary {
    NSNumber *theOpacity = [NSNumber numberWithFloat:(view.alpha * 255.0)];
        
    [dictionary setObject:theOpacity forKey:@"opacity"];
}

/**
 * Get Clip
 */

- (void)get_clip:(NSMutableDictionary *)dictionary {
    if (!self.clipsToBounds) {
        [dictionary removeObjectForKey:@"clip"];
    } else if ([dictionary objectForKey:@"clip"]) {
        NSArray *clipBox = [NSArray arrayWithObjects:[NSNumber numberWithFloat:clip_x], [NSNumber numberWithFloat:clip_y], [NSNumber numberWithFloat:clip_w], [NSNumber numberWithFloat:clip_h], nil];
        
        [dictionary setObject:clipBox forKey:@"clip"];
    }
}

- (void)get_has_clip:(NSMutableDictionary *)dictionary {
    if (self.clipsToBounds) {
        [dictionary setObject:[NSNumber numberWithBool:YES] forKey:@"has_clip"];
    } else {
        [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"has_clip"];
    }
}

/**
 * Get center
 */

- (void)get_center:(NSMutableDictionary *)dictionary {
    NSArray *coords = [NSArray arrayWithObjects:[NSNumber numberWithFloat:view.center.x + x_position - x_anchor], [NSNumber numberWithFloat:view.center.y + y_position - y_anchor], nil];
    [dictionary setObject:coords forKey:@"center"];
}

/**
 * Check visibility, only changes with do_show: do_hide: methods
 */

- (void)get_is_visible:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithBool:!self.hidden] forKey:@"is_visible"];
}

/**
 * Check to see if object is animating.
 */

- (void)get_is_animating:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithBool:(animations.count > 0)] forKey:@"is_animating"];
}

/**
 * Getter function
 */

- (NSDictionary *)getValuesFromArgs:(NSDictionary *)properties {
    NSLog(@"ERROR: getValuesFromArgs:(NSDictioanry *) must be overwritten");
    
    return nil;
}


#pragma mark -
#pragma mark Function handling

- (id)do_set:(NSArray *)args {
    id properties = [args objectAtIndex:0];
    NSLog(@"properties for set: %@", properties);
    if ([properties isKindOfClass:[NSDictionary class]]) {
        [self setValuesFromArgs:properties];
        return [NSNumber numberWithBool:YES];
    }
    
    return [NSNumber numberWithBool:NO];
}

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
    if (!([args count] >= 2)) {
        return [NSNumber numberWithBool:NO];
    }
    
    x_position += [[args objectAtIndex:0] floatValue];
    y_position += [[args objectAtIndex:1] floatValue];
    
    [self rotate_and_translate];
    return [NSNumber numberWithBool:YES];
}

/**
 * Get parent
 */

- (id)do_get_parent:(NSArray *)args {
    TrickplayUIElement *parent = nil;
    if ([self.superview isKindOfClass:[TrickplayUIElement class]]) {
        parent = (TrickplayUIElement *)self.superview;
    } else if ([self.superview.superview isKindOfClass:[TrickplayUIElement class]]) {
        parent = (TrickplayUIElement *)self.superview.superview;
    } else {
        return nil;
    }
    
    NSDictionary *parentDictionary = [self createObjectJSONFromObject:parent];
    return parentDictionary;
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
// TODO: fix this
- (id)do_move_anchor_point:(NSArray *)args {
    if (!([args count] >= 2)) {
        return [NSNumber numberWithBool:NO];
    }
    
    CGFloat
    x = [(NSNumber *)[args objectAtIndex:0] floatValue]/w_size + view.layer.position.x,
    y = [(NSNumber *)[args objectAtIndex:1] floatValue]/h_size + view.layer.position.y;
    
    self.layer.anchorPoint = CGPointMake(x, y);
    return [NSNumber numberWithBool:YES];
}

- (id)do_transform_point:(NSArray *)args {
    TrickplayUIElement *ancestor = [manager findObjectForID:[(NSDictionary *)[args objectAtIndex:0] objectForKey:@"id"]];
    NSLog(@"ancester: %@", ancestor);
    if (ancestor && ([args count] > 2)) {
        CGPoint point = CGPointMake([[args objectAtIndex:1] floatValue], [[args objectAtIndex:2] floatValue]);
        CGPoint transformedPoint = [view.layer convertPoint:point toLayer:ancestor.view.layer];
        return [NSArray arrayWithObjects:[NSNumber numberWithFloat:transformedPoint.x], [NSNumber numberWithFloat:transformedPoint.y], nil];
    }
    
    return [NSNumber numberWithBool:NO];
}


#pragma mark -
#pragma mark Animations

- (void)trickplayAnimationDidStop:(id)anim {
    id completion = [animations objectForKey:anim];
    if ([anim isKindOfClass:[NSMutableDictionary class]]) {
        completion = anim;
    }
    if (completion && [completion isKindOfClass:[NSMutableDictionary class]]) {
        [completion setObject:ID forKey:@"id"];
        [completion setObject:@"on_completed" forKey:@"event"];
        
        [manager.gestureViewController sendEvent:@"UX" JSON:[completion yajl_JSONString]];
    }
    
    [animations removeObjectForKey:anim];
}

- (id)do_animate:(NSArray *)args {
    //NSLog(@"do_animate:%@", args);
    
    NSMutableDictionary *table = [NSMutableDictionary dictionaryWithDictionary:[args objectAtIndex:0]];
    NSNumber *duration = [table objectForKey:@"duration"];
    [table removeObjectForKey:@"duration"];
    if (!duration) {
        return [NSNumber numberWithBool:NO];
    }
    
    if (timeLine) {
        if ([table objectForKey:@"on_completed"]) {
            NSMutableDictionary *completion = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[table objectForKey:@"on_completed"], @"animation_id", nil];
            [animations setObject:completion forKey:table];
        } else {
            [animations setObject:@"1" forKey:table];
        }
        [timeLine animateWithTable:table duration:duration view:self];
    } else {
        TrickplayAnimation *anim = [[TrickplayAnimation alloc] initWithTable:table duration:duration view:self];

        if ([table objectForKey:@"on_completed"]) {
            NSMutableDictionary *completion = [NSMutableDictionary dictionaryWithObjectsAndKeys:[table objectForKey:@"on_completed"], @"animation_id", nil];
            [animations setObject:completion forKey:anim];
        } else {
            [animations setObject:@"1" forKey:anim];
        }
        
        [anim animationStart];
        [anim release];
    }
    //start = CFAbsoluteTimeGetCurrent();
    
    return [NSNumber numberWithBool:YES];
}

- (id)do_complete_animation:(NSArray *)args {
    if (timeLine) {
        [timeLine removeAnimations:self];
    } else {
        for (TrickplayAnimation *anim in [animations allKeys]) {
            [anim animationDidStop:nil finished:NO];
        }
        [self.layer removeAllAnimations];
        [animations removeAllObjects];
    }
    
    return [NSNumber numberWithBool:YES];
}

#pragma mark -
#pragma mark New Protocol

- (id)callMethod:(NSString *)method withArgs:(NSArray *)args {
    id result = nil;
        
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"do_%@:", method]);
    
    if ([TrickplayUIElement instancesRespondToSelector:selector]) {
        result = [self performSelector:selector withObject:args];
        //NSLog(@"result: %@", result);
    }
    
    return result;
}

#pragma mark -
#pragma mark Copy/Deallocation

- (id)copyWithZone:(NSZone *)zone {
    return [self retain];
}

- (void)dealloc {
    if (activeTouches) {
        CFRelease(activeTouches);
    }
    if (animations) {
        [animations release];
    }
    self.timeLine = nil;
    
    self.view = nil;
    self.clip = nil;
    self.ID = nil;
    self.name = nil;
    self.manager = nil;
    
    if ([self superview]) {
        [self removeFromSuperview];
    }
    
    [super dealloc];
}

@end
