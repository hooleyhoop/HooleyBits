//
//  HooAudioStreamer.m
//  ActorKitTest
//
//  Created by steve hooley on 18/06/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "HooAudioStreamer.h"
#import "MP3Downloader.h"

#define PRINTERROR(LABEL) printf("%s err %4.4s %d\n", LABEL, (char *)&err, (int)err)

@interface HooAudioStreamer (privateMethods)

void MyAudioQueueOutputCallback( void *inClientData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer );
void MyPropertyListenerProc( void *inClientData, AudioFileStreamID inAudioFileStream, AudioFileStreamPropertyID inPropertyID, UInt32 *ioFlags );
void MyPacketsProc( void *inClientData, UInt32 inNumberBytes, UInt32 inNumberPackets, const void *inInputData,  AudioStreamPacketDescription *inPacketDescriptions );
void MyAudioQueueIsRunningCallback( void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID );

- (void)handlePropertyChangeForFileStream:(AudioFileStreamID)inAudioFileStream fileStreamPropertyID:(AudioFileStreamPropertyID)inPropertyID ioFlags:(UInt32 *)ioFlags;
- (void)handlePropertyChangeForQueue:(AudioQueueRef)inAQ propertyID:(AudioQueuePropertyID)inID;
- (void)handleAudioPackets:(const void *)inInputData numberBytes:(UInt32)inNumberBytes numberPackets:(UInt32)inNumberPackets packetDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions;
- (void)handleBufferCompleteForQueue:(AudioQueueRef)inAQ buffer:(AudioQueueBufferRef)inBuffer;
- (void)failWithError:(OSErr)err string:(char *)anErrorString;
- (OSStatus)enqueueBuffer;

@end

@implementation HooAudioStreamer

@synthesize audioQueue = _audioQueue;
@synthesize bytesFilled = _bytesFilled, packetsFilled = _packetsFilled;
@synthesize fillBufferIndex = _fillBufferIndex;
@synthesize userRequestStop=_userRequestStop, started=_started, stopped=_stopped, failed=_failed;

#pragma mark init methods
- (id)initWithURL:(NSURL *)value {

	self = [super init];
	if(!self)
		return nil;
	
	_url = [value retain];
	_mp3DownloaderProxy = [[MP3Downloader alloc] init];
	[_mp3DownloaderProxy setDelegate:self];
	return self;
}

// Hmm gets called from different threads
- (void)dealloc {
	
	OSStatus err = noErr;
	
	NSLog(@"dealloc streamer");
	pthread_mutex_lock(&self->mutex); 

	if(_audioFileStream) {
		err = AudioFileStreamClose(_audioFileStream);
		_audioFileStream=nil;
		NSAssert(err==noErr, @"doesnt seem to be much point bailing in dealloc");
	}
	
	//
	// Dispose of the Audio Queue
	//
	if( _audioQueue ) {
		err = AudioQueueDispose(_audioQueue, true); // also cleans up buffers and resources
		_audioQueue = nil;
		NSAssert(err==noErr, @"doesnt seem to be much point bailing in dealloc");
	}	
	pthread_mutex_unlock(&self->mutex);

	[_url release];
	[_mp3DownloaderProxy release];
	_mp3DownloaderProxy = nil;
	_url = nil;
	[super dealloc];
}

#pragma mark action methods
- (void)startPlayingAudio {
	[NSThread detachNewThreadSelector:@selector(_startInternalPlayingAudio) toTarget:self withObject:nil];
}

//
// stop - Called from mainTherad
//
// This method can be called to stop downloading/playback before it completes.
// It is automatically called when an error occurs.
//
// If playback has not started before this method is called, it will toggle the
// "isPlaying" property so that it is guaranteed to transition to true and
// back to false 
//
- (void)stopPlayingAudio {
	
	OSStatus err = noErr;
	
	self.userRequestStop = YES;

	pthread_mutex_lock(&self->mutex); 

	//
	// If the AudioQueue started, then flush it (to make certain everything
	// sent thus far will be processed) and subsequently stop the queue.
	//
	if( self.audioQueue ) {
		AudioQueueStop( self.audioQueue, true );
	} else {
		self.stopped = YES;
	}
	pthread_mutex_unlock(&self->mutex);

	[self retain];
	[_mp3DownloaderProxy stopIfNeeded];
	[self release];
}


