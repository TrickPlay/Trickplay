//
//  ViewController.m
//  VideoSIP
//
//  Created by Rex Fenley on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import "rtpenc_h264.h"


@implementation ViewController

@synthesize captureSession;
@synthesize imageView;
@synthesize customLayer;
@synthesize prevLayer;

#pragma mark -
#pragma Video Capture

- (void)initCapture {
    //glEnable(GL_TEXTURE_2D);
	//glDisable(GL_DEPTH_TEST);
        
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil];
    
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    /*
    if ([self setUpNetwork] != 0) {
        NSLog(@"could not set up network");
        return;
    }
    //*/
    networkMan = [[NetworkManager alloc] init];
    networkMan.delegate = self;
    
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    dispatch_queue_t video_capture_queue;
    video_capture_queue = dispatch_queue_create("video_capture_queue", NULL);
    [captureOutput setSampleBufferDelegate:self queue:video_capture_queue];
    dispatch_release(video_capture_queue);
    
    NSString *pixelBufferKey = (NSString *)kCVPixelBufferPixelFormatTypeKey;
    NSNumber *pixelBufferType = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    
    captureOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey, pixelBufferType, pixelBufferKey, nil];
    
    captureSession = [[AVCaptureSession alloc] init];
    [captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    
    [captureSession addInput:captureInput];
    [captureSession addOutput:captureOutput];
    
    customLayer = [CALayer layer];
    customLayer.frame = self.view.bounds;
    //customLayer.transform = CATransform3DRotate(CATransform3DIdentity, M_PI/2.0f, 0, 0, 1.0);
    customLayer.contentsGravity = kCAGravityResizeAspectFill;
    [self.view.layer addSublayer:customLayer];
    
    imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0.0, 0.0, 150.0, 150.0);
    [self.view addSubview:imageView];
    
    prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    prevLayer.frame = CGRectMake(150.0, 0.0, 150.0, 150.0);
    prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:prevLayer];
    
    //[networkMan startEncoder];
    //[captureSession startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //dispatch_sync(image_processing_queue, ^{
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    //fprintf(stderr, "bytesPerRow: %lu; width: %lu; height: %lu\n", bytesPerRow, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextRotateCTM(newContext, M_PI_2);
    CFAbsoluteTime begin = CFAbsoluteTimeGetCurrent();
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    
    /*
     if (!pxbuffer) {
     NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithBool:YES],
     kCVPixelBufferCGImageCompatibilityKey,
     [NSNumber numberWithBool:YES],
     kCVPixelBufferCGBitmapContextCompatibilityKey,
     nil];
     
     CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (CFDictionaryRef)options, &pxbuffer);
     
     NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
     }
     
     CVPixelBufferLockBaseAddress(pxbuffer, 0);
     CGContextRef context = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(pxbuffer), width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
     CGContextTranslateCTM(context, width*.5, height);
     CGContextRotateCTM(context, -M_PI_2);
     CFAbsoluteTime a_start = CFAbsoluteTimeGetCurrent();
     CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), newImage);
     CFAbsoluteTime an_end = CFAbsoluteTimeGetCurrent();
     CGImageRelease(newImage);
     
     
     newImage = CGBitmapContextCreateImage(context);
     
     
     fprintf(stderr, "\nNew bitmap time = %lf\n", (an_end - a_start)*1000.0);
     //*/
    
    CGContextRelease(newContext);
    //CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    CFAbsoluteTime starttime = CFAbsoluteTimeGetCurrent();
    
    //fprintf(stderr, "\nSetup time = %lf\n", (starttime - begin)*1000.0);
    
    
    // TODO: create reusable OpenCV objects as instance variables to reduce
    // overhead of object creation
    /*
     using namespace cv;
     
     IplImage *iplImage = cvCreateImage(cvSize(width, height), IPL_DEPTH_8U, 4);//[self IplImageFromCGImage:newImage];
     iplImage->imageData = (char *)baseAddress;
     
     CFAbsoluteTime afteripl = CFAbsoluteTimeGetCurrent();
     fprintf(stderr, "\nIplImage conversion time = %lf\n", (afteripl - starttime)*1000.0);
     
     IplImage *rotated_image = cvCreateImage(cvSize(iplImage->height, iplImage->width), iplImage->depth, iplImage->nChannels);
     
     CFAbsoluteTime afterrot = CFAbsoluteTimeGetCurrent();
     fprintf(stderr, "IplImage creation time = %lf\n", (afterrot - afteripl)*1000.0);
     
     // rotate image
     char *src = iplImage->imageData;
     char *dest = rotated_image->imageData;
     for (int x = 0; x <= iplImage->width; x++) {
     for (int y = iplImage->height - 1; y > -1; y--) {
     *dest = *(src + ((y * width) + x) * iplImage->nChannels);
     dest++;
     }
     }
     
     //cvTranspose(iplImage, rotated_image);
     //cvFlip(rotated_image, rotated_image, 1);
     
     CFAbsoluteTime rotatetime = CFAbsoluteTimeGetCurrent();
     fprintf(stderr, "Rotation time = %lf\n", (rotatetime - afterrot)*1000.0);
     
     cvReleaseImage(&iplImage);
     
     CGImageRelease(newImage);
     newImage = [self CGImageFromIplImage:rotated_image];
     
     cvReleaseImage(&rotated_image);
     
     CFAbsoluteTime endtime = CFAbsoluteTimeGetCurrent();
     
     fprintf(stderr, "Convert back time = %lf\n", (endtime - rotatetime)*1000.0);
     //*/
    
    //[self rotateBuffer:imageBuffer];
    
    CFAbsoluteTime endtime = CFAbsoluteTimeGetCurrent();
    
    //fprintf(stderr, "Total time = %lf\n", (endtime - starttime)*1000.0);
    
    [customLayer performSelectorOnMainThread:@selector(setContents:) withObject:(id)newImage waitUntilDone:NO];
    
    //UIImage *image = [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
    
    CGImageRelease(newImage);
    
    //[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    //CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    [networkMan.avcEncoder encode:sampleBuffer];
    //});
    
    [pool drain];
}

#pragma mark -
#pragma mark NetworkManager Protocol

- (void)networkManagerEncoderReady:(NetworkManager *)networkManager {
    if (networkManager == networkMan) {
        [networkMan startEncoder];
        [captureSession startRunning];
    }
}

#pragma mark - 
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self initCapture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.imageView = nil;
    self.customLayer = nil;
    self.prevLayer = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    if (networkMan) {
        [networkMan release];
        networkMan = nil;
    }
    
    self.imageView = nil;
    self.customLayer = nil;
    self.prevLayer = nil;
    
    self.captureSession = nil;
    
    if (pxbuffer) {
        CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    }
}

@end
