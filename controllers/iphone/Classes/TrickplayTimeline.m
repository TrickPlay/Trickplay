//
//  TrickplayTimeline.m
//  TrickplayController
//
//  Created by Rex Fenley on 8/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayTimeline.h"
#import "TrickplayUIElement.h"
#import "AdvancedUIObjectManager.h"

@implementation TrickplayTimeline

@synthesize blocks;
@synthesize timeLine;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.blocks = [NSMutableArray arrayWithCapacity:20];
        self.timeLine = nil;
    }
    
    return self;
}

#pragma mark -
#pragma mark Timeline controls

- (void)callTimeline:(CADisplayLink *)sender {
    //fprintf(stderr, "timestamp: %f\n", [timeLine timestamp]);
    //fprintf(stderr, "duration: %f\n", [timeLine duration]);
    
    // dispatch_syncronously all blocks
    // delete block if return = NO
    NSMutableArray *blocksToRemove = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary *blockInfo in blocks) {
        //fprintf(stderr, "timestamp: %f\n", [timeLine timestamp]);
        //fprintf(stderr, "duration: %f\n", [timeLine duration]);
        NSArray *args;
        if ([blockInfo objectForKey:@"args"]) {
            args = [blockInfo objectForKey:@"args"];
        } else {
            args = [NSArray arrayWithObjects:[blockInfo objectForKey:@"startTime"], [NSNumber numberWithFloat:[timeLine timestamp]], nil];
        }
        BOOL (^block)(NSArray *) = [blockInfo objectForKey:@"block"];
        BOOL keepAlive = block(args);
        
        if (!keepAlive) {
            [blocksToRemove addObject:blockInfo];
        }
    }
    for (NSDictionary *blockInfo in blocksToRemove) {
        [blocks removeObject:blockInfo];
    }
}

