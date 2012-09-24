//
//  VideoStreamer.m
//  VideoSIP
//
//  Created by Rex Fenley on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoStreamer.h"
#import "NetworkManager.h"

#import "rtpenc_h264.h"


@interface _VideoStreamerContext : VideoStreamerContext {
@private
    NSString *fullAddress;
    NSString *SIPPassword;
    NSString *SIPUserName;
    NSString *SIPRemoteUserName;
    NSString *SIPServerHostName;
    UInt16 SIPServerPort;       // defaults to 5060
    UInt16 SIPClientPort;       // defaults to 5060
}

@end

@implementation _VideoStreamerContext

#pragma mark -
#pragma mark Property Getters

- (NSString *)fullAddress {
    return fullAddress;
}

- (NSString *)SIPPassword {
    return SIPPassword;
}

- (NSString *)SIPUserName {
    return SIPUserName;
}

- (NSString *)SIPRemoteUserName {
    return SIPRemoteUserName;
}

- (NSString *)SIPServerHostName {
    return SIPServerHostName;
}

- (UInt16)SIPServerPort {
    return SIPServerPort;
}

- (UInt16)SIPClientPort {
    return SIPClientPort;
}

#pragma mark -
#pragma mark init function

- (id)init {
    return [self initWithUserName:nil password:nil remoteUserName:nil serverHostName:nil serverPort:0 clientPort:0];
}

- (id)initWithUserName:(NSString *)user password:(NSString *)password remoteAddress:(NSString *)remoteAddress serverPort:(NSUInteger)serverPort clientPort:(NSUInteger)clientPort {
    if (!user || !password || !remoteAddress) {
        [self release];
        return nil;
    }
    
    NSArray *components = [remoteAddress componentsSeparatedByString:@":"];
    if (components.count != 2) {
        [self release];
        return nil;
    }
    NSString *protocol = [components objectAtIndex:0]; // For now this should be "sip"
    if ([protocol compare:@"sip"] != NSOrderedSame) {
        [self release];
        return nil;
    }
    NSString *userAndHost = [components objectAtIndex:1];
    components = [userAndHost componentsSeparatedByString:@"@"];
    if (components.count != 2) {
        [self release];
        return nil;
    }
    NSString *remoteUser = [components objectAtIndex:0];
    NSString *host = [components objectAtIndex:1];
    
    return [self initWithUserName:user password:password remoteUserName:remoteUser serverHostName:host serverPort:serverPort clientPort:clientPort];
}

- (id)initWithUserName:(NSString *)user password:(NSString *)password remoteUserName:(NSString *)remoteUser serverHostName:(NSString *)hostName serverPort:(NSUInteger)serverPort clientPort:(NSUInteger)clientPort {
    if (!user || !password || !remoteUser || !hostName) {
        [self release];
        return nil;
    }
    
    self = [super init];
    if (self) {
        fullAddress = [[NSString stringWithFormat:@"sip:%@@%@", remoteUser, hostName] retain];
        SIPUserName = [user retain];
        SIPPassword = [password retain];
        SIPRemoteUserName = [remoteUser retain];
        SIPServerHostName = [hostName retain];
        SIPServerPort = serverPort;
        // TODO: May want to figure out something better to do for ports. I.E. if two different devices
        // on the same network decide to use 5060, SIP packets will be directed to only one of
        // them from FreeSwitch
        if (SIPServerPort < 1025 || SIPServerPort > 65355) {
            SIPServerPort = 5060;
        }
        SIPClientPort = clientPort;
        if (SIPClientPort < 1025 || SIPClientPort > 65355) {
            SIPClientPort = 5060;
        }
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"VideoStreamerContext dealloc");
    
    [fullAddress release];
    [SIPUserName release];
    [SIPPassword release];
    [SIPRemoteUserName release];
    [SIPServerHostName release];
    
    [super dealloc];
}

@end






@implementation VideoStreamerContext

