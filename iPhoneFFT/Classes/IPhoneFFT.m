//
//  IPhoneFFT.m
//  iPhoneFFT
//
//  Created by Steven Hooley on 27/05/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "IPhoneFFT.h"
#import <AVFoundation/AVFoundation.h>
#import "MyWorkerClass.h"
#include <libkern/OSAtomic.h>
#import "OouraFFT.h"
#import "NSPortMessage.h"

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

@interface IPhoneFFT ()
	
	- (void)setUpInputRemoteIO;
	static OSStatus _input_callback( void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData );
	static OSStatus _output_callback( void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData );

	static OSStatus recordingCallback( void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData);
	- (void)setUpGraph;
	- (void)_beginRecording;
@end

#pragma mark -
@implementation IPhoneFFT


+ (AudioComponentDescription)inputDesc {
	
	AudioComponentDescription input_desc;
	input_desc.componentType = kAudioUnitType_Output;
	input_desc.componentSubType = kAudioUnitSubType_RemoteIO;
	input_desc.componentFlags = 0;
	input_desc.componentFlagsMask = 0;
	input_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	return input_desc;
}

+ (AudioComponentDescription)mixer_desc {
	
	AudioComponentDescription mixer_desc;
	mixer_desc.componentType = kAudioUnitType_Mixer;
	mixer_desc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
	mixer_desc.componentFlags = 0;
	mixer_desc.componentFlagsMask = 0;
	mixer_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	return mixer_desc;
}

- (void)beginRecording {

	_myFFT = [[OouraFFT alloc] initForSignalsOfLength:1024 andNumWindows:10];
	
	// single way
//	[self setUpInputRemoteIO];
	
	
	// Use an NSPort so the background thread can sen the main thread messages
    NSPort *myPort = [NSMachPort port];
	// This class handles incoming port messages.
	[myPort setDelegate:self];
	// Install the port as an input source on the current run loop.
	[[NSRunLoop currentRunLoop] addPort:myPort forMode:NSDefaultRunLoopMode];

	[self performSelectorInBackground:@selector(_processDataInBackground:) withObject:myPort];
	
	[self performSelectorInBackground:@selector(_mockCoreAudioThread:) withObject:myPort];

// GRAPH WAY
//	[self setUpGraph];
//	[self _beginRecording];
}

#pragma mark -
#pragma mark Background Thread Stuf
#define kCheckinMessage 100

// Handle responses from the worker thread. - port delegate method
- (void)handlePortMessage:(NSPortMessage *)portMessage {

    unsigned int message = [portMessage msgid];
    NSPort *distantPort = nil;
    if( message==kCheckinMessage ) {
        // Get the worker thread’s communications port.
        _distantPort = [[portMessage sendPort] retain];
    }
    else
    {
        // Handle other messages.
    }
}

