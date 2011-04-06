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
        // ** Get the color and alpha values **
        CGFloat red = 1.0, green = 1.0, blue = 1.0, alpha = 1.0;
        NSArray *colorArray = [args objectForKey:@"color"];
        if (colorArray && [colorArray count] > 0 && [colorArray objectAtIndex:0]) {
            red = [(NSNumber *)[colorArray objectAtIndex:0] floatValue]/255.0;
        }
        if (colorArray && [colorArray count] > 1 && [colorArray objectAtIndex:1]) {
            green = [(NSNumber *)[colorArray objectAtIndex:1] floatValue]/255.0;
        }
        if (colorArray && [colorArray count] > 2 && [colorArray objectAtIndex:2]) {
            blue = [(NSNumber *)[colorArray objectAtIndex:2] floatValue]/255.0;
        }
        if (colorArray && [colorArray count] > 3 && [colorArray objectAtIndex:3]) {
            alpha = [(NSNumber *)[colorArray objectAtIndex:3] floatValue]/255.0;
        }
        
        CGRect frame = [self getFrameFromArgs:args];
        self.view = [[UIView alloc] initWithFrame:frame];
        
        NSLog(@"Color: %@", [UIColor colorWithRed:red green:green blue:blue alpha:alpha]);
        view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"TrickplayRectangle dealloc");
    
    [super dealloc];
}

@end
