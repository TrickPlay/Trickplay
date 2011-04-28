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
@synthesize resourceManager;

- (id)initWithView:(UIView *)aView resourceManager:(ResourceManager *)aResourceManager {
    if ((self = [super init])) {
        self.rectangles = [[NSMutableDictionary alloc] initWithCapacity:20];
        self.images = [[NSMutableDictionary alloc] initWithCapacity:20];
        self.textFields = [[NSMutableDictionary alloc] initWithCapacity:20];
        self.groups = [[NSMutableDictionary alloc] initWithCapacity:20];
        
        self.resourceManager = aResourceManager;
        
        view = aView;
    }
    
    return self;
}


/**
 * Creates Images and stores them
 */

- (void)createImage:(NSString *)imageID withArgs:(NSDictionary *)args {
    
    
    TrickplayImage *image = [[[TrickplayImage alloc] initWithID:imageID args:args resourceManager:resourceManager] autorelease];
    
    NSLog(@"Image created: %@", image);
    [images setObject:image forKey:imageID];
    
    [view addSubview:image];
}


/**
 * Creates Rectangles and stores them.
 */

- (void)createRectangle:(NSString *)rectID withArgs:(NSDictionary *)args {
    TrickplayRectangle *rect = [[[TrickplayRectangle alloc] initWithID:rectID args:args] autorelease];
    
    NSLog(@"Rectangle created: %@", rect);
    [rectangles setObject:rect forKey:rectID];
    
    [view addSubview:rect];
}


/**
 * Creates TextFields and stores them
 */

- (void)createText:(NSString *)textID withArgs:(NSDictionary *)args {
    TrickplayText *text = [[[TrickplayText alloc] initWithID:textID args:args] autorelease];
    
    NSLog(@"Text created: %@", text);
    [textFields setObject:text forKey:textID];
    
    [view addSubview:text];
}


/**
 * Object creation function.
 */

- (void)createObjects:(NSArray *)JSON_Array {
    // Destroy any objects of the same name
    [self destroyObjects:JSON_Array];
    
    NSLog(@"Creating Objects from JSON: %@", JSON_Array);
    
    // Now that we have the JSON Array of objects, create all the objects
    for (NSDictionary *object in JSON_Array) {
        NSLog(@"Creating object %@", object);
        if ([(NSString *)[object objectForKey:@"type"] compare:@"Rectangle"] == NSOrderedSame) {
            [self createRectangle:(NSString *)[object objectForKey:@"id"]
                         withArgs:object];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Image"] == NSOrderedSame) {
            [self createImage:(NSString *)[object objectForKey:@"id"]
                     withArgs:object];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Text"] == NSOrderedSame) {
            [self createText:(NSString *)[object objectForKey:@"id"]
                     withArgs:object];
        }
    }
}


/**
 * Object Destruction function.
 */

- (void)destroyObjects:(NSArray *)JSON_Array {
    NSLog(@"Destroying Objects from JSON: %@", JSON_Array);
    
    // Total destruction
    for (NSDictionary *object in JSON_Array) {
        // remove from local repository
        NSLog(@"Destroying object %@", object);
        if ([(NSString *)[object objectForKey:@"type"] compare:@"Rectangle"] == NSOrderedSame) {
            [[rectangles objectForKey:(NSString *)[object objectForKey:@"id"]]removeFromSuperview];
            [rectangles removeObjectForKey:(NSString *)[object objectForKey:@"id"]];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Image"] == NSOrderedSame) {
            [[images objectForKey:(NSString *)[object objectForKey:@"id"]]removeFromSuperview];
            [images removeObjectForKey:(NSString *)[object objectForKey:@"id"]];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Text"] == NSOrderedSame) {
            [[textFields objectForKey:(NSString *)[object objectForKey:@"id"]]removeFromSuperview];
            [textFields removeObjectForKey:(NSString *)[object objectForKey:@"id"]];
        }
    }
}


/**
 * Object Setter function.
 */

- (void)setValuesForObjects:(NSArray *)JSON_Array {
    for (NSDictionary *object in JSON_Array) {
        NSLog(@"Setting object %@", object);
        
        // Set values for class specific properties
        if ([(NSString *)[object objectForKey:@"type"] compare:@"Rectangle"] == NSOrderedSame) {
            [(TrickplayUIElement *)[rectangles objectForKey:(NSString *)[object objectForKey:@"id"]] setValuesFromArgs:object];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Image"] == NSOrderedSame) {
            [(TrickplayUIElement *)[images objectForKey:(NSString *)[object objectForKey:@"id"]] setValuesFromArgs:object];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Text"] == NSOrderedSame) {
            [(TrickplayUIElement *)[textFields objectForKey:(NSString *)[object objectForKey:@"id"]] setValuesFromArgs:object];
        }
    }
}


/**
 * Object Getter function.
 */

- (void)getValuesForObjects:(NSArray *)JSON_Array {
    for (NSDictionary *object in JSON_Array) {
        // Set values for class specific properties
        if ([(NSString *)[object objectForKey:@"type"] compare:@"Rectangle"] == NSOrderedSame) {
            [(TrickplayUIElement *)[rectangles objectForKey:(NSString *)[object objectForKey:@"id"]] getValuesFromArgs:object];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Image"] == NSOrderedSame) {
            [(TrickplayUIElement *)[images objectForKey:(NSString *)[object objectForKey:@"id"]] getValuesFromArgs:object];
        } else if ([(NSString *)[object objectForKey:@"type"] compare:@"Text"] == NSOrderedSame) {
            [(TrickplayUIElement *)[textFields objectForKey:(NSString *)[object objectForKey:@"id"]] getValuesFromArgs:object];
        }    
    }
}


- (void)dealloc {
    NSLog(@"AdvancedUIObjectManager dealloc");
    
    self.rectangles = nil;
    self.images = nil;
    self.textFields = nil;
    self.groups = nil;
    self.resourceManager = nil;
    
    [super dealloc];
}

@end
