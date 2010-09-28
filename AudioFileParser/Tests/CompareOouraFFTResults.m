//
//  CompareOouraFFTResults.m
//  AudioFileParser
//
//  Created by Steven Hooley on 27/09/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <vecLib/vecLib.h>
#include "SpectrumAnalysis.h"


@interface CompareOouraFFTResults : SenTestCase {
	
}

@end


@implementation CompareOouraFFTResults



// Run OouraFFT side by side with acceslerated fft and compare results
- (void)testOooura1DFFT {
	
	// spoof some input data
	UInt32 fftSize = 1024;
	UInt32 fftSizeOver2 = 512;
	UInt32 overlapBetweenFrames = 512;
	UInt32 numberOfChannes = 1;
	UInt32 mMaxFramesPerSlice = 1024;
	UInt32 numberOfResults = fftSizeOver2+1;
	vDSP_Length mLog2FFTSize = 10; // (2^10 == 1024 ) 

	Float32 *testInData = (Float32 *)calloc( fftSize, sizeof( Float32 ) );	
	float phase =0;
	float freq = 1000 * 2. * 3.14159265359 / 44100;
	
	for( UInt32 i=0; i<fftSize; i++ ) {
		float wave = sinf(phase);			// generate sine wave
		phase = phase + freq;				// increment phase
		testInData[i] = wave;
	}
	
/* Do it the VectorLib way */	
	// reusable twiddle values
	FFTSetup mFFTSetup = vDSP_create_fftsetup( mLog2FFTSize, FFT_RADIX2 );
	
	// A real array A = {A[0],...,A[n]} must be transformed into an even-odd array AEvenOdd = {A[0],A[2],...,A[n-1],A[1],A[3],...A[n]} by means of the call vDSP_ctoz
	DSPSplitComplex *complexData = (DSPSplitComplex *)calloc( 1, sizeof( DSPSplitComplex ) );
	
	//NB, we get fftSizeOver2+1 results, packed into fftSizeOver2 slots. The last is empty. We unpack it ourselfs and repack it before Inverse FFT
	complexData->realp = (float *)calloc( numberOfResults, sizeof( float ) );
    complexData->imagp = (float *)calloc( numberOfResults, sizeof( float ) );
	vDSP_ctoz( (DSPComplex *)testInData, (vDSP_Stride)2, complexData, (vDSP_Stride)1, (vDSP_Length)fftSizeOver2 ); // input is now even odd

	// Do Forward FFT
	vDSP_fft_zrip( mFFTSetup, complexData, (vDSP_Stride)1, mLog2FFTSize, FFT_FORWARD );
	
	// unpack the data we have 513 complex values packed into 512 value
	// complexData->realp[fftSizeOver2] = complexData->imagp[0];
	// complexData->imagp[0] = 0;
	
/* Do it the OouraFFT way */
	H_SPECTRUM_ANALYSIS mSpectrumAnalysis = SpectrumAnalysisCreate(1024);
	UInt32 mAudioBufferSize = 1024 * sizeof(int32_t);
	int32_t *mAudioBuffer = (int32_t*)malloc(mAudioBufferSize);
	int32_t* outFFTData = (int32_t*)malloc(mAudioBufferSize);

	for( UInt32 i=0; i<fftSize; i++ ) {
		// I think there may be a pi adjustment needed here
		mAudioBuffer[i] = FloatToFixed((CGFloat)(testInData[i]*127.0f));
	}
	SpectrumAnalysisProcess(mSpectrumAnalysis, mAudioBuffer, outFFTData, true);		
	
	
/* Now lets compare some results */	
	for (UInt32 i=0; i<fftSizeOver2; i++ ) {
//		int ooVal1 = outFFTData[i];
//		int ooVal2 = outFFTData[i*2+1];

		float hmm1 = FixedToFloat(outFFTData[(int)i]);
		float hmm2 = FixedToFloat(outFFTData[(int)i + 1]);
		
		float fft_l = (outFFTData[(int)i] & 0xFF000000) >> 24;
		float fft_r = (outFFTData[(int)i + 1] & 0xFF000000) >> 24;
		float fft_l_fl = (CGFloat)(fft_l + 80) / 64.;
		float fft_r_fl = (CGFloat)(fft_r + 80) / 64.;
		double fftIdx_i;
		float fftIdx_f = modf(i, &fftIdx_i);

		float interpVal = fft_l_fl * (1. - i) + fft_r_fl * i;
	// 	interpVal = CLAMP(0., interpVal, 1.);
		
		float libVc1 = complexData->realp[i];
		float libVc2 = complexData->imagp[i];

		NSLog(@"%f -  %f %f", hmm1, libVc1, libVc2 );
	}
}


@end
