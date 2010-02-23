//
//  SHCASpectralProcessorTests.m
//  AudioFileParser
//
//  Created by Steven Hooley on 24/12/2009.
//  Copyright 2009 Tinsal Parks. All rights reserved.
//
#import "CAAutoDisposer.h"
#import "SHCASpectralProcessor.h"

static UInt32 _callbackCount;

@interface SHCASpectralProcessorTests : SenTestCase {
	
	SHCASpectralProcessor *_mSpectralProcessor;
}

@end


@implementation SHCASpectralProcessorTests

- (void)setUp {
	
	UInt32 fftSize = 1024;				//1024
	UInt32 overlapBetweenFrames = fftSize>>1; //512
	UInt32 numberOfChannes = 1;
	UInt32 mMaxFramesPerSlice = 512;
	_mSpectralProcessor = new SHCASpectralProcessor( fftSize, overlapBetweenFrames, numberOfChannes, mMaxFramesPerSlice);
	
	_callbackCount = 0;
}

- (void)tearDown {
}

void callBackFunction(SpectralBufferList* inSpectra, void* inUserData) {

	UInt32 length = 512;
	
	SHCASpectralProcessor *sp = (SHCASpectralProcessor *)inUserData;
	Float32 *freqs_ptr = (Float32 *)calloc( length, sizeof(Float32));
	sp->GetFrequencies(freqs_ptr, 44100.0f);
  	free(freqs_ptr);
	
	AudioBufferList *bl_ptr = (AudioBufferList *)calloc(1, sizeof(AudioBufferList));
	bl_ptr->mNumberBuffers = 1;
	AudioBuffer *aBuf_ptr = bl_ptr->mBuffers;
	
	// generate some fake data
	Float32 *dataPtr = (Float32 *)calloc(length, sizeof(Float32));
	aBuf_ptr->mNumberChannels = 1;
	aBuf_ptr->mDataByteSize = sizeof(Float32)*length;
	aBuf_ptr->mData = dataPtr;
	

	Float32 min, max;
	sp->GetMagnitude( bl_ptr, &min, &max );
	
	free(aBuf_ptr);
	free(bl_ptr);
	free(dataPtr);
	
	_callbackCount++;
}

// _callbackCount is (size/512)-1
//   o o o
//   | | |
// |_|_|_|_|
//  1 2 3 4
- (void)testCallBackCount {
	
	UInt32 size = 3000;
	Float32 *dataPtr = (Float32 *)calloc(size, sizeof(Float32));
	AudioBufferList *inInput = (AudioBufferList *)calloc(1, sizeof(AudioBufferList));
	inInput->mNumberBuffers = 1;
	AudioBuffer *aBuf = inInput->mBuffers;

	aBuf->mNumberChannels=1;
    aBuf->mDataByteSize = size*sizeof(Float32);
    aBuf->mData = dataPtr;
	
	UInt32 inNumFrames = size;

	_mSpectralProcessor->SetSpectralFunction(&callBackFunction, _mSpectralProcessor);
	_mSpectralProcessor->ProcessForwards(inNumFrames, inInput);
	
	STAssertTrue(_callbackCount==(size/512)-1, @"what?");
	
	free(inInput);
	free(aBuf);
	free(dataPtr);
}

//1/10th of a second is 4410 bytes!
static Float32 *outputFreqs_ptr;
static Float32 *outputMags_ptr;

void callBackFunction_printFrequencies(SpectralBufferList* inSpectra, void* inUserData) {
		
	SHCASpectralProcessor *sp = (SHCASpectralProcessor *)inUserData;
	sp->GetFrequencies(outputFreqs_ptr, 44100.0f);	
}