#pragma mark private action methods
- (void)_startInternalPlayingAudio {
	
	if(!_audioFileStream)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		_streamerProxyThread = [NSThread currentThread];
		NSLog( @"Start Playing audio on thread %@", _streamerProxyThread );
		
		AudioFileTypeID fileTypeHint = kAudioFileMP3Type;
		OSStatus err = AudioFileStreamOpen( self, MyPropertyListenerProc, MyPacketsProc, fileTypeHint, &_audioFileStream );
		if (err) { 
			PRINTERROR("AudioFileStreamOpen"); 
			goto end;
		}
		
		//hmm	self.state = AS_WAITING_FOR_DATA;
		
		[_mp3DownloaderProxy downloadURL:_url];
		
	end:
		[pool release];
	}
}

- (void)stopPlayingAudioWithConnectionError {
	[self failWithError:noErr string:"Network connection failed"];
}

#pragma mark provide data
/* Sync call on our thread, don't return til ready */
- (OSErr)parseAudioBytes:(NSData *)data {
	
	NSAssert([NSThread currentThread]==_streamerProxyThread, @"oops, wong thread?");
	
	if(self.userRequestStop)
		return 16;
	
	//
	// If there are no queued buffers, we need to check here since the
	// handleBufferCompleteForQueue:buffer: should not change the state
	// (may not enter the synchronized section).
	//
	//hmm	if( _buffersUsed==0 && self.state==AS_PLAYING ) {
	//hmm		self.state = AS_BUFFERING;
	//hmm	}
	
	//	NSLog(@"parseAudioBytes on thread %@", [NSThread currentThread]);
	
	OSStatus err  = AudioFileStreamParseBytes( _audioFileStream, [data length], [data bytes], 0 );	// use kAudioFileStreamParseFlag_Discontinuity if seeking
	if( err ){
		[self failWithError:err string:"Parse bytes failed"];
	}
	return err;
}

- (void)connectionFinishedLoading {
	
	NSAssert([NSThread currentThread]==_streamerProxyThread, @"oops, wong thread?");
	
	//
	// If there is a partially filled buffer, pass it to the AudioQueue for
	// processing
	//
	if(_bytesFilled) {
		[self enqueueBuffer];
	}
	
	//
	// If the AudioQueue started, then flush it (to make certain everything
	// sent thus far will be processed) and subsequently stop the queue.
	//
	if( self.audioQueue )
	{
		OSStatus err = noErr;
		
		//
		// Set the progress at the end of the stream
		//
		err = AudioQueueFlush( self.audioQueue );
		if( err ) {
			[self failWithError:err string:"Audio queue flush failed"];
			return;
		}
		
		err = AudioQueueStop( self.audioQueue, false);
		if( err ) {
			[self failWithError:err string:"Audio queue flush failed"];
			return;
		}
	} else {
		self.stopped = YES;
	}
}

