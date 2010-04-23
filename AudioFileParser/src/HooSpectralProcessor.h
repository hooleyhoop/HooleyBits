//
//  HooSpectralProcessor.h
//  AudioFileParser
//
//  Created by steve hooley on 20/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <Accelerate/Accelerate.h>

struct HooSpectralChannel 
{
	Float32 *mInputBuf;			// log2ceil(FFT size + max frames)
	Float32 *mOutputBuf;		// log2ceil(FFT size + max frames)

	Float32 *mFFTBuf;			// the 1024 bytes into fft or 1024 bytes out of inverse FFt 
	
	Float32 *mSplitFFTBuf;		// FFT size
};

struct HooSpectralBufferList
{
	UInt32 mNumberSpectra;
	DSPSplitComplex mDSPSplitComplex[1];
};

@interface HooSpectralProcessor : NSObject {

	UInt32 mIOBufSize;
	UInt32 mInputPos;
	UInt32 mNumChannels;
	UInt32 mInputSize;
	UInt32 mIOMask;
	UInt32 mFFTSize;
	UInt32 mInFFTPos;
	UInt32 mFFTByteSize;
	UInt32 mHopSize;
	UInt32 mOutFFTPos;
	UInt32 mOutputPos;
	UInt32 mMaxFrames;
	UInt32 mLog2FFTSize;
	UInt32 mFFTMask;

	Float32 *mWindow;

	FFTSetup mFFTSetup;

	id _delegate;
	
	struct HooSpectralChannel *mChannels;
	struct HooSpectralBufferList *mSpectralBufferList;

}

@property (assign) id delegate;

- (id)init:(UInt32)inFFTSize :(UInt32)inHopSize :(UInt32)inNumChannels :(UInt32)inMaxFrames;

- (void)sineWindow;

- (void)process:(UInt32)inNumFrames :(AudioBufferList *)inInput :(AudioBufferList *)outOutput;
- (BOOL)processForwards:(UInt32)inNumFrames :(AudioBufferList *)inInput;
- (BOOL)processBackwards:(UInt32)inNumFrames :(AudioBufferList *)outOutput;
- (void)flushForward;

@end
