//
//  CompareOouraFFTResults.m
//  AudioFileParser
//
//  Created by Steven Hooley on 27/09/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <vecLib/vecLib.h>
#include "SpectrumAnalysis.h"
#include "rad2fft.h"
#include <math.h>


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
	float freq = 10000 * 2. * 3.14159265359 / 44100;
	
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
	struct SPECTRUM_ANALYSIS *mSpectrumAnalysis = SpectrumAnalysisCreate(1024);
	UInt32 mAudioBufferSize = 1024 * sizeof(int32_t);
	int32_t *mAudioBuffer = (int32_t*)malloc(4096);
	int32_t* outFFTData = (int32_t*)malloc(mAudioBufferSize);

	for( UInt32 i=0; i<fftSize; i++ ) {
		// I think there may be a pi adjustment needed here
		mAudioBuffer[i] = (int)FloatToFixed((CGFloat)(testInData[i]*127.0f));
	}
	SpectrumAnalysisProcess(mSpectrumAnalysis, mAudioBuffer, outFFTData, true);		
	//			for(uint i = 0; i < p->size/2; ++i)
	//			{
	// (p->fftBuffer[i].real, p->fftBuffer[i].imag
 // }

/* Now lets compare some results */	
	for (UInt32 i=0; i<fftSizeOver2; i++ ) {

		UInt32 twoddle1 = mSpectrumAnalysis->fftBuffer[i].real;
		UInt32 twoddle2 = mSpectrumAnalysis->fftBuffer[i].imag;
		
	CGFloat hmm1 = (twoddle1 & 0xFF000000) >> 24;
	CGFloat hmm2 = (twoddle2 & 0xFF000000) >> 24;
	CGFloat hmm1f = (CGFloat)(hmm1 + 80) / 64.;
	CGFloat hmm2f = (CGFloat)(hmm2 + 80) / 64.;
		
		CGFloat fuckThis1 = (CGFloat)FixedToFloat(twoddle1);
		CGFloat fuckThis2 = (CGFloat)FixedToFloat(twoddle2);

//		CGFloat yFract = (CGFloat)i / (CGFloat)(fftSizeOver2 - 1);
//		CGFloat fftIdx = yFract * ((CGFloat)fftSizeOver2);
//		
//		double fftIdx_i, fftIdx_f;
//		fftIdx_f = modf(fftIdx, &fftIdx_i);
//		
//		CGFloat fft_l = (outFFTData[i] & 0xFF000000) >> 24;
//		CGFloat fft_r = (outFFTData[i + 1] & 0xFF000000) >> 24;
		
//		CGFloat fft_l_fl = (CGFloat)(fft_l + 80) / 64.;
//		CGFloat fft_r_fl = (CGFloat)(fft_r + 80) / 64.;
//		CGFloat interpVal = fft_l_fl * (1. - fftIdx_f) + fft_r_fl * fftIdx_f;
//		interpVal = interpVal *120;
		
//		double fftIdx_i;
//		float fftIdx_f = modf(i, &fftIdx_i);

//		float interpVal = fft_l_fl * (1. - i) + fft_r_fl * i;
	// 	interpVal = CLAMP(0., interpVal, 1.);
		
		float libVc1 = complexData->realp[i];
		float libVc2 = complexData->imagp[i];

		NSLog(@"%f %f -  %f %f", fuckThis1, fuckThis2, libVc1, libVc2 );
	}
}


@end
