//
//  MP3Downloader.m
//  ActorKitTest
//
//  Created by steve hooley on 18/06/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "MP3Downloader.h"
#import "PLActorRPCProxy.h"
#import "ActorKit.h"

@implementation MP3Downloader

- (id)init {
	if((self=[super init])==nil)
		return nil;
	// Launch our actor
	id proxy = [[PLActorRPCProxy alloc] initWithTarget: self];
	[self release];
	return proxy;
}

- (void)dealloc {
	[super dealloc];
}

// Method is called asynchronously
- (oneway void)downloadURL:(NSURL *)anURL {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	PLActorMessage *message=nil;

	NSURLRequest *request = [NSURLRequest requestWithURL:anURL];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	// Loop forever, receiving messages
	while( !_streamShouldFinish )
	{
		NSAutoreleasePool *innerPool = [[NSAutoreleasePool alloc] init];

	//	message=[PLActorKit receive];
	//	NSLog(@"downloading on Thread %@ - message is %@", [NSThread currentThread], message);
		NSRunLoop *rl = [NSRunLoop currentRunLoop];
		[rl runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		
		[innerPool release];
	}
	NSLog(@"ECHO killing download actor");
	[connection release];
	connection = nil;

	[pool release];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return nil;
}

- (void)connection:(NSURLConnection *)inConnection didReceiveData:(NSData *)data {
	
//	NSLog(@"received data on thread %@", [NSThread currentThread]);
	
//	BOOL streamIsDiscontinuous, streamShouldFinish, streamDidFail;
//	pthread_mutex_lock(&statusMutex);
//	streamIsDiscontinuous = discontinuous;
//	streamShouldFinish = shouldFinish;
//	streamDidFail = failed;
//	pthread_mutex_unlock(&statusMutex);
//	
//	if (streamShouldFinish || streamDidFail) {
//		return;
//	}
//	
	OSStatus err = AudioFileStreamParseBytes(audioFileStream, [data length], [data bytes], streamIsDiscontinuous ? kAudioFileStreamParseFlag_Discontinuity : 0);
//	if (err) {
//		PRINTERROR("AudioFileStreamParseBytes");
//		pthread_mutex_lock(&statusMutex);
//		failed = true;
//		pthread_mutex_unlock(&statusMutex);
//	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)inConnection {
	
	NSLog(@"finished loading data");
	_streamShouldFinish = YES;
	
//	BOOL streamShouldFinish, streamDidFail;
//	pthread_mutex_lock(&statusMutex);
//	streamShouldFinish = shouldFinish;
//	streamDidFail = failed;
//	pthread_mutex_unlock(&statusMutex);
//	
//	if (streamShouldFinish || streamDidFail) {
//		return;
//	}
//	
//	//
//	// If there is a partially filled buffer, pass it to the AudioQueue for
//	// processing
//	//
//	if (bytesFilled)
//	{
//		MyEnqueueBuffer(self);
//	}
//	
//	//
//	// If the AudioQueue started, then flush it (to make certain everything
//	// sent thus far will be processed) and subsequently stop the queue.
//	//
//	if (started)
//	{
//		OSStatus err = AudioQueueFlush(audioQueue);
//		if (err) { PRINTERROR("AudioQueueFlush"); return; }
//		
//		err = AudioQueueStop(audioQueue, false);
//		if (err) { PRINTERROR("AudioQueueStop"); return; }
//		
//		pthread_mutex_lock(&statusMutex);
//		[connection release];
//		connection = nil;
//		pthread_mutex_unlock(&statusMutex);
//	}
//	else
//	{
//		//
//		// If we have reached the end of the file without starting, then we
//		// have failed to find any audio in the file. Abort.
//		//
//		pthread_mutex_lock(&statusMutex);
//		failed = YES;
//		pthread_mutex_unlock(&statusMutex);
//	}
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	NSLog(@"Failed");
//	pthread_mutex_lock(&statusMutex);
//	failed = YES;
//	pthread_mutex_unlock(&statusMutex);
}


@end
