//
//  BacwardsProcessTests.mm
//  AudioFileParser
//
//  Created by Steven Hooley on 23/01/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "BacwardsProcessTests.h"
#import <vecLib/vecLib.h>
#import "CABufferList.h"
#import "SHCASpectralProcessor.h"
#import "AudioFileParser.h"
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/ExtendedAudioFile.h>

static SHCASpectralProcessor *_mSpectralProcessor;

extern void muthaFuckingCallback( SpectralBufferList* inSpectra, void* inUserData );

@implementation BacwardsProcessTests

- (id)init {
	
	self = [super init];
	if(self){
		UInt32 fftSize = 1024;				//1024
		UInt32 overlapBetweenFrames =512;
		UInt32 numberOfChannes = 1;
		
		// This is a random guess
		UInt32 mMaxFramesPerSlice = 1024;
		
		_mSpectralProcessor = new SHCASpectralProcessor( fftSize, overlapBetweenFrames, numberOfChannes, mMaxFramesPerSlice);
		_mSpectralProcessor->SetSpectralFunction( &muthaFuckingCallback, (void *)self );

	}
	return self;
}

void muthaFuckingCallback( SpectralBufferList *inSpectra, void *inUserData ) {

	NSLog(@"fill in the spectral buffer list");
}

- (void)doBackwardsFFT {
	
	UInt32 inNumFrames = 1024;

	AudioBufferList *outputBufList = (AudioBufferList *)calloc(1, sizeof(AudioBufferList));
	outputBufList->mNumberBuffers = 1;	
	AudioBuffer *aBuf = outputBufList->mBuffers;
	aBuf->mNumberChannels=1;
	aBuf->mDataByteSize = inNumFrames*sizeof(Float32);
	Float32 *aSingleBlock =  (Float32 *)calloc(1024, sizeof(Float32));
	aBuf->mData = aSingleBlock;	
	
	//	bool success = _mSpectralProcessor->ProcessForwards(inFramesToProcess, inputBufList);
	/* Temporarily see what we get out */
//	_mSpectralProcessor->ProcessBackwards( inFramesToProcess, inputBufList, outputBufList );
	
	/* Fill outputBufList with the reverse FFT of what we put in muthaFuckingCallback */
	_mSpectralProcessor->ProcessBackwards( inNumFrames, outputBufList );

//	[self addDataToWriteFile:outputBufList :1024];
	
//	Float32 *mMinAmp = (Float32*) calloc(inputBufList->mNumberBuffers, sizeof(Float32));
//	Float32 *mMaxAmp = (Float32*) calloc(inputBufList->mNumberBuffers, sizeof(Float32));
	
	//hmm		CAStreamBasicDescription bufClientDesc;
	//hmm		bufClientDesc.SetCanonical(1, false);
	//hmm		CABufferList* mSpectralDataBufferList = CABufferList::New("temp buffer", bufClientDesc );
	
	// Compare the Output - Ok, totally different
	//	for(int i=0;i<1024;i++ ){
	//		AudioBuffer *buf1 =  inputBufList->mBuffers;
	//		Float32 *fbuf1 = (Float32 *)buf1->mData;
	//		AudioBuffer *buf2 =  outputBufList->mBuffers;
	//		Float32 *fbuf2 = (Float32 *)buf2->mData;
	//		Float32 f1 = fbuf1[i];
	//		Float32 f2 = fbuf2[i];
	//		printf("COMPARE OUTPUT %f, %f \n", f1, f2 );
	//	}
	
#define kMaxNumAnalysisFrames	1024
#define kMaxNumBins				1024
	//hmm		static const UInt64 kDefaultValue_BufferSize = kMaxNumAnalysisFrames*kMaxNumBins;
	//hmm		UInt32 frameLength = kDefaultValue_BufferSize*sizeof(Float32);
	//hmm		mSpectralDataBufferList->AllocateBuffers(frameLength);
	//hmm		AudioBufferList *sdBufferList = &mSpectralDataBufferList->GetModifiableBufferList();
	
	//		_mSpectralProcessor->GetMagnitude(sdBufferList, mMinAmp, mMaxAmp);
	
	//		Float32* freqs = (Float32*)calloc(1024, sizeof(Float32));
	//		_mSpectralProcessor->GetFrequencies(freqs, 44100.0f);
	//
	//		NSLog(@"what have we got? %f, %f", mMinAmp[0], mMaxAmp[1]);
	//		
	//		for (UInt32 i=0; i<kMaxNumBins; i++) {
	//			
	//			// Crashes AU...why, 'cause topFreq isn't malloc'ed correctly?
	//			// *topFreq = (Float32) sdBufferList->mBuffers[i].mData;
	//			Float32 freq =  freqs[i];
	//			AudioBuffer buff = sdBufferList->mBuffers[0];
	//			Float32 amp = (Float32)(((Float32 *)buff.mData)[i]);
	//			if(freq>1.0f)
	//				NSLog(@"freqs %f, %f", freq, amp);
	//		}
	
	
	// copy mNumBins of numbers out
	
	//	SampleTime s = (SampleTime) (mRenderStamp.mSampleTime);
	//	mSpectrumBuffer->Store(sdBufferList, 1, s);
	//	
	//	mRenderStamp.mSampleTime += 1; 
	
	free(aSingleBlock);
	free(outputBufList);
}

@end
