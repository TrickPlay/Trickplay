//
//  ResourceManager.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncImageView.h"
#import "TVConnection.h"


@interface ResourceManager : NSObject <AsyncImageViewDelegate> {
    TVConnection *tvConnection;

    NSMutableDictionary *resourceNames;
    NSMutableDictionary *resources;
    
    NSMutableDictionary *loadingResources;
}

- (id)initWithTVConnection:(TVConnection *)tvConnection;

- (void)declareResourceWithObject:(id)Object forKey:(id)key;
- (void)loadImageDataForImageView:(AsyncImageView *)imageView withResource:(NSString *)name;
- (NSData *)fetchResource:(NSString *)name;
- (AsyncImageView *)fetchImageViewUsingResource:(NSString *)name frame:(CGRect)frame;
- (NSMutableDictionary *)getResourceInfo:(NSString *)name;

- (void)dropResourceGroup:(NSString *)groupName;
- (void)clean;

@end
