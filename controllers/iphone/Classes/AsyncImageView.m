//
//  AsyncImageView.m
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageView.h"


@implementation AsyncImageView

@synthesize dataCacheDelegate;
@synthesize otherDelegate;
@synthesize resourceKey;

- (void)loadImageFromURL:(NSURL *)url resourceKey:(id)key {
    if (connection) {
        [connection cancel];
        [connection release];
        connection = nil;
    }
    if (data) {
        [data release];
        data = nil;
    }
    self.resourceKey = key;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
        NSLog(@"Connection to URL %@ could not be established", url);
        // make a broken link symbol in image
        return;
    }
    //spinny thing
    loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadingIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addSubview:loadingIndicator];
    [loadingIndicator release];
    loadingIndicator.hidesWhenStopped = YES;
    [loadingIndicator startAnimating];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)incrementalData {
    if (!data) {
        data = [[NSMutableData alloc] initWithCapacity:10000];
    }
    
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
    NSLog(@"Connection did finish loading %@", resourceKey);
    [connection cancel];
    [connection release];
    connection = nil;

    if ([[self subviews] count] > 0) {
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageWithData:data]] autorelease];
    // might need to change this to scale to fill
    //imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    // If the width and/or height of the AsyncImageView was unspecified then
    // set as the natural width and/or height of the Image
    CGFloat width = (self.frame.size.width == 0.0) ? imageView.frame.size.width : self.frame.size.width;
    CGFloat height = (self.frame.size.height == 0.0) ? imageView.frame.size.height : self.frame.size.height;
    if (self.frame.size.width == 0.0 || self.frame.size.height == 0.0) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
    }
    
    [self addSubview:imageView];
    imageView.frame = self.bounds;
    [imageView setNeedsLayout];
    [self setNeedsLayout];
    
    // send data to the delegate if it exists for cacheing
    if (dataCacheDelegate) {
        [dataCacheDelegate dataReceived:data resourcekey:resourceKey];
    }
    if (otherDelegate) {
        [otherDelegate dataReceived:data resourcekey:resourceKey];
    }

    [data release];
    data = nil;
    [loadingIndicator stopAnimating];
    [loadingIndicator removeFromSuperview];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
    NSLog(@"Image did fail with error: %@", error);
}

- (UIImageView *)imageView {
    return [[self subviews] objectAtIndex:0];
}

- (void)dealloc {
    NSLog(@"AsyncImageView dealloc");
    if (connection) {
        [connection cancel];
        [connection release];
    }
    if (data) {
        [data release];
    }
    if (resourceKey) {
        [resourceKey release];
    }
    if (dataCacheDelegate) {
        [(NSObject *)dataCacheDelegate release];
        dataCacheDelegate = nil;
    }
    
    [super dealloc];
}

@end