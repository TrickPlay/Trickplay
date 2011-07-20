//
//  TrickplayText.h
//  TrickplayController
//
//  Created by Rex Fenley on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EditableTextView.h"
#import "TrickplayUIElement.h"

@interface TrickplayText : TrickplayUIElement <UITextViewDelegate> {
    NSUInteger maxLength;
}

- (id)initWithID:(NSString *)groupID args:(NSDictionary *)args objectManager:(AdvancedUIObjectManager *)objectManager;

@end
