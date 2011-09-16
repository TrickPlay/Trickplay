//
//  AudioController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioStreamer.h"
#import "SocketManager.h"
#import "ResourceManager.h"


@interface AudioController : NSObject {
    ResourceManager *resourceManager;
    SocketManager *socketManager;
    
    AudioStreamer *audioStreamer;
    NSString *soundLoopName;
}

- (id)initWithResourceManager:(ResourceManager *)resman
               socketManager:(SocketManager *)sockman;

- (void)sendSoundStatusMessage:(NSString *)resource message:(NSString *)message;
- (void)playSoundFile:(NSString *)resourcename filename:(NSString *)filename;
- (void)playbackStateChanged:(NSNotification *)aNotification;
- (void)createAudioStreamer:(NSString *)audioURL;
- (void)destroyAudioStreamer;

@end
