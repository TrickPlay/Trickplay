//
//  TrickplayGroup.h
//  TrickplayController
//
//  Created by Rex Fenley on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YAJLiOS/YAJL.h>
#import "ResourceManager.h"
#import "TrickplayUIElement.h"
#import "AdvancedUIObjectManager.h"

@class AdvancedUIObjectManager;

@interface TrickplayGroup : TrickplayUIElement {
    AdvancedUIObjectManager *manager;
}

@property (nonatomic, retain) AdvancedUIObjectManager *manager;

- (id)initWithID:(NSString *)groupID args:(NSDictionary *)args resourceManager:(ResourceManager *)resourceManager;

@end