#pragma mark audio playing internals
// enqueueBuffer
//
// Called from MyPacketsProc and connectionDidFinishLoading to pass filled audio
// bufffers (filled by MyPacketsProc) to the AudioQueue for playback. This
// function does not return until a buffer is idle for further filling or
// the AudioQueue is stopped.
//
// This function is adapted from Apple's example in AudioFileStreamExample with
// CBR functionality added.
//
- (OSStatus)enqueueBuffer {
	
	if(self.userRequestStop)
		return 0;
	
	OSStatus err = noErr;
	_inuse[_fillBufferIndex] = true;		// set in use flag
	_buffersUsed++;
	
	//	if( self.state==AS_BUFFERING ) {
	//		self.state = AS_PLAYING;
	//	}
	//		
	
	// enqueue buffer
	AudioQueueBufferRef fillBuf = _audioQueueBuffers[_fillBufferIndex];
	fillBuf->mAudioDataByteSize = _bytesFilled;
	
	err = AudioQueueEnqueueBuffer( self.audioQueue, fillBuf, _packetsFilled, _packetDescs);
	
	if( err ) {
		[self failWithError:err string:"AudioQueueEnqueueBuffer"];
		return err; 
	}
	
	if (!self.started) { // start the queue if it has not been started already
		//
		// Fill all the buffers before starting. This ensures that the
		// AudioFileStream stays a small amount ahead of the AudioQueue to
		// avoid an audio glitch playing streaming files on iPhone SDKs < 3.0
		err = AudioQueueStart( self.audioQueue, NULL);
		if (err) { 
			[self failWithError:err string:"AudioQueueStart"];
			return err; 
		}		
		self.started = YES;
		//		printf("started\n");
	}
	
	// go to next buffer
	if (++_fillBufferIndex >= kNumAQBufs) _fillBufferIndex = 0;
	_bytesFilled = 0;		// reset bytes filled
	_packetsFilled = 0;		// reset packets filled
	
	// wait until next buffer is not in use
	//	printf("->lock\n");
	pthread_mutex_lock(&self->mutex); 
	while (_inuse[_fillBufferIndex]) {
		//		printf("... WAITING ...\n");
		pthread_cond_wait(&self->cond, &self->mutex);
	}
	pthread_mutex_unlock(&self->mutex);
	//	printf("<-unlock\n");
	
	return err;
}

//
// handleAudioPackets:numberBytes:numberPackets:packetDescriptions:
//
// Object method which handles the implementation of MyPacketsProc
//
// Parameters:
//    inInputData - the packet data
//    inNumberBytes - byte size of the data
//    inNumberPackets - number of packets in the data
//    inPacketDescriptions - packet descriptions
//
- (void)handleAudioPackets:(const void *)inInputData numberBytes:(UInt32)inNumberBytes numberPackets:(UInt32)inNumberPackets packetDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions {
	
	// this is called by audio file stream when it finds packets of audio
//	printf("got data.  bytes: %d  packets: %d\n", inNumberBytes, inNumberPackets);
	
	if(self.userRequestStop)
		return;

	// the following code assumes we're streaming VBR data. for CBR data, you'd need another code branch here.
	for (int i = 0; i < inNumberPackets; ++i)
	{
		SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
		SInt64 packetSize   = inPacketDescriptions[i].mDataByteSize;

		// If the audio was terminated before this point, then
		// exit.
		if(self.userRequestStop)
			return;
		
		// if the space remaining in the buffer is not enough for this packet, then enqueue the buffer.
		size_t bufSpaceRemaining = kAQBufSize - _bytesFilled;
		if (bufSpaceRemaining < packetSize) {
			[self enqueueBuffer];
		}

		// If the audio was terminated while waiting for a buffer, then
		// exit.
		if(self.userRequestStop)
			return;

		// copy data to the audio queue buffer
		AudioQueueBufferRef fillBuf = _audioQueueBuffers[_fillBufferIndex];
		memcpy((char*)fillBuf->mAudioData + _bytesFilled, (const char*)inInputData + packetOffset, packetSize);
		// fill out packet description
		_packetDescs[_packetsFilled] = inPacketDescriptions[i];
		_packetDescs[_packetsFilled].mStartOffset = _bytesFilled;
		// keep track of bytes filled and packets filled
		_bytesFilled += packetSize;
		_packetsFilled += 1;

		// if that was the last free packet description, then enqueue the buffer.
		size_t packetsDescsRemaining = kAQMaxPacketDescs - _packetsFilled;
		if (packetsDescsRemaining == 0) {
			[self enqueueBuffer];
		}
	}	
}

