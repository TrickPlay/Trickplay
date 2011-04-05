//
//  AdvancedUIObjectManager.m
//  TrickplayController
//
//  Created by Rex Fenley on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AdvancedUIObjectManager.h"


@implementation AdvancedUIObjectManager

@synthesize rectangles;
@synthesize images;
@synthesize textFields;
@synthesize groups;

- (id)initWithView:(UIView *)aView {
    if ((self = [super init])) {
        self.rectangles = [[NSMutableDictionary alloc] initWithCapacity:20];
        self.images = [[NSMutableDictionary alloc] initWithCapacity:20];
        self.textFields = [[NSMutableDictionary alloc] initWithCapacity:20];
        self.groups = [[NSMutableDictionary alloc] initWithCapacity:20];
        
        view = aView;
    }
    
    return self;
}

/**
 * Creates Rectangles and stores them.
 */

- (void)createRectangle:(NSString *)id withArgs:(NSDictionary *)args {
    CGFloat
    x = [(NSNumber *)[args objectForKey:@"x"] floatValue],
    y = [(NSNumber *)[args objectForKey:@"x"] floatValue],
    width = [(NSNumber *)[args objectForKey:@"w"] floatValue],
    height = [(NSNumber *)[args objectForKey:@"h"] floatValue],
    red = [(NSNumber *)[(NSArray *)[args objectForKey:@"color"] objectAtIndex:0] floatValue]/255.0,
    green = [(NSNumber *)[(NSArray *)[args objectForKey:@"color"] objectAtIndex:1] floatValue]/255.0,
    blue = [(NSNumber *)[(NSArray *)[args objectForKey:@"color"] objectAtIndex:2] floatValue]/255.0;
    
    CGRect frame = CGRectMake(x, y, width, height);
    UIView *rect = [[UIView alloc] initWithFrame:frame];
    NSLog(@"Color: %@", [UIColor colorWithRed:red green:green blue:blue alpha:(CGFloat)1]);
    rect.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:(CGFloat)1];
    
    NSLog(@"Rectangle created: %@", rect);
    
    [view addSubview:rect];
}


/**
 * Object creation function.
 */

- (void)createObject:(NSString *)JSON_String {
    NSArray *JSON_Array = [JSON_String yajl_JSON];
    NSLog(@"Creating Objects from JSON: %@", JSON_Array);
    
    // Now that we have the JSON Array of objects, create all the objects
    for (NSDictionary *object in JSON_Array) {
        NSLog(@"Creating object %@", object);
        if ([(NSString *)[object objectForKey:@"type"] compare:@"Rectangle"] == NSOrderedSame) {
            [self createRectangle:(NSString *)[object objectForKey:@"id"]
                         withArgs:object];
        }
    }
}

- (void)dealloc {
    NSLog(@"AdvancedUIObjectManager dealloc");
    
    if (rectangles) {
        [rectangles release];
    }
    if (images) {
        [images release];
    }
    if (textFields) {
        [textFields release];
    }
    if (groups) {
        [groups release];
    }
    
    [super dealloc];
}

@end
