//
//  HooSpectralProcessor.m
//  AudioFileParser
//
//  Created by steve hooley on 20/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "HooSpectralProcessor.h"
#import <vecLib/vectorOps.h>
#import "CABitOperations.h"

@implementation HooSpectralProcessor

@synthesize delegate=_delegate;

// base 2 log of next power of two greater or equal to x
extern UInt32 Log2Ceil(UInt32 x);
extern UInt32 NextPowerOfTwo(UInt32 x);

- (id)init:(UInt32)inFFTSize :(UInt32)inHopSize :(UInt32)inNumChannels :(UInt32)inMaxFrames {

	self = [super init];
	if(self){
	
		mFFTSize = inFFTSize;
		mHopSize = inHopSize;
		mNumChannels = inNumChannels;
		mMaxFrames = inMaxFrames;
		
		mLog2FFTSize = Log2Ceil(mFFTSize);
		
		mFFTMask = mFFTSize - 1;
		mFFTByteSize = mFFTSize * sizeof(Float32);

		mIOBufSize = NextPowerOfTwo(mFFTSize+mMaxFrames);

		mIOMask = mIOBufSize-1;
		mInputSize = 0;
		mInputPos = 0; 
		mOutputPos = -mFFTSize & mIOMask;
		mInFFTPos = 0;
		mOutFFTPos = 0;
//		mSpectralFunction(0), 
//		mUserData(0)
//
		mWindow = calloc(mFFTSize, sizeof(Float32));
		[self sineWindow]; // set default window.
//		
		mChannels = calloc( mNumChannels, sizeof(struct HooSpectralChannel) );

		// allocate enough memory for our struct a la "http://stackoverflow.com/questions/2681983/core-audio-constructing-an-audiobufferlist-struct-q-about-c-struct-definition"
		NSUInteger test1 = sizeof(struct HooSpectralBufferList);
		NSUInteger test2 = sizeof *mSpectralBufferList;

		mSpectralBufferList = malloc( sizeof(struct HooSpectralBufferList) + (mNumChannels-1)*sizeof(mSpectralBufferList->mDSPSplitComplex[0]));
		mSpectralBufferList->mNumberSpectra = mNumChannels;
		
		for( UInt32 i=0; i<mNumChannels; ++i ) 
		{
			mChannels[i].mInputBuf = calloc( mIOBufSize, sizeof(Float32) );
			mChannels[i].mOutputBuf = calloc( mIOBufSize, sizeof(Float32) );

			mChannels[i].mFFTBuf= calloc( mFFTSize, sizeof(Float32) );
		
			mChannels[i].mSplitFFTBuf= calloc(mFFTSize, sizeof(Float32));
			
			mSpectralBufferList->mDSPSplitComplex[i].realp = mChannels[i].mSplitFFTBuf;
			mSpectralBufferList->mDSPSplitComplex[i].imagp = mChannels[i].mSplitFFTBuf + (mFFTSize >> 1);
		}
		NSAssert1( mLog2FFTSize==10, @"%i", mLog2FFTSize );
		mFFTSetup = vDSP_create_fftsetup( mLog2FFTSize, FFT_RADIX2 );		
	}
	return self;
}

- (void)dealloc {
	
	for( UInt32 i=0; i<mNumChannels; ++i ) 
	{
		free(mChannels[i].mInputBuf);
		free(mChannels[i].mOutputBuf);
		free(mChannels[i].mFFTBuf);
		free(mChannels[i].mSplitFFTBuf);
	}
	free(mChannels);
	free(mSpectralBufferList);
	free(mWindow);
	[super dealloc];
}

- (void)sineWindow {

	double w = pi / (double)(mFFTSize - 1);
	for( UInt32 i = 0; i < mFFTSize; ++i ) {
		mWindow[i] = (Float32)(sin(w * (double)i));
	}
}

