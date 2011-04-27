//
//  AsyncImageView.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol AsyncImageViewDelegate

@required
- (void)dataReceived:(NSData *)data resourcekey:(id)resourceKey;

@end

#import "ResourceManager.h"


@interface AsyncImageView : UIImageView {
    NSURLConnection *connection;
    NSMutableData *data;
    id resourceKey;
    
    UIActivityIndicatorView *loadingIndicator;
    
    id <AsyncImageViewDelegate> dataCacheDelegate;
}

@property (nonatomic, retain) id resourceKey;
//@property (nonatomic, assign) id <AsyncImageViewDelegate> dataCacheDelegate;
@property (nonatomic, retain) id <AsyncImageViewDelegate> dataCacheDelegate;

- (void)loadImageFromURL:(NSURL *)url resourceKey:(id)key;
- (UIImageView *)imageView;

@end
