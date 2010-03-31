//
//  main.m
//  FFT Explore
//
//  Created by Steven Hooley on 1/24/09.
//  Copyright Bestbefore 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <Accelerate/Accelerate.h>

#define Log2N 10u		// Base-two logarithm of number of elements.	:10
#define	N	(1u<<Log2N)	// Number of elements.							:1024
static const float_t TwoPi = 0x3.243f6a8885a308d313198a2e03707344ap1;

int main(int argc, char *argv[])
{	
	FFTSetup Setup = vDSP_create_fftsetup(Log2N, FFT_RADIX2);

	const vDSP_Stride Stride = 1;
	float *Signal = malloc(N * Stride * sizeof Signal);
	float *ObservedMemory = malloc(N * sizeof *ObservedMemory);
	DSPSplitComplex Observed = { ObservedMemory, ObservedMemory + N/2 };

	// Perform a real-to-complex FFT.
	
	// in 1024 samples the highest frequency wave has 512 peaks and 512 troughs. The lowest wave has haslf a wave length 1024 samples
	// lowest partial (1) fits in with 1/2 period, 
	// the second partial (2) fits in with 1 period, 
	// the third partial (3) fits in with 1 1/2 period asf. into the 1000 samples we are looking at.
	// we always get as many sine waves out as samples we put in

	// given 4800 samples - alternating peak/trough equal 24k so no mater what window size highest freq is always 24k (4 samples is 1 wave, 256 wavelengths is 1024 samples)
	// the lowest frequency will depend on window size
	// 12k (8 samples is 1 wave, 128 wavelengths is 1024 samples)
	// 6k (16 samples is 1 wave, 64 wavelengths is 1024 samples)
	// 3k (32 samples is 1 wave, 32 wavelengths is 1024 samples)
	// 1.5k (64 samples is 1 wave, 16 wavelengths is 1024 samples)
	// 750 (128 samples is 1 wave, 8 wavelengths is 1024 samples)
	// 375 (256 samples is 1 wave, 4 wavelengths is 1024 samples)
	// 187.5 (512 samples is 1 wave, 2 wavelengths is 1024 samples)
	// 93.75 (1024 samples is 1 wave, 1 wavelengths is 1024 samples)
	// 46.875 (1024 samples is 1/2 wave, 1/2 wavelengths is 1024 samples)

	// So, to reiterate - highest sinewave is always the same whatever window size, lowest sin wave depends on window size - we need a larger window to go lower

	const float Frequency0 = 79, Frequency1 = 296, Frequency2 = 143;
	const float Phase0 = 0, Phase1 = .2f, Phase2 = .6f;
	for (vDSP_Length i=0; i<N; ++i){
		Signal[i*Stride] =
		cos((i * Frequency0 / N + Phase0) * TwoPi)
		//+ cos((i * Frequency1 / N + Phase1) * TwoPi)
		//+ cos((i * Frequency2 / N + Phase2) * TwoPi);
		;
		NSLog(@"%f", Signal[i*Stride]);
	}
//	vDSP_fft_zrip(Setup, &Observed, Stride, Log2N, FFT_FORWARD);
	
	vDSP_destroy_fftsetup(Setup);
	free(ObservedMemory);

    return NSApplicationMain(argc,  (const char **) argv);
}
