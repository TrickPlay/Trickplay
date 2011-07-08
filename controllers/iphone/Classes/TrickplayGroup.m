//
//  TrickplayGroup.m
//  TrickplayController
//
//  Created by Rex Fenley on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayGroup.h"
#import "TrickplayRectangle.h"
#import "TrickplayText.h"
#import "TrickplayTextHTML.h"
#import "TrickplayImage.h"

@implementation TrickplayGroup

@synthesize delegate;

- (id)initWithID:(NSString *)groupID args:(NSDictionary *)args objectManager:(AdvancedUIObjectManager *)objectManager {
    if ((self = [super initWithID:groupID objectManager:objectManager])) {
        self.view = [[[UIView alloc] init] autorelease];
        view.layer.anchorPoint = CGPointMake(0.0, 0.0);
        //view.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];

        if (args) {
            [self setValuesFromArgs:args];
        }
        
        [self addSubview:view];
    }
    
    return self;
}

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"This Group has been touched");
}
 */

- (void)handleTouchesBegan:(NSSet *)touches {
    NSLog(@"handle touches began: %@", self);
    if (manager && manager.gestureViewController) {
        CFMutableArrayRef newTouches = (CFMutableArrayRef)[[NSMutableArray alloc] initWithCapacity:10];
        for (UITouch *touch in [touches allObjects]) {
            CGFloat
            x = [touch locationInView:self].x,
            y = [touch locationInView:self].y,
            x_sub = [touch locationInView:view].x,
            y_sub = [touch locationInView:view].y;
            /*
            NSLog(@"\ntouch location: self: (%f, %f) view: (%f, %f)\n", x, y, x_sub, y_sub);
            NSLog(@"\ncomparisons: self: (%f, %f), (%f, %f) view: (%f, %f), (%f, %f)", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height, view.bounds.origin.x, view.bounds.origin.y, view.bounds.size.width, view.bounds.size.height);
            NSLog(@"\nresults:\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n", x >= self.bounds.origin.x, x <= self.bounds.size.width, y >= self.bounds.origin.y, y <= self.bounds.size.width, x_sub >= view.bounds.origin.x, x_sub <= view.bounds.size.width, y_sub >= view.bounds.origin.y, y_sub <= view.bounds.size.height);
            //*/
            // check that its within clipping range
            if (x >= self.bounds.origin.x
                && x <= self.bounds.size.width
                && y >= self.bounds.origin.y
                && y <= self.bounds.size.width
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
            for (TrickplayUIElement *element in view.subviews) {
                [element handleTouchesBegan:[NSSet setWithArray:(NSArray *)newTouches]];
            }
        }
        CFRelease(newTouches);
    }
}

- (void)handleTouchesMoved:(NSSet *)touches {
    if (manager && manager.gestureViewController) {
        CFMutableArrayRef newTouches = (CFMutableArrayRef)[[NSMutableArray alloc] initWithCapacity:10];
        for (UITouch *touch in [touches allObjects]) {
            if (CFDictionaryGetValue(activeTouches, touch)) {
                CFArrayAppendValue(newTouches, touch);
            }
        }
        if (((NSArray *)newTouches).count > 0) {
            [self sendTouches:(NSArray *)newTouches withState:@"moved"];
            for (TrickplayUIElement *element in view.subviews) {
                [element handleTouchesMoved:[NSSet setWithArray:(NSArray *)newTouches]];
            }
        }
        CFRelease(newTouches);
    }
}

- (void)handleTouchesEnded:(NSSet *)touches {
    if (manager && manager.gestureViewController) {
        CFMutableArrayRef newTouches = (CFMutableArrayRef)[[NSMutableArray alloc] initWithCapacity:10];
        for (UITouch *touch in [touches allObjects]) {
            if (CFDictionaryGetValue(activeTouches, touch)) {
                CFArrayAppendValue(newTouches, touch);
            }
        }
        if (((NSArray *)newTouches).count > 0) {
            [self sendTouches:(NSArray *)newTouches withState:@"ended"];
            for (TrickplayUIElement *element in view.subviews) {
                [element handleTouchesEnded:[NSSet setWithArray:(NSArray *)newTouches]];
            }
        }
        CFRelease(newTouches);
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
            for (TrickplayUIElement *element in view.subviews) {
                [element handleTouchesCancelled:[NSSet setWithArray:(NSArray *)newTouches]];
            }
        }
        CFRelease(newTouches);
    }
    
    for (UITouch *touch in [touches allObjects]) {
        [self removeTouch:touch];
    }
}

#pragma mark -
#pragma mark Deleter

/**
 * Deleter function
 */

- (void)deleteValuesFromArgs:(NSDictionary *)properties {
    for (NSString *property in [properties allKeys]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"delete_%@", property]);
        
        if ([TrickplayGroup instancesRespondToSelector:selector]) {
            [self performSelector:selector withObject:properties];
        }
    }
}

#pragma mark -
#pragma mark Setters

/**
 * Setter function
 */

- (void)setValuesFromArgs:(NSDictionary *)properties {
    for (NSString *property in [properties allKeys]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set_%@:", property]);
        
        if ([TrickplayGroup instancesRespondToSelector:selector]) {
            [self performSelector:selector withObject:properties];
        } else {
            selector = NSSelectorFromString([NSString stringWithFormat:@"do_set_%@:", property]);
            if ([TrickplayGroup instancesRespondToSelector:selector]) {
                [self performSelector:selector withObject:properties];
            }
        }
    }
}