- (void)startTimeline {
    self.timeLine = [CADisplayLink displayLinkWithTarget:self selector:@selector(callTimeline:)];
    [timeLine addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopTimeline {
    [timeLine invalidate];
    self.timeLine = nil;
}

- (void)addBlock:(BOOL (^)(NSArray *args))block args:(NSArray *)args {
    BOOL (^copied_block)(NSArray *args) = Block_copy(block);
    if (args) {
        [blocks addObject:[NSDictionary dictionaryWithObjectsAndKeys:args, @"args", copied_block, @"block", [NSNumber numberWithFloat:[timeLine timestamp]], @"startTime", nil]];
    } else {
        [blocks addObject:[NSDictionary dictionaryWithObjectsAndKeys:copied_block, @"block", [NSNumber numberWithFloat:[timeLine timestamp]], @"startTime", nil]];
    }
    Block_release(copied_block);
}

#pragma mark -
#pragma mark Animation controls

- (void)removeAnimations:(TrickplayUIElement *)view {
    NSMutableArray *blocksToRemove = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary *blockInfo in blocks) {
        NSArray *args = [blockInfo objectForKey:@"args"];
        
        if (args && [[args objectAtIndex:0] isKindOfClass:[NSString class]] && [(NSString *)[args objectAtIndex:0] compare:@"animation"] == NSOrderedSame && [args objectAtIndex:1] && [args objectAtIndex:1] == view) {
            
            BOOL (^block)(NSArray *) = [blockInfo objectForKey:@"block"];
            block([NSArray arrayWithObject:@"complete"]);
            
            [blocksToRemove addObject:blockInfo];
        }
    }
    for (NSDictionary *blockInfo in blocksToRemove) {
        [blocks removeObject:blockInfo];
    }
}

- (void)animateWithTable:(NSDictionary *)table duration:(NSNumber *)duration view:(TrickplayUIElement *)view {
    CGFloat start_x = 0.0, start_y = 0.0, start_z = 0.0,
    start_rot_z = 0.0, start_w = 0.0, start_h = 0.0,
    start_scale_x = 0.0, start_scale_y = 0.0, start_opacity = 0.0;
    
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
    start_x = view.x_position;
    start_y = view.y_position;
    start_z = view.z_position;
    
    NSNumber *w = [table objectForKey:@"w"] ? [table objectForKey:@"w"] : [table objectForKey:@"width"];
    NSNumber *h = [table objectForKey:@"h"] ? [table objectForKey:@"h"] : [table objectForKey:@"height"];
    NSArray *size = [table objectForKey:@"size"];
    if (size && size.count > 1) {
        w = [size objectAtIndex:0] ? [size objectAtIndex:0] : w;
        h = [size objectAtIndex:1] ? [size objectAtIndex:1] : h;
    }
    start_w = view.w_size;
    start_h = view.h_size;
    
    NSNumber *rotation_z = nil;
    if ([table objectForKey:@"z_rotation"] && [[table objectForKey:@"z_rotation"] isKindOfClass:[NSNumber class]]) {
        rotation_z = [NSNumber numberWithFloat:[[table objectForKey:@"z_rotation"] floatValue] * M_PI/180.0];
        start_rot_z = view.z_rotation;
    }
    
    NSArray *scale = [table objectForKey:@"scale"];
    NSNumber *scale_x = nil;
    NSNumber *scale_y = nil;
    if (scale.count > 1) {
        scale_x = [scale objectAtIndex:0];
        scale_y = [scale objectAtIndex:1];
        start_scale_x = view.x_scale;
        start_scale_y = view.y_scale;
    }
    
    NSNumber *opacity = [table objectForKey:@"opacity"];
    if (opacity) {
        opacity = [NSNumber numberWithFloat:[opacity floatValue]/255];
        start_opacity = view.opacity;
    }
    
    
    CFAbsoluteTime startTime = [timeLine timestamp];
    [self addBlock:^(NSArray *args) {
        CFAbsoluteTime currentTime = [timeLine timestamp];
        CGFloat percent = fabsf(currentTime - startTime)/[duration floatValue]*1000;
        if (percent > 1.0 || ([[args objectAtIndex:0] isKindOfClass:[NSString class]] && [(NSString *)[args objectAtIndex:0] compare:@"complete"] == NSOrderedSame)) {
            percent = 1.0;
        }
        
        if (x) {
            view.x_position = start_x + ([x floatValue] - start_x)*percent;
        }
        if (y) {
            view.y_position = start_y + ([y floatValue] - start_y)*percent;
        }
        
        if (rotation_z) {
            view.z_rotation = start_rot_z + ([rotation_z floatValue] - start_rot_z)*percent;
            [view.layer setValue:[NSNumber numberWithFloat:view.z_rotation] forKeyPath:@"transform.rotation.z"];
        }
        
        if (x || y || (rotation_z && (view.x_rot_point != 0.0 || view.y_rot_point != 0.0))) {
            view.layer.position = CGPointMake([view get_x_prime], [view get_y_prime]);
        }
        
        if (w) {
            view.w_size = start_w + ([w floatValue] - start_w)*percent;
        }
        if (h) {
            view.h_size = start_h + ([h floatValue] - start_h)*percent;
        }
        if (w || h) {
            view.view.bounds = CGRectMake(0.0, 0.0, view.w_size, view.h_size);
        }
        
        if (scale) {
            view.x_scale = start_scale_x + ([scale_x floatValue] - start_scale_x)*percent;
            view.y_scale = start_scale_y + ([scale_y floatValue] - start_scale_y)*percent;
            [view.layer setValue:[NSNumber numberWithFloat:view.x_scale] forKeyPath:@"transform.scale.x"];
            [view.layer setValue:[NSNumber numberWithFloat:view.y_scale] forKeyPath:@"transform.scale.y"];
        }
        
        if (opacity) {
            view.opacity = start_opacity + ([opacity floatValue] - start_opacity)*percent;
            view.layer.opacity = view.opacity;
        }
        
        
        if (percent >= 1.0) {
            [view trickplayAnimationDidStop:[NSMutableDictionary dictionaryWithObjectsAndKeys:[table objectForKey:@"on_completed"], @"animation_id", nil]];
            return NO;
        }
        return YES;
    }
              args:[NSArray arrayWithObjects:@"animation", view, nil]];
}

#pragma mark -
#pragma mark Deallocation

- (void)dealloc {
    NSLog(@"TrickplayTimeline dealloc");
    
    if (timeLine) {
        [timeLine invalidate];
    }
    self.timeLine = nil;
    self.blocks = nil;
    
    [super dealloc];
}

@end
