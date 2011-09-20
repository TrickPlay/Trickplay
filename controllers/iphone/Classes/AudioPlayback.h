//
//  AudioPlayback.h
//  TrickplayController
//
//  Created by Rex Fenley on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>

#define NUMBER_OF_BUFFERS 16

struct AQPlayerState {
    // Audio data format
    AudioStreamBasicDescription mDataFormat;
    // The playback audio queue created by your app
    AudioQueueRef mQueue;
    // Array holding pointers to audio que buffers
    AudioQueueBufferRef mBuffers[NUMBER_OF_BUFFERS];
    // Object corresponding to audio file being played
    AudioFileID mAudioFile;
    // Size in bytes of each Audio Queue buffer
    UInt32 bufferByteSize;
    // Packet index for next packet to play
    SInt64 mCurrentPacket;
    // Number of packets to read on each invocation of audioqueue's playback
    UInt32 mNumPacketsToRead;
    // Array of packet descriptions for VBR data
    AudioStreamPacketDescription *mPacketDescs;
    // Indicator of audio queue runnning
    bool mIsRunning;
};

// The playback Audio Queue Callback Declaration
static void handleOutputBuffer(void *AQData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer);

@interface AudioPlayback : NSObject {
    
}

@end
