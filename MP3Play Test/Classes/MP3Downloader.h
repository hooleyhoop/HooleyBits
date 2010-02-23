//
//  MP3Downloader.h
//  ActorKitTest
//
//  Created by steve hooley on 18/06/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HooAudioStreamer;

@interface MP3Downloader : NSObject {

	BOOL _streamShouldFinish, _failed;
	HooAudioStreamer *_delegate;
	
	// debug
	NSThread *_downloaderThread;
}

@property (assign) HooAudioStreamer *delegate;
@property (readwrite) BOOL streamShouldFinish, failed;

- (oneway void)downloadURL:(NSURL *)anURL;

- (void)stopIfNeeded;


@end
