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

- (id)initWithID:(NSString *)imageID args:(NSDictionary *)args resourceManager:(ResourceManager *)resourceManager objectManager:(AdvancedUIObjectManager *)objectManager {
    if ((self = [super initWithID:imageID objectManager:objectManager])) {
        self.src = nil;
        id source = [args objectForKey:@"src"];
        if (source && [source isKindOfClass:[NSString class]]) {
            self.src = source;
        }
                
        CGRect frame = [self getFrameFromArgs:args];        
        self.view = [resourceManager fetchImageViewUsingResource:src frame:frame];
        ((AsyncImageView *)self.view).otherDelegate = self;
        view.layer.anchorPoint = CGPointMake(0.0, 0.0);
        view.layer.frame = CGRectMake(0.0, 0.0, view.layer.frame.size.width, view.layer.frame.size.height);
        
        [self setValuesFromArgs:args];
                
        [self addSubview:view];
    }
        
    return self;
}

- (void)dataReceived:(NSData *)data resourcekey:(id)resourceKey {
    
}

- (void)on_loadedFailed:(BOOL)failed {
    if (manager && manager.appViewController) {
        NSMutableDictionary *JSON_dic = [[NSMutableDictionary alloc] initWithCapacity:10];
        [JSON_dic setObject:ID forKey:@"id"];
        [JSON_dic setObject:@"on_loaded" forKey:@"event"];
        [JSON_dic setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:failed], nil] forKey:@"args"];
        [JSON_dic setObject:[NSNumber numberWithBool:failed] forKey:@"failed"];
        
        [manager.appViewController sendEvent:@"UX" JSON:[JSON_dic yajl_JSONString]];
        
        [JSON_dic release];
    }
}

#pragma mark -
#pragma mark Deleter

/**
 * Stop tiling
 */
- (void)delete_tile {
    BOOL toTileWidth = NO;
    BOOL toTileHeight = NO;
    [((AsyncImageView *)view) setTileWidth:toTileWidth height:toTileHeight];
}

/**
 * Deleter function
 */

- (void)deleteValuesFromArgs:(NSDictionary *)properties {
    for (NSString *property in [properties allKeys]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"delete_%@", property]);
        
        if ([TrickplayImage instancesRespondToSelector:selector]) {
            [self performSelector:selector withObject:properties];
        }
    }
}

#pragma mark -
#pragma mark Setters

/**
 * Set tiling
 */

- (void)set_tile:(NSDictionary *)args {
    id tile = [args objectForKey:@"tile"];
    if (![tile isKindOfClass:[NSArray class]]) {
        return;
    }
    BOOL toTileWidth = [[(NSArray *)tile objectAtIndex:0] boolValue];
    BOOL toTileHeight = [[(NSArray *)tile objectAtIndex:1] boolValue];
    [((AsyncImageView *)view) setTileWidth:toTileWidth height:toTileHeight];
}

/**
 * Setter function
 */

- (void)setValuesFromArgs:(NSDictionary *)properties {
    for (NSString *property in [properties allKeys]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set_%@:", property]);
        
        if ([TrickplayImage instancesRespondToSelector:selector]) {
            [self performSelector:selector withObject:properties];
        } else {
            selector = NSSelectorFromString([NSString stringWithFormat:@"do_set_%@:", property]);
            if ([TrickplayImage instancesRespondToSelector:selector]) {
                [self performSelector:selector withObject:properties];
            }
        }
    }
}

#pragma mark -
#pragma mark Getters

/**
 * Get the source of the image
 */

- (void)get_src:(NSMutableDictionary *)dictionary {
    if (src) {
        [dictionary setObject:src forKey:@"src"];
    } else {
        [dictionary setObject:@"[null]" forKey:@"src"];
    }
}

/**
 * Get the tile
 */

- (void)get_tile:(NSMutableDictionary *)dictionary {
    NSArray *tiling = [NSArray arrayWithObjects:[NSNumber numberWithBool:((AsyncImageView *)view).tileWidth], [NSNumber numberWithBool:((AsyncImageView *)view).tileHeight], nil];
    [dictionary setObject:tiling forKey:@"tile"];
}

/**
 * Get whether the image loaded
 */

- (void)get_loaded:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithBool:((AsyncImageView *)view).loaded] forKey:@"loaded"];
}

/**
 * Get base image size
 */

- (void)get_base_size:(NSMutableDictionary *)dictionary {
    if (((AsyncImageView *)view).loaded) {
        NSNumber *width = [NSNumber numberWithFloat:((UIImageView *)view).image.size.width];
        NSNumber *height = [NSNumber numberWithFloat:((UIImageView *)view).image.size.height];
        NSArray *imageSize = [NSArray arrayWithObjects:width, height, nil];
        [dictionary setObject:imageSize forKey:@"base_size"];
    } else {
        NSArray *imageSize = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.0], nil];
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

#pragma mark -
#pragma mark New Protocol

- (id)callMethod:(NSString *)method withArgs:(NSArray *)args {
    return [super callMethod:method withArgs:args];
}

#pragma mark -
#pragma mark Deallocation

- (void)dealloc {
    NSLog(@"TrickplayImage dealloc");
    
    self.src = nil;
    ((AsyncImageView *)self.view).otherDelegate = nil;
    
    [super dealloc];
}

@end