- (void)_processDataInBackground:(NSPort *)inData {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// Set up the connection between this thread and the main thread.
    NSPort *distantPort = (NSPort *)inData;

	MyWorkerClass *workerOb = [[MyWorkerClass alloc] init];
	[workerOb sendCheckinMessage:distantPort];
	[distantPort release];
	
	BOOL moreWorkToDo = YES;
	BOOL exitNow = NO;
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	
	// Add the exitNow BOOL to the thread dictionary.
	NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
	[threadDict setValue:[NSNumber numberWithBool:exitNow] forKey:@"ThreadShouldExitNow"];
		
    while( moreWorkToDo && !exitNow )
    {
        // Do one chunk of a larger body of work here.
        // Change the value of the moreWorkToDo Boolean when done.
		// -- if more data is needed..
		if(_hasData==1) {
			
			/** DO FFT HERE **/
			@synchronized(self)
			{			
				// 2. Then fill up an array with data with your own function
				// fillUpInputSignalWithMyData( _myFFT.inputData );
			
				// 3. And then compute the FFT
				[_myFFT calculateWelchPeriodogramWithNewSignalSegment];
			
				// 4. ... then finally, plot the signal with your own function
				// doSomethingWithTheFrequencyData(myFFT.spectrumData)
				UInt32 half = 1024 >> 1;
				for (UInt32 i=0; i< half; i++){
					float freq = ((Float32)(i)/(Float32)1024)*44100.00;
					float data = 20. * log10f( (2.*_myFFT.spectrumData[i]) );
					if(data!=0)
						NSLog(@"freq %f\t - amp: %f", freq, data );
				}
				NSLog(@"ooh");
				// Repeat steps 2-4 for any new data you acquire
			
//	OouraFFT.spectrumData contains the frequencies in the signal you plopped into OouraFFT.inputData, then computed by 
//	calling calculateWelchPeriodogramWithNewSignalSegment.
//	Now, which frequencies correspond to which entries in the array?
//	Say your signal has a sampling rate of 48,000 Hz, and you are computing the FFT on chunks of your signal 1024 samples 
//	long. Then, OouraFFT.spectrumData has 1024/2 = 512 frequencies in it, evenly spaced between 0 and 48,000/2 = 24,000.
//
//	So, for 0 < i < OouraFFT.numFrequencies,
//	spectrumData[i] holds data for (i*samplingRate)/(2*numFrequencies)
			}

			//-- set more data needed
			OSAtomicDecrement32(&_hasData);
		}
		
        // Run the run loop but timeout immediately if the input source isn't waiting to fire.
        [runLoop runUntilDate:[NSDate date]];
		
        // Check to see if an input source handler changed the exitNow value.
        exitNow = [[threadDict valueForKey:@"ThreadShouldExitNow"] boolValue];
    }
	[workerOb release];
	[pool release];
}

- (void)_mockCoreAudioThread:(NSPort *)inData {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Set up the connection between this thread and the main thread.
    NSPort *distantPort = (NSPort *)inData;
	[distantPort release];
	
	BOOL moreWorkToDo = YES;
	BOOL exitNow = NO;
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	
	// Add the exitNow BOOL to the thread dictionary.
	NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
	[threadDict setValue:[NSNumber numberWithBool:exitNow] forKey:@"ThreadShouldExitNow"];
	
    while( moreWorkToDo && !exitNow )
    {
        // Do one chunk of a larger body of work here.
        // Change the value of the moreWorkToDo Boolean when done.
		float *mockAudioData = malloc(sizeof(float)*1024);
		double phase =0;
		double freq = 1000 * 2. * 3.14159265359 / 44100;

		// generate a wave between -1.0f and 1.0f
		for (NSUInteger i=0; i<1024; i++) {
			float wave = sin(phase);			// generate sine wave
			phase = phase + freq;				// increment phase
			mockAudioData[i] = wave;
			// NSLog(@"%f", wave);
		}
		
		// -- if more data is needed..
		if(_hasData==0) {
			//-- copy audio data to shared memory
			NSLog(@"Writing new memory");

			// 2. Then fill up an array with data with your own function
			memcpy(_myFFT.inputData, mockAudioData, 1024);

			//-- set more data not needed
			OSAtomicIncrement32(&_hasData);
		} else {
			NSLog(@"__");
		}

				
		free(mockAudioData);
	
        // Run the run loop but timeout immediately if the input source isn't waiting to fire.
        [runLoop runUntilDate:[NSDate date]];
		
        // Check to see if an input source handler changed the exitNow value.
        exitNow = [[threadDict valueForKey:@"ThreadShouldExitNow"] boolValue];
		sleep(0.03);
    }
	[pool release];
}

#pragma mark -

