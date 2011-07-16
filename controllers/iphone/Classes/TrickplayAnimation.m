//
//  TrickplayAnimation.m
//  TrickplayController
//
//  Created by Rex Fenley on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayAnimation.h"
#import "TrickplayUIElement.h"

@implementation TrickplayAnimation

@synthesize view;
@synthesize delegate;
@synthesize table;
@synthesize duration;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id) initWithTable:(NSDictionary *)theTable duration:(NSNumber *)theDuration view:(TrickplayUIElement *)aView {
    self = [super init];
    if (self) {
        self.view = aView;
        self.table = theTable;
        self.duration = theDuration;
        delegate = (id)view;
        animationCount = 0;
        
        completion = nil;
    }
    
    return self;
}

- (void)animationStart {
    if ([table objectForKey:@"on_completed"]) {
        completion = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[table objectForKey:@"on_completed"], @"animation_id", nil];
    }
    
    NSNumber *x = [table objectForKey:@"x"];
    NSNumber *y = [table objectForKey:@"y"];
    NSNumber *z = [table objectForKey:@"z"];
    NSArray *position = [table objectForKey:@"position"];
    if (position && position.count > 1) {
        x = [position objectAtIndex:0] ? [position objectAtIndex:0] : x;
        y = [position objectAtIndex:1] ? [position objectAtIndex:1] : y;
        if (position.count > 2) {
            z = [position objectAtIndex:2] ? [position objectAtIndex:2] : z;
        }
    }
    
    NSNumber *rotation_z = nil;
    if ([table objectForKey:@"z_rotation"] && [[table objectForKey:@"z_rotation"] isKindOfClass:[NSNumber class]]) {
        rotation_z = [table objectForKey:@"z_rotation"];
    }
    
    NSNumber *w = [table objectForKey:@"w"] ? [table objectForKey:@"w"] : [table objectForKey:@"width"];
    NSNumber *h = [table objectForKey:@"h"] ? [table objectForKey:@"h"] : [table objectForKey:@"height"];
    NSArray *size = [table objectForKey:@"size"];
    if (size && size.count > 1) {
        w = [size objectAtIndex:0] ? [size objectAtIndex:0] : w;
        h = [size objectAtIndex:1] ? [size objectAtIndex:1] : h;
    }
    
    if (x) {
        view.x_position = [x floatValue];
        CABasicAnimation *animation_x = [CABasicAnimation animationWithKeyPath:@"position.x"];
        animation_x.fillMode = kCAFillModeForwards;
        animation_x.removedOnCompletion = NO;
        [animation_x setToValue:[NSNumber numberWithFloat:[view get_x_prime]]];
        [animation_x setDuration:[duration floatValue]/1000.0];
        animation_x.delegate = self;
        [view.view.layer addAnimation:animation_x forKey:@"x_position"];
        animationCount++;
    }
    if (y) {
        view.y_position = [y floatValue];
        CABasicAnimation *animation_y = [CABasicAnimation animationWithKeyPath:@"position.y"];
        animation_y.fillMode = kCAFillModeForwards;
        animation_y.removedOnCompletion = NO;
        [animation_y setToValue:[NSNumber numberWithFloat:[view get_y_prime]]];
        [animation_y setDuration:[duration floatValue]/1000.0];
        animation_y.delegate = self;
        [view.view.layer addAnimation:animation_y forKey:@"y_position"];
        animationCount++;
    }
    if (z) {
        //do nothing for now
    }
    
    if (w) {
        view.w_size = [w floatValue];
        CABasicAnimation *animation_w = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
        animation_w.fillMode = kCAFillModeForwards;
        animation_w.removedOnCompletion = NO;
        [animation_w setToValue:[NSNumber numberWithFloat:view.w_size]];
        [animation_w setDuration:[duration floatValue]/1000.0];
        animation_w.delegate = self;
        [view.view.layer addAnimation:animation_w forKey:@"w_size"];
        animationCount ++;
    }
    if (h) {
        view.h_size = [h floatValue];
        CABasicAnimation *animation_h = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
        animation_h.fillMode = kCAFillModeForwards;
        animation_h.removedOnCompletion = NO;
        [animation_h setToValue:[NSNumber numberWithFloat:view.h_size]];
        [animation_h setDuration:[duration floatValue]/1000.0];
        animation_h.delegate = self;
        [view.view.layer addAnimation:animation_h forKey:@"h_size"];
        animationCount++;
    }
    
    if (rotation_z) {
        NSNumber *z_rot = [NSNumber numberWithFloat:[rotation_z floatValue] * M_PI/180.0];
        if (view.x_rot_point != 0.0 || view.y_rot_point != 0.0) {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            animation.fillMode = kCAFillModeForwards;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            animation.removedOnCompletion = NO;
            CGMutablePathRef arc = CGPathCreateMutable();
            CGFloat x_initial = [view get_x_prime];
            CGFloat y_initial = [view get_y_prime];
            CGPathMoveToPoint(arc, NULL, x_initial, y_initial);
            CGFloat z_rot_initial = view.z_rotation;
            CGFloat gradient = ([z_rot floatValue] - view.z_rotation)/fabs(([z_rot floatValue] - view.z_rotation));
            CGFloat number_of_paths = floor(fabs([z_rot floatValue] - view.z_rotation)/(90.0*M_PI/180)) + 1;
            CGFloat path_angle = fabsf([z_rot floatValue] - view.z_rotation)/number_of_paths;
            fprintf(stderr, "number of paths: %f, path_angle: %f\n", number_of_paths, path_angle);
            view.z_rotation += path_angle*gradient;
            while (view.z_rotation*gradient < [z_rot floatValue]*gradient) {
                CGPathAddQuadCurveToPoint(arc, NULL, [view get_bezier_middle_point_x:x_initial :z_rot_initial], [view get_bezier_middle_point_y:y_initial :z_rot_initial], [view get_x_prime], [view get_y_prime]);
                
                z_rot_initial = view.z_rotation;
                x_initial = [view get_x_prime];
                y_initial = [view get_y_prime];
                view.z_rotation += path_angle*gradient;
            }
            view.z_rotation = [z_rot floatValue];
            CGPathAddQuadCurveToPoint(arc, NULL, [view get_bezier_middle_point_x:x_initial :z_rot_initial], [view get_bezier_middle_point_y:y_initial :z_rot_initial], [view get_x_prime], [view get_y_prime]);
            animation.path = arc;
            CGPathRelease(arc);
            //animation.rotationMode = kCAAnimationRotateAuto;
            animation.duration = [duration floatValue]/1000.0;
            animation.delegate = self;
            [view.view.layer addAnimation:animation forKey:@"z_rotation_arc"];
            animationCount++;
        }
        //*
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [animation setToValue:z_rot];
        [animation setDuration:[duration floatValue]/1000.0];
        animation.delegate = self;
        [view.view.layer addAnimation:animation forKey:@"z_rotation"];
        animationCount++;
        //*/
        view.z_rotation = [z_rot floatValue];
    }
    
    NSArray *scale = [table objectForKey:@"scale"];
    NSNumber *scale_x = nil;
    NSNumber *scale_y = nil;
    if (scale.count > 1) {
        scale_x = [scale objectAtIndex:0];
        scale_y = [scale objectAtIndex:1];
    }
    
    if (scale_x) {
        view.x_scale = [scale_x floatValue];
        CABasicAnimation *animation_x = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
        animation_x.fillMode = kCAFillModeForwards;
        animation_x.removedOnCompletion = NO;
        [animation_x setToValue:[NSNumber numberWithFloat:view.x_scale]];
        [animation_x setDuration:[duration floatValue]/1000.0];
        animation_x.delegate = self;
        [view.view.layer addAnimation:animation_x forKey:@"scale_x"];
        animationCount++;
    }
    if (scale_y) {
        view.y_scale = [scale_y floatValue];
        CABasicAnimation *animation_y = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
        animation_y.fillMode = kCAFillModeForwards;
        animation_y.removedOnCompletion = NO;
        [animation_y setToValue:[NSNumber numberWithFloat:view.y_scale]];
        [animation_y setDuration:[duration floatValue]/1000.0];
        animation_y.delegate = self;
        [view.view.layer addAnimation:animation_y forKey:@"scale_y"];
        animationCount++;
    }
    
    NSNumber *opacity = [table objectForKey:@"opacity"];
    if (opacity) {
        view.opacity = [opacity floatValue]/255.0;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [animation setToValue:[NSNumber numberWithFloat:view.opacity]];
        [animation setDuration:[duration floatValue]/1000.0];
        animation.delegate = self;
        [view.view.layer addAnimation:animation forKey:@"opacity"];
        animationCount++;
    }
}

