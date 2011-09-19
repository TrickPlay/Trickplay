//
//  TrickplayImage.h
//  TrickplayController
//
//  Created by Rex Fenley on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResourceManager.h"
#import "TrickplayUIElement.h"

@class AdvancedUIObjectManager;

@interface TrickplayImage : TrickplayUIElement <AsyncImageViewDelegate> {
    BOOL loaded;
    NSString *src;
}

@property (nonatomic, retain) NSString *src;

// Async protocol
- (void)dataReceived:(NSData *)data resourcekey:(id)resourceKey;

//
- (id)initWithID:(NSString *)imageID args:(NSDictionary *)args resourceManager:(ResourceManager *)resourceManager objectManager:(AdvancedUIObjectManager *)objectManager;

@end
