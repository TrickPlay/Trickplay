//
//  TrickplayImage.m
//  TrickplayController
//
//  Created by Rex Fenley on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayImage.h"


@implementation TrickplayImage

@synthesize src;

- (id)initWithID:(NSString *)imageID args:(NSDictionary *)args resourceManager:(ResourceManager *)resourceManager {
    if ((self = [super initWithID:imageID])) {
        loaded = NO;
        self.src = nil;
        id source = [args objectForKey:@"src"];
        if (source && [source isKindOfClass:[NSString class]]) {
            self.src = source;
        }
        
        CGRect frame = [self getFrameFromArgs:args];
        
        self.view = [resourceManager fetchImageViewUsingResource:src frame:frame];
        ((AsyncImageView *)self.view).otherDelegate = self;
        
        [self setValuesFromArgs:args];
                
        [self addSubview:view];
    }
        
    return self;
}

- (void)dataReceived:(NSData *)data resourcekey:(id)resourceKey {
    loaded = YES;
}


#pragma mark -
#pragma mark Getters

/**
 * Get the source of the image
 */

- (void)get_src:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"src"] && src) {
        [dictionary setObject:src forKey:@"src"];
    }
}

/**
 * Get whether the image loaded
 */

- (void)get_loaded:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"loaded"]) {
        [dictionary setObject:[NSNumber numberWithBool:loaded] forKey:@"loaded"];
    }
}

/**
 * Get base image size
 */

- (void)get_base_size:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"base_size"] && loaded) {
        NSNumber *width = [NSNumber numberWithFloat:((UIImageView *)view).image.size.width];
        NSNumber *height = [NSNumber numberWithFloat:((UIImageView *)view).image.size.height];
        NSArray *imageSize = [NSArray arrayWithObjects:width, height, nil];
        [dictionary setObject:imageSize forKey:@"base_size"];
    }
}

/**
 * Getter function
 */

- (NSDictionary *)getValuesFromArgs:(NSDictionary *)properties {
    NSMutableDictionary *JSON_Dictionary = [NSMutableDictionary dictionaryWithDictionary:properties];
    
    for (NSString *property in [properties allKeys]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"get_%@:", property]);
        
        if ([TrickplayImage instancesRespondToSelector:selector]) {
            [self performSelector:selector withObject:JSON_Dictionary];
        } else {
            [JSON_Dictionary removeObjectForKey:property];
        }
    }
    
    return JSON_Dictionary;
}


- (void)dealloc {
    NSLog(@"TrickplayImage dealloc");
    
    self.src = nil;
    
    [super dealloc];
}

@end
