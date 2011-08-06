//
//  TrickplayTimeline.m
//  TrickplayController
//
//  Created by Rex Fenley on 8/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayTimeline.h"
#import "TrickplayUIElement.h"

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
    for (NSDictionary *blockInfo in blocks) {
        NSArray *args;
        if ([blockInfo objectForKey:@"args"]) {
            args = [blockInfo objectForKey:@"args"];
        } else {
            args = [NSArray arrayWithObjects:[blockInfo objectForKey:@"startTime"], [NSNumber numberWithFloat:[timeLine timestamp]], nil];
        }
        BOOL (^block)(NSArray *) = [blockInfo objectForKey:@"block"];
        BOOL keepAlive = block(args);
        
        if (!keepAlive) {
            [blocks removeObject:blockInfo];
        }
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
    if (args) {
        [blocks addObject:[NSDictionary dictionaryWithObjectsAndKeys:args, @"args", Block_copy(block), @"block", [NSNumber numberWithFloat:[timeLine timestamp]], @"startTime", nil]];
    } else {
        [blocks addObject:[NSDictionary dictionaryWithObjectsAndKeys:Block_copy(block), @"block", [NSNumber numberWithFloat:[timeLine timestamp]], @"startTime", nil]];
    }
    Block_release(block);
}

#pragma mark -
#pragma mark Animation controls

- (void)animateWithTable:(NSDictionary *)table duration:(NSNumber *)duration view:(TrickplayUIElement *)view {
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
    
    [self addBlock:^(NSArray *args) {
        NSLog(@"wtf");
        CFAbsoluteTime startTime = [[args objectAtIndex:0] floatValue];
        CFAbsoluteTime currentTime = [timeLine timestamp];
        CGFloat percent = (startTime - currentTime)/[duration floatValue];
        if (percent > 1.0) {
            percent = 1.0;
        }
        CGFloat start_x = [[args objectAtIndex:2] floatValue];
        
        if (x) {
            view.x_position = start_x + ([x floatValue] - start_x)*percent;
            view.layer.position = CGPointMake([view get_x_prime], [view get_y_prime]);
        }
        /*
        if (y) {
            view.y_position = [y floatValue];
            CABasicAnimation *animation_y = [CABasicAnimation animationWithKeyPath:@"position.y"];
            [animation_y setToValue:[NSNumber numberWithFloat:[view get_y_prime]]];
            [animation_y setDuration:[duration floatValue]/1000.0];
            animation_y.delegate = self;
            [view.layer addAnimation:animation_y forKey:@"y_position"];
        }
         */
        
        if (startTime + [duration floatValue] > currentTime) {
            return NO;
        }
        return YES;
    }
              args:[NSArray arrayWithObjects:[NSNumber numberWithFloat:[timeLine timestamp]], [NSNumber numberWithFloat:[timeLine timestamp]], [NSNumber numberWithFloat:view.x_position], nil]];
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
