//
//  TrickplayTextHTML.m
//  TrickplayController
//
//  Created by Rex Fenley on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayTextHTML.h"


@implementation TrickplayTextHTML

- (id)initWithID:(NSString *)textID args:(NSDictionary *)args objectManager:(AdvancedUIObjectManager *)objectManager {
    if ((self = [super initWithID:textID objectManager:objectManager])) {
        self.frame = [[UIScreen mainScreen] applicationFrame];
        self.view = [[[UIWebView alloc] initWithFrame:[self getFrameFromArgs:args]] autorelease];
        
        view.userInteractionEnabled = YES;
        
        self.view.backgroundColor = [UIColor clearColor];
        
        maxLength = 0;
        
        [self setValuesFromArgs:args];
        
        [self addSubview:view];
    }
    
    return self;
}

#pragma mark -
#pragma mark Deleter

/**
 * Deleter function
 */

- (void)deleteValuesFromArgs:(NSDictionary *)properties {
    for (NSString *property in [properties allKeys]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"delete_%@", property]);
        
        if ([TrickplayTextHTML instancesRespondToSelector:selector]) {
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
        
        if ([TrickplayTextHTML instancesRespondToSelector:selector]) {
            [self performSelector:selector withObject:properties];
        }
    }
}

#pragma mark -
#pragma mark Getters

/**
 * Get color
 */

- (void)get_color:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"color"]) {
        NSNumber *red, *green, *blue, *alpha;
        
        const CGFloat *components = CGColorGetComponents(((UITextView *)view).textColor.CGColor);
        red = [NSNumber numberWithFloat:components[0] * 255.0];
        green = [NSNumber numberWithFloat:components[1] * 255.0];
        blue = [NSNumber numberWithFloat:components[2] * 255.0];
        alpha = [NSNumber numberWithFloat:CGColorGetAlpha(((UITextView *)view).textColor.CGColor) * 255.0];
        
        NSArray *colorArray = [NSArray arrayWithObjects:red, green, blue, alpha, nil];
        [dictionary setObject:colorArray forKey:@"color"];
    }
}

/**
 * Get background color
 */

- (void)get_background_color:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"background_color"]) {
        NSNumber *red, *green, *blue, *alpha;
        
        const CGFloat *components = CGColorGetComponents(view.layer.backgroundColor);
        red = [NSNumber numberWithFloat:components[0] * 255.0];
        green = [NSNumber numberWithFloat:components[1] * 255.0];
        blue = [NSNumber numberWithFloat:components[2] * 255.0];
        alpha = [NSNumber numberWithFloat:CGColorGetAlpha(view.layer.backgroundColor) * 255.0];
        
        NSArray *colorArray = [NSArray arrayWithObjects:red, green, blue, alpha, nil];
        [dictionary setObject:colorArray forKey:@"background_color"];
    }
}

/**
 * Getter function
 */

- (NSDictionary *)getValuesFromArgs:(NSDictionary *)properties {
    NSMutableDictionary *JSON_Dictionary = [NSMutableDictionary dictionaryWithDictionary:properties];
    
    for (NSString *property in [properties allKeys]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"get_%@:", property]);
        
        if ([TrickplayTextHTML instancesRespondToSelector:selector]) {
            [self performSelector:selector withObject:JSON_Dictionary];
        } else {
            [JSON_Dictionary removeObjectForKey:property];
        }
    }
    
    return JSON_Dictionary;
}


- (void)dealloc {
    NSLog(@"TrickplayTextHTML dealloc");
    
    [super dealloc];
}

@end