- (void)copyInput:(UInt32)inNumFrames :(AudioBufferList *)inInput {
	
	UInt32 numBytes = inNumFrames * sizeof(Float32);
	UInt32 firstPart = mIOBufSize - mInputPos;
	
	if( firstPart < inNumFrames )
	{
		UInt32 firstPartBytes = firstPart * sizeof(Float32);
		UInt32 secondPartBytes = numBytes - firstPartBytes;
		for (UInt32 i=0; i<mNumChannels; ++i) {
			// fill to the end of the ring buffer?
			memcpy( mChannels[i].mInputBuf + mInputPos, inInput->mBuffers[i].mData, firstPartBytes );
			// fill the remainder to the end of the ringbuffer?
			memcpy( mChannels[i].mInputBuf, (UInt8 *)inInput->mBuffers[i].mData + firstPartBytes, secondPartBytes );
		}
	} else {
		UInt32 numBytes = inNumFrames * sizeof(Float32);
		for (UInt32 i=0; i<mNumChannels; ++i) {		
			memcpy( mChannels[i].mInputBuf + mInputPos, inInput->mBuffers[i].mData, numBytes);
		}
	}
	//printf("CopyInput %g %g\n", mChannels[0].mInputBuf[mInputPos], mChannels[0].mInputBuf[(mInputPos + 200) & mIOMask]);
	//printf("CopyInput mInputPos %lu   mIOBufSize %lu\n", mInputPos, mIOBufSize);
	mInputSize += inNumFrames;
	mInputPos = (mInputPos + inNumFrames) & mIOMask;
}

- (void)copyInputToFFT {

	UInt32 firstPart = mIOBufSize - mInFFTPos;
	UInt32 firstPartBytes = firstPart * sizeof(Float32);
	if( firstPartBytes < mFFTByteSize ) {
		UInt32 secondPartBytes = mFFTByteSize - firstPartBytes;
		for (UInt32 i=0; i<mNumChannels; ++i) {
			memcpy( mChannels[i].mFFTBuf, mChannels[i].mInputBuf + mInFFTPos, firstPartBytes );
			memcpy((UInt8*)mChannels[i].mFFTBuf+ firstPartBytes, mChannels[i].mInputBuf, secondPartBytes);
		}
	} else {
		for( UInt32 i=0; i<mNumChannels; ++i ) {
			memcpy( mChannels[i].mFFTBuf, mChannels[i].mInputBuf + mInFFTPos, mFFTByteSize);
		}
	}
	mInputSize -= mHopSize;
	mInFFTPos = (mInFFTPos + mHopSize) & mIOMask;
}

- (void)doWindowing {

	Float32 *win = mWindow;

	for( UInt32 i=0; i<mNumChannels; ++i ) {
		Float32 *x = mChannels[i].mFFTBuf;
		vDSP_vmul(x, 1, win, 1, x, 1, mFFTSize);
	}
	//printf("DoWindowing %g %g\n", mChannels[0].mFFTBuf()[0], mChannels[0].mFFTBuf()[200]);
}

- (void)doFwdFFT {

	vDSP_Length fftSizeOver2 = mFFTSize >> 1;
	for( UInt32 i=0; i<mNumChannels; ++i ) {
	
		// copy
		struct HooSpectralChannel inChannel = mChannels[i];
		DSPComplex *inputData = (DSPComplex *)inChannel.mFFTBuf;
		DSPSplitComplex *complexOutputData = &mSpectralBufferList->mDSPSplitComplex[i];
		vDSP_ctoz( inputData, (vDSP_Stride)2, complexOutputData, (vDSP_Stride)1, fftSizeOver2 );
		
		// fft
		vDSP_fft_zrip( mFFTSetup, complexOutputData, (vDSP_Stride)1, mLog2FFTSize, FFT_FORWARD );
	}
}

- (void)doInvFFT {

	//printf("->DoInvFFT %g %g\n", mChannels[0].mFFTBuf()[0], mChannels[0].mFFTBuf()[200]);
	UInt32 half = mFFTSize >> 1;
	for (UInt32 i=0; i<mNumChannels; ++i) 
	{
		vDSP_fft_zrip( mFFTSetup, &mSpectralBufferList->mDSPSplitComplex[i], 1, mLog2FFTSize, FFT_INVERSE );
		vDSP_ztoc( &mSpectralBufferList->mDSPSplitComplex[i], 1, (DSPComplex*)mChannels[i].mFFTBuf, 2, half );		
		float scale = 0.5f / mFFTSize;
		vDSP_vsmul( mChannels[i].mFFTBuf, 1, &scale, mChannels[i].mFFTBuf, 1, mFFTSize );
	}
	//printf("<-DoInvFFT %g %g\n", direction, mChannels[0].mFFTBuf()[0], mChannels[0].mFFTBuf()[200]);
}