void _tweakInputStreamDesc( AudioStreamBasicDescription *desc, AudioUnit *unit ) {
	
	UInt32 inputStream_desc_size = sizeof(*desc);

	// CONFIGURE INPUT FORMAT
	// get the current input stream format
	RequireNoErr( AudioUnitGetProperty( *unit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 1,desc, &inputStream_desc_size ));

	// tweak it to what we want and set it
	// mixer_input_desc.mChannelsPerFrame = 1;
	desc->mSampleRate			= 44100.00;
	desc->mFormatID				= kAudioFormatLinearPCM;
	desc->mFormatFlags			= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked; // 1100
	desc->mFramesPerPacket		= 1;
	desc->mChannelsPerFrame		= 1;
	desc->mBitsPerChannel		= 16;
	desc->mBytesPerPacket		= 2;
	desc->mBytesPerFrame		= 2;
	

	// ARggg! which one here?
	RequireNoErr( AudioUnitSetProperty( *unit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, desc, inputStream_desc_size ));
	RequireNoErr( AudioUnitSetProperty( *unit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, desc, inputStream_desc_size ));
}

#pragma mark -
#pragma mark Single RemoteIO way
- (void)setUpInputRemoteIO {

	AudioComponentDescription input_desc = [IPhoneFFT inputDesc];
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &input_desc);

	RequireNoErr(AudioComponentInstanceNew(inputComponent, &_inputRemoteIOUnit));
	// Enable IO for recording
	UInt32 flag = 1;
	RequireNoErr(AudioUnitSetProperty(_inputRemoteIOUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input,  1, &flag, sizeof(flag)));
	// Enable IO for playback
	RequireNoErr(AudioUnitSetProperty(_inputRemoteIOUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &flag,  sizeof(flag)));
				 
	// set input stream format
	AudioStreamBasicDescription inputStream_desc;
	_tweakInputStreamDesc( &inputStream_desc, &_inputRemoteIOUnit );
				 
	// set input callback
	AURenderCallbackStruct rcbs1;
	rcbs1.inputProc = &_input_callback;
	rcbs1.inputProcRefCon = self;
	
//	RequireNoErr(AudioUnitSetProperty( _inputRemoteIOUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 1, &rcbs1, sizeof(rcbs1)));
	
	// Set output callback
	AURenderCallbackStruct rcbs2;
	rcbs2.inputProc = _output_callback;
	rcbs2.inputProcRefCon = self;
	RequireNoErr( AudioUnitSetProperty( _inputRemoteIOUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, 0, &rcbs2, sizeof(rcbs2)));
	
	// TODO: Allocate our own buffers if we want
	
	RequireNoErr( AudioUnitInitialize(_inputRemoteIOUnit));
	RequireNoErr( AudioOutputUnitStart(_inputRemoteIOUnit));

}

- (void)stopInput {
//	RequireNoErr( AudioOutputUnitStop(audioUnit));
	
// when finished
//	RequireNoErr( AudioUnitUninitialize(audioUnit));
}

