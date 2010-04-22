//
//  SpectrumResults.m
//  AudioFileParser
//
//  Created by steve hooley on 22/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "SpectrumResults.h"
#import "BufferStore.h"
#import "HooSpectralProcessor.h"

@implementation SpectrumResults

- (id)initWithFormattedData:(BufferStore *)arg {

	self = [super init];
	if(self){
		_bufferStore = [arg retain];
		
		UInt32 fftSize = 1024;
		UInt32 overlapBetweenFrames = 512;
		UInt32 numberOfChannes = 1;
		UInt32 mMaxFramesPerSlice = 1024;

		_spectralProcessor = [[HooSpectralProcessor alloc] init:fftSize :overlapBetweenFrames :numberOfChannes :mMaxFramesPerSlice];
		[_spectralProcessor setDelegate:self];
	}
	return self;
}

- (void)dealloc {

	[_spectralProcessor release];
	[_bufferStore release];
	[super dealloc];
}

- (void)processInputData {
	
	struct AudioBufferList inInputBufferList;
	inInputBufferList.mNumberBuffers = 1;
	inInputBufferList.mBuffers[0].mNumberChannels = 1;
	inInputBufferList.mBuffers[0].mDataByteSize = 1024;

	[_bufferStore resetReading];
	while( [_bufferStore hasMoreSamples] ) {
		Float32 *samples = [_bufferStore nextSamples];
		inInputBufferList.mBuffers[0].mData = samples;
		[_spectralProcessor processForwards:1024 :&inInputBufferList];
	}
	[_spectralProcessor flush];

}

- (void)_callback_complexOutput:(struct HooSpectralBufferList *)inSpectra {

	-- save the spectrum data
}

@end
