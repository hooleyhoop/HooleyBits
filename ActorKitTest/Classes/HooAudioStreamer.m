//
//  HooAudioStreamer.m
//  ActorKitTest
//
//  Created by steve hooley on 18/06/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "HooAudioStreamer.h"
#import "MP3Downloader.h"

@implementation HooAudioStreamer

- (id)initWithURL:(NSURL *)value {

	self = [super init];
	if(!self)
		return nil;
	
	_url = [value retain];
	id proxy = [[PLActorRPCProxy alloc] initWithTarget: self];
	[self release];
	return proxy;
}

- (void)dealloc {
	[_url release];
	[super dealloc];
}

- (void)start {
	
	MP3Downloader *mp3DownloaderProxy = [[[MP3Downloader alloc] init] autorelease];
	[mp3DownloaderProxy downloadURL:_url];
}

- (void)stop {
	
}

@end
