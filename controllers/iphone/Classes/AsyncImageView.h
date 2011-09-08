//
//  AsyncImageView.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@protocol AsyncImageViewDelegate

@optional
- (void)on_loadedFailed:(BOOL)failed;

@required
- (void)dataReceived:(NSData *)data resourcekey:(id)resourceKey;

@end

//#import "ResourceManager.h"
@class ResourceManager;

@interface AsyncImageView : UIView {
    NSURLConnection *connection;
    NSMutableData *data;
    BOOL loaded;
    id resourceKey;
    
    BOOL tileWidth;
    BOOL tileHeight;
    
    UIImage *image;
    
    UIActivityIndicatorView *loadingIndicator;
    
    id <AsyncImageViewDelegate> dataCacheDelegate;
    id <AsyncImageViewDelegate> otherDelegate;
}

@property (assign) BOOL loaded;
@property (retain) UIImage *image;
@property (retain) id resourceKey;
@property (assign) BOOL tileWidth;
@property (assign) BOOL tileHeight;
@property (assign) id <AsyncImageViewDelegate> otherDelegate;
@property (retain) id <AsyncImageViewDelegate> dataCacheDelegate;

- (void)loadImageFromURL:(NSURL *)url resourceKey:(id)key;
- (void)on_loadedFailed:(BOOL)failed;
- (void)loadImageFromData:(NSData *)data;
- (void)setTileWidth:(BOOL)toTileWidth height:(BOOL)toTileHeight;
- (void)animateSpinner;
//- (UIImageView *)imageView;

@end
