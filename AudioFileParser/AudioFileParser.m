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

@synthesize in_AudioFilePath = _in_AudioFilePath;
@synthesize out_graphicsDirPath = _out_graphicsDirPath;

// ***********************
#pragma mark-
static AudioFileParser *afp;
+ (AudioFileParser *)afp {
	return afp;
}

- (id)init {
	self = [super init];
	if(self){
		afp = self;
		_in_AudioFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/in.wav"] retain];
		_out_graphicsDirPath = [@"shit" retain];
	}
	return self;
}

- (void)dealloc {
	[_in_AudioFilePath release];
	[_out_graphicsDirPath release];
	[super dealloc];
}

- (void)awakeFromNib {
	
}


#pragma mark protocol
- (void)_callback_error:(id)hmm {

}

- (void)_callback_withData:(struct HooAudioBuffer *)hmm {
	// copy all frames to 1024 size blocks
	//	tempHooBuffer is invalid after we return from this call 
	//	[_bufferStore addFrames:writeFrames :tempHooBuffer];
}

- (void)_callback_complete:(id)hmm {
	
}

#pragma mark -

- (IBAction)processFiles:(id)sender {

	OfflineAudioQueueWrapper *qw = [[OfflineAudioQueueWrapper alloc] initWithAudioFilePath:_in_AudioFilePath dataConsumer:self];
	[qw beginProcessing];
	
	[qw release];

	
	_bufferStore = [[BufferStore alloc] init];
	[_bufferStore setBlockSize:1024];
	

	
	_fft = [FFTHelper new];
	[_fft open];
	
	[_bufferStore resetReading];
	while([_bufferStore hasMoreSamples]){
		Float32 *samples = [_bufferStore nextSamples];
		
#warning! fill with 1
//		memset(samples, 1, sizeof(Float32)*1024 );
		

		[_fft processSomeAudio:1024 :samples];
	}
	[_fft close];

	[_fft saveImage];
//Doh!	[_fft saveImageSequence];
	
	[_fft release];
	[_bufferStore release];
}

- (AudioChannelLayout *)inputChannelLayout {
//put back	return _inputChannelLayout;
	return nil;
}

- (AudioStreamBasicDescription *)captureFormat {
//put back		return _captureFormat;
	return nil;
}

//- (NSString *)in_AudioFilePath {
//	return _in_AudioFilePath;
//}
//
//- (void)setIn_AudioFilePath:(NSString *)value {
//	_in_AudioFilePath = [value retain];
//}

@end
