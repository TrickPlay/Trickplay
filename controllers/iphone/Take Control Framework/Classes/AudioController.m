//
//  AudioController.m
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioController.h"
#import "SocketManager.h"
#import "Extensions.h"

@implementation AudioController

- (id)initWithResourceManager:(ResourceManager *)resman
                 tvConnection:(TVConnection *)_tvConnection {

    if ((self = [super init])) {
        resourceManager = [resman retain];
        tvConnection = [_tvConnection retain];
        soundLoopName = nil;
    }
    
    return self;
}

- (void)sendSoundStatusMessage:(NSString *)resource message:(NSString *)message {
	NSData *sentData = [[NSString stringWithFormat:@"SOUND\t%@\t%@\n", resource, message] dataUsingEncoding:NSUTF8StringEncoding];
    [[tvConnection socketManager] sendData:[sentData bytes] numberOfBytes:[sentData length]];
}

- (void)playSoundFile:(NSString *)resourcename filename:(NSString *)filename {
	if ([filename hasPrefix:@"http:"] || [filename hasPrefix:@"https:"])
	{
		//NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:filename ofType: @"mp3"];
		//NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
		//self.mAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        //**
		[self createAudioStreamer:filename];
        //*/
	}
	else
	{
        //**
		[self createAudioStreamer:[NSString stringWithFormat:@"http://%@:%d/%@", tvConnection.hostName, tvConnection.http_port, filename]];
        //*/
		//NSURL *fileURL = [NSURL URLWithString:];
		//self.mAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
		//NSLog([fileURL absoluteString]);
	}
	//self.mAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[itemAtIndex objectForKey:@"link"]] error:nil]; 
    
    if (soundLoopName) {
        [soundLoopName release];
    }
    soundLoopName = [resourcename retain];
}

- (void)playbackStateChanged:(NSNotification *)aNotification {
    //**
	if ([audioStreamer isWaiting]) // not sure why this is here
	{
		
	}
	else if ([audioStreamer isPlaying]) // ditto
	{
		
	}
	else if ([audioStreamer isIdle])
	{
        NSMutableDictionary *resourceInfo = [resourceManager getResourceInfo:soundLoopName];
        if (resourceInfo) {
            NSInteger loopValue = [[resourceInfo objectForKey:@"loop"] intValue];
            if (loopValue == 0) {
                [self playSoundFile:soundLoopName filename:[resourceInfo objectForKey:@"link"]];
            } else if (loopValue > 1) {
                [self sendSoundStatusMessage:soundLoopName
                                     message:[NSString stringWithFormat: @"LOOP_COMPLETE=%d", loopValue]];
                --loopValue;
				
				[self playSoundFile:soundLoopName filename:[resourceInfo objectForKey:@"link"]];
				//Finite # of loops, get the number of loops left and reset that number
                NSString *loopvalStr = [NSString stringWithFormat: @"%d", loopValue];
                [resourceInfo setObject:loopvalStr forKey:@"loop"];		
            } else {
                //Last loop, end the sound
				[self sendSoundStatusMessage:soundLoopName message:@"COMPLETE"];
				[self destroyAudioStreamer];
            }
        }
	}
     //*/
}

- (void)createAudioStreamer:(NSString *)audioURL
{
    //**
	if (audioStreamer)
	{
        [self destroyAudioStreamer];
	}
	
	NSURL *url = [NSURL URLWithString:audioURL];
	audioStreamer = [[AudioStreamer alloc] initWithURL:url];
	
	[[NSNotificationCenter defaultCenter] 
        addObserver:self
           selector:@selector(playbackStateChanged:)
               name:ASStatusChangedNotification
             object:audioStreamer];
	[audioStreamer start];
     //*/
}

- (void)destroyAudioStreamer
{
    //**
	if (audioStreamer) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:audioStreamer];
		
		[audioStreamer stop];
		[audioStreamer release];
		audioStreamer = nil;
	}
    //*/
}

- (void)dealloc {
    NSLog(@"AudioController dealloc");
    [self destroyAudioStreamer];
    if (resourceManager) {
        [resourceManager release];
    }
    if (tvConnection) {
        [tvConnection release];
        tvConnection = nil;
    }
    if (soundLoopName) {
        [soundLoopName release];
    }
    [super dealloc];
}

@end
