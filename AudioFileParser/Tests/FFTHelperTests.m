//
//  FFTHelperTests.m
//  AudioFileParser
//
//  Created by Steven Hooley on 02/01/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "FFTHelper.h"
#import "HooleyStuff.h"
#import "BufferStore.h"

@interface FFTHelperTests : SenTestCase {
	
	FFTHelper *_fft;
}

@end

@implementation FFTHelperTests

- (void)setUp {
	_fft = [[FFTHelper alloc] init];
}

- (void)tearDown {
	[_fft release];
}


- (void)testBlahBlah {
	
	BufferStore *testStore = [[BufferStore alloc] init];
	[testStore setBlockSize:16];
	
	struct HooAudioBuffer *hooBuff1 = newHooAudioBuffer(128,0);
	[testStore addFrames:128 :hooBuff1];

	[testStore closeInput];
	STAssertTrue( 8==[testStore numberOfWholeBuffers], @"oops %i", [testStore numberOfWholeBuffers]);

	[testStore resetReading];
	while([testStore hasMoreSamples]){
		Float32 *aSingleBlock = [testStore nextSamples];
		[_fft processSomeAudio:16 :aSingleBlock];
	}
	
	freeHooAudioBuffer(hooBuff1);
	[testStore release];
}

@end
