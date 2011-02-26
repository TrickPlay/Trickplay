//
//  ResourceManager.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketManager.h"
#import "AsyncImageView.h"


@interface ResourceManager : NSObject <AsyncImageViewDelegate>{

    SocketManager *socketManager;
    NSMutableDictionary *resourceNames;
    NSMutableDictionary *resources;
    
}

- (id)initWithSocketManager:(SocketManager *)sockman;

- (void)declareResourceWithObject:(id)Object forKey:(id)key;
- (NSData *)fetchResource:(NSString *)name;
- (UIImageView *)fetchImageViewUsingResource:(NSString *)name frame:(CGRect)frame;
- (NSMutableDictionary *)getResourceInfo:(NSString *)name;

@end
