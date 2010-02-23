//
//  CoreAudioSineGeneratorTests.m
//  iphonePlay
//
//  Created by steve hooley on 29/01/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "GTMSenTestCase.h"
#import "CoreAudioSineGenerator.h"

#define HC_SHORTHAND
#import <hamcrest/hamcrest.h>

@interface CoreAudioSineGeneratorTests : SenTestCase {

	CoreAudioSineGenerator *coreAudio;
}
@end


@implementation CoreAudioSineGeneratorTests

- (void)setUp {

	coreAudio = [[CoreAudioSineGenerator alloc] init];
}

- (void)tearDown {

	[coreAudio release];
}

/* normally graph will start and stop automagically as we enable and disable inputs */
- (void)testStartAndStopGraph {
	// - (void)_startAudio
	// - (void)_stopAudio
	// - (void)setUpGraph
	// - (void)tearDownGraph
	STAssertThrows([coreAudio _startAudio], @"should not be ready");
	[coreAudio setUpGraph];
	STAssertFalse([coreAudio isPlaying], @"should not be playing");
	[coreAudio _startAudio];
	STAssertTrue([coreAudio isPlaying], @"should be playing");
	
	// -- should probably be playing but no notes are Turned on - this shouldn't happen in normal operation
	
	[coreAudio _stopAudio];
	STAssertFalse([coreAudio isPlaying], @"should not be playing");
	[coreAudio tearDownGraph];
	STAssertThrows([coreAudio _startAudio], @"should not be ready");
}

- (void)testNextFreeChannel {
	
	[coreAudio setUpGraph];

	for(int i=0; i<16; i++)
	{
		int channelIndex = [coreAudio nextFreeChanel];
		STAssertTrue(channelIndex==i, @"should be playing");
		[coreAudio _reserveChannel:channelIndex];
	}
	int channelIndex = [coreAudio nextFreeChanel];
	STAssertTrue(channelIndex==-1, @"should be playing");

	for(int i=15; i>-1; i--)
	{
		[coreAudio _releaseChannel:i];
		channelIndex = [coreAudio nextFreeChanel];
		STAssertTrue(channelIndex==i, @"should be playing");
	}
	
	[coreAudio tearDownGraph];
}

- (void)testSetInputIsEnabled {
// - (void)setInput:(UInt8)inputIndex isEnabled:(AudioUnitParameterValue)status
	
	STAssertThrows([coreAudio setInput:0 isEnabled:0.0f], @"should not be ready");
	[coreAudio setUpGraph];
	STAssertFalse([coreAudio isPlaying], @"should not be playing");
	
	// turn on an input
	[coreAudio setInput:0 isEnabled:1.0f];
	STAssertTrue([coreAudio isPlaying], @"should be playing");
	STAssertTrue([coreAudio numberOfActiveInputs]==1, @"should be playing - %i", [coreAudio numberOfActiveInputs]);
	// we aren't manipulatieng inputs at the minute
	STAssertTrue([coreAudio volumeOfInput:0]==1.0f, @"should be playing - %f", [coreAudio volumeOfInput:0]);

	STAssertTrue( [[coreAudio activeInputs] isEqualToIndexSet:[NSIndexSet indexSetWithIndex:0]], @"should be equal");

	[coreAudio setInput:0 isEnabled:0.0f];
	STAssertTrue([coreAudio numberOfActiveInputs]==0, @"should be playing - %i", [coreAudio numberOfActiveInputs]);
	
	STAssertFalse([coreAudio isPlaying], @"should not be playing");

	[coreAudio tearDownGraph];
	STAssertThrows([coreAudio setInput:0 isEnabled:1.0f], @"should not be ready");
}

/* This should be the way to stop all audio */
- (void)testTurnOffAllInputs {
	// - (void)turnOffAllInputs

	[coreAudio setUpGraph];
	[coreAudio setInput:0 isEnabled:1.0f];
	[coreAudio setInput:1 isEnabled:1.0f];
	STAssertTrue([coreAudio numberOfActiveInputs]==2, @"should be playing - %i", [coreAudio numberOfActiveInputs]);
	[coreAudio turnOffAllInputs];
	STAssertTrue([coreAudio numberOfActiveInputs]==0, @"should be playing - %i", [coreAudio numberOfActiveInputs]);
	STAssertFalse([coreAudio isPlaying], @"should not be playing");
	[coreAudio tearDownGraph];
}

- (void)testVolumes {
	// - (AudioUnitParameterValue)volumeOfInput:(UInt8)inputIndex
	// - (void)setInput:(UInt8)inputIndex volume:(AudioUnitParameterValue)vol
	[coreAudio setUpGraph];
	[coreAudio setInput:0 isEnabled:1.0f];
	[coreAudio setInput:0 volume:0.45f];
	STAssertTrue([coreAudio volumeOfInput:0.0f]==0.45f, @"did not successfully set the volume");
	[coreAudio setInput:0 volume:1.0f];
	STAssertTrue([coreAudio volumeOfInput:0.0f]==1.0f, @"did not successfully set the volume");
	[coreAudio tearDownGraph];
}

- (void)testGetLoad {
// - (void)getCPULoad
	[coreAudio setUpGraph];
	[coreAudio setInput:0 isEnabled:1.0f];
	[coreAudio setInput:0 volume:0.45f];
	[coreAudio getCPULoad];
	[coreAudio tearDownGraph];
}

- (void)testTurnOnSine {
	// - (void)turnOnSine:(UInt8)inputIndex freq:(float)freq amp:(CGFloat)amplitude
	// - (void)turnOffSine:(UInt8)sinIndex
}

- (void)testInputNumberToMixerPortTranslation {
	// - (void)getMixerForInput:(NSUInteger)inputIndex mixer:(NSUInteger *)mixerIndex mixerInput:(NSUInteger *)mixerInIndex;
	
	NSUInteger mixerIndex, mixerInIndex;
	[coreAudio getMixerForInput:7 mixer:&mixerIndex mixerInput:&mixerInIndex];
	STAssertTrue( mixerIndex==0, @"wha!" );
	STAssertTrue( mixerInIndex==7, @"wha!" );
	
	[coreAudio getMixerForInput:8 mixer:&mixerIndex mixerInput:&mixerInIndex];
	STAssertTrue( mixerIndex==1, @"wha!" );
	STAssertTrue( mixerInIndex==0, @"wha!" );	

}

@end