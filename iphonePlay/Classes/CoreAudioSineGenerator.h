//
//  CoreAudioSineGenerator.h
//  iphonePlay
//
//  Created by Steven Hooley on 1/27/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

//#import <Cocoa/Cocoa.h>
#import "LowLevelSoundGeneratorProtocol.h"
#import <AudioToolbox/AudioToolbox.h>

enum _noteStatus {
    NOTE_FREE,
    NOTE_ATTACK,
    NOTE_RELEASE,
	NOTE_ENDED
};

struct SineData
{
	CGFloat phase;
	CGFloat freq, freqz;
	CGFloat amp, ampz;
	CGFloat MAX_AMP_FOR_FREQ;
	CGFloat UP_SLOPE_FOR_FREQ, MINIMUM_SUSTAIN_DURATION, DOWN_SLOPE_FOR_FREQ;
	CGFloat sustainDuration;
	enum _noteStatus status;
};

#define MANY_INPUTS 1
#ifdef MANY_INPUTS
	#define NUMBER_OF_INPUT_MIXERS	2
#else
	#define NUMBER_OF_INPUT_MIXERS	1
#endif

#define INPUTS_PER_MIXER			8 
#define MAX_INPUTS					NUMBER_OF_INPUT_MIXERS*INPUTS_PER_MIXER

@interface CoreAudioSineGenerator : NSObject <LowLevelSoundGeneratorProtocol> {

	AUGraph	_audioGraph;
	AudioUnit	_mixer;
	BOOL		_isPlaying;
	
	NSMutableIndexSet *_activeInputs;
	struct SineData *sineDatas[MAX_INPUTS];
	
	/* Experimental */
	AudioUnit	_inputMixerUnits[NUMBER_OF_INPUT_MIXERS];
}

@property BOOL isPlaying;

- (void)setUpGraph;
- (void)tearDownGraph;

/* we dont need to directly stat and stop the audio - you should start and stop a channel instead */
- (void)_startAudio;
- (void)_stopAudio;

- (NSIndexSet *)activeInputs;
- (UInt8)numberOfActiveInputs;
- (void)turnOffAllInputs;
- (void)setInput:(UInt8)inputIndex isEnabled:(AudioUnitParameterValue)status;

- (void)turnOnSine:(UInt8)inputIndex freq:(CGFloat)freq amp:(CGFloat)amplitude;
- (void)turnOffSine:(UInt8)inputIndex;

- (AudioUnitParameterValue)volumeOfInput:(UInt8)inputIndex;
- (void)setInput:(UInt8)inputIndex volume:(AudioUnitParameterValue)vol;

- (Float32)getCPULoad;

- (int)nextFreeChanel; // will return -1 if no free channels
- (void)_reserveChannel:(UInt8)inputIndex;
- (void)_releaseChannel:(UInt8)inputIndex;

- (void)getMixerForInput:(NSUInteger)inputIndex mixer:(NSUInteger *)mixerIndex mixerInput:(NSUInteger *)mixerInIndex;

@end
