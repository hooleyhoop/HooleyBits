//
//  AudioQueuePlay.m
//  AudioQueueFilePlayer
//
//  Created by steve hooley on 04/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "AudioQueuePlay.h"

#define RequireNoErr(error)	do { if( (error) != noErr ) [NSException raise:@"CoreAudio ERROR" format:@"%i", error]; } while (false)

static UInt32 gIsRunning = 0;
static struct AQTestInfo myInfo;

@implementation AudioQueuePlay

static void AQPlayCallback( void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inCompleteAQBuffer ) 
{
	struct AQTestInfo *myInfo = (struct AQTestInfo *)inUserData;
	//	if (myInfo->mDone) 
	//		return;
	
	UInt32 numBytes;
	UInt32 nPackets = myInfo->mNumPacketsToRead;
	
	RequireNoErr( AudioFileReadPackets(myInfo->inAFID, false, &numBytes, myInfo->mPacketDescs, myInfo->mCurrentPacket, &nPackets, inCompleteAQBuffer->mAudioData));
	
	if (nPackets > 0) {
		inCompleteAQBuffer->mAudioDataByteSize = numBytes;		
		
		// NSLog(@"Filling buffer...");
		AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, (myInfo->mPacketDescs ? nPackets : 0), myInfo->mPacketDescs);
		
		myInfo->mCurrentPacket += nPackets;
	} else {
		// RequireNoErr( AudioQueueStop(myInfo->mQueue, false));
		// reading nPackets == 0 is our EOF condition
		//myInfo->mDone = true;
		
		/* LOOP-DE-LOOP */
		// NSLog(@"Loop");
		myInfo->mCurrentPacket = 0;
		AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, 0, myInfo->mPacketDescs);
	}
}

void MyAudioQueuePropertyListenerProc( void * inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID)
{
	UInt32 size = sizeof(gIsRunning);
	RequireNoErr( AudioQueueGetProperty( inAQ, kAudioQueueProperty_IsRunning, &gIsRunning, &size));
}

// we only use time here as a guideline
// we're really trying to get somewhere between 16K and 64K buffers, but not allocate too much if we don't need it
void CalculateBytesForTime( AudioStreamBasicDescription *inDesc, UInt32 inMaxPacketSize, Float64 inSeconds, UInt32 *outBufferSize, UInt32 *outNumPackets)
{
	static const int maxBufferSize = 0x10000; // limit size to 64K
	static const int minBufferSize = 0x4000; // limit size to 16K
	
	if (inDesc->mFramesPerPacket) {
		Float64 numPacketsForTime = inDesc->mSampleRate / inDesc->mFramesPerPacket * inSeconds;
		*outBufferSize = numPacketsForTime * inMaxPacketSize;
	} else {
		// if frames per packet is zero, then the codec has no predictable packet == time
		// so we can't tailor this (we don't know how many Packets represent a time period
		// we'll just return a default buffer size
		*outBufferSize = maxBufferSize > inMaxPacketSize ? maxBufferSize : inMaxPacketSize;
	}
	
	// we're going to limit our size to our default
	if (*outBufferSize > maxBufferSize && *outBufferSize > inMaxPacketSize)
		*outBufferSize = maxBufferSize;
	else {
		// also make sure we're not too small - we don't want to go the disk for too small chunks
		if (*outBufferSize < minBufferSize)
			*outBufferSize = minBufferSize;
	}
	*outNumPackets = *outBufferSize / inMaxPacketSize;
}