- (void)testFrequencies {
	
	UInt32 size = 1024;
	Float32 *dataPtr = (Float32 *)calloc(size, sizeof(Float32));
	AudioBufferList *inInput = (AudioBufferList *)calloc(1, sizeof(AudioBufferList));
	inInput->mNumberBuffers = 1;
	AudioBuffer *aBuf = inInput->mBuffers;

	aBuf->mNumberChannels=1;
    aBuf->mDataByteSize = size*sizeof(Float32);
    aBuf->mData = dataPtr;
	
	UInt32 inNumFrames = size;

	_mSpectralProcessor->SetSpectralFunction(&callBackFunction_printFrequencies, _mSpectralProcessor);
	
	outputFreqs_ptr = (Float32 *)calloc( 512, sizeof(Float32));

	_mSpectralProcessor->ProcessForwards(inNumFrames, inInput);
//	0
//	43
//	86
//	129
//	172
//	215
//	258
//	301
//	344
//	387
//	430
//	...
//	3014
//	...
//	10292
//	for(int i=0;i<512;i++){
//		printf("Freq: %f\n",outputFreqs_ptr[i]);
//	}
  	free(outputFreqs_ptr);
	
	free(inInput);
	free(aBuf);
	free(dataPtr);
}

void callBackFunction_getMagnitudes(SpectralBufferList* inSpectra, void* inUserData) {
	
	UInt32 length = 512;

	SHCASpectralProcessor *sp = (SHCASpectralProcessor *)inUserData;

	AudioBufferList *bl_ptr = (AudioBufferList *)calloc(1, sizeof(AudioBufferList));
	bl_ptr->mNumberBuffers = 1;
	AudioBuffer *aBuf_ptr = bl_ptr->mBuffers;

	// generate some fake data
	aBuf_ptr->mNumberChannels = 1;
	aBuf_ptr->mDataByteSize = sizeof(Float32)*length;
	aBuf_ptr->mData = outputMags_ptr;


	Float32 min, max;
	sp->GetMagnitude( bl_ptr, &min, &max );
	sp->GetFrequencies( outputFreqs_ptr, 44100.0f);

	for(int i=0;i<512;i++){
		if(outputMags_ptr[i]>2.0f){
			printf("Freq: %f - ",outputFreqs_ptr[i]);
			printf("Amp: %f - \n",outputMags_ptr[i]);
		}
	}
	
	free(aBuf_ptr);
	free(bl_ptr);
	
	_callbackCount++;
}

const Float32 twopi = 2.0f * M_PI;

- (void)testFoundmagnitudes {
	
	UInt32 size = 2048;
	Float32 *dataPtr = (Float32 *)calloc(size, sizeof(Float32));
	// 2 blocks of 215
	Float32 phase = 0.f;
	Float32 freqHz = 215.f;
	double freqForSampleRate = freqHz * (twopi/44100.f);

	for(int i=0;i<1024;i++){
		dataPtr[i]=sinf(phase);
		phase += freqForSampleRate;
	}
	// 1 block of 0
	freqHz = 0.0f;
	freqForSampleRate = freqHz * (twopi/44100.f);
	for(int i=1024;i<1536;i++){
		dataPtr[i]=sinf(phase);
		phase += freqForSampleRate;
	}
	// 1 block of 430
	freqHz = 430.f;
	freqForSampleRate = freqHz * (twopi/44100.f);
	for(int i=1536;i<2048;i++){
		dataPtr[i]=sinf(phase);
		phase += freqForSampleRate;
	}
	AudioBufferList *inInput = (AudioBufferList *)calloc(1, sizeof(AudioBufferList));
	AudioBuffer *aBuf = inInput->mBuffers;
	aBuf->mNumberChannels=1;
    aBuf->mDataByteSize = size*sizeof(Float32);
    aBuf->mData = dataPtr;
	
	UInt32 inNumFrames = size;
	inInput->mNumberBuffers = 1;
	inInput->mBuffers[0] = *aBuf;
	_mSpectralProcessor->SetSpectralFunction( &callBackFunction_getMagnitudes, _mSpectralProcessor );
	
	outputFreqs_ptr = (Float32 *)calloc( 512, sizeof(Float32));
	outputMags_ptr = (Float32 *)calloc( 512, sizeof(Float32));
	
	_mSpectralProcessor->ProcessForwards(inNumFrames, inInput);
	
  	free(outputMags_ptr);
  	free(outputFreqs_ptr);
	
	free(inInput);
	free(aBuf);
	free(dataPtr);
}


@end
