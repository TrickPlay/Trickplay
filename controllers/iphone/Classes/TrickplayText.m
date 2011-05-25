//
//  TrickplayText.m
//  TrickplayController
//
//  Created by Rex Fenley on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayText.h"


@implementation TrickplayText

- (id)initWithID:(NSString *)textID args:(NSDictionary *)args objectManager:(AdvancedUIObjectManager *)objectManager {
    if ((self = [super initWithID:textID objectManager:objectManager])) {
        self.frame = [[UIScreen mainScreen] applicationFrame];
        self.view = [[[EditableTextView alloc] initWithFrame:CGRectMake(100, 100, 150, 150)] autorelease];
        
        view.userInteractionEnabled = YES;
        //((UITextView *)view).delegate = (EditableTextView *)view;
        if (((UITextView *)view).text.length > 0) {
            NSRange range = NSMakeRange(((UITextView *)view).text.length - 1, 1);
            [((UITextView *)view) scrollRangeToVisible:range];
        }
        //((UITextView *)view).selectedRange = NSMakeRange(((UITextView *)view).text.length - 1, 0);
        
        ((UITextView *)view).delegate = self;
        
        maxLength = 0;
        
        [self setValuesFromArgs:args];
        
        [self addSubview:view];
    }
    
    return self;
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"selected range");//: %@", [textView selectedRange]);
    NSLog(@"content size: %f, %f", ((UITextView *)view).contentSize.width, ((UITextView *)view).contentSize.height);
    //((UITextView *)view).contentSize = CGSizeMake(view.layer.bounds.size.width, view.layer.bounds.size.height);
    NSLog(@"size: %f, %f", view.layer.bounds.size.width, view.layer.bounds.size.height);
    NSLog(@"content size after: %f, %f", ((UITextView *)view).contentSize.width, ((UITextView *)view).contentSize.height);
    
    [((UITextView *)view) scrollRangeToVisible:textView.selectedRange];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if (maxLength == 0) {
        return YES;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > maxLength) ? NO : YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    NSLog(@"Done editing...");
    [textView resignFirstResponder];
    NSRange range = NSMakeRange(0,1);
    [textView scrollRangeToVisible:range];
    
    return YES;
}

#pragma mark -
#pragma mark Setters


/**
 * Setter function
 */

- (void)setValuesFromArgs:(NSDictionary *)properties {
    for (NSString *property in [properties allKeys]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set_%@:", property]);
        
        if ([TrickplayText instancesRespondToSelector:selector]) {
            [self performSelector:selector withObject:properties];
        }
    }
}

/**
 * Set max length
 */

- (void)set_max_length:(NSDictionary *)args {
    NSNumber *max = [args objectForKey:@"max_length"];
    if (max) {
        maxLength = [max unsignedIntValue];
        
        if (maxLength > 0 && [((UITextView *)view).text length] > maxLength ) {
            NSString *text = [((UITextView *)view).text substringToIndex:maxLength];
            ((UITextView *)view).text = text;
        }
    }
}

/**
 * Set alignment
 */

- (void)set_alignment:(NSDictionary *)args {
    NSString *alignment = [args objectForKey:@"alignment"];
    if (alignment) {
        if ([alignment compare:@"LEFT"] == NSOrderedSame) {
            ((UITextView *)view).textAlignment = UITextAlignmentLeft;
        } else if ([alignment compare:@"RIGHT"] == NSOrderedSame) {
            ((UITextView *)view).textAlignment = UITextAlignmentRight;
        } else if ([alignment compare:@"CENTER"] == NSOrderedSame) {
            ((UITextView *)view).textAlignment = UITextAlignmentCenter;
        }
    }
}

/**
 * Set editable to true if you like editing text
 */

- (void)set_editable:(NSDictionary *)args {
    if ([args objectForKey:@"editable"]) {
        ((UITextView *)view).editable = [[args objectForKey:@"editable"] boolValue];
    }
}

/**
 * Set the font, this parses it to match iOS implementation
 */

- (void)set_font:(NSDictionary *)args {
    NSString *fontAndSize = [args objectForKey:@"font"];
    if (fontAndSize) {
        NSMutableArray *components = [NSMutableArray arrayWithCapacity:5];
        NSScanner *aScannerDarkly = [NSScanner scannerWithString:fontAndSize];
        
        while (![aScannerDarkly isAtEnd]) {
            NSString *component = nil;
            [aScannerDarkly scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&component];
            if (component) {
                [components addObject:component];
            }
        }
        
        if ([components count] <= 1) {
            return;
        } else {
            // get the font size
            NSScanner *pixelScanner = [NSScanner scannerWithString:[components objectAtIndex:[components count]-1]];
            CGFloat fontSize;
            if (![pixelScanner scanFloat:&fontSize]) {
                NSLog(@"No pixel size found amoung font components: %@", components);
                return;
            }
            // recombine the rest of the components
            NSString *fontName = [components objectAtIndex:0];
            for (int i = 1; i < [components count]-1; i++) {
                fontName = [NSString stringWithFormat:@"%@ %@", fontName, [components objectAtIndex:i]];
            }
            UIFont *font = [UIFont fontWithName:fontName size:fontSize];
            
            ((UITextView *)view).font = font;
        }
    }
}

