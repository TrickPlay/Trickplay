//
//  TrickplayTextHTML.m
//  TrickplayController
//
//  Created by Rex Fenley on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrickplayTextHTML.h"


@implementation TrickplayTextHTML

@synthesize text;
@synthesize origText;
@synthesize fontFamily;
@synthesize fontStyle;
@synthesize fontVariant;
@synthesize fontWeight;
@synthesize fontStretch;
@synthesize wrap_mode;
@synthesize alignment;

- (id)initWithID:(NSString *)textID args:(NSDictionary *)args objectManager:(AdvancedUIObjectManager *)objectManager {
    if ((self = [super initWithID:textID objectManager:objectManager])) {
        self.view = [[[UIWebView alloc] initWithFrame:[self getFrameFromArgs:args]] autorelease];
        view.layer.anchorPoint = CGPointMake(0.0, 0.0);
                
        self.text = @"";
        self.origText = @"";
        
        view.userInteractionEnabled = YES;
        
        view.contentMode = UIViewContentModeRedraw;
        
        self.view.backgroundColor = [UIColor clearColor];
        self.view.opaque = NO;
        
        maxLength = 0;
        
        // init .color property
        red = 255;
        green = 255;
        blue = 255;
        textAlpha = 1.0;
        
        // init .font property
        fontFamily = nil;
        fontStyle = nil;
        fontVariant = nil;
        fontWeight = nil;
        fontStretch = nil;
        fontSize = 0.0;
        
        // .ellipsize
        ellipsize = NO;
        
        // .wrap
        wrap = NO;
        self.wrap_mode = @"WORD";
        
        // .justify
        justify = NO;
        
        // .alignment
        alignment = nil;
        
        // .password_char
        password_char = NO;
        
        // .line_spacing
        line_spacing = 0.0;
        
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

- (NSString *)getHtml {
    NSString *html = [NSString stringWithFormat:@"<html><body><div style='vertical-align:baseline;"];

    // .color property
    html = [NSString stringWithFormat:@"%@color:#%02x%02x%02x;", html, red, green, blue];
    html = [NSString stringWithFormat:@"%@opacity:%f;", html, textAlpha];
    
    // .font property
    if (fontFamily) {
        html = [NSString stringWithFormat:@"%@font-family:%@;", html, fontFamily];
    }
    if (fontStyle) {
        html = [NSString stringWithFormat:@"%@font-style:%@;", html, fontStyle];
    }
    if (fontVariant) {
        html = [NSString stringWithFormat:@"%@font-variant:%@;", html, fontVariant];
    }
    if (fontWeight) {
        html = [NSString stringWithFormat:@"%@font-weight:%@;", html, fontWeight];
    }
    if (fontStretch) {
        html = [NSString stringWithFormat:@"%@font-stretch:%@;", html, fontStretch];
    }
    html = [NSString stringWithFormat:@"%@font-size:%fpx;", html, fontSize];
    
    // .ellipsize
    if (ellipsize) {
        html = [NSString stringWithFormat:@"%@text-overflow:ellipsis;", html];
    } else {
        html = [NSString stringWithFormat:@"%@text-overflow:clip;", html];
    }
    
    // .wrap
    if (!wrap) {
        html = [NSString stringWithFormat:@"%@white-space:nowrap;", html];
    }
    
    // .wrap_mode
    if (wrap_mode) {
        if ([wrap_mode compare:@"WORD"] == NSOrderedSame) {
            html = [NSString stringWithFormat:@"%@word-wrap:normal;", html];
        } else if (([wrap_mode compare:@"CHAR"] == NSOrderedSame) || ([wrap_mode compare:@"WORD_CHAR"] == NSOrderedSame)) {
            html = [NSString stringWithFormat:@"%@word-wrap:break-word;", html];
        }
    }
    
    // .justify
    if (justify) {
        html = [NSString stringWithFormat:@"%@text-align:center;", html];
    }
    
    // .alignment
    if (alignment) {
        if ([alignment compare:@"LEFT"] == NSOrderedSame) {
            html = [NSString stringWithFormat:@"%@text-align:left;", html];
        } else if ([alignment compare:@"CENTER"] == NSOrderedSame) {
            html = [NSString stringWithFormat:@"%@text-align:center;", html];
        } else if ([alignment compare:@"RIGHT"] == NSOrderedSame) {
            html = [NSString stringWithFormat:@"%@text-align:right;", html];
        }
    }
    
    // .line_spacing
    html = [NSString stringWithFormat:@"%@line-height:%fpx;", html, line_spacing + fontSize];
    
    // .password_char
    if (password_char) {
        html = [NSString stringWithFormat:@"%@overflow:hidden;background-color:transparent;'>", html];
        for (int i = 0; i < text.length; i++) {
            html = [NSString stringWithFormat:@"%@*", html];
        }
        html = [NSString stringWithFormat:@"%@</div></body></html>", html];
    } else {
        html = [NSString stringWithFormat:@"%@overflow:hidden;background-color:transparent;'>%@</div></body></html>", html, text];
    }
    
    NSLog(@"html: %@", html);
    return html;
    //return [NSString stringWithFormat:@"<html><body><span style='color:#ff00ff55;font-family:arial;font-variant:small-caps;font-stretch:condensed;font-size:32px;font-style:italic;font-weight:bold;text-decoration:underline;text-align:center;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;line-height:10px'>%@</span></body></html>", html];
}

- (void)setHTML {
    [(UIWebView *)view loadHTMLString:[self getHtml] baseURL:nil];
}

/**
 * Set the string of text that is displayed.
 */

- (void)on_text_changed:(NSString *)theText {
    if (manager && manager.gestureViewController) {
        NSMutableDictionary *JSON_dic = [[NSMutableDictionary alloc] initWithCapacity:10];
        [JSON_dic setObject:ID forKey:@"id"];
        [JSON_dic setObject:@"on_text_changed" forKey:@"event"];
        [JSON_dic setObject:theText forKey:@"text"];
        
        [manager.gestureViewController sendEvent:@"UX" JSON:[JSON_dic yajl_JSONString]];
        [JSON_dic release];
    }
}

- (void)set_text:(NSDictionary *)args {
    if (args) {
        NSString *atext = [args objectForKey:@"text"];
    
        if (atext) {
            self.origText = atext;
            if (maxLength) {
                atext = [atext substringToIndex:maxLength];
            }
            self.text = atext;
            
            [self on_text_changed:atext];
        }
    }
}

- (void)do_set_text:(NSDictionary *)args {
    if (args) {
        NSString *atext = [args objectForKey:@"text"];
        
        if (atext) {
            self.origText = atext;
            if (maxLength) {
                atext = [atext substringToIndex:maxLength];
            }
            self.text = atext;
            
            [self on_text_changed:atext];
        }
    }
}

/**
 * Set the color of the Text.
 */

- (void)set_color:(NSDictionary *)args {
    // ** Get the color and alpha values **
    if ([[args objectForKey:@"color"] isKindOfClass:[NSArray class]]) {
        NSArray *colorArray = [args objectForKey:@"color"];
        if (!colorArray || [colorArray count] < 3) {
            return;
        }
        
        red = [(NSNumber *)[colorArray objectAtIndex:0] unsignedIntValue];
        green = [(NSNumber *)[colorArray objectAtIndex:1] unsignedIntValue];
        blue = [(NSNumber *)[colorArray objectAtIndex:2] unsignedIntValue];
        
        if ([colorArray count] > 3) {
            textAlpha = [(NSNumber *)[colorArray objectAtIndex:3] floatValue]/255.0;
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
            red = (value & 0xFF000000) >> 24;
            green = (value & 0x00FF0000) >> 16;
            blue = (value & 0x0000FF00) >> 8;
            textAlpha = (value & 0x000000FF)/255.0;
        } else {
            // just RGB
            red = (value & 0xFF0000) >> 16;
            green = (value & 0x00FF00) >> 8;
            blue = value & 0x0000FF;
        }
    } else {
        return;
    }
}

/**
 * Set the font, this parses it to match HTML
 *
 * MUST have font-family as the first component of this string
 * MUST have style attributes in this order:
 *     font-style font-variant font-weight font-stretch
 * but may leave out the latter, i.e. if only font-style and font-variant
 * are needed then just use "font-style font-variant"
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
        
        if ([components count] < 1) {
            return;
        } else {
            // its all in the family
            self.fontFamily = [components objectAtIndex:0];
            
            self.fontStyle = nil;
            self.fontVariant = nil;
            self.fontWeight = nil;
            self.fontStretch = nil;
            
            if ([components count] > 1) {
                // get the font size
                NSScanner *pixelScanner = [NSScanner scannerWithString:[components objectAtIndex:[components count]-1]];
                if ([pixelScanner scanFloat:&fontSize]) {
                    [components removeLastObject];
                }
                        
                // get style attributes
                for (int i = 1; i < components.count; i++) {
                    if (i == 1) {
                        self.fontStyle = [components objectAtIndex:i];
                    } else if (i == 2) {
                        self.fontVariant = [components objectAtIndex:i];
                    } else if (i == 3) {
                        self.fontWeight = [components objectAtIndex:i];
                    } else if (i == 4) {
                        self.fontStretch = [components objectAtIndex:i];
                    } else {
                        break;
                    }
                }
            }
        }
    }
}

/**
 * Sets ellipsize, values "START", "END", and "MIDDLE" all set html
 * text-overflow:ellipsis
 */

- (void)set_ellipsize:(NSDictionary *)args {
    id to_ellipsize = [args objectForKey:@"ellipsize"];
    
    if (to_ellipsize && [to_ellipsize isKindOfClass:[NSString class]]) {
        if ([(NSString *)to_ellipsize compare:@"START"] == NSOrderedSame) {
            ellipsize = YES;
        } else if ([(NSString *)to_ellipsize compare:@"MIDDLE"] == NSOrderedSame) {
            ellipsize = YES;
        } else if ([(NSString *)to_ellipsize compare:@"END"] == NSOrderedSame) {
            ellipsize = YES;
        } else if ([(NSString *)to_ellipsize compare:@"NONE"] == NSOrderedSame) {
            ellipsize = NO;
        }
    }
}

/**
 * Sets the word wrapping
 */

- (void)set_wrap:(NSDictionary *)args {
    wrap = [[args objectForKey:@"wrap"] boolValue];
}

- (void)set_wrap_mode:(NSDictionary *)args {
    if ([[args objectForKey:@"wrap_mode"] isKindOfClass:[NSString class]]) {
        self.wrap_mode = (NSString *)[args objectForKey:@"wrap_mode"];
    }
}

/**
 * Sets justification of text
 */

- (void)set_justify:(NSDictionary *)args {
    justify = [[args objectForKey:@"justify"] boolValue];
}

/**
 * Sets the alignment of the text
 */

- (void)set_alignment:(NSDictionary *)args {
    if ([[args objectForKey:@"alignment"] isKindOfClass:[NSString class]]) {
        self.alignment = [args objectForKey:@"alignment"];
    }
}

/**
 * Sets max number of characters
 */

- (void)set_max_length:(NSDictionary *)args {
    NSLog(@"origText: %@", origText);
    maxLength = [[args objectForKey:@"max_length"] unsignedIntValue];
    
    if (origText && [origText length] > maxLength && maxLength > 0) {
        self.text = [origText substringToIndex:maxLength];
    } else {
        self.text = [NSString stringWithFormat:@"%@", origText];
    }
}

/**
 * Sets the password_char bool
 */

- (void)set_password_char:(NSDictionary *)args {
    password_char = [[args objectForKey:@"password_char"] boolValue];
}

/**
 * Set line_spacing float
 */

- (void)set_line_spacing:(NSDictionary *)args {
    id space = [args objectForKey:@"line_spacing"];
    if (space && [space isKindOfClass:[NSNumber class]]) {
        line_spacing = [space floatValue];
    }
}

/**
 * Setter function
 */

- (void)setValuesFromArgs:(NSDictionary *)properties {
    for (NSString *property in [properties allKeys]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set_%@:", property]);
        
        if ([TrickplayTextHTML instancesRespondToSelector:selector]) {
            [self performSelector:selector withObject:properties];
        } else {
            selector = NSSelectorFromString([NSString stringWithFormat:@"do_set_%@:", property]);
            if ([TrickplayTextHTML instancesRespondToSelector:selector]) {
                [self performSelector:selector withObject:properties];
            }
        }
    }
    
    [self setHTML];
}

#pragma mark -
#pragma mark Getters

/**
 * Get color
 */

- (void)get_color:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"color"]) {
        NSNumber *a_red, *a_green, *a_blue, *an_alpha;
        
        a_red = [NSNumber numberWithUnsignedInt:red];
        a_green = [NSNumber numberWithUnsignedInt:green];
        a_blue = [NSNumber numberWithUnsignedInt:blue];
        an_alpha = [NSNumber numberWithFloat:textAlpha * 255.0];
        
        NSArray *colorArray = [NSArray arrayWithObjects:a_red, a_green, a_blue, an_alpha, nil];
        [dictionary setObject:colorArray forKey:@"color"];
    }
}

