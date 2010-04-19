//
//  OfflineAudioQueueWrapper.m
//  AudioFileParser
//
//  Created by steve hooley on 16/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "OfflineAudioQueueWrapper.h"

#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/ExtendedAudioFile.h>

#import <SHShared/SHShared.h>
#import "HooleyStuff.h"
#import "OffLineAudioQueueCallbackProtocol.h"

#if COREAUDIOTYPES_VERSION < 1050
	typedef Float32 AudioSampleType;
	enum { kAudioFormatFlagsCanonical = kAudioFormatFlagIsFloat | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked };
#endif
#if COREAUDIOTYPES_VERSION < 1051
	typedef Float32 AudioUnitSampleType;
#endif


// the application specific info we keep track of
struct AQTestInfo
{
	AudioFileID						mAudioFile;
	AudioStreamBasicDescription		mDataFormat;
	AudioQueueRef					mQueue;
	AudioQueueBufferRef				mBuffer;
	SInt64							mCurrentPacket;
	UInt32							mNumPacketsToRead;
	AudioStreamPacketDescription    *mPacketDescs;
	bool							mFlushed;
	bool							mDone;
};

#pragma mark-
// ***********************
// AudioQueueOutputCallback function used to push data into the audio queue

static void AQTestBufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inCompleteAQBuffer) 
{
	struct AQTestInfo * myInfo = ( struct AQTestInfo *)inUserData;
	if (myInfo->mDone) return;
	
	UInt32 numBytes;
	UInt32 nPackets = myInfo->mNumPacketsToRead;
	OSStatus result = AudioFileReadPackets(myInfo->mAudioFile,      // The audio file from which packets of audio data are to be read.
                                           false,                   // Set to true to cache the data. Otherwise, set to false.
                                           &numBytes,               // On output, a pointer to the number of bytes actually returned.
                                           myInfo->mPacketDescs,    // A pointer to an array of packet descriptions that have been allocated.
                                           myInfo->mCurrentPacket,  // The packet index of the first packet you want to be returned.
                                           &nPackets,               // On input, a pointer to the number of packets to read. On output, the number of packets actually read.
                                           inCompleteAQBuffer->mAudioData); // A pointer to user-allocated memory.
	if (result) {
		[NSException raise:@"Error reading from file" format:@"%d", (int)result];
		exit(1);
	}
    
    // we have some data
	if (nPackets > 0) {
		inCompleteAQBuffer->mAudioDataByteSize = numBytes;
        
		result = AudioQueueEnqueueBuffer(inAQ,                                  // The audio queue that owns the audio queue buffer.
                                         inCompleteAQBuffer,                    // The audio queue buffer to add to the buffer queue.
                                         (myInfo->mPacketDescs ? nPackets : 0), // The number of packets of audio data in the inBuffer parameter. See Docs.
                                         myInfo->mPacketDescs);                 // An array of packet descriptions. Or NULL. See Docs.
		if (result) {
			[NSException raise:@"Error enqueuing buffer" format:@"%d", (int)result];
			exit(1);
		}
        
		myInfo->mCurrentPacket += nPackets;
        
	} else {
        // **** This ensures that we flush the queue when done -- ensures you get all the data out ****
		
        if (!myInfo->mFlushed) {
			result = AudioQueueFlush(myInfo->mQueue);
			
            if (result) {
				[NSException raise:@"AudioQueueFlush failed" format:@"%d", (int)result];
				exit(1);
			}
            
			myInfo->mFlushed = true;
		}
		
		result = AudioQueueStop(myInfo->mQueue, false);
		if (result) {
			[NSException raise:@"AudioQueueStop(false) failed" format:@"%d", (int)result];
			exit(1);
		}
        
		// reading nPackets == 0 is our EOF condition
		myInfo->mDone = true;
	}
}

#pragma mark-

void SetAUCanonical( AudioStreamBasicDescription *captureFormat, UInt32 nChannels, bool interleaved )
{
	captureFormat->mFormatID = kAudioFormatLinearPCM;
#if CA_PREFER_FIXED_POINT
	mFormatFlags = kAudioFormatFlagsCanonical | (kAudioUnitSampleFractionBits << kLinearPCMFormatFlagsSampleFractionShift);
#else
	captureFormat->mFormatFlags = kAudioFormatFlagsCanonical;
#endif
	captureFormat->mChannelsPerFrame = nChannels;
	captureFormat->mFramesPerPacket = 1;
	captureFormat->mBitsPerChannel = 8 * sizeof(AudioUnitSampleType);
	if (interleaved)
		captureFormat->mBytesPerPacket = captureFormat->mBytesPerFrame = nChannels * sizeof(AudioUnitSampleType);
	else {
		captureFormat->mBytesPerPacket = captureFormat->mBytesPerFrame = sizeof(AudioUnitSampleType);
		captureFormat->mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
	}
}

