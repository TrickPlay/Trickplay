//
//  TrickplayTimeline.h
//  TrickplayController
//
//  Created by Rex Fenley on 8/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class TrickplayUIElement;

@interface TrickplayTimeline : NSObject {
    NSMutableArray *blocks;
    CADisplayLink *timeLine;
}

@property (retain) NSMutableArray *blocks;
@property (retain) CADisplayLink *timeLine;

- (void)startTimeline;
- (void)stopTimeline;
- (void)addBlock:(BOOL (^)(NSArray *args))block args:(NSArray *)args;
- (void)animateWithTable:(NSDictionary *)table duration:(NSNumber *)duration view:(TrickplayUIElement *)aView;

@end