- (void)playFile:(NSString *)filePath {
	
	/* Swizzle the path to an URL and open the file */
	NSAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath], @"Not a valid file");
	NSURL *fileURL = [NSURL fileURLWithPath:filePath];
	NSAssert(fileURL, @"cannot get file url");
	NSAssert([fileURL isFileURL], @"gone wrong");
	
	RequireNoErr( AudioFileOpenURL( (CFURLRef)fileURL, kAudioFileReadPermission, kAudioFileAIFFType, &myInfo.inAFID ));
	
	/* Get some info about the file */
	UInt32 in_file_desc_size = sizeof(myInfo.in_file_desc);
	RequireNoErr( AudioFileGetProperty( myInfo.inAFID, kAudioFilePropertyDataFormat, &in_file_desc_size, &myInfo.in_file_desc ));
	
	RequireNoErr( AudioQueueNewOutput( &myInfo.in_file_desc, AQPlayCallback, &myInfo, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &myInfo.mQueue ));
	
	/* Enable Metering */
	UInt32 trueValue = true;
	RequireNoErr( AudioQueueSetProperty( myInfo.mQueue, kAudioQueueProperty_EnableLevelMetering,  &trueValue, sizeof (UInt32) ));
	
	BOOL isFormatVBR = (myInfo.in_file_desc.mBytesPerPacket==0 || myInfo.in_file_desc.mFramesPerPacket==0);
	// first check to see what the max size of a packet is - if it is bigger
	// than our allocation default size, that needs to become larger
	UInt32 maxPacketSize;
	UInt32 maxPacketSize_size = sizeof(maxPacketSize);
	RequireNoErr( AudioFileGetProperty( myInfo.inAFID, kAudioFilePropertyPacketSizeUpperBound, &maxPacketSize_size, &maxPacketSize ));	
	
	// adjust buffer size to represent about a half second of audio based on this format
	UInt32 bufferByteSize;
	CalculateBytesForTime( &myInfo.in_file_desc, maxPacketSize, 0.5/*seconds*/, &bufferByteSize, &myInfo.mNumPacketsToRead );
	
	if (isFormatVBR){
		// AudioStreamPacketDescription *mPacketDescs = new AudioStreamPacketDescription [myInfo.mNumPacketsToRead];
		[NSException raise:@"Not suported" format:@""];
	} else {
		myInfo.mPacketDescs = NULL;	
	}
	
	NSLog( @"Buffer Byte Size: %d, Num Packets to Read: %d\n", (int)bufferByteSize, (int)myInfo.mNumPacketsToRead );
	
	// (2) If the file has a cookie, we should get it and set it on the AQ
	UInt32 cookieSize = sizeof(UInt32);
	OSStatus result = AudioFileGetPropertyInfo( myInfo.inAFID, kAudioFilePropertyMagicCookieData, &cookieSize, NULL);
	if (!result && cookieSize) {
		[NSException raise:@"Not suported" format:@""];
	}
	
	// channel layout?
	UInt32 channelLayoutSize = sizeof(UInt32);
	OSStatus err = AudioFileGetPropertyInfo( myInfo.inAFID, kAudioFilePropertyChannelLayout, &channelLayoutSize, NULL);
	if( err==noErr && channelLayoutSize>0) {
		AudioChannelLayout *acl = (AudioChannelLayout *)malloc(channelLayoutSize);
		RequireNoErr( AudioFileGetProperty( myInfo.inAFID, kAudioFilePropertyChannelLayout, &channelLayoutSize, acl));
		RequireNoErr( AudioQueueSetProperty( myInfo.mQueue, kAudioQueueProperty_ChannelLayout, acl, channelLayoutSize));
		free(acl);
	}
	
	myInfo.mDone = false;
	for (int i = 0; i < kNumberBuffers; ++i) {
		RequireNoErr( AudioQueueAllocateBuffer( myInfo.mQueue, bufferByteSize, &myInfo.mBuffers[i]));
		AQPlayCallback( &myInfo, myInfo.mQueue, myInfo.mBuffers[i] );
		if (myInfo.mDone)
			break;
	}
	
	// set the volume of the queue
	Float32 volume = 1;
	RequireNoErr( AudioQueueSetParameter( myInfo.mQueue, kAudioQueueParam_Volume, volume));
	
	RequireNoErr( AudioQueueAddPropertyListener( myInfo.mQueue, kAudioQueueProperty_IsRunning, MyAudioQueuePropertyListenerProc, NULL));
	
	// lets start playing now - stop is called in the AQTestBufferCallback when there's
	// no more to read from the file
	RequireNoErr( AudioQueueStart(myInfo.mQueue, NULL));
	
	
	//	Sod cleaning up
	//	RequireNoErr( AudioQueueDispose(myInfo.mQueue, true));
	//	RequireNoErr( AudioFileClose(myInfo.inAFID));
}


- (void)getAudioLevels:(Float32 *)levels peakLevels:(Float32 *)peakLevels {
	
	AudioQueueLevelMeterState audioLevels[myInfo.in_file_desc.mChannelsPerFrame];	// array of audio levels for each channel
	UInt32 propertySize = myInfo.in_file_desc.mChannelsPerFrame * sizeof (AudioQueueLevelMeterState);
	RequireNoErr( AudioQueueGetProperty( myInfo.mQueue, kAudioQueueProperty_CurrentLevelMeter, audioLevels, &propertySize ));
	levels[0] = audioLevels[0].mAveragePower;
	peakLevels[0] = audioLevels[0].mPeakPower;
}


@end
