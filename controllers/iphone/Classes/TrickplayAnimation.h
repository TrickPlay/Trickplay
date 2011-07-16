//
//  TrickplayAnimation.h
//  TrickplayController
//
//  Created by Rex Fenley on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TrickplayUIElement;
@class TrickplayAnimation;

@protocol TrickplayAnimationDelegate <NSObject>

@required
- (void)trickplayAnimationDidStop:(TrickplayAnimation *)anim;

@end

@interface TrickplayAnimation : NSObject <NSCopying> {
    TrickplayUIElement *view;
    NSDictionary *table;
    NSNumber *duration;
    NSUInteger animationCount;
    NSMutableDictionary *completion;
    
    id <TrickplayAnimationDelegate> delegate;
}

@property (assign) id<TrickplayAnimationDelegate> delegate;
@property (nonatomic, retain) TrickplayUIElement *view;
@property (retain) NSDictionary *table;
@property (retain) NSNumber *duration;

- (id) initWithTable:(NSDictionary *)table duration:(NSNumber *)duration view:(TrickplayUIElement *)aView;

- (void)animationStart;

@end