/**
 * Get background color
 */

- (void)get_background_color:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"background_color"]) {
        NSNumber *a_red, *a_green, *a_blue, *an_alpha;
        
        const CGFloat *components = CGColorGetComponents(view.layer.backgroundColor);
        a_red = [NSNumber numberWithFloat:components[0] * 255.0];
        a_green = [NSNumber numberWithFloat:components[1] * 255.0];
        a_blue = [NSNumber numberWithFloat:components[2] * 255.0];
        an_alpha = [NSNumber numberWithFloat:CGColorGetAlpha(view.layer.backgroundColor) * 255.0];
        
        NSArray *colorArray = [NSArray arrayWithObjects:a_red, a_green, a_blue, an_alpha, nil];
        [dictionary setObject:colorArray forKey:@"background_color"];
    }
}

/**
 * Get text
 */

- (void)get_text:(NSMutableDictionary *)dictionary {
    if ([dictionary objectForKey:@"text"]) {
        [dictionary setObject:origText forKey:@"text"];
    }
}


/**
 * Get the font, this parses it to match HTML
 *
 * MUST have font-family as the first component of this string
 * MUST have style attributes in this order:
 *     font-style font-variant font-weight font-stretch
 * but may leave out the latter, i.e. if only font-style and font-variant
 * are needed then just use "font-style font-variant"
 */