//
// handlePropertyChangeForFileStream:fileStreamPropertyID:ioFlags:
//
// Object method which handles implementation of MyPropertyListenerProc
//
// Parameters:
//    inAudioFileStream - should be the same as self->audioFileStream
//    inPropertyID - the property that changed
//    ioFlags - the ioFlags passed in
//
- (void)handlePropertyChangeForFileStream:(AudioFileStreamID)inAudioFileStream fileStreamPropertyID:(AudioFileStreamPropertyID)inPropertyID ioFlags:(UInt32 *)ioFlags {

	if(self.userRequestStop)
		return;

	// this is called by audio file stream when it finds property values
	OSStatus err = noErr;
	
//	printf("found property '%c%c%c%c'\n", (inPropertyID>>24)&255, (inPropertyID>>16)&255, (inPropertyID>>8)&255, inPropertyID&255);
	
	switch (inPropertyID) {
		case kAudioFileStreamProperty_ReadyToProducePackets :
		{
			// the file stream parser is now ready to produce audio packets.
			// get the stream format.
			AudioStreamBasicDescription asbd;
			UInt32 asbdSize = sizeof(asbd);
			err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &asbdSize, &asbd);
			if( err ) { 
				[self failWithError:err string:"get kAudioFileStreamProperty_DataFormat"];
				break; 
			}
			
			// create the audio queue
			err = AudioQueueNewOutput(&asbd, MyAudioQueueOutputCallback, self, NULL, NULL, 0, &_audioQueue);
			if( err ) { 
				[self failWithError:err string:"AudioQueueNewOutput"];
				break; 
			}
			
			// start the queue if it has not been started already
			// listen to the "isRunning" property
			err = AudioQueueAddPropertyListener(_audioQueue, kAudioQueueProperty_IsRunning, MyAudioQueueIsRunningCallback, self);
			if( err ) {
				[self failWithError:err string:"Audio queue add listener failed"];
				break;
			}
			
			// allocate audio queue buffers
			for (unsigned int i = 0; i < kNumAQBufs; ++i) {
				err = AudioQueueAllocateBuffer(_audioQueue, kAQBufSize, &_audioQueueBuffers[i]);
				if( err ) { 
					[self failWithError:err string:"AudioQueueAllocateBuffer"];
					break; 
				}
			}

			break;
		}
	}
}

- (int)MyFindQueueBuffer:(AudioQueueBufferRef)inBuffer {

	for (unsigned int i = 0; i < kNumAQBufs; ++i) {
		if (inBuffer == _audioQueueBuffers[i]) 
			return i;
	}
	return -1;
}

//
// handleBufferCompleteForQueue:buffer:
//
// Handles the buffer completetion notification from the audio queue
//
// Parameters:
//    inAQ - the queue
//    inBuffer - the buffer
//
- (void)handleBufferCompleteForQueue:(AudioQueueRef)inAQ buffer:(AudioQueueBufferRef)inBuffer {

	// this is called by the audio queue when it has finished decoding our data. 
	// The buffer is now free to be reused.
	unsigned int bufIndex = [self MyFindQueueBuffer:inBuffer];
	
	// signal waiting thread that the buffer is free.
	pthread_mutex_lock(&self->mutex);
	_inuse[bufIndex] = false;
	_buffersUsed--;
	
	//  Enable this logging to measure how many buffers are queued at any time.
	printf("Queued buffers: %ld\n", _buffersUsed);
	
	pthread_cond_signal(&self->cond);
	pthread_mutex_unlock(&self->mutex);
}

