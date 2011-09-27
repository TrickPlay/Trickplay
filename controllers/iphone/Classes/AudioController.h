//
//  AudioController.h
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioStreamer.h"
#import "ResourceManager.h"


@interface AudioController : NSObject {
    ResourceManager *resourceManager;
    TVConnection *tvConnection;
    
    AudioStreamer *audioStreamer;
    NSString *soundLoopName;
}

- (id)initWithResourceManager:(ResourceManager *)resman
                 tvConnection:(TVConnection *)tvConnection;
    
- (void)sendSoundStatusMessage:(NSString *)resource message:(NSString *)message;
- (void)playSoundFile:(NSString *)resourcename filename:(NSString *)filename;
- (void)playbackStateChanged:(NSNotification *)aNotification;
- (void)createAudioStreamer:(NSString *)audioURL;
- (void)destroyAudioStreamer;

@end
