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

- (id)initWithID:(NSString *)groupID args:(NSDictionary *)args resourceManager:(ResourceManager *)resourceManager {
    if ((self = [super init])) {
        self.view = [[[UIView alloc] init] autorelease];
        
        manager = [[AdvancedUIObjectManager alloc] initWithView:self.view resourceManager:resourceManager];
        [self setValuesFromArgs:args];
        
        [self addSubview:view];
    }
    
    return self;
}

/**
 * Getter function
 */

- (void)getValuesFromArgs:(NSDictionary *)args {
    [super getValuesFromArgs:args];
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

- (void)dealloc {
    self.manager = nil;
    
    [super dealloc];
}

@end
