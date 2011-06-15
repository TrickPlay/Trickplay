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


@interface ResourceManager : NSObject <AsyncImageViewDelegate> {

    SocketManager *socketManager;

    NSMutableDictionary *resourceNames;
    NSMutableDictionary *resources;
    
    NSMutableDictionary *loadingResources;
}

- (id)initWithSocketManager:(SocketManager *)sockman;

- (void)declareResourceWithObject:(id)Object forKey:(id)key;
- (NSData *)fetchResource:(NSString *)name;
- (AsyncImageView *)fetchImageViewUsingResource:(NSString *)name frame:(CGRect)frame;
- (NSMutableDictionary *)getResourceInfo:(NSString *)name;

- (void)dropResourceGroup:(NSString *)groupName;
- (void)clean;

@end
