//
//  HooAudioStreamer.h
//  ActorKitTest
//
//  Created by steve hooley on 18/06/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class MP3Downloader, PLActorRPCProxy;

#define kNumAQBufs 3			// number of audio queue buffers we allocate
#define kAQBufSize 32 * 1024	// number of bytes in each audio queue buffer
#define kAQMaxPacketDescs 512	// number of packet descriptions in our array

//typedef enum
//{
//	AS_INITIALIZED = 0,
//	AS_STARTING_FILE_THREAD,
//	AS_WAITING_FOR_DATA,
//	AS_WAITING_FOR_QUEUE_TO_START,
//	AS_PLAYING,
//	AS_BUFFERING,
//	AS_STOPPING,
//	AS_STOPPED,
//	AS_PAUSED
//} AudioStreamerState;
//
//typedef enum
//{
//	AS_NO_STOP = 0,
//	AS_STOPPING_EOF,
//	AS_STOPPING_USER_ACTION,
//	AS_STOPPING_ERROR,
//	AS_STOPPING_TEMPORARILY
//} AudioStreamerStopReason;
//
//typedef enum
//{
//	AS_NO_ERROR = 0,
//	AS_NETWORK_CONNECTION_FAILED,
//	AS_FILE_STREAM_GET_PROPERTY_FAILED,
//	AS_FILE_STREAM_SEEK_FAILED,
//	AS_FILE_STREAM_PARSE_BYTES_FAILED,
//	AS_FILE_STREAM_OPEN_FAILED,
//	AS_FILE_STREAM_CLOSE_FAILED,
//	AS_AUDIO_DATA_NOT_FOUND,
//	AS_AUDIO_QUEUE_CREATION_FAILED,
//	AS_AUDIO_QUEUE_BUFFER_ALLOCATION_FAILED,
//	AS_AUDIO_QUEUE_ENQUEUE_FAILED,
//	AS_AUDIO_QUEUE_ADD_LISTENER_FAILED,
//	AS_AUDIO_QUEUE_REMOVE_LISTENER_FAILED,
//	AS_AUDIO_QUEUE_START_FAILED,
//	AS_AUDIO_QUEUE_PAUSE_FAILED,
//	AS_AUDIO_QUEUE_BUFFER_MISMATCH,
//	AS_AUDIO_QUEUE_DISPOSE_FAILED,
//	AS_AUDIO_QUEUE_STOP_FAILED,
//	AS_AUDIO_QUEUE_FLUSH_FAILED,
//	AS_AUDIO_STREAMER_FAILED,
//	AS_GET_AUDIO_TIME_FAILED
//} AudioStreamerErrorCode;


@interface HooAudioStreamer : NSObject {

	NSURL *_url;
	MP3Downloader *_mp3DownloaderProxy;
	
	// the audio file stream parser
	AudioFileStreamID _audioFileStream;
	AudioQueueRef _audioQueue;

	size_t _bytesFilled, _packetsFilled;
	NSUInteger _fillBufferIndex;	// the index of the audioQueueBuffer that is being filled
	BOOL _inuse[kNumAQBufs];			// flags to indicate that a buffer is still in use
	NSInteger _buffersUsed;

	@public
	AudioQueueBufferRef _audioQueueBuffers[kNumAQBufs];
	AudioStreamPacketDescription _packetDescs[kAQMaxPacketDescs];	// packet descriptions for enqueuing audio


	BOOL _userRequestStop;
	
	// debugInfo
	NSThread *_streamerProxyThread;
	
	// apple
	BOOL _failed;
	BOOL _started;					// flag to indicate that the queue has been started
	BOOL _stopped;

	pthread_mutex_t mutex;			// a mutex to protect the inuse flags
	pthread_cond_t cond;			// a condition varable for handling the inuse flags
}

@property (readwrite) AudioQueueRef audioQueue;
@property (readwrite) size_t bytesFilled, packetsFilled;
@property (readwrite) NSUInteger fillBufferIndex;
@property (readwrite) BOOL userRequestStop, started, stopped, failed;

- (id)initWithURL:(NSURL *)newURL;

- (void)startPlayingAudio;
- (void)stopPlayingAudioWithConnectionError;
- (void)stopPlayingAudio;

- (OSErr)parseAudioBytes:(NSData *)value;

- (oneway void)connectionFinishedLoading;

@end
