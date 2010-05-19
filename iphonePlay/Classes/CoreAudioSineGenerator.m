//
//  CoreAudioSineGenerator.m
//  iphonePlay
//
//  Created by Steven Hooley on 1/27/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import "CoreAudioSineGenerator.h"
#import "LogController.h"
#import "G3DFunctions.h"

#define RequireNoErr(error)	do { if( (error) != noErr ) [NSException raise:@"CoreAudio ERROR" format:@"%i", error]; } while (false)

/*
 * FixedToFloat/FloatToFixed are 10.3+ SDK items - include definitions
 * here so we can use older SDKs.
 */
#ifndef FixedToFloat
#define fixed1              ((Fixed) 0x00010000L)
#define FixedToFloat(a)     ((CGFloat)(a) / fixed1)
#define FloatToFixed(a)     ((Fixed)((CGFloat)(a) * fixed1))
#endif

const CGFloat kGraphSampleRate = 44100.f;
CGFloat pow3(CGFloat x) { return x*x*x; }
CGFloat pow5(CGFloat x) { CGFloat x2 = x*x; return x2*x2*x; }

OSStatus renderInput(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{	
	struct SineData* myData = (struct SineData *)inRefCon;
	CGFloat phase = myData->phase;
	CGFloat freq = myData->freq;
//	CGFloat amp = myData->amp;
	CGFloat ampz = myData->ampz;
//    CGFloat freqz = myData->freqz;
	
	Fixed *outA = (Fixed *)ioData->mBuffers[0].mData;
	CGFloat wave = 0.f;
	
	switch( myData->status ){
		case NOTE_FREE :
			for( NSUInteger i=0; i<inNumberFrames; ++i ){
				outA[i] = FloatToFixed(0.0f);
			}
			break;
			
		case NOTE_ATTACK :
			for( NSUInteger i=0; i<inNumberFrames; ++i ) 
			{				
				wave = pow3(sinf(phase)) * ampz; // between -1 and 1 // the pow3 smooths transition from zero - stops crackles?
				outA[i] = FloatToFixed((CGFloat)(wave*127.0f));
				phase += freq;
				if (phase > TWOPI) 
					phase -= (CGFloat)TWOPI;
				// de-zipper controls - seems fucked if zero?
				if (ampz < myData->MAX_AMP_FOR_FREQ) {
					ampz += myData->UP_SLOPE_FOR_FREQ;
					// ampz  = 0.0001 * amp  + 0.9990 * ampz;
				} else {
					/* Spastic debug */
					// myData->status = NOTE_RELEASE;
				}
				// freqz = 1.000 * freq + 0.000 * freqz;
			}
			break;

		case NOTE_RELEASE :
			// logInfo(@"NOTE_RELEASE %i", inBusNumber);
			for (UInt32 i=0; i<inNumberFrames; ++i) 
			{
				/* Only begin the fade-out when we have sustained for the minimum amount dof time */
				if((myData->sustainDuration > myData->MINIMUM_SUSTAIN_DURATION))
				{
					if( ampz>0.0 ){
						ampz -= myData->DOWN_SLOPE_FOR_FREQ;
					} else {				
						myData->status = NOTE_ENDED;
						/* Spastic debug */
						//myData->status = NOTE_ATTACK;
					}
				}
				
				//if(amp<0.0)
				//	amp = 0.0;
				wave = pow3(sinf(phase)) * ampz; // between -1 and 1
				Fixed outVal = FloatToFixed((float)(wave*127.0f));
				outA[i] = outVal;
				phase += freq;
				// de-zipper controls - seems fucked if zero?
				// ampz  = 0.0001 * amp  + 0.9990 * ampz;
				// freqz = 1.000 * freq + 0.000 * freqz;
			}
			myData->sustainDuration+=inNumberFrames;
			
			break;
		case NOTE_ENDED :
			for (UInt32 i=0; i<inNumberFrames; ++i) 
			{
				outA[i] = FloatToFixed(0.0f);
			}
			break;
	}
	myData->phase = phase;
    // myData->freqz = freqz;
    myData->ampz = ampz;
	return noErr;
}

@implementation CoreAudioSineGenerator

@synthesize isPlaying = _isPlaying;

- (id)init {
	
	self = [super init];
	if(self){
		_isPlaying = NO;
		_audioGraph = 0;
		_mixer = 0;
		_activeInputs = [[NSMutableIndexSet indexSet] retain];
		
		for(int i=0; i<MAX_INPUTS; i++){
			struct SineData* dataForChannel = (struct SineData *)calloc(1, sizeof(struct SineData));
			dataForChannel->status = NOTE_FREE;
			sineDatas[i] = dataForChannel;
		}
	}
	return self;
}

- (void)dealloc {
	
	int waitCount=0;
	while([self numberOfActiveInputs]>0 && waitCount<20){
		sleep(0.1f);
		logInfo(@"waiting for shutdown..");
		waitCount++;
	}
	NSAssert([self numberOfActiveInputs]==0, @"Cant dealloc CoreAudio sine generator when inputs are active");
	[_activeInputs release];
	
	for(int i=0; i<MAX_INPUTS; i++){
		free(sineDatas[i]);
	}

	[super dealloc];
}

- (void)setUpGraph {
	
	RequireNoErr( NewAUGraph(&_audioGraph) );
	
	// Describe audio components
	AudioComponentDescription output_desc;
	output_desc.componentType = kAudioUnitType_Output;
	output_desc.componentSubType = kAudioUnitSubType_RemoteIO;
	output_desc.componentFlags = 0;
	output_desc.componentFlagsMask = 0;
	output_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	// Multichannel mixer unit—Allows any number of mono or stereo inputs, each of which can be 16-bit linear or 8.24-bit fixed-point PCM. 
	// Provides one stereo output in 8.24-bit fixed-point PCM. Your application can mute and unmute each input channel as well as control its volume. 
	// Programmatically, this is the kAudioUnitSubType_MultiChannelMixer unit.
	// THE MIXER HAS 8 Input Busses and 1 output bus. This is fixed!
	AudioComponentDescription mixer_desc;
	mixer_desc.componentType = kAudioUnitType_Mixer;
	mixer_desc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
	mixer_desc.componentFlags = 0;
	mixer_desc.componentFlagsMask = 0;
	mixer_desc.componentManufacturer = kAudioUnitManufacturer_Apple;

	// add the iphone output node to the graph
	AUNode outputNode;
	RequireNoErr( AUGraphAddNode( _audioGraph, &output_desc, &outputNode));

	// add the shitty iphone mixer
	AUNode _mixerNode;
	RequireNoErr( AUGraphAddNode( _audioGraph, &mixer_desc, &_mixerNode ));

	// Connect our Mixer to our Output
	// We connect busses
	// busses can have any number of channels
	// some units have fixed number of output busses - some can be configured - the ones we are dealing with here are fixed
	RequireNoErr( AUGraphConnectNodeInput(_audioGraph, _mixerNode, 0, outputNode, 0 ));

	// So we have a mixer conected to the output - add another mixer
AUNode inputMixerNodes[NUMBER_OF_INPUT_MIXERS];

#ifdef MANY_INPUTS
	for(NSUInteger i=0; i<NUMBER_OF_INPUT_MIXERS; i++){
		RequireNoErr( AUGraphAddNode( _audioGraph, &mixer_desc, &inputMixerNodes[i] ));
		RequireNoErr( AUGraphConnectNodeInput(_audioGraph, inputMixerNodes[i], 0, _mixerNode, i ));
	}
#else
	inputMixerNodes[0] = _mixerNode;
#endif
	
	RequireNoErr( AUGraphOpen(_audioGraph));
	
	// Obtain a reference to the Mixer AudioUnit
	RequireNoErr( AUGraphNodeInfo(_audioGraph, _mixerNode, NULL, &_mixer  ));
	
#ifdef MANY_INPUTS
	for(NSUInteger i=0; i<NUMBER_OF_INPUT_MIXERS; i++){
		RequireNoErr( AUGraphNodeInfo(_audioGraph, inputMixerNodes[i], NULL, &_inputMixerUnits[i]  ));
	}
#else
	_inputMixerUnits[0] = _mixer;
#endif
	
	// Configure Output
	// Try using this AudioStreamBasicDescription -- SEE http://www.blackbagops.net/?p=117 use output units first output bus description
	// When you connect an output to an input the input will be mathed to the output, therefore in a graph you don't need to set the format of each output and input, only the key ones
	
	// MASTER MIXER INPUTS
	for( int i=0; i<INPUTS_PER_MIXER; i++ ) 
	{
		// set input stream format
		AudioStreamBasicDescription mixer_input_desc;
		UInt32 mixer_input_desc_size = sizeof(mixer_input_desc);
		
		// get the current input stream format
		RequireNoErr( AudioUnitGetProperty( _mixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &mixer_input_desc, &mixer_input_desc_size ));
		
		// tweak it to what we want and set it
		mixer_input_desc.mChannelsPerFrame = 1;
		RequireNoErr( AudioUnitSetProperty(	_mixer,  kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &mixer_input_desc, mixer_input_desc_size ));
	}
	
#ifdef MANY_INPUTS
	for(NSUInteger j=0; j<NUMBER_OF_INPUT_MIXERS; j++){
		for( int i=0; i<INPUTS_PER_MIXER; i++ ) {
			AudioStreamBasicDescription mixer_input_desc;
			UInt32 mixer_input_desc_size = sizeof(mixer_input_desc);
			RequireNoErr( AudioUnitGetProperty( _inputMixerUnits[j], kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &mixer_input_desc, &mixer_input_desc_size ));
			mixer_input_desc.mChannelsPerFrame = 1;
			RequireNoErr( AudioUnitSetProperty(	_inputMixerUnits[j],  kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &mixer_input_desc, mixer_input_desc_size ));
		}
	}
#endif

	// NOW that we've set everything up we can initialize the graph 
	// (which will also validate the connections)
	RequireNoErr( AUGraphInitialize(_audioGraph));
}

- (void)tearDownGraph {

	if(self.isPlaying)
		[self turnOffAllInputs];

	RequireNoErr( AUGraphUninitialize(_audioGraph) ); 
	RequireNoErr( AUGraphClose(_audioGraph) ); 
	RequireNoErr( DisposeAUGraph(_audioGraph) );
	_mixer = 0;
	_audioGraph = 0;
}

// Dont call this Directly!
- (void)_startAudio {

	NSAssert(_isPlaying==NO, @"already playing");

	if(_audioGraph==NULL)
		[NSException raise:@"Graph Not Ready" format:@"-- --"];

	RequireNoErr( AUGraphStart(_audioGraph));
	self.isPlaying = YES;

	// Start with all inputs disabled (muted)
	for(NSUInteger j=0; j<NUMBER_OF_INPUT_MIXERS; j++){
		for( int i=0; i<INPUTS_PER_MIXER; i++ ) 
		{
			AudioUnitParameterValue initialStatus = 0.0f;
			RequireNoErr( AudioUnitSetParameter( _inputMixerUnits[j], kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, i, initialStatus, 0) );
			// Just a check
			AudioUnitParameterValue currentStatus=-99;
			RequireNoErr( AudioUnitGetParameter( _inputMixerUnits[j], kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, i, &currentStatus ));
			NSAssert(G3DCompareFloat(currentStatus, 0.0f, 0.001f)==0, @"why no work?");
		}
	}
}

// Dont call this Directly!
- (void)_stopAudio {

	NSAssert(_isPlaying==YES, @"not playing");

	if(_audioGraph==NULL)
		[NSException raise:@"Graph Not Ready" format:@"-- --"];

	RequireNoErr( AUGraphStop(_audioGraph));
	self.isPlaying = NO;
}

- (NSIndexSet *)activeInputs {
	return [[_activeInputs copy] autorelease];
}

- (UInt8)numberOfActiveInputs {
	return [_activeInputs count];
}

- (void)turnOffAllInputs {

	NSIndexSet *indexesNow = [[_activeInputs copy] autorelease];
	int index = [indexesNow firstIndex];
	while(index!=NSNotFound){
		[self setInput:index isEnabled:0.0f];
		index = [indexesNow indexGreaterThanIndex:index];
	}
}

- (void)setInput:(UInt8)inputIndex isEnabled:(AudioUnitParameterValue)status
{
	// logInfo(@"Enable:%f - %i", (CGFloat)status, inputIndex);
	NSParameterAssert( inputIndex<MAX_INPUTS );
	if(_audioGraph==NULL)
		[NSException raise:@"Graph Not Ready" format:@"-- --"];

	// if we are turning on the first input we need to start the graph
	if(G3DCompareFloat(status, 1.0f, 0.001f)==0 && self.isPlaying==NO)
		[self _startAudio];

	NSUInteger mixerIndex, mixerInIndex;
	[self getMixerForInput:inputIndex mixer:&mixerIndex mixerInput:&mixerInIndex];

	// what is out current enabled Status?
	AudioUnitParameterValue currentStatus; //-- float32
	RequireNoErr( AudioUnitGetParameter( _inputMixerUnits[mixerIndex], kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, mixerInIndex, &currentStatus ));
	NSAssert(G3DCompareFloat(currentStatus, status, 0.001f)!=0, @"cant reset the same value fuckwit");

	// set the desired status
	RequireNoErr( AudioUnitSetParameter( _inputMixerUnits[mixerIndex], kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, mixerInIndex, status, 0) );

	// see if it worked
	RequireNoErr( AudioUnitGetParameter( _inputMixerUnits[mixerIndex], kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, mixerInIndex, &currentStatus ));
	NSAssert(G3DCompareFloat(currentStatus, status, 0.001f)==0, @"why no work?");

	// Add or remove the callback
	if(G3DCompareFloat(status, 0.0f, 0.001f)==0){
		
		// set the render callback for this bus
		AURenderCallbackStruct rcbs;
		rcbs.inputProc = NULL;
		rcbs.inputProcRefCon = NULL;
		RequireNoErr( AudioUnitSetProperty( _inputMixerUnits[mixerIndex], kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, mixerInIndex, &rcbs, sizeof(AURenderCallbackStruct) ));

		NSAssert([_activeInputs containsIndex:inputIndex]==YES, @"what?");
		[self _releaseChannel:inputIndex];
	} else {
		// set render callback
		AURenderCallbackStruct rcbs;
		rcbs.inputProc = &renderInput;
		rcbs.inputProcRefCon = sineDatas[inputIndex];
		
		// set the render callback for this bus
		RequireNoErr( AudioUnitSetProperty( _inputMixerUnits[mixerIndex], kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, mixerInIndex, &rcbs, sizeof(AURenderCallbackStruct) ));
		NSAssert([_activeInputs containsIndex:inputIndex]==NO, @"what?");
		[self _reserveChannel: inputIndex];
		// NOT USING THE INPUTS VOLUME CURRENTLY -- [self setInput:inputIndex volume:0.0f];
	}

#ifdef NSDEBUGENABLED
	// how many inputs do we have playing? Stop the graph if it is none
	if([self numberOfActiveInputs]==0 && self.isPlaying )
		[self _stopAudio];
#endif

}

- (void)setInput:(UInt8)inputIndex volume:(AudioUnitParameterValue)vol
{
	NSParameterAssert( inputIndex<MAX_INPUTS );
	NSAssert(_audioGraph!=0, @"graph not ready");
	// set the desired status
	NSUInteger mixerIndex, mixerInIndex;
	[self getMixerForInput:inputIndex mixer:&mixerIndex mixerInput:&mixerInIndex];
	RequireNoErr( AudioUnitSetParameter( _inputMixerUnits[mixerIndex], kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, mixerInIndex, vol, 0) );
}

- (AudioUnitParameterValue)volumeOfInput:(UInt8)inputIndex {
	
	// what is out current enabled Status?
	AudioUnitParameterValue currentVolume;
	NSUInteger mixerIndex, mixerInIndex;
	[self getMixerForInput:inputIndex mixer:&mixerIndex mixerInput:&mixerInIndex];
	RequireNoErr( AudioUnitGetParameter(  _inputMixerUnits[mixerIndex], kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, mixerInIndex, &currentVolume ));
	return currentVolume;
}

/* A load of 1.0 means it took as long to render as the duration of what you are rendering */
- (Float32)getCPULoad {

	Float32 cpuLoad, maxLoad;
	RequireNoErr( AUGraphGetCPULoad( _audioGraph, &cpuLoad ));
	RequireNoErr( AUGraphGetMaxCPULoad( _audioGraph, &maxLoad ));
	return maxLoad;
}

- (void)turnOnSine:(UInt8)inputIndex freq:(CGFloat)freq amp:(CGFloat)amplitude {

	NSParameterAssert(inputIndex<MAX_INPUTS);
	NSParameterAssert(amplitude>=0. && amplitude<=1.0);

	// convert freq from Hz to samplerate-adjusted freq
	CGFloat freqForSampleRate = freq * ((CGFloat)TWOPI/kGraphSampleRate);

	struct SineData *playingData = sineDatas[inputIndex];

	NSAssert1( G3DCompareFloat(playingData->amp, 0.0f, 0.00001f )==0, @"channel %i hmm, doesnt seem to have been cleaned up properly", inputIndex );
	playingData->freq = freqForSampleRate;
	playingData->phase = 0.0f;
	playingData->amp = 1.0f;	// This will be dezippered
	playingData->ampz = 0.0f;
	playingData->freqz = playingData->freq;
	playingData->status = NOTE_ATTACK;

	// calculate MAX_AMP, UPSLOPE, DOWNSLOPE based on the frequency
	// Here we decrease the volume linearly with frequence. Dont know how to do it logarthmically line between 2 points y = m(x-x1)+y1
	CGPoint p1 = CGPointMake(0.0f, 0.7f); 
	CGPoint p2 = CGPointMake(2000.0f, 0.3f);
	CGFloat m = (p2.y-p1.y)/(p2.x-p1.x);
	
	/* we need to make this a more sophisticated og curve */
	playingData->MAX_AMP_FOR_FREQ = amplitude;

	NSUInteger numberOfWavelengthsToFadeInOver = 50;
	CGFloat distanceWeMustFadeInOver = (kGraphSampleRate/freq) * numberOfWavelengthsToFadeInOver;
	CGFloat frequencyDependantUpSloap = playingData->MAX_AMP_FOR_FREQ / distanceWeMustFadeInOver;
	
	playingData->UP_SLOPE_FOR_FREQ = playingData->MAX_AMP_FOR_FREQ / (0.01f * kGraphSampleRate);
	playingData->UP_SLOPE_FOR_FREQ  = frequencyDependantUpSloap;

	// playingData->UP_SLOPE_FOR_FREQ = playingData->MAX_AMP_FOR_FREQ / (0.005f * kGraphSampleRate);
	playingData->DOWN_SLOPE_FOR_FREQ = playingData->MAX_AMP_FOR_FREQ / (0.005f * kGraphSampleRate);
	playingData->sustainDuration = 0.0f;
	playingData->MINIMUM_SUSTAIN_DURATION = kGraphSampleRate/17.0f;
	
	// Now we should be ready to set the callback, turn on the input, etc.
	[self setInput:inputIndex isEnabled:1.0f];
}

- (void)turnOffSine:(UInt8)inputIndex {

	NSParameterAssert(inputIndex<MAX_INPUTS);

	// commence fade out of volume - we must wait sufficient time for fade out to complete
	struct SineData *playingData = sineDatas[inputIndex];
	playingData->amp = 0.0f;
	playingData->status = NOTE_RELEASE;

//	CGFloat currentAmplitudeCheck = playingData->amp;
	//logInfo(@"Turning off inputIndex %i, current Vol = %f", inputIndex, (float)currentAmplitudeCheck );

	// -- turn off when we get to the end of the fade out - !nightmare to test!
	[self performSelector:@selector(_delayedTurnOff:) withObject:[NSNumber numberWithInt:inputIndex] afterDelay:0.3f]; // Ideally we would calculate this
}

/* callback from th runloop when hopefully we have allowed enough time to fade out */
- (void)_delayedTurnOff:(NSNumber *)inputIndex {

	UInt8 inIndex = [inputIndex unsignedIntValue];
	NSParameterAssert(inIndex<MAX_INPUTS);

	struct SineData *playingData = sineDatas[inIndex];
	if( playingData->status==NOTE_ENDED)
	{
		CGFloat currentAmplitudeCheck = playingData->amp;
		NSAssert( currentAmplitudeCheck<0.0001, @"We are turning off the channel before its volume faded to Zero" );
		
		[self setInput:inIndex isEnabled:0.0f];

		// clean up
		playingData->freq = 0.0f;
		playingData->freqz = 0.0f;
		playingData->amp = 0.0f;
		playingData->ampz = 0.0f;
		playingData->status = NOTE_FREE;
	} else {
		logWarning(@"Note not ready to turn off!");
		[self performSelector:@selector(_delayedTurnOff:) withObject:inputIndex afterDelay:0.1f]; // Ideally we would calculate this
	}
}

- (int)nextFreeChanel {

	int nextFreeChannel = -1;
	for(int i=0; i<MAX_INPUTS; i++){
		if( [_activeInputs containsIndex:i]==NO ){
			nextFreeChannel = i;
			break;
		}
	}
	return nextFreeChannel;
}

- (void)_reserveChannel:(UInt8)inputIndex {
	
	NSParameterAssert( inputIndex<MAX_INPUTS );
	NSAssert( [_activeInputs containsIndex:inputIndex]==NO, @"you fucked up");
	[_activeInputs addIndex:inputIndex];
}

- (void)_releaseChannel:(UInt8)inputIndex {

	NSParameterAssert( inputIndex<MAX_INPUTS );
	NSAssert( [_activeInputs containsIndex:inputIndex]==YES, @"you fucked up");
	[_activeInputs removeIndex:inputIndex];
}

- (void)getMixerForInput:(NSUInteger)inputIndex mixer:(NSUInteger *)mixerIndex mixerInput:(NSUInteger *)mixerInIndex {
	
	NSParameterAssert(inputIndex<MAX_INPUTS);

	*mixerIndex = inputIndex/INPUTS_PER_MIXER;
	*mixerInIndex = inputIndex%INPUTS_PER_MIXER;
}

@end
