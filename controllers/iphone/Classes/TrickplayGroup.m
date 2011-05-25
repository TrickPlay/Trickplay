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
#import "TrickplayImage.h"

@implementation TrickplayGroup

- (id)initWithID:(NSString *)groupID args:(NSDictionary *)args objectManager:(AdvancedUIObjectManager *)objectManager {
    if ((self = [super initWithID:groupID objectManager:objectManager])) {
        self.view = [[[UIView alloc] init] autorelease];
        
        //manager = [[AdvancedUIObjectManager alloc] initWithView:self.view resourceManager:resourceManager];
        [self setValuesFromArgs:args];
        
        [self addSubview:view];
    }
    
    return self;
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


/////// not a function from Trickplay, just a helper method
- (NSMutableDictionary *)createChildJSONFromChild:(TrickplayUIElement *)child {
    NSMutableDictionary *childDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    [childDictionary setObject:child.ID forKey:@"id"];
    if ([child isKindOfClass:[TrickplayRectangle class]]) {
        [childDictionary setObject:@"Rectangle" forKey:@"type"];
    } else if ([child isKindOfClass:[TrickplayImage class]]) {
        [childDictionary setObject:@"Image" forKey:@"type"];
    } else if ([child isKindOfClass:[TrickplayText class]]) {
        [childDictionary setObject:@"Text" forKey:@"type"];
    } else if ([child isKindOfClass:[TrickplayGroup class]]) {
        [childDictionary setObject:@"Group" forKey:@"type"];
    }
    
    return childDictionary;
}
///////////////////////////


- (NSArray *)do_get_children:(NSArray *)args {
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:20];
    for (id child in [self.view subviews]) {
        NSLog(@"this is a child: %@", child);
        if ([child isKindOfClass:[TrickplayUIElement class]]) {
            [children addObject:[self createChildJSONFromChild:(TrickplayUIElement *)child]];
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
                return [self createChildJSONFromChild:child];
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

- (id)callMethod:(NSString *)method withArgs:(NSArray *)args {
    id result = nil;
    
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