/**
 * Set the string of text that is displayed.
 */

- (void)set_text:(NSDictionary *)args {
    NSString *text = [args objectForKey:@"text"];
    
    if (text) {
        ((UITextView *)view).text = text;
    }
}


/**
 * Set the color of the Text.
 */

- (void)set_color:(NSDictionary *)args {
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
            alpha = CGColorGetAlpha(((UITextView *)view).textColor.CGColor);
        }
    } else if ([[args objectForKey:@"color"] isKindOfClass:[NSString class]]) {
        NSString *hexString = [args objectForKey:@"color"];
        if (!hexString || [hexString length] < 6) {
            return;
        }
        
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
            alpha = CGColorGetAlpha(((UITextView *)view).textColor.CGColor);
        }
    } else {
        return;
    }
    
    ((UITextView *)view).textColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)set_cursor_position:(NSDictionary *)args {
    NSNumber *position = [args objectForKey:@"cursor_position"];
    if (position && [view isFirstResponder]) {
        NSRange range = NSMakeRange([position unsignedIntValue], 0);
        ((UITextView *)view).selectedRange = range;
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
 * Get text
 */

- (void)get_text:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"text"]) {
        [dictionary setObject:((UITextView *)view).text forKey:@"text"];
    }
}

/**
 * Get editable
 */

- (void)get_editable:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"editable"]) {
        [dictionary setObject:[NSNumber numberWithBool:((UITextView *)view).editable] forKey:@"editable"];
    }
}

/**
 * Get alignemnt
 */

- (void)get_alignment:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"alignment"]) {
        if (((UITextView *)view).textAlignment == UITextAlignmentLeft) {
            [dictionary setObject:@"LEFT" forKey:@"alignment"];
        } else if (((UITextView *)view).textAlignment == UITextAlignmentRight) {
            [dictionary setObject:@"RIGHT" forKey:@"alignment"];
        } else if (((UITextView *)view).textAlignment == UITextAlignmentCenter) {
            [dictionary setObject:@"CENTER" forKey:@"alignment"];
        }
    }
}

/**
 * Get font
 */

- (void)get_font:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"font"]) {
        UIFont *font = ((UITextView *)view).font;
        NSString *fontName = font.fontName;
        CGFloat fontSize = font.pointSize;
        
        [dictionary setObject:[NSString stringWithFormat:@"%@ %f", fontName, fontSize] forKey:@"font"];
    }
}

/**
 * Get cursor position
 */

- (void)get_cursor_position:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"cursor_position"]) {
        NSUInteger location = ((UITextView *)view).selectedRange.location;
        if (location != NSNotFound) {
            [dictionary setObject:[NSNumber numberWithUnsignedInt:location] forKey:@"cursor_position"];
        }
    }
}

/**
 * Get max length
 */

- (void)get_max_length:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"max_length"]) {
        [dictionary setObject:[NSNumber numberWithUnsignedInt:maxLength] forKey:@"max_length"];
    }
}

/**
 * Get selected text
 */

- (void)get_selected_text:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"selected_text"]) {
        NSRange range = ((UITextView *)view).selectedRange;
        NSString *selection = [((UITextView *)view).text substringWithRange:range];
        [dictionary setObject:selection forKey:@"selected_text"];
    }
}

/**
 * Get selection end
 */

- (void)get_selection_end:(NSMutableDictionary *)dictionary {
    NSRange range = ((UITextView *)view).selectedRange;
    if (range.length > 0) {
        [dictionary setObject:[NSNumber numberWithUnsignedInteger:(range.location + range.length - 1)] forKey:@"selection_end"];
    } else {
        [dictionary setObject:[NSNumber numberWithInt:0] forKey:@"selection_end"];
    }
}

/**
 * Cursor is always visible if first responder.
 */

- (void)get_cursor_visible:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"cursor_visible"]) {
        if ([((UITextView *)view) isFirstResponder]) {
            [dictionary setObject:[NSNumber numberWithBool:YES] forKey:@"cursor_visible"];
        } else {
            [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"cursor_visible"];
        }
    }
}

/**
 * Getter function
 */

- (NSDictionary *)getValuesFromArgs:(NSDictionary *)properties {
    NSMutableDictionary *JSON_Dictionary = [NSMutableDictionary dictionaryWithDictionary:properties];
    
    for (NSString *property in [properties allKeys]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"get_%@:", property]);
        
        if ([TrickplayText instancesRespondToSelector:selector]) {
            [self performSelector:selector withObject:JSON_Dictionary];
        } else {
            [JSON_Dictionary removeObjectForKey:property];
        }
    }
    
    return JSON_Dictionary;
}


- (void)dealloc {
    NSLog(@"TrickplayText dealloc");
    
    [super dealloc];
}

@end