#pragma mark -
#pragma mark Graph Method
- (void)setUpGraph {
	
	RequireNoErr( NewAUGraph(&_audioGraph) );
	
	// Describe audio components
	AudioComponentDescription input_desc = [IPhoneFFT inputDesc];
	AudioComponentDescription mixer_desc = [IPhoneFFT mixer_desc];

	// see http://www.subfurther.com/blog/?p=507

	//                          -------------------------
	//                          | i                   o |
	// -- BUS 1 -- from mic --> | n    REMOTE I/O     u | -- BUS 1 -- to app -->
	//                          | p      AUDIO        t |
	// -- BUS 0 -- from app --> | u       UNIT        p | -- BUS 0 -- to speaker -->
	//                          | t                   u |
	//                          |                     t |
	//                          -------------------------	

	// Input Scope:0 Set ASBD to indicate what you’re providing for play-out
	// Input Scope:1 Get ASBD to inspect audio format being received from H/W

	// Output Scope:0	 Get ASBD to inspect audio format being sent to H/W		
	// Output Scope:1	 Set ASBD to indicate what format you want your units to receive	
	

	// add the iphone output node to the graph
	RequireNoErr( AUGraphAddNode( _audioGraph, &input_desc, &_inputNode1));

	// add the shitty iphone mixer
	RequireNoErr( AUGraphAddNode( _audioGraph, &mixer_desc, &_mixerNode ));
	
	// Connect our Input to our Mixer
	// We connect busses
	// busses can have any number of channels
	// some units have fixed number of output busses - some can be configured - the ones we are dealing with here are fixed	
	RequireNoErr( AUGraphConnectNodeInput( _audioGraph, _inputNode1, 1, _mixerNode, 0 ));

	// Initialize late but open as soon as you can, stuff (AUGraphNodeInfo) wont work if graph isnt open
	RequireNoErr( AUGraphOpen(_audioGraph));
	
	// Obtain a reference to the IOUnit
	RequireNoErr( AUGraphNodeInfo(_audioGraph, _inputNode1, NULL, &_inputUnit1  ));

	// Configure Input

	// Enable IO for recording
	UInt32 flag = 1;
	RequireNoErr( AudioUnitSetProperty( _inputUnit1, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &flag, sizeof(flag) ));
//	RequireNoErr( AudioUnitSetProperty( _inputUnit1, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 1, &flag, sizeof(flag)));	
	
	//  - assert that the _inputUnit has 2 input busses
//	UInt32 currentInBusCount;
//	UInt32 propSize = sizeof(currentInBusCount);
//	RequireNoErr( AudioUnitGetProperty( _inputUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &currentInBusCount, &propSize));
//
//	//  - assert that the _inputUnit has 2 output bus
//	UInt32 currentOutBusCount;
//	propSize = sizeof(currentOutBusCount);
//	RequireNoErr( AudioUnitGetProperty( _inputUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Output, 0, &currentOutBusCount, &propSize));

	
	
	// set input stream format
	AudioStreamBasicDescription inputStream_desc;
	_tweakInputStreamDesc( &inputStream_desc, &_inputUnit1 );

	// check
	//RequireNoErr( AudioUnitGetProperty( _inputUnit1, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 1, &inputStream_desc, &inputStream_desc_size ));


	// CONFIGURE OUTPUT FORMAT
	// RequireNoErr( AudioUnitGetProperty( _inputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, kInputBus, &inputStream_desc, &inputStream_desc_size ));
	// tweak
	// RequireNoErr( AudioUnitSetProperty( _inputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, kInputBus, &inputStream_desc, inputStream_desc_size ));	

	// static AudioDeviceID InputDeviceID;
	// status = AudioUnitSetProperty( _inputUnit, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0, &InputDeviceID, sizeof(InputDeviceID));
	
	
	// NOW that we've set everything up we can initialize the graph 
	// (which will also validate the connections)
	RequireNoErr( AUGraphInitialize(_audioGraph) );
}

- (void)_beginRecording {
	
//	AudioUnitParameterValue initialStatus = 0.0f;
//	RequireNoErr( AudioUnitSetParameter( _inputMixerUnits[j], kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, i, initialStatus, 0) );
//	// Just a check
//	AudioUnitParameterValue currentStatus=-99;
//	RequireNoErr( AudioUnitGetParameter( _inputMixerUnits[j], kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, i, &currentStatus ));
//	NSAssert(G3DCompareFloat(currentStatus, 0.0f, 0.001f)==0, @"why no work?");
	
	// set render callback
	AURenderCallbackStruct rcbs;
	rcbs.inputProc = &recordingCallback;
	rcbs.inputProcRefCon = self;
	
	// set the render callback for this bus
//	RequireNoErr( AudioUnitSetProperty( _inputUnit,  , kAudioUnitScope_Output, kInputBus, &rcbs, sizeof(AURenderCallbackStruct) ));
//	RequireNoErr( AudioUnitSetProperty( _inputUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Input, kOutputBus, &rcbs, sizeof(AURenderCallbackStruct) ));
//	RequireNoErr( AudioUnitSetProperty( _inputUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, kOutputBus, &rcbs, sizeof(AURenderCallbackStruct) ));

	
	// Register a callback with the AUNode
	RequireNoErr( AUGraphSetNodeInputCallback( _audioGraph, _mixerNode, 1, &rcbs ));
	

	// Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
	// UInt32 flag = 0;
	// RequireNoErr( AudioUnitSetProperty( _inputUnit, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Output, kInputBus, &flag, sizeof(flag)));
	
	/* This will fail if no mic attached. There must be a way to test this before we get this far? */
	RequireNoErr( AUGraphStart(_audioGraph) );

}

#pragma mark -
#pragma mark Callbacks
static OSStatus _input_callback( void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData ) {
	NSLog(@"got r_input_callback");
	
	IPhoneFFT *self = (IPhoneFFT *)inRefCon;
	AudioBufferList *bufferList;
	
    OSStatus status;

	// very un thread safe way to access _inputRemoteIOUnit
	status = AudioUnitRender( self->_inputRemoteIOUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, bufferList);
	return status;
}

static OSStatus _output_callback( void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData ) {

	if(ioData)
	{
		static int firstRun = 0;
		if(firstRun==0){
			NSLog(@"got rendering callback");
			firstRun = 1;
		}
		IPhoneFFT *self = (IPhoneFFT *)inRefCon;
		// OSStatus err = AudioUnitRender( self->_inputUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData );
		
		NSCAssert( ioData->mNumberBuffers==1, @"sheeeet" );
		AudioBuffer ab = ioData->mBuffers[0]; // this is a variable length array of mNumberBuffers elements
		void* mData = ab.mData;	
		
		Fixed *outA = (Fixed *)ioData->mBuffers[0].mData;
		for( NSUInteger i=0; i<inNumberFrames; ++i ){
			Fixed val = outA[i];
			//float val = ((float *)mData)[i];
			if(FixedToFloat(val)!=0)
				NSLog(@"sample is %f", FixedToFloat(val) );
		}
	}

    return noErr;	
}

				 
// http://lists.apple.com/archives/coreaudio-api/2009/Apr/msg00129.html

static OSStatus recordingCallback( void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData ) {

	if(ioData)
	{
		static int firstRun = 0;
		if(firstRun==0){
			NSLog(@"got rendering callback");
			firstRun = 1;
		}
		IPhoneFFT *self = (IPhoneFFT *)inRefCon;

		NSCAssert( ioData->mNumberBuffers==1, @"sheeeet" );
		AudioBuffer ab = ioData->mBuffers[0]; // this is a variable length array of mNumberBuffers elements
		void* mData = ab.mData;	
		
	Fixed *outA = (Fixed *)ioData->mBuffers[0].mData;
	for( NSUInteger i=0; i<inNumberFrames; ++i ){
		Fixed val = outA[i];
		//float val = ((float *)mData)[i];
		if(FixedToFloat(val)!=0)
			NSLog(@"sample is %f", FixedToFloat(val) );
	}
	}
    // TODO: Use inRefCon to access our interface object to do stuff
    // Then, use inNumberFrames to figure out how much data is available, and make
    // that much space available in buffers in an AudioBufferList.
	
//    AudioBufferList *bufferList; // <- Fill this up with buffers (you will want to malloc it, as it's a dynamic-length list)
//	
//    // Then:
//    // Obtain recorded samples
//	
//    OSStatus status;
//	
//    status = AudioUnitRender( [audioInterface audioUnit], ioActionFlags, inTimeStamp, nBusNumber, inNumberFrames, bufferList);
//    checkStatus(status);
//	
//    // Now, we have the samples we just read sitting in buffers in bufferList
//    DoStuffWithTheRecordedAudio(bufferList);

    return noErr;
}

// Update: You can adjust the latency of RemoteIO (and, in fact, any other audio framework) by setting the kAudioSessionProperty_PreferredHardwareIOBufferDuration property:
//
// float aBufferLength = 0.005; // In seconds
// AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(aBufferLength), &aBufferLength);
// This adjusts the length of buffers that’re passed to you – if buffer length was originally, say, 1024 samples, then halving the number of samples halves the amount of time taken to process them.


@end
