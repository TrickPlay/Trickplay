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

@interface TrickplayText : TrickplayUIElement {
    
}

- (id)initWithID:(NSString *)textID args:(NSDictionary *)args;

- (void)setTextColorFromArgs:(NSDictionary *)args;
- (void)setTextFromArgs:(NSDictionary *)args;

@end