#pragma mark -
#pragma mark Getters

/**
 * Getter function
 */

- (NSDictionary *)getValuesFromArgs:(NSDictionary *)properties {
    NSMutableDictionary *JSON_Dictionary = [NSMutableDictionary dictionaryWithDictionary:properties];
    
    for (NSString *property in [properties allKeys]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"get_%@:", property]);
        
        if ([TrickplayGroup instancesRespondToSelector:selector]) {
            [self performSelector:selector withObject:JSON_Dictionary];
        } else {
            [JSON_Dictionary removeObjectForKey:property];
        }
    }
    
    return JSON_Dictionary;
}

#pragma mark -
#pragma mark Function Calls

- (NSNumber *)do_add:(NSArray *)args {
    NSArray *childIDs = [args objectAtIndex:0];
    BOOL result = NO;
    for (NSString *childID in childIDs) {
        TrickplayUIElement *child = [manager findObjectForID:childID];
        [child removeFromSuperview];
        [self.view addSubview:child];
        if (delegate) {
            [delegate object_added];
        }
        result = YES;
    }
    
    return [NSNumber numberWithBool:result];;
}

- (NSNumber *)do_remove:(NSArray *)args {
    NSArray *childIDs = [args objectAtIndex:0];
    BOOL result = NO;
    for (NSString *childID in childIDs) {
        TrickplayUIElement *child = [manager findObjectForID:childID];
        if (child && [child isDescendantOfView:self.view]) {
            [child removeFromSuperview];
            result = YES;
        }
    }
    
    return [NSNumber numberWithBool:result];
}

- (NSNumber *)do_set_children:(NSArray *)args {
    for (UIView *child in self.view.subviews) {
        [child removeFromSuperview];
    }
    
    return [self do_add:args];
}

- (NSArray *)do_get_children:(NSArray *)args {
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:20];
    for (id child in [self.view subviews]) {
        NSLog(@"this is a child: %@", child);
        if ([child isKindOfClass:[TrickplayUIElement class]]) {
            [children addObject:[self createObjectJSONFromObject:(TrickplayUIElement *)child]];
        }
    }
    
    return children;
}

- (NSDictionary *)do_find_child:(NSArray *)args {
    if ([args objectAtIndex:0] && [[args objectAtIndex:0] isKindOfClass:[NSString class]]) {
        NSString *nameQuery = [args objectAtIndex:0];
        NSDictionary *JSON_reply = nil;
        for (TrickplayUIElement *child in self.view.subviews) {
            if ([child.name compare:nameQuery] == NSOrderedSame) {
                return [self createObjectJSONFromObject:child];
            }
            if ([child isKindOfClass:[TrickplayGroup class]]) {
                JSON_reply = [((TrickplayGroup *)child) do_find_child:args];
                if (JSON_reply) {
                    return JSON_reply;
                }
            }
        }
    }
    
    return nil;
}

- (NSNumber *)do_clear:(NSArray *)args {
    for (UIView *child in self.view.subviews) {
        [child removeFromSuperview];
    }
    
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)do_raise_child:(NSArray *)args {
    TrickplayUIElement *child = [manager findObjectForID:[args objectAtIndex:0]];
    TrickplayUIElement *sibling = [manager findObjectForID:[args objectAtIndex:1]];
    
    if (!sibling || ![sibling isDescendantOfView:self.view]) {
        if (!child || ![child isDescendantOfView:self.view]) {
            return [NSNumber numberWithBool:NO];
        }
        
        [child do_raise_to_top:args];
    } else {
        [self.view insertSubview:child aboveSubview:sibling];
    }
    
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)do_lower_child:(NSArray *)args {
    TrickplayUIElement *child = [manager findObjectForID:[args objectAtIndex:0]];
    TrickplayUIElement *sibling = [manager findObjectForID:[args objectAtIndex:1]];
    
    if (!sibling || ![sibling isDescendantOfView:self.view]) {
        if (!child || ![child isDescendantOfView:self.view]) {
            return [NSNumber numberWithBool:NO];
        }
        
        [child do_lower_to_bottom:args];
    } else {
        [self.view insertSubview:child belowSubview:sibling];
    }
    
    return [NSNumber numberWithBool:YES];
}

////////////////// Screen Only method /////////////////////////

- (NSNumber *)do_set_background:(NSArray *)args {
    if (delegate) {
        [delegate do_UB:args];
    }
    
    return [NSNumber numberWithBool:YES];
}

//////////////////////////////////////////////////////////////

- (id)callMethod:(NSString *)method withArgs:(NSArray *)args {
    id result = nil;
    
    //NSLog(@"\n\n method = %@,    args = %@\n\n", method, args);
    
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"do_%@:", method]);
        
    if ([TrickplayGroup instancesRespondToSelector:selector]) {
        result = [self performSelector:selector withObject:args];
    } else {
        result = [super callMethod:method withArgs:args];
    }
    
    return result;
}


- (void)dealloc {
    NSLog(@"TrickplayGroup dealloc: %@", self);
    self.manager = nil;
    
    [super dealloc];
}

@end
