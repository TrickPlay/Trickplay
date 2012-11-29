//
//  AVCEncoder.h
//  AVCEncoder
//
//  Created by Steve McFarlin on 5/5/11.
//  Copyright 2011 Steve McFarlin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "AVCParameters.h"

#pragma mark -
#pragma Block types
#pragma mark -

@class AVCEncoder;

/*!
 @discussion
 
 This block will be called for each AVC frame in the video. This block will be running on a queue
 created by the AVCEncoder. You should copy the data immediatly and return. If you are streaming
 over a UDP based protocol you may be able to get away with writing the packet before returning.
 
 
 @param frame An Annex B encoded NAL unit.
 @param size The size of the NAL unit in bytes.
 @param pts The time stamp of the captured image.
 */
typedef void (^AVCEncoderCallback)(const void* frame, uint32_t length, CMTime pts) ;

/*! NOT IMPLEMENTED
 @discussion
 
 This block takes a different approach. The encoder will submit this to a serial queue for 
 processing. You are resposible for releasing the data. Using this method the NAL units
 will be queued on a GCD queue. It is safe to do any processing in this callback. The 
 primary purpose for this callback is so you do not have to manage a separate queue.
 However, you now have the overhead of GCD. 
 
 @param data The NAL unit (NOTE: you take ownership of this data).
 @param The time stamp of the captured image.
 
 */
typedef void (^AVCEncoderSerialQueueCallback)(NSData* data, CMTime time_stamp) ;


#pragma mark -
#pragma AVCEncoder
#pragma mark -

/*!
 @abstract The AVCEncoder
 @discussion
 
 This class will take a series of images and convert this into a AVC Annex B byte stream. 
 When the start message is sent the callback will immediatly be sent two NALUs. It will
 send the SPS and then the PPS in Annex B format.
 
 Usage -
 
 Set the AVCParameters. 
 Call the prepareEncoder function. (At this point the spspps NAL units are ready.)
 Start feeding the encode function with CMSampleBufferRefs.
 
 
 */
@interface AVCEncoder : NSObject {
    AVCParameters *parameters;
@private
    BOOL isEncoding;
	long maxBitrate;
    AVCEncoderCallback callback;
    AVCEncoderSerialQueueCallback callbackOnSerialQueue; //Not used.
    dispatch_queue_t caller_queue; //not used.
    NSError* error;
    
}
//Parameters should be set before a call to prepareEncoder.
@property (nonatomic, retain) AVCParameters *parameters;
@property (nonatomic, retain) AVCEncoderCallback callback; //The block needs to be heap allocated.
@property (nonatomic, retain) AVCEncoderSerialQueueCallback callbackOnSerialQueue; //Not implemented
@property (nonatomic, retain, readonly) NSData *spspps; //only valid after encoder is prepared. In Annex B format
@property (nonatomic, retain, readonly) NSData *sps, *pps;
@property (nonatomic, readonly) BOOL isEncoding;
@property (nonatomic, readonly, retain) NSError *error;
@property (nonatomic, assign) long maxBitrate; //Set to 0 to turn off (default)

/*!
 @discussion
 
 This will change the bitrate of the stream. This method should not be called continiously. Given the hostile 
 networking enviornment a cell phone usually sees it is wise to create a statistical network average over a period
 of time before making a decision on how to set the encoding bitrate. I do not recomend setting this at a 
 frequency below 3Hz.
 
 This method blocks the caller until the change has occured.
 */

@property (nonatomic, assign) unsigned averagebps;



/*!
 @discussion 
 
 This sets up the encoder with the currently assigned parameters. If the current parameters are nil, then defaults are used. 
 After this call the sps and pps properties will be valid.
 
 */
- (BOOL) prepareEncoder;
- (BOOL) start;
- (void) startWithCallbackQueue:(dispatch_queue_t) queue; //Not implemented
- (void) stop;
- (void) encode:(CMSampleBufferRef) sample;
- (void) encode:(CVPixelBufferRef) buffer withPresentationTime:(CMTime) pts; //Not implemented


@end
