//
//  TrickplayText.h
//  TrickplayController
//
//  Created by Rex Fenley on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrickplayUIElement.h"
#import "ResourceManager.h"
#import "EditableTextView.h"

@interface TrickplayText : TrickplayUIElement <UITextViewDelegate> {
    NSUInteger maxLength;
}

- (id)initWithID:(NSString *)textID args:(NSDictionary *)args;

- (void)setTextColorFromArgs:(NSDictionary *)args;
- (void)setFontFromArgs:(NSDictionary *)args;
- (void)setEditableFromArgs:(NSDictionary *)args;
- (void)setTextFromArgs:(NSDictionary *)args;
- (void)setTextAlignmentFromArgs:(NSDictionary *)args;
- (void)setMaxLengthFromArgs:(NSDictionary *)args;

@end