//
// handlePropertyChangeForQueue:propertyID:
//
// Implementation for MyAudioQueueIsRunningCallback
//
// Parameters:
//    inAQ - the audio queue
//    inID - the property ID
//
- (void)handlePropertyChangeForQueue:(AudioQueueRef)inAQ propertyID:(AudioQueuePropertyID)inID {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	if( inID==kAudioQueueProperty_IsRunning ) {
		UInt32 gIsRunning=0;
		UInt32 size = sizeof(gIsRunning);
		AudioQueueGetProperty( _audioQueue, kAudioQueueProperty_IsRunning, &gIsRunning, &size);
		self.stopped = gIsRunning ? NO : YES;
		if(!gIsRunning)
			AudioQueueRemovePropertyListener(_audioQueue, kAudioQueueProperty_IsRunning, MyAudioQueueIsRunningCallback, self);
	}

	[pool release];
}

//
// failWithErrorCode:
//
// Sets the playback state to failed and logs the error.
//
// Parameters:
//    anErrorCode - the error condition
//
- (void)failWithError:(OSErr)err string:(char *)anErrorString {

	if(!self.failed)
	{
		self.failed = YES;
		PRINTERROR(anErrorString); 

		if(self.started)
			AudioQueueStop( _audioQueue, true );
	
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Audio Error", @"Errors", nil) message:NSLocalizedStringFromTable(@"Attempt to play streaming audio failed.", @"Errors", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
		[alert performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];

	}
}

#pragma mark audio callbacks

//
// MyAudioQueueOutputCallback
//
// Called from the AudioQueue when playback of specific buffers completes. This
// function signals from the AudioQueue thread to the AudioStream thread that
// the buffer is idle and available for copying data.
//
// This function is unchanged from Apple's example in AudioFileStreamExample.
//
void MyAudioQueueOutputCallback( void *inClientData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer ) {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// this is called by the audio queue when it has finished decoding our data. 
	// The buffer is now free to be reused.
	HooAudioStreamer *streamer = (HooAudioStreamer *)inClientData;
	[streamer handleBufferCompleteForQueue:inAQ buffer:inBuffer];
	[pool release];
}

//
// MyAudioQueueIsRunningCallback
//
// Called from the AudioQueue when playback is started or stopped. This
// information is used to toggle the observable "isPlaying" property and
// set the "finished" flag.
//
void MyAudioQueueIsRunningCallback( void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID ) {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	HooAudioStreamer *streamer = (HooAudioStreamer *)inUserData;
	[streamer handlePropertyChangeForQueue:inAQ propertyID:inID];
	[pool release];
}

//
// MyPropertyListenerProc
//
// Receives notification when the AudioFileStream has audio packets to be
// played. In response, this function creates the AudioQueue, getting it
// ready to begin playback (playback won't begin until audio packets are
// sent to the queue in MyEnqueueBuffer).
//
// This function is adapted from Apple's example in AudioFileStreamExample with
// kAudioQueueProperty_IsRunning listening added.
//
void MyPropertyListenerProc( void *inClientData, AudioFileStreamID inAudioFileStream, AudioFileStreamPropertyID inPropertyID, UInt32 *ioFlags ) {
	
	// this is called by audio file stream when it finds property values
	HooAudioStreamer *streamer = (HooAudioStreamer *)inClientData;
	[streamer handlePropertyChangeForFileStream:inAudioFileStream fileStreamPropertyID:inPropertyID ioFlags:ioFlags];
}

//
// MyPacketsProc
//
// When the AudioStream has packets to be played, this function gets an
// idle audio buffer and copies the audio packets into it. The calls to
// MyEnqueueBuffer won't return until there are buffers available (or the
// playback has been stopped).
//
// This function is adapted from Apple's example in AudioFileStreamExample with
// CBR functionality added.
//
void MyPacketsProc( void *inClientData, UInt32 inNumberBytes, UInt32 inNumberPackets, const void *inInputData,  AudioStreamPacketDescription *inPacketDescriptions ) {
	
	// this is called by audio file stream when it finds packets of audio
	HooAudioStreamer* streamer = (HooAudioStreamer *)inClientData;
	[streamer  handleAudioPackets:inInputData numberBytes:inNumberBytes numberPackets:inNumberPackets packetDescriptions:inPacketDescriptions];
}


@end
