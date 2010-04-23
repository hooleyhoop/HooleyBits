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
#import <SHShared/SHShared.h>

@implementation SpectrumResults

// no retain when we add the autoreleasepool (would throw an exception)
const void *myPoolRetain( CFAllocatorRef allocator, const void *ptr ) {
    return ptr;
}

// however we do release when we remove the pools (balances alloc)
void myPoolRelease( CFAllocatorRef allocator, const void *ptr ) {
	
	struct HooSpectralBufferList *hoo_ptr = (struct HooSpectralBufferList *)ptr;
	for( NSUInteger i=0; i<hoo_ptr->mNumberSpectra; i++ )
	{
		free( hoo_ptr->mDSPSplitComplex[i].realp );
		free( hoo_ptr->mDSPSplitComplex[i].imagp );
	}
	free(hoo_ptr);
}

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
		
		// Custom dictionary to store spectra struct in - only using a dictionary because i dont know how to do similar(custom callbacks) for an array
		CFDictionaryValueCallBacks nonRetainingDictionaryValueCallbacks = kCFTypeDictionaryValueCallBacks;
		nonRetainingDictionaryValueCallbacks.retain = myPoolRetain;
		nonRetainingDictionaryValueCallbacks.release = myPoolRelease;		
		_spectraDict = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &nonRetainingDictionaryValueCallbacks );
	}
	return self;
}

- (void)dealloc {
	
	CFDictionaryRemoveAllValues(_spectraDict);
	CFRelease(_spectraDict);

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
	[_spectralProcessor flushForward];

}

- (void)_callback_complexOutput:(struct HooSpectralBufferList *)inSpectra {
	
//	-- save the spectrum data	
	struct HooSpectralBufferList *spectraCpy;
	spectraCpy = malloc( sizeof(*inSpectra) + (inSpectra->mNumberSpectra-1) * sizeof(inSpectra->mDSPSplitComplex[0]));
	spectraCpy->mNumberSpectra = inSpectra->mNumberSpectra;

	for( NSUInteger i=0; i<inSpectra->mNumberSpectra; i++ )
	{
		Float32 val1 = inSpectra->mDSPSplitComplex[i].realp[0];
		Float32 val2 = inSpectra->mDSPSplitComplex[i].imagp[0];
		
		float *realp_cpy = malloc( sizeof(Float32) * 513 );
		float *imagp_cpy = malloc( sizeof(Float32) * 513 );
		
		DSPSplitComplex *complexData = &(inSpectra->mDSPSplitComplex[i]);
		memcpy( realp_cpy, complexData->realp, 512*sizeof(Float32) );
		memcpy( imagp_cpy, complexData->imagp, 512*sizeof(Float32) );
		
		spectraCpy->mDSPSplitComplex[i].realp = realp_cpy;
		spectraCpy->mDSPSplitComplex[i].imagp = imagp_cpy;
		
		Float32 val3 = spectraCpy->mDSPSplitComplex[i].realp[0];
		Float32 val4 = spectraCpy->mDSPSplitComplex[i].imagp[0];
		
		NSAssert( G3DCompareFloat(val1, val3, 0.001f)==0, nil );
		NSAssert( G3DCompareFloat(val2, val4, 0.001f)==0, nil );
	}

	NSNumber *key = [NSNumber numberWithInteger:CFDictionaryGetCount(_spectraDict)];
	NSAssert( CFDictionaryGetCountOfKey(_spectraDict, key)==0, nil );
	CFDictionaryAddValue( _spectraDict, key, spectraCpy );
}

- (NSUInteger)frameCount {
	return CFDictionaryGetCount(_spectraDict);
}

@end
