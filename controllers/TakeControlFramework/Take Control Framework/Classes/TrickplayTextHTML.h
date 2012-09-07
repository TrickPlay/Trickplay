//
//  TrickplayTextHTML.h
//  TrickplayController
//
//  Created by Rex Fenley on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrickplayUIElement.h"

    
@interface TrickplayTextHTML : TrickplayUIElement <UIWebViewDelegate> {
    NSUInteger maxLength;
    NSString *origText;
    NSString *text;
    
    // .color properties
    NSUInteger red, green, blue;
    CGFloat textAlpha;
    
    // .font properties
    NSString *fontFamily;
    NSString *fontStyle;
    NSString *fontVariant;
    NSString *fontWeight;
    NSString *fontStretch;
    CGFloat fontSize;
    
    // .ellipsize property
    BOOL ellipsize;
    
    // .wrap
    BOOL wrap;
    
    // .wrap_mode
    NSString *wrap_mode;
    
    // .justify
    BOOL justify;
    
    // .alignment
    NSString *alignment;
    
    // .password_char
    BOOL password_char;
    
    // .line_spacing
    CGFloat line_spacing;
    
    // .markup TODO: (could be security risk)
    NSString *markup;
    BOOL use_markup;
}

@property (retain) NSString *text;
@property (retain) NSString *origText;
// .font
@property (retain) NSString *fontFamily;
@property (retain) NSString *fontStyle;
@property (retain) NSString *fontVariant;
@property (retain) NSString *fontWeight;
@property (retain) NSString *fontStretch;
// .wrap_mode
@property (retain) NSString *wrap_mode;
// .alignment
@property (retain) NSString *alignment;

- (id)initWithID:(NSString *)groupID args:(NSDictionary *)args objectManager:(AdvancedUIObjectManager *)objectManager;
- (void)setHTML;

@end