- (void)overlapAddOutput {
	
	//printf("OverlapAddOutput mOutFFTPos %lu\n", mOutFFTPos);
	UInt32 firstPart = mIOBufSize - mOutFFTPos;
	if (firstPart < mFFTSize) {
		UInt32 secondPart = mFFTSize - firstPart;
		for (UInt32 i=0; i<mNumChannels; ++i) {
			float* out1 = mChannels[i].mOutputBuf + mOutFFTPos;
			vDSP_vadd(out1, 1, mChannels[i].mFFTBuf, 1, out1, 1, firstPart);
			float* out2 = mChannels[i].mOutputBuf;
			vDSP_vadd( out2, 1, mChannels[i].mFFTBuf + firstPart, 1, out2, 1, secondPart );
		}
	} else {
		for (UInt32 i=0; i<mNumChannels; ++i) {
			float* out1 = mChannels[i].mOutputBuf + mOutFFTPos;
			vDSP_vadd(out1, 1, mChannels[i].mFFTBuf, 1, out1, 1, mFFTSize);
		}
	}
	//printf("OverlapAddOutput %g %g\n", mChannels[0].mOutputBuf[mOutFFTPos], mChannels[0].mOutputBuf[(mOutFFTPos + 200) & mIOMask]);
	mOutFFTPos = (mOutFFTPos + mHopSize) & mIOMask;
}

- (void)copyOutput:(UInt32)inNumFrames :(AudioBufferList *)outOutput {
	
	//printf("->CopyOutput %g %g\n", mChannels[0].mOutputBuf[mOutputPos], mChannels[0].mOutputBuf[(mOutputPos + 200) & mIOMask]);
	//printf("CopyOutput mOutputPos %lu\n", mOutputPos);
	UInt32 numBytes = inNumFrames * sizeof(Float32);
	UInt32 firstPart = mIOBufSize - mOutputPos;
	if (firstPart < inNumFrames) {
		UInt32 firstPartBytes = firstPart * sizeof(Float32);
		UInt32 secondPartBytes = numBytes - firstPartBytes;
		for (UInt32 i=0; i<mNumChannels; ++i) {
			memcpy(outOutput->mBuffers[i].mData, mChannels[i].mOutputBuf + mOutputPos, firstPartBytes);
			memcpy((UInt8*)outOutput->mBuffers[i].mData + firstPartBytes, mChannels[i].mOutputBuf, secondPartBytes);
			memset(mChannels[i].mOutputBuf + mOutputPos, 0, firstPartBytes);
			memset(mChannels[i].mOutputBuf, 0, secondPartBytes);
		}
	} else {
		for (UInt32 i=0; i<mNumChannels; ++i) {
			memcpy(outOutput->mBuffers[i].mData, mChannels[i].mOutputBuf + mOutputPos, numBytes);
			memset(mChannels[i].mOutputBuf + mOutputPos, 0, numBytes);
		}
	}
	//printf("<-CopyOutput %g %g\n", ((Float32*)outOutput->mBuffers[0].mData)[0], ((Float32*)outOutput->mBuffers[0].mData)[200]);
	mOutputPos = (mOutputPos + inNumFrames) & mIOMask;
}

- (void)processSpectrum:(UInt32)inFFTSize :(struct HooSpectralBufferList *)inSpectra {

	[_delegate _callback_complexOutput:inSpectra];
}

- (BOOL)processForwards:(UInt32)inNumFrames :(AudioBufferList *)inInput {

	// copy from buffer list to input buffer
	[self copyInput:inNumFrames :inInput];
	
	BOOL processed = NO;
	// if enough input to process, then process.
	while (mInputSize >= mFFTSize) 
	{
		[self copyInputToFFT]; // copy from input buffer to fft buffer
		[self doWindowing];
		[self doFwdFFT];
		[self processSpectrum:mFFTSize :mSpectralBufferList];
	
		processed = YES;
	}
	
	return processed;
}

- (BOOL)processBackwards:(UInt32)inNumFrames :(AudioBufferList *)outOutput {		
	
	[self processSpectrum:mFFTSize :mSpectralBufferList];
	[self doInvFFT];
	[self doWindowing];
	[self overlapAddOutput];		
	
	// copy from output buffer to buffer list
	[self copyOutput:inNumFrames :outOutput];
	
	return YES;
}

- (void)process:(UInt32)inNumFrames :(AudioBufferList *)inInput :(AudioBufferList *)outOutput {
	
	// copy from buffer list to input buffer
	[self copyInput:inNumFrames :inInput];
	
	// if enough input to process, then process.
	while( mInputSize >= mFFTSize ) 
	{
		[self copyInputToFFT]; // copy from input buffer to fft buffer
		[self doWindowing];
		[self doFwdFFT];
		[self processSpectrum:mFFTSize :mSpectralBufferList];
		[self doInvFFT];
		[self doWindowing];
		[self overlapAddOutput];
	}
	
	// copy from output buffer to buffer list
	[self copyOutput:inNumFrames :outOutput];
}

@end
