//
//  ResourceManager.m
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResourceManager.h"


@implementation ResourceManager

- (id)initWithSocketManager:(SocketManager *)sockman {
    if ((self = [super init])) {
        socketManager = [sockman retain];
        resourceNames = [[NSMutableDictionary alloc] initWithCapacity:40];
        resources = [[NSMutableDictionary alloc] initWithCapacity:40];
    }
    return self;
}

- (void)declareResourceWithObject:(id)Object forKey:(id)key {
    [resourceNames setObject:Object forKey:key];
    if ([resources objectForKey:key]) {
        [resources removeObjectForKey:key];
    }
}

- (NSMutableDictionary *)getResourceInfo:name {
    return [resourceNames objectForKey:name];
}

- (NSData *)fetchResource:(NSString *)name {
    NSLog(@"Fetching resource %@", name);
    NSData *tempData;
    
    if ((tempData = [resources objectForKey:name])) {
        NSLog(@" from dictionary");
        return tempData;
    } else {    // pull resource
        NSLog(@" from network");
        NSString *dataURLString = [[resourceNames objectForKey:name] objectForKey:@"link"];
        if ([dataURLString hasPrefix:@"http:"] || [dataURLString hasPrefix:@"https:"]) {
            tempData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dataURLString]];
            /** For testing
            NSURL *dataurl = [NSURL URLWithString:@"http://www.google.com/logos/2011/womensday11-hp.jpg"];
            tempData = [NSData dataWithContentsOfURL:dataurl];
            //*/
        } else {
            //Use the hostname and port to construct the url
            NSURL *dataurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/%@", [socketManager host], [socketManager port], dataURLString]];
            /** For testing
            dataurl = [NSURL URLWithString:@"http://www.google.com/logos/2011/womensday11-hp.jpg"];
            //*/
            tempData = [NSData dataWithContentsOfURL:dataurl];
        }
        if (tempData) {
            [resources setObject:tempData forKey:name];
        } else {
            NSLog(@"Trouble pulling resource %@ from network! Will set as nil\n", [resourceNames objectForKey:name]);
        }
        
    }
    return tempData;
}

- (UIImageView *)fetchImageViewUsingResource:(NSString *)name
                                       frame:(CGRect)frame {
    AsyncImageView *imageView = [[[AsyncImageView alloc] initWithFrame:frame] autorelease];
    
    NSData *tempData;
    if ((tempData = [resources objectForKey:name])) {
        // image data already cached, set it to the view
        imageView.image = [UIImage imageWithData:tempData];
    } else {
        // asynchronously pull the image
        NSLog(@" from network");
        NSURL *dataurl;
        // create the url to pull the data from
        NSString *dataURLString = [[resourceNames objectForKey:name] objectForKey:@"link"];
        if ([dataURLString hasPrefix:@"http:"] || [dataURLString hasPrefix:@"https:"]) {
            dataurl = [NSURL URLWithString:dataURLString];
        } else {
            //Use the hostname and port to construct the url
            dataurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/%@", [socketManager host], [socketManager port], dataURLString]];
        }
        /**For testing
        dataurl = [NSURL URLWithString:@"http://www.google.com/logos/2011/womensday11-hp.jpg"];
        //*/
        imageView.dataCacheDelegate = self;
        [imageView loadImageFromURL:dataurl resourceKey:name];
    }

    return (UIImageView *)imageView;
}

- (void)dataReceived:(NSData *)data resourcekey:(id)resourceKey {
    if (data && resourceKey) {
        [resources setObject:data forKey:(NSString *)resourceKey];
    } else {
        NSLog(@"Could not cache data, either no key is specified or the data never arrived over the network");
    }
}

- (void)clean {
    [resourceNames removeAllObjects];
    [resources removeAllObjects];
}

- (void)dealloc {
    NSLog(@"ResourceManager dealloc");
    [self clean];
    if (socketManager) {
        [socketManager release];
    }
    if (resourceNames) {
        [resourceNames release];
    }
    if (resources) {
        [resources release];
    }
    
    [super dealloc];
}

@end