// ***********************
// CalculateBytesForTime Utility Function

// we only use time here as a guideline
// we are really trying to get somewhere between 16K and 64K buffers, but not allocate too much if we don't need it
void CalculateBytesForTime( AudioStreamBasicDescription *inDesc, UInt32 inMaxPacketSize, Float64 inSeconds, UInt32 *outBufferSize, UInt32 *outNumPackets)
{
	static const UInt32 maxBufferSize = 0x10000;   // limit size to 64K
	static const UInt32 minBufferSize = 0x4000;    // limit size to 16K
	
	if(inDesc->mFramesPerPacket) {
		Float64 numPacketsForTime = inDesc->mSampleRate / inDesc->mFramesPerPacket * inSeconds;
		*outBufferSize = (UInt32)(numPacketsForTime * inMaxPacketSize);
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


#pragma mark -
@implementation OfflineAudioQueueWrapper

- (id)initWithAudioFilePath:(NSString *)pathArg dataConsumer:(NSObject <OffLineAudioQueueCallbackProtocol>*)callbackArg {

	self = [super init];
	if(self){
		_callbackDelegate = callbackArg;
		_in_AudioFilePath = [pathArg retain];
	}
	return self;
}

- (void)dealloc {

	_callbackDelegate = nil;
	[_in_AudioFilePath release];

	// -- if we have processed
	if(_inputChannelLayout){
		free(_inputChannelLayout);
		free(_captureFormat);
	}
	
	[super dealloc];
}

- (void)beginProcessing {

	const char *inputPath = [_in_AudioFilePath cStringUsingEncoding:NSUnicodeStringEncoding]; 
	// main audio queue code
	@try {
		struct AQTestInfo myInfo;
		myInfo.mDone = false;
		myInfo.mFlushed = false;
		myInfo.mCurrentPacket = 0;
	
		// get the source file
		CFURLRef srcFile = CFURLCreateFromFileSystemRepresentation (NULL, (const UInt8 *)inputPath, strlen(inputPath), false);
		if(!srcFile) 
			[NSException raise:@"can't parse file path" format:@""];
		
		OSStatus result = AudioFileOpenURL( srcFile, 0x01, kAudioFileWAVEType/*inFileTypeHint*/, &myInfo.mAudioFile );
		CFRelease(srcFile);
		if(result!=noErr)
			[NSException raise:@"AudioFileOpen failed" format:@""];
		
		UInt32 size = sizeof(myInfo.mDataFormat);
		result = AudioFileGetProperty(myInfo.mAudioFile, kAudioFilePropertyDataFormat, &size, &myInfo.mDataFormat);
		if(result!=noErr)
			[NSException raise:@"couldn't get file's data format" format:@""];
		
		NSAssert( G3DCompareFloat( (CGFloat)myInfo.mDataFormat.mSampleRate, 44100.0f, 0.1f )==0, @"Error samplerate");
		NSAssert( myInfo.mDataFormat.mChannelsPerFrame==((UInt32)1), @"Error channels");
		
		//	myInfo.mDataFormat.Print();
		
		// create a new audio queue output
		result = AudioQueueNewOutput( &myInfo.mDataFormat,      // The data format of the audio to play. For linear PCM, only interleaved formats are supported.
									 AQTestBufferCallback,     // A callback function to use with the playback audio queue.
									 &myInfo,                  // A custom data structure for use with the callback function.
									 CFRunLoopGetCurrent(),    // The event loop on which the callback function pointed to by the inCallbackProc parameter is to be called.
									 // If you specify NULL, the callback is invoked on one of the audio queue’s internal threads.
									 kCFRunLoopCommonModes,    // The run loop mode in which to invoke the callback function specified in the inCallbackProc parameter. 
									 0,                        // Reserved for future use. Must be 0.
									 &myInfo.mQueue);
		
		if(result!=noErr)
			[NSException raise:@"cAudioQueueNew failed" format:@""];

		UInt32 bufferByteSize;
		
		// we need to calculate how many packets we read at a time and how big a buffer we need
		// we base this on the size of the packets in the file and an approximate duration for each buffer
		{
			bool isFormatVBR = (myInfo.mDataFormat.mBytesPerPacket == 0 || myInfo.mDataFormat.mFramesPerPacket == 0);
			
			// first check to see what the max size of a packet is - if it is bigger
			// than our allocation default size, that needs to become larger
			UInt32 maxPacketSize;
			size = sizeof(maxPacketSize);
			result = AudioFileGetProperty( myInfo.mAudioFile, kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize );
			if(result!=noErr)
				[NSException raise:@"couldn't get file's max packet size" format:@""];
			
			// adjust buffer size to represent about a second of audio based on this format
			CalculateBytesForTime( &(myInfo.mDataFormat), maxPacketSize, 1.0/*seconds*/, &bufferByteSize, &myInfo.mNumPacketsToRead );
			
			if (isFormatVBR) {
				myInfo.mPacketDescs = (AudioStreamPacketDescription *)malloc( sizeof(struct AudioStreamPacketDescription) * myInfo.mNumPacketsToRead);
			} else {
				myInfo.mPacketDescs = NULL; // we don't provide packet descriptions for constant bit rate formats (like linear PCM)
			}
			
			printf ("Buffer Byte Size: %d, Num Packets to Read: %d\n", (int)bufferByteSize, (int)myInfo.mNumPacketsToRead);
		}
		
		// if the file has a magic cookie, we should get it and set it on the AQ
		size = sizeof(UInt32);
		result = AudioFileGetPropertyInfo( myInfo.mAudioFile, kAudioFilePropertyMagicCookieData, &size, NULL );
		
		if (!result && size) {
			
			char* cookie = (char *)malloc(sizeof(char)*size);
			result = AudioFileGetProperty (myInfo.mAudioFile, kAudioFilePropertyMagicCookieData, &size, cookie);
			if(result!=noErr)
				[NSException raise:@"get cookie from file" format:@""];
			
			result = AudioQueueSetProperty(myInfo.mQueue, kAudioQueueProperty_MagicCookie, cookie, size);
			if(result!=noErr)
				[NSException raise:@"set cookie on queue" format:@""];
			
			free(cookie);
		}
		
		// channel layout?
		OSStatus err = AudioFileGetPropertyInfo(myInfo.mAudioFile, kAudioFilePropertyChannelLayout, &size, NULL);
		if (err == noErr && size > 0) {
			_inputChannelLayout = (AudioChannelLayout *)malloc(size);
			result = AudioFileGetProperty(myInfo.mAudioFile, kAudioFilePropertyChannelLayout, &size, _inputChannelLayout);
			if(result!=noErr)
				[NSException raise:@"get audio file's channel layout" format:@""];
			
			result = AudioQueueSetProperty(myInfo.mQueue, kAudioQueueProperty_ChannelLayout, _inputChannelLayout, size);
			if(result!=noErr)
				[NSException raise:@"set channel layout on queue" format:@""];
		}
		
		//allocate the input read buffer
		result = AudioQueueAllocateBuffer( myInfo.mQueue, bufferByteSize, &myInfo.mBuffer );
		if(result!=noErr)
			[NSException raise:@"AudioQueueAllocateBuffer" format:@""];
		
		
		// prepare a canonical interleaved capture format
		_captureFormat = calloc(1,sizeof(AudioStreamBasicDescription));
		_captureFormat->mSampleRate = myInfo.mDataFormat.mSampleRate;
		SetAUCanonical( _captureFormat, myInfo.mDataFormat.mChannelsPerFrame, true ); // interleaved
		
		result = AudioQueueSetOfflineRenderFormat( myInfo.mQueue, _captureFormat, _inputChannelLayout );
		if(result!=noErr)
			[NSException raise:@"set offline render format" format:@""];

		
		// allocate the capture buffer, just keep it at half the size of the enqueue buffer
		// we don't ever want to pull any faster than we can push data in for render
		// this 2:1 ratio keeps the AQ Offline Render happy
		const UInt32 captureBufferByteSize = bufferByteSize / 2;
		
		AudioQueueBufferRef captureBuffer;
		AudioBufferList captureABL;
		
		result = AudioQueueAllocateBuffer( myInfo.mQueue, captureBufferByteSize, &captureBuffer );
		if(result!=noErr)
			[NSException raise:@"AudioQueueAllocateBuffer" format:@""];
		
		captureABL.mNumberBuffers = 1;
		captureABL.mBuffers[0].mData = captureBuffer->mAudioData;
		captureABL.mBuffers[0].mNumberChannels = _captureFormat->mChannelsPerFrame;
		
		// lets start playing now - stop is called in the AQTestBufferCallback when there's
		// no more to read from the file
		result = AudioQueueStart(myInfo.mQueue, NULL);
		if(result!=noErr)
			[NSException raise:@"AudioQueueStart failed" format:@""];
		
		AudioTimeStamp ts;
		ts.mFlags = kAudioTimeStampSampleTimeValid;
		ts.mSampleTime = 0;		

		// we need to call this once asking for 0 frames
		result = AudioQueueOfflineRender( myInfo.mQueue, &ts, captureBuffer, 0 );
		if(result!=noErr)
			[NSException raise:@"AudioQueueOfflineRender" format:@""];
		
		// we need to enqueue a buffer after the queue has started
		AQTestBufferCallback(&myInfo, myInfo.mQueue, myInfo.mBuffer);
		static NSInteger totalFramesProcesses1 = 0;
		static NSInteger totalFramesProcesses2 = 0;
		
		while (true) 
		{
			UInt32 reqFrames = captureBufferByteSize / _captureFormat->mBytesPerFrame;
			
			// sooo, we supply a buffer for the output
			result = AudioQueueOfflineRender( myInfo.mQueue, &ts, captureBuffer, reqFrames );
			if(result!=noErr)
				[NSException raise:@"AudioQueueOfflineRender" format:@""];
			
			// mono wav
			//			bytesperpacket = 4
			//			framesperpacket = 1
			//			bytesperframe = 4
			//			channelsperframe = 1
			//			bitsperchannel = 32
			
			captureABL.mBuffers[0].mData = captureBuffer->mAudioData;
			captureABL.mBuffers[0].mDataByteSize = captureBuffer->mAudioDataByteSize;
			UInt32 bytesPerFrame = _captureFormat->mBytesPerFrame;
			
			// loopMax is half writeFrames
			NSInteger writeFrames = captureABL.mBuffers[0].mDataByteSize / bytesPerFrame; // 1024
	//		UInt32 loopMax = captureBuffer->mAudioDataByteSize/2; //2048		
		
			
			//tsk!			totalFramesProcesses1 = totalFramesProcesses1+writeFrames; // 49152
			//tsk!			totalFramesProcesses2 = totalFramesProcesses2+loopMax;	// 98304
			
			//			NSLog(@"%i", captureABL.bytesPerFrame);
			//			NSLog(@"%i", mChannelsPerFrame);
			//			NSLog(@"%i", mBitsPerChannel);
			//			UInt32 fixedeSize = sizeof(Fixed); //-- 4
			
			
			//			for(UInt32 i=0; i<writeFrames; i+=2) {
			//				Float32 a = *(((Float32*)(captureBuffer->mAudioData)) + i);
			//	Float32 b = *(((Float32*)(captureBuffer->mAudioData)) + i + 1);
			//				NSLog(@"what the %f", (Float32)a);
			//			}
			//			http://developer.apple.com/mac/library/technotes/tn2007/tn2200.html#GENID8
			//			Fixed *dataPtr = (Fixed *)captureABL.mBuffers[0].mData;
			
			//-- some sort of ring buffer to do 1024 at a time
			AudioBuffer outAudioBuffer = captureABL.mBuffers[0];
			
			struct HooAudioBuffer *tempHooBuffer = newHooAudioBuffer_weak( &outAudioBuffer, writeFrames, 0 );
			
			// copy all frames to 1024 size blocks
			[_callbackDelegate _callback_withData:tempHooBuffer];
			
			freeHooAudioBuffer(tempHooBuffer);
			
			//-- end sort of ringbuffer to do 1024 at a time
			
			//	for(NSUInteger i=0; i<writeFrames; i++){
			
			//		Fixed thisFrame = dataPtr[i];
			//		NSInteger hmm = FixedToInt(thisFrame);
			//		if(hmm>0)
			//			NSLog(@"break here maybe?");
			//	outA[i] = FloatToFixed((float)(wave*127.0f));
			
			//	UInt32 aByte = dataPtr[i];
			//		NSLog(@"%i", hmm); NSNotFound
			//	}
			
			//			printf("t = %.f: AudioQueueOfflineRender:  req %d fr/%d bytes, got %i fr/%i bytes\n", ts.mSampleTime, (int)reqFrames, (int)captureBufferByteSize, writeFrames, (int)captureABL.mBuffers[0].mDataByteSize);
			
			if (myInfo.mFlushed)
				break;
			
			ts.mSampleTime += writeFrames;
		}
		
		
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, false);
		
		result = AudioQueueDispose(myInfo.mQueue, true);
		if(result!=noErr)
			[NSException raise:@"AudioQueueDispose(true) failed" format:@""];
		
		result = AudioFileClose(myInfo.mAudioFile);
		if(result!=noErr)
			[NSException raise:@"AudioQueueDispose(false) failed" format:@""];
		
		free(myInfo.mPacketDescs);
	}
	@catch (NSException *exception) {
		NSLog(@"Caught %@: %@", [exception name], [exception reason]);
	}	
}

@end