- (void)get_font:(NSMutableDictionary *)dictionary {
    NSString *font = @"";
    
    // .font property
    if (fontFamily) {
        font = [NSString stringWithFormat:@"%@ %@", font, fontFamily];
    }
    if (fontStyle) {
        font = [NSString stringWithFormat:@"%@ %@", font, fontStyle];
    }
    if (fontVariant) {
        font = [NSString stringWithFormat:@"%@ %@", font, fontVariant];
    }
    if (fontWeight) {
        font = [NSString stringWithFormat:@"%@ %@", font, fontWeight];
    }
    if (fontStretch) {
        font = [NSString stringWithFormat:@"%@ %@", font, fontStretch];
    }
    font = [NSString stringWithFormat:@"%@ %fpx", font, fontSize];
    
    [dictionary setObject:font forKey:@"font"];
}

/**
 * Gets ellipsize, values "START", "END", and "MIDDLE" all set html
 * text-overflow:ellipsis
 */

- (void)get_ellipsize:(NSMutableDictionary *)dictionary {
    if (ellipsize) {
        [dictionary setObject:@"START" forKey:@"ellipsize"];
    } else {
        [dictionary setObject:@"NONE" forKey:@"ellipsize"];
    }
}

/**
 * Gets the word wrapping
 */

- (void)get_wrap:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithBool:wrap] forKey:@"wrap"];
}

