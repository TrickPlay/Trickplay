//
//  ViewController.h
//  VideoSIP
//
//  Created by Rex Fenley on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>

#import "NetworkManager.h"

@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
    NetworkManager *networkMan;
    
    AVCaptureSession *captureSession;
    UIImageView *imageView;
    CALayer *customLayer;
    AVCaptureVideoPreviewLayer *prevLayer;
    
    CVPixelBufferRef pxbuffer;
}

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) CALayer *customLayer;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prevLayer;

- (void)initCapture;

@end
