//
//  TrickplayRectangle.m
//  TrickplayController
//
//  Created by Rex Fenley on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayRectangle.h"


@implementation TrickplayRectangle

- (id)initWithID:(NSString *)rectID args:(NSDictionary *)args {
    if ((self = [super init])) {
        self.view = [[[UIView alloc] init] autorelease];
        
        [self setValuesFromArgs:args];
        /** Tests
        NSLog(@"view before: %@", view);
        NSLog(@"bounds before: %f, %f", view.layer.bounds.size.width, view.layer.bounds.size.height);
        NSLog(@"position before: %f, %f", view.layer.position.x, view.layer.position.y);
        NSLog(@"anchorpoint before: %f, %f", view.layer.anchorPoint.x, view.layer.anchorPoint.y);
        [self.view.layer setValue:[NSNumber numberWithInt:100] forKeyPath:@"transform.translation.x"];
        [self.view.layer setValue:[NSNumber numberWithInt:1] forKeyPath:@"transform.rotation.z"];
        [self.view.layer setValue:[NSNumber numberWithInt:2] forKeyPath:@"transform.scale.x"];
        NSLog(@"transform: %@", [self.view.layer valueForKeyPath:@"transform.translation.x"]);
        NSLog(@"view after: %@", view);
        NSLog(@"bounds after: %f, %f", view.layer.bounds.size.width, view.layer.bounds.size.height);
        NSLog(@"position after: %f, %f", view.layer.position.x, view.layer.position.y);        
        NSLog(@"anchorpoint after: %f, %f", view.layer.anchorPoint.x, view.layer.anchorPoint.y);
        */
        
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
    
    [self setColorFromArgs:args];
    [self setBorderColorFromArgs:args];
    [self setBorderWidthFromArgs:args];
}


/**
 * Set the color of the rectangle
 */

- (void)setColorFromArgs:(NSDictionary *)args {
    // ** Get the color and alpha values **
    CGFloat red, green, blue, alpha;
    if ([[args objectForKey:@"color"] isKindOfClass:[NSArray class]]) {
        NSArray *colorArray = [args objectForKey:@"color"];
        if (!colorArray || [colorArray count] < 3) {
            return;
        }
    
        red = [(NSNumber *)[colorArray objectAtIndex:0] floatValue]/255.0;
        green = [(NSNumber *)[colorArray objectAtIndex:1] floatValue]/255.0;
        blue = [(NSNumber *)[colorArray objectAtIndex:2] floatValue]/255.0;
    
        if ([colorArray count] > 3) {
            alpha = [(NSNumber *)[colorArray objectAtIndex:3] floatValue]/255.0;
        } else {
            alpha = view.alpha;
        }
    } else if ([[args objectForKey:@"color"] isKindOfClass:[NSString class]]) {
        NSString *hexString = [args objectForKey:@"color"];
        unsigned int value;
        
        if ([hexString characterAtIndex:0] == '#') {
            hexString = [hexString substringFromIndex:1];
        }
        
        [[NSScanner scannerWithString:hexString] scanHexInt:&value];
        if ([hexString length] > 6) {
            // alpha exists
            red = ((value & 0xFF000000) >> 24)/255.0;
            green = ((value & 0x00FF0000) >> 16)/255.0;
            blue = ((value & 0x0000FF00) >> 8)/255.0;
            alpha = (value & 0x000000FF)/255.0;
        } else {
            // just RGB
            red = ((value & 0xFF0000) >> 16)/255.0;
            green = ((value & 0x00FF00) >> 8)/255.0;
            blue = (value & 0x0000FF)/255.0;
            alpha = view.alpha;
        }
    } else {
        return;
    }
    
    view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


/**
 * Set border color
 */

- (void)setBorderColorFromArgs:(NSDictionary *)args {
    NSArray *borderColorArray = [args objectForKey:@"border_color"];
    if (!borderColorArray || [borderColorArray count] < 3) {
        return;
    }
    
    CGFloat red, green, blue, alpha;
    
    red = [(NSNumber *)[borderColorArray objectAtIndex:0] floatValue]/255.0;
    green = [(NSNumber *)[borderColorArray objectAtIndex:1] floatValue]/255.0;
    blue = [(NSNumber *)[borderColorArray objectAtIndex:2] floatValue]/255.0;
    
    if ([borderColorArray count] > 3) {
        alpha = [(NSNumber *)[borderColorArray objectAtIndex:3] floatValue]/255.0;
    } else {
        alpha = view.alpha;
    }
    
    view.layer.borderColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha].CGColor;
}


/**
 * Set border width
 */

- (void)setBorderWidthFromArgs:(NSDictionary *)args {
    CGFloat borderWidth = [(NSNumber *)[args objectForKey:@"border_width"] floatValue];
    
    if (borderWidth) {
        view.layer.borderWidth = borderWidth;
    }
}

#pragma mark -
#pragma mark New Protocol

- (NSString *)callMethod:(NSString *)method withArgs:(NSArray *)args {
    return [super callMethod:method withArgs:args];
}


- (void)dealloc {
    NSLog(@"TrickplayRectangle dealloc");
    
    [super dealloc];
}

@end
