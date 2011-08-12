//
//  TrickplayGroup.h
//  TrickplayController
//
//  Created by Rex Fenley on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YAJLiOS/YAJL.h>
#import "TrickplayUIElement.h"

@protocol AdvancedUIScreenDelegate <NSObject>

@required
- (void)do_UB:(NSArray *)args;
- (void)object_added;

@end

@interface TrickplayGroup : TrickplayUIElement {
    id <AdvancedUIScreenDelegate> delegate;
}

@property (assign) id <AdvancedUIScreenDelegate> delegate;

- (id)initWithID:(NSString *)groupID args:(NSDictionary *)args objectManager:(AdvancedUIObjectManager *)objectManager;

- (NSDictionary *)do_find_child:(NSArray *)args;
- (NSNumber *)do_clear:(NSArray *)args;

@end
