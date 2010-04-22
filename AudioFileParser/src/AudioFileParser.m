//
//  AudioFileParser.m
//  AudioFileParser
//
//  Created by steve hooley on 18/12/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "AudioFileParser.h"
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/ExtendedAudioFile.h>
#import <SHShared/SHShared.h>

#import "ProcessingStuff.h"
#import "BufferStore.h"
#import "FFTHelper.h"

#import "OfflineAudioQueueWrapper.h"

@implementation AudioFileParser


// ***********************
#pragma mark-
- (id)initWithAudioFileURL:(NSString *)arg1 {

	self = [super init];
	if(self){
		_inputFile = [arg1 retain];
	}
	return self;
}

- (void)dealloc {
	
	[_aq_progressCallbackCustomInv release];
	[_aq_completeCallbackCustomInv release];
	[_inputFile release];
	[super dealloc];
}

#pragma mark audioQueue callback protocol
- (void)_aq_callback_error:(id)hmm {
	logError(@"AudioWueue stuff failed");
}

- (void)_aq_callback_withData:(struct HooAudioBuffer *)hmm {

	[_aq_progressCallbackCustomInv setArgument:&hmm->length atIndex:2];
	[_aq_progressCallbackCustomInv setArgument:&hmm atIndex:3];
	[_aq_progressCallbackCustomInv invoke];
}

- (void)_aq_callback_complete:(id)hmm {

	[_aq_completeCallbackCustomInv invoke];
}

#pragma mark -

- (void)processInputFile {

	OfflineAudioQueueWrapper *qw = [[OfflineAudioQueueWrapper alloc] initWithAudioFilePath:_inputFile dataConsumer:self];
	[qw beginProcessing];
	[qw release];
}

//- (AudioChannelLayout *)inputChannelLayout {
////put back	return _inputChannelLayout;
//	return nil;
//}
//
//- (AudioStreamBasicDescription *)captureFormat {
////put back		return _captureFormat;
//	return nil;
//}

//- (NSString *)in_AudioFilePath {
//	return _in_AudioFilePath;
//}
//
//- (void)setIn_AudioFilePath:(NSString *)value {
//	_in_AudioFilePath = [value retain];
//}

- (void)setAQ_progressCallbackCustomInv:(NSInvocation *)arg {

	[_aq_progressCallbackCustomInv release];
	_aq_progressCallbackCustomInv = [arg retain];
}

- (void)setAQ_completeCallbackCustomInv:(NSInvocation *)arg {
	
	[_aq_completeCallbackCustomInv release];
	_aq_completeCallbackCustomInv = [arg retain];
}


@end
