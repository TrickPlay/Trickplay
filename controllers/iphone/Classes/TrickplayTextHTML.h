//
//  TrickplayTextHTML.h
//  TrickplayController
//
//  Created by Rex Fenley on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrickplayUIElement.h"

@interface TrickplayTextHTML : TrickplayUIElement {
    NSUInteger maxLength;
}

- (id)initWithID:(NSString *)groupID args:(NSDictionary *)args objectManager:(AdvancedUIObjectManager *)objectManager;

@end