- (void)get_wrap_mode:(NSMutableDictionary *)dictionary {
        [dictionary setObject:wrap_mode forKey:@"wrap_mode"];
}

/**
 * Gets justification of text
 */

- (void)get_justify:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithBool:justify] forKey:@"justify"];
}

/**
 * Gets the alignment of the text
 */

- (void)get_alignment:(NSMutableDictionary *)dictionary {
    if (!alignment) {
        [dictionary setObject:[NSNull null] forKey:@"alignment"];
        return;
    }
    [dictionary setObject:alignment forKey:@"alignment"];
}

/**
 * Gets max number of characters
 */

- (void)get_max_length:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithUnsignedInt:maxLength] forKey:@"max_length"];
}

/**
 * Gets the password_char bool
 */

- (void)get_password_char:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithBool:password_char] forKey:@"password_char"];
}

/**
 * Gets the line spacing
 */

- (void)get_line_spacing:(NSMutableDictionary *)dictionary {
    [dictionary setObject:[NSNumber numberWithFloat:line_spacing] forKey:@"line_spacing"];
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
    
    self.text = nil;
    self.origText = nil;
    self.fontFamily = nil;
    self.fontStyle = nil;
    self.fontVariant = nil;
    self.fontWeight = nil;
    self.fontStretch = nil;
    self.wrap_mode = nil;
    self.alignment = nil;
    
    [super dealloc];
}

@end
