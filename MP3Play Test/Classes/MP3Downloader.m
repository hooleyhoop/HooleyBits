//
//  MP3Downloader.m
//  ActorKitTest
//
//  Created by steve hooley on 18/06/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "MP3Downloader.h"
#import "HooAudioStreamer.h"
#import <CFNetwork/CFNetwork.h>

#define v2_CFReadStream


@interface MP3Downloader (private)
void ASReadStreamCallBack ( CFReadStreamRef aStream, CFStreamEventType eventType, void* inClientInfo);
@end

@implementation MP3Downloader

@synthesize delegate = _delegate;
@synthesize streamShouldFinish=_streamShouldFinish, failed=_failed;

- (id)init {

	if((self=[super init])==nil)
		return nil;
	return self;
}

- (void)dealloc {

	[super dealloc];
}

#pragma mark Action methods
// Method is called asynchronously
- (oneway void)downloadURL:(NSURL *)anURL {
	
	_downloaderThread = [NSThread currentThread];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSAssert(self.delegate!=nil, @"hmm");

#ifdef v2_CFReadStream
	//
	// Create the GET request
	//
	CFHTTPMessageRef message= CFHTTPMessageCreateRequest(NULL, (CFStringRef)@"GET", (CFURLRef)anURL, kCFHTTPVersion1_1);
	CFReadStreamRef stream = CFReadStreamCreateForHTTPRequest(NULL, message);
	CFRelease(message);

	//
	// Open the stream
	//
	if(!CFReadStreamOpen(stream)) {	
		CFRelease(stream);
		NSLog(@"failed - pop up an alert! clean up!");
		[pool release];
		return;
	}
	
	//
	// Set our callback function to receive the data
	//
	CFStreamClientContext context = {0, self, NULL, NULL, NULL};
	CFReadStreamSetClient( stream, kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered, ASReadStreamCallBack,  &context);
	CFReadStreamScheduleWithRunLoop( stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes );

#else
	
	// Use NSURLConnection instead of CFReadStream
	NSURLRequest *request = [NSURLRequest requestWithURL:anURL];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

#endif
	
	// Loop forever, receiving messages
	while( !self.streamShouldFinish )
	{
		NSAutoreleasePool *innerPool = [[NSAutoreleasePool alloc] init];
		if(self.failed){
			// error downloading..
			[self.delegate stopPlayingAudioWithConnectionError];
			[innerPool release];
			break;
		}
	
		NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];
		[myRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	
		[innerPool release];
	}
	NSLog(@"ECHO killing download actor");

#ifdef v2_CFReadStream
	CFReadStreamClose(stream);
	CFRelease(stream);
#else
	[connection cancel];
	[connection release];
	connection = nil;
#endif

	[pool release];
}
	
- (void)stopIfNeeded {
	self.delegate = nil;
	self.streamShouldFinish = YES;
	NSLog(@"**** Yaya!!!! ***");
}

#pragma mark Connection callbacks
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return nil;
}

- (void)connection:(NSURLConnection *)inConnection didReceiveData:(NSData *)data {
	
	NSAssert( _downloaderThread==[NSThread currentThread], @"oops wrong thread");

	OSErr err=0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	err = [self.delegate parseAudioBytes:data];
	[pool release];

	// our custom error number
	if( err==16 ) {
		[inConnection cancel];
		self.streamShouldFinish=YES;
		NSLog(@"Finishing!");
	} else if( err ) {
		
		self.failed = YES;
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)inConnection {
	
	NSAssert( _downloaderThread==[NSThread currentThread], @"oops wrong thread");

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self.delegate connectionFinishedLoading];
	[pool release];
	
	self.streamShouldFinish = YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	NSAssert( _downloaderThread==[NSThread currentThread], @"oops wrong thread");
	self.failed = YES;
}

#pragma mark CFReadStream stuff

#ifdef v2_CFReadStream
- (void)readBufferFromStream:(CFReadStreamRef)stream {
	
	UInt8 bytes[kAQBufSize];
	CFIndex length;
	
	//
	// Read the bytes from the stream
	//
	length = CFReadStreamRead(stream, bytes, kAQBufSize);
	if( length==0 || length==-1 ) 
		return;
	
	[self connection:nil didReceiveData:[NSData dataWithBytes:bytes length:length]];
}

//
// handleReadFromStream:eventType:data:
//
// Reads data from the network file stream into the AudioFileStream
//
// Parameters:
//    aStream - the network file stream
//    eventType - the event which triggered this method
//
- (void)handleReadFromStream:(CFReadStreamRef)aStream eventType:(CFStreamEventType)eventType {
	
	if( eventType==kCFStreamEventErrorOccurred ) {
		NSLog(@"kCFStreamEventErrorOccurred");
		[self connection:nil didFailWithError:nil];
		
	} else if( eventType==kCFStreamEventEndEncountered ) {
		
		[self readBufferFromStream:aStream];
		[self connectionDidFinishLoading:nil];
		
	} else if( eventType==kCFStreamEventHasBytesAvailable ) {
		[self readBufferFromStream:aStream];
	}
}

//
// ReadStreamCallBack
//
// This is the callback for the CFReadStream from the network connection. This
// is where all network data is passed to the AudioFileStream.
//
// Invoked when an error occurs, the stream ends or we have data to read.
//
void ASReadStreamCallBack ( CFReadStreamRef aStream, CFStreamEventType eventType, void* inClientInfo) {
	MP3Downloader* downloader = (MP3Downloader *)inClientInfo;
	[downloader handleReadFromStream:aStream eventType:eventType];
}
#endif


@end