#pragma mark -
#pragma mark Animation Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    /*
    for (NSString *key in [view.view.layer animationKeys]) {
        NSLog(@"key: %@", key);
        NSLog(@"animations: %@", [view.view.layer animationForKey:key]);
        NSLog(@"anim: %@", anim);
    }
    //*/
    
    //*
    if ([view.view.layer animationForKey:@"scale_x"] == anim) {
        [view.view.layer removeAnimationForKey:@"scale_x"];
        [view.view.layer setValue:[NSNumber numberWithFloat:view.x_scale] forKeyPath:@"transform.scale.x"];
    } else if ([view.view.layer animationForKey:@"scale_y"] == anim) {
        [view.view.layer removeAnimationForKey:@"scale_y"];
        [view.view.layer setValue:[NSNumber numberWithFloat:view.y_scale] forKeyPath:@"transform.scale.y"];
    } else if ([view.view.layer animationForKey:@"x_position"] == anim) {
        [view.view.layer removeAnimationForKey:@"x_position"];
        //[view.layer setValue:[NSNumber numberWithFloat:[self get_x_prime]] forKey:@"position.x"];
        view.view.layer.position = CGPointMake([view get_x_prime], [view get_y_prime]);
    } else if ([view.view.layer animationForKey:@"y_position"] == anim) {
        [view.view.layer removeAnimationForKey:@"y_position"];
        //[view.layer setValue:[NSNumber numberWithFloat:[self get_y_prime]] forKey:@"position.y"];
        view.view.layer.position = CGPointMake([view get_x_prime], [view get_y_prime]);
    } else if ([view.view.layer animationForKey:@"w_size"] == anim) {
        [view.view.layer removeAnimationForKey:@"w_size"];
        view.view.layer.bounds = CGRectMake(0.0, 0.0, view.w_size, view.h_size);
    } else if ([view.view.layer animationForKey:@"h_size"] == anim) {
        [view.view.layer removeAnimationForKey:@"h_size"];
        view.view.layer.bounds = CGRectMake(0.0, 0.0, view.w_size, view.h_size);
    } else if ([view.view.layer animationForKey:@"z_rotation"] == anim) {
        [view.view.layer removeAnimationForKey:@"z_rotation"];
        [view.view.layer setValue:[NSNumber numberWithFloat:view.z_rotation] forKeyPath:@"transform.rotation.z"];
    } else if ([view.view.layer animationForKey:@"z_rotation_arc"] == anim) {
        [view.view.layer removeAnimationForKey:@"z_rotation_arc"];
        view.view.layer.position = CGPointMake([view get_x_prime], [view get_y_prime]);
    } else if ([view.view.layer animationForKey:@"opacity"] == anim) {
        [view.view.layer removeAnimationForKey:@"opacity"];
        view.view.layer.opacity = view.opacity;
    }
    //*
    animationCount--;
    
    if (animationCount <= 0) {
        if (completion) {
            [completion setObject:view.ID forKey:@"id"];
            [completion setObject:@"on_completed" forKey:@"event"];
            
            [view.manager.gestureViewController sendEvent:@"UX" JSON:[completion yajl_JSONString]];
        }
        [delegate trickplayAnimationDidStop:self];
    }
    //*/
}

- (id)copyWithZone:(NSZone *)zone {
    return [self retain];
}

- (void)dealloc {
    self.view = nil;
    self.duration = nil;
    self.table = nil;
    
    if (completion) {
        [completion release];
        completion = nil;
    }
    
    [super dealloc];
}

@end
