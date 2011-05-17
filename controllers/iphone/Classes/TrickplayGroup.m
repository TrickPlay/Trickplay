//
//  TrickplayGroup.m
//  TrickplayController
//
//  Created by Rex Fenley on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayGroup.h"

@implementation TrickplayGroup

@synthesize manager;

- (id)initWithID:(NSString *)groupID args:(NSDictionary *)args objectManager:(AdvancedUIObjectManager *)objectManager {
    if ((self = [super init])) {
        self.view = [[[UIView alloc] init] autorelease];
        
        //manager = [[AdvancedUIObjectManager alloc] initWithView:self.view resourceManager:resourceManager];
        self.manager = objectManager;
        [self setValuesFromArgs:args];
        
        [self addSubview:view];
    }
    
    return self;
}

/**
 * Getter function
 */

- (NSDictionary *)getValuesFromArgs:(NSDictionary *)args {
    return [super getValuesFromArgs:args];
}

/**
 * Setter function
 */

- (void)setValuesFromArgs:(NSDictionary *)args {
    [super setValuesFromArgs:args];
}

- (void)setChildrenFromArgs:(NSDictionary *)args {
    NSArray *children = [args objectForKey:@"children"];
    [manager createObjects:children];
}

#pragma mark -
#pragma mark New Protocol

- (NSString *)addChildren:(NSArray *)childIDs {
    NSString *result = @"false";
    for (NSString *childID in childIDs) {
        TrickplayUIElement *child = [manager findObjectForID:childID];
        [child removeFromSuperview];
        [self.view addSubview:child];
        result = @"true";
    }
    NSString *JSON_reply = [[NSDictionary dictionaryWithObject:result forKey:@"result"] yajl_JSONString];
    return JSON_reply;
}

- (NSString *)callMethod:(NSString *)method withArgs:(NSArray *)args {
    if ([method compare:@"add"] == NSOrderedSame) {
        return [self addChildren:[args objectAtIndex:0]];
    }
    
    return [super callMethod:method withArgs:args];
}


- (void)dealloc {
    NSLog(@"TrickplayGroup dealloc: %@", self);
    self.manager = nil;
    
    [super dealloc];
}

@end