+ (id)alloc {
    if ([self isEqual:[VideoStreamerContext class]]) {
        NSZone *temp = [self zone];
        /** TODO: find out if release is necessary here via memory leaks in instruments
         or release should be done in a placeholder class init method **/
        
        //fprintf(stderr, "retain count 1: %d\n", [self retainCount]);
        [self release];
        //fprintf(stderr, "retain count 2: %d\n", [self retainCount]);
        return [_VideoStreamerContext allocWithZone:temp];
    } else {
        return [super alloc];
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    if ([self isEqual:[VideoStreamerContext class]]) {
        //fprintf(stderr, "retain count 1: %d\n", [self retainCount]);
        [self release];
        //fprintf(stderr, "retain count 2: %d\n", [self retainCount]);
        return [_VideoStreamerContext allocWithZone:zone];
    } else {
        return [super allocWithZone:zone];
    }
}

- (id)initWithUserName:(NSString *)user password:(NSString *)password remoteUserName:(NSString *)remoteUser serverHostName:(NSString *)hostName serverPort:(NSUInteger)serverPort clientPort:(NSUInteger)clientPort {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (id)initWithUserName:(NSString *)user password:(NSString *)password remoteAddress:(NSString *)address serverPort:(NSUInteger)serverPort clientPort:(NSUInteger)clientPort {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *)fullAddress {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException 
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *)SIPUserName {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *)SIPPassword {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *)SIPRemoteUserName {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *)SIPServerHostName {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (UInt16)SIPServerPort {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (UInt16)SIPClientPort {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (id)initWithUserName:(NSString *)user password:(NSString *)password remoteUserName:(NSString *)remoteUser {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end




#pragma mark -
#pragma mark VideoStreamer
#pragma mark -




@interface _VideoStreamer : VideoStreamer <AVCaptureVideoDataOutputSampleBufferDelegate, NetworkManagerDelegate> {
    
    NetworkManager *networkMan;
    
    AVCaptureSession *captureSession;
    CALayer *customLayer;
    
    CVPixelBufferRef pxbuffer;
    
    VideoStreamerContext *streamerContext;
    
    enum CONNECTION_STATUS status;
    
    NSString *terminationInfo;
    enum NETWORK_TERMINATION_CODE terminationCode;
            
    id <VideoStreamerDelegate> delegate;
}

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) CALayer *customLayer;

// AVCaptureSessions cleanup asynchronously after a call to stopRunning.
// This callback is thus called after the AVCaptureSession cleans up
// its internal stuff.
void capture_cleanup(void *context);

- (void)initCapture;
- (void)terminateCaptureWithInfo:(NSString *)info networkCode:(enum NETWORK_TERMINATION_CODE)code;

@end



@implementation _VideoStreamer

@synthesize captureSession;

void capture_cleanup(void *context) {
    _VideoStreamer *self = (_VideoStreamer *)context;
    if (self->networkMan) {
        [self->networkMan release];
        self->networkMan = nil;
    }
    
    self.customLayer = nil;
    
    self.captureSession = nil;
    
    if (self->pxbuffer) {
        CVPixelBufferUnlockBaseAddress(self->pxbuffer, 0);
    }
        
    [self.delegate videoStreamer:self chatEndedWithInfo:self->terminationInfo networkCode:self->terminationCode];
}

#pragma mark -
#pragma mark properties

- (CALayer *)customLayer {
    return customLayer;
}

- (void)setCustomLayer:(CALayer *)_customLayer {
    [_customLayer release];
    customLayer = [_customLayer retain];
}

- (VideoStreamerContext *)streamerContext {
    return streamerContext;
}

- (enum CONNECTION_STATUS)status {
    return status;
}

- (id <VideoStreamerDelegate>)delegate {
    return delegate;
}

- (void)setDelegate:(id <VideoStreamerDelegate>)_delegate {
    delegate = _delegate;
}

#pragma mark -
#pragma mark code descriptions

// TODO: Provide better descriptions of how or why the called did what it did
- (NSString *)networkTerminationDescription:(enum NETWORK_TERMINATION_CODE)code {
    switch (code) {
        case CALL_FAILED:
            return @"CALL_FAILED";
            
        case CALL_DROPPED:
            return @"CALL_DROPPED";
            
        case CALL_ENDED_BY_CALLEE:
            return @"CALL_ENDED_BY_CALLEE";
            
        case CALL_ENDED_BY_CALLER:
            return @"CALL_ENDED_BY_CALLER";
            
        default:
            return @"CALL_ENDED";
    }
}

// TODO: Provide better state descriptions
- (NSString *)connectionStatusDescription:(enum CONNECTION_STATUS)_status {
    switch (_status) {
        case CONNECTED:
            return @"CONNECTED";

        case INITIATING:
            return @"INITIATING";
            
        case DISCONNECTED:
            return @"DISCONNECTED";
            
        default:
            return @"DISCONNECTED";
    }
}

#pragma mark -
#pragma mark init functions

- (id)init {
    return [self initWithContext:nil delegate:nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithContext:nil delegate:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithContext:nil delegate:nil];
}

// Designated initializer
- (id)initWithContext:(VideoStreamerContext *)_streamerContext delegate:(id <VideoStreamerDelegate>)_delegate {
    // Make sure there is a context
    if (!_streamerContext) {
        [self release];
        // TODO: send an error message to caller
        return nil;
    }
    // Make sure a camera exists on the device
    if (![AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]) {
        [self release];
        // TODO: send an error message to caller
        return nil;
    }
    
    // No reason to load a nib! just init and view auto stretches to parent view.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self = [super initWithNibName:nil bundle:nil];
    } else {
        self = [super initWithNibName:nil bundle:nil];
    }
    
    if (self) {
        streamerContext = [_streamerContext retain];
        status = INITIATING;
        terminationCode = CALL_ENDED_BY_CALLEE;
        terminationInfo = nil;
        self.delegate = _delegate;
    }
    
    return self;
}

#pragma mark -
#pragma User Chat controls

- (void)startChat {
    [self initCapture];
    networkMan = [[NetworkManager alloc] initWithContext:streamerContext];
    if (networkMan) {
        networkMan.delegate = self;
        [delegate videoStreamerInitiatingChat:self];
    } else {
        status = DISCONNECTED;
        [delegate videoStreamer:self chatEndedWithInfo:@"Network Connection Failure" networkCode:CALL_FAILED];
    }
}

- (void)endChat {
    [networkMan endChat];
}

#pragma mark -
#pragma Video Capture

- (void)initCapture {
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil];
    
    AVCaptureVideoDataOutput *captureOutput = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    dispatch_queue_t video_capture_queue;
    video_capture_queue = dispatch_queue_create("video_capture_queue", NULL);
    dispatch_set_context(video_capture_queue, self);
    dispatch_set_finalizer_f(video_capture_queue, (dispatch_function_t)capture_cleanup);
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
    
    /*
     imageView = [[UIImageView alloc] init];
     imageView.frame = CGRectMake(0.0, 0.0, 150.0, 150.0);
     [self.view addSubview:imageView];
     */
    
    /*
     prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
     prevLayer.frame = CGRectMake(150.0, 0.0, 150.0, 150.0);
     prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
     [self.view.layer addSublayer:prevLayer];
     */
}

- (void)terminateCaptureWithInfo:(NSString *)info networkCode:(enum NETWORK_TERMINATION_CODE)code {
    status = DISCONNECTED;
    terminationInfo = [info retain];
    terminationCode = code;
    
    // By calling stopRunning the capture_cleanup
    // handler will be called when the iOS internal
    // video processing block cleans up.
    [captureSession stopRunning];
    self.captureSession = nil;
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
    //CFAbsoluteTime begin = CFAbsoluteTimeGetCurrent();
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
    
    //CFAbsoluteTime starttime = CFAbsoluteTimeGetCurrent();
    
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
    
    //CFAbsoluteTime endtime = CFAbsoluteTimeGetCurrent();
    
    //fprintf(stderr, "Total time = %lf\n", (endtime - starttime)*1000.0);
    
    [customLayer performSelectorOnMainThread:@selector(setContents:) withObject:(id)newImage waitUntilDone:NO];
    
    //UIImage *image = [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
    
    CGImageRelease(newImage);
    
    //[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    //CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    [networkMan packetize:sampleBuffer];
    //});
    
    [pool drain];
}

#pragma mark -
#pragma mark NetworkManager Protocol

- (void)networkManagerEncoderReady:(NetworkManager *)networkManager {
    if (networkManager == networkMan) {
        status = CONNECTED;
        [networkMan startEncoder];
        [captureSession startRunning];
    } else {
        [self terminateCaptureWithInfo:@"Network Connection Failure" networkCode:CALL_FAILED];
    }
}

- (void)networkManagerInvalid:(NetworkManager *)networkManager endedWithCode:(enum NETWORK_TERMINATION_CODE)code {
    [self terminateCaptureWithInfo:@"Chat Ended" networkCode:code];
}

#pragma mark - 
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // TODO: Add in a guarentee that this method for view did load has been called before
    // startChat, else, postpone startChat until this has been called or a timer runs out.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self terminateCaptureWithInfo:@"Chat Ended: VideoStreamer UIView Did Unload" networkCode:CALL_FAILED];
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
    NSLog(@"VideoStreamer dealloc");
    
    if (networkMan) {
        [networkMan release];
        networkMan = nil;
    }
    
    if (streamerContext) {
        [streamerContext release];
    }
    
    self.customLayer = nil;
    
    self.captureSession = nil;
    
    if (pxbuffer) {
        CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    }
    
    [terminationInfo release];
    
    self.delegate = nil;
    
    [super dealloc];
}

@end




#pragma mark -
#pragma mark -
#pragma mark -
#pragma mark -
#pragma mark -
#pragma mark -
#pragma mark -



@implementation VideoStreamer

+ (id)alloc {
    if ([self isEqual:[VideoStreamer class]]) {
        NSZone *temp = [self zone];
        [self release];
        return [_VideoStreamer allocWithZone:temp];
    } else {
        return [super alloc];
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    if ([self isEqual:[VideoStreamer class]]) {
        [self release];
        return [_VideoStreamer allocWithZone:zone];
    } else {
        return [super allocWithZone:zone];
    }
}

- (VideoStreamerContext *)streamerContext {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (enum CONNECTION_STATUS)status {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (CALayer *)customLayer {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setCustomLayer:(CALayer *)_customLayer {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (id <VideoStreamerDelegate>)delegate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)setDelegate:(id <VideoStreamerDelegate>)_delegate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

// Designated initializer
- (id)initWithContext:(VideoStreamerContext *)_streamerContext delegate:(id<VideoStreamerDelegate>)_delegate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *)networkTerminationDescription:(enum NETWORK_TERMINATION_CODE)code {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *)connectionStatusDescription:(enum CONNECTION_STATUS)_status {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark -
#pragma User Chat controls

- (void)startChat {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)endChat {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end




