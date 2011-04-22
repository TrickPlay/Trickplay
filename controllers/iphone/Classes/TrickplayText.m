//
//  TrickplayText.m
//  TrickplayController
//
//  Created by Rex Fenley on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayText.h"


@implementation TrickplayText

- (id)initWithID:(NSString *)textID args:(NSDictionary *)args {
    if ((self = [super init])) {
        self.view = [[[UITextField alloc] init] autorelease];
        
        [self setValuesFromArgs:args];
    }
    
    return self;
}


/**
 * Set the string of text that is displayed.
 */

- (void)setTextFromArgs:(NSDictionary *)args {
    NSString *text = [args objectForKey:@"text"];
    
    if (text) {
        ((UITextField *)view).text = text;
    }
}


/**
 * Set the color of the Text.
 */

- (void)setTextColorFromArgs:(NSDictionary *)args {
    NSArray *colorArray = [args objectForKey:@"color"];
    if (!colorArray || [colorArray count] < 3) {
        return;
    }
    
    // ** Get the color and alpha values **
    CGFloat red, green, blue, alpha;
    
    red = [(NSNumber *)[colorArray objectAtIndex:0] floatValue]/255.0;
    green = [(NSNumber *)[colorArray objectAtIndex:1] floatValue]/255.0;
    blue = [(NSNumber *)[colorArray objectAtIndex:2] floatValue]/255.0;
    
    if ([colorArray count] > 3) {
        alpha = [(NSNumber *)[colorArray objectAtIndex:3] floatValue]/255.0;
    } else {
        alpha = view.alpha;
    }
    
    ((UITextField *)view).textColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
