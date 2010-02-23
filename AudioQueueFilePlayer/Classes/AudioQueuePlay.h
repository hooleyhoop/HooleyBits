//
//  AudioQueuePlay.h
//  AudioQueueFilePlayer
//
//  Created by steve hooley on 04/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/AudioQueue.h>
#import "SHooleyObject.h"

# define kNumberBuffers 3

struct AQTestInfo {

	AudioFileID						inAFID;
	AudioStreamBasicDescription		in_file_desc;
	AudioQueueRef					mQueue;
	AudioQueueBufferRef				mBuffers[kNumberBuffers];
	SInt64							mCurrentPacket;
	UInt32							mNumPacketsToRead;
	AudioStreamPacketDescription *	mPacketDescs;
	bool							mDone;
};

@interface AudioQueuePlay : SHooleyObject {

}

- (void)playFile:(NSString *)filePath;
- (void)getAudioLevels:(Float32 *)levels peakLevels:(Float32 *)peakLevels;

@end
