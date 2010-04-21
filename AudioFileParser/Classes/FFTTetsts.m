//
//  FFTTetsts.m
//  AudioFileParser
//
//  Created by steve hooley on 10/02/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <vecLib/vecLib.h>

@interface FFTTetsts : SenTestCase {
	
}

@end

@implementation FFTTetsts

- (void)setUp {
	
}

- (void)tearDown {
	
}

//	8 * 8 image
//	do each row at a time
//	we now have eight rows of 5 complex values
//	now fft each column. how do we do this shit face? pad it out?

- (void)test2DFFT {

	UInt32 cols = 32; // 2*2*2*2*2 *2*2*2*2*2
	UInt32 rows = 32;
	UInt32 numberOfPixels = cols*rows;
	vDSP_Length mLog2FFTSizeRow = 5; // (2^5 == rows ) // 2 is min : 10 is max
	vDSP_Length mLog2FFTSizeCol = 5; // (2^5 == cols ) // 2 is min : 10 is max
	UInt32 fftSizeOver2 = numberOfPixels/2;

	// spoof some input data
	float *myData = (float *)calloc( numberOfPixels, sizeof( float ) );
	float *myInverseOuputData = (float *)calloc( numberOfPixels, sizeof( float ) );
	
	for( UInt32 i=0; i<numberOfPixels; i++ ) {
		myData[i] = i;
	}
	
	FFTSetup setup = vDSP_create_fftsetup( mLog2FFTSizeRow, FFT_RADIX2 ); // make sure you use the largest - mLog2FFTSizeRow or mLog2FFTSizeCol

	// Forward FFT
	DSPSplitComplex *complexData = (DSPSplitComplex *)calloc( 1, sizeof( DSPSplitComplex ) );
	// fftSizeOver2+1 results are packed into a square fftSizeOver2 array - i will unpack the last row and column manually after
	complexData->realp = (float *)calloc( fftSizeOver2, sizeof( float ) );
    complexData->imagp = (float *)calloc( fftSizeOver2, sizeof( float ) );
	
	vDSP_ctoz( (DSPComplex *)myData, (vDSP_Stride)2, complexData, (vDSP_Stride)1, (vDSP_Length)fftSizeOver2 ); // input is now even odd
	vDSP_fft2d_zrip( setup, complexData, (vDSP_Stride)1, (vDSP_Stride)0, (vDSP_Length)mLog2FFTSizeCol, (vDSP_Length)mLog2FFTSizeRow, FFT_FORWARD );
	
	// unpack the data - last imagines and first imagins dont exist
	//		col col col
	//		|	|	|
	// row ---
	// row ---
	// row --
	// [0][1] = 0
//http://developer.apple.com/hardwaredrivers/ve/downloads/vDSP_Library.pdf
	
	
//	for( UInt32 i=0; i<fftSizeOver2+1; i++ ) {
//		float freq = ((Float32)(i)/(Float32)1024)*44100;	
//		NSLog(@"freq %f: %f - %f : Mag. %f", freq, complexData->realp[i], complexData->imagp[i], 0 );
//	}
	

	
	
	// Inverse FFT
	// pack the data
	
	// do the fft
	vDSP_fft2d_zrip( setup, complexData, (vDSP_Stride)1, (vDSP_Stride)0,  (vDSP_Length)mLog2FFTSizeCol, (vDSP_Length)mLog2FFTSizeRow, FFT_INVERSE );

	// interleave the complex values into 1 array which should now be the same as the original but 2048(?)
    vDSP_ztoc( complexData, 1, (DSPComplex *)myInverseOuputData, 2, fftSizeOver2 );

	// compare with original
	for( UInt32 i=0; i<numberOfPixels; i++ ) {
		NSLog(@"Output %f ", myInverseOuputData[i]/2048 );
	}
	
	
	vDSP_destroy_fftsetup(setup);
	free(myData);
	free(myInverseOuputData);
	free(complexData);
}

- (void)test1DFFT {
	
	UInt32 fftSize = 1024;
	UInt32 fftSizeOver2 = 512;
	UInt32 overlapBetweenFrames = 512;
	UInt32 numberOfChannes = 1;
	UInt32 mMaxFramesPerSlice = 1024;
	UInt32 numberOfResults = fftSizeOver2+1;

	vDSP_Length mLog2FFTSize = 10; // (2^10 == 1024 ) 

	// spoof some input data
	float *myData = (float *)calloc( fftSize, sizeof( float ) );
	float *myInverseOuputData = (float *)calloc( fftSize, sizeof( float ) );

	for( UInt32 i=0; i<fftSize; i++ ) {
		float evenOdd = i & 1;
		if(evenOdd==0)
			evenOdd = -1.0f;
		myData[i] = 1*evenOdd;
	}
	
	// reusable twiddle values
	FFTSetup mFFTSetup = vDSP_create_fftsetup( mLog2FFTSize, FFT_RADIX2 );

	// A real array A = {A[0],...,A[n]} must be transformed into an even-odd array AEvenOdd = {A[0],A[2],...,A[n-1],A[1],A[3],...A[n]} by means of the call vDSP_ctoz
	DSPSplitComplex *complexData = (DSPSplitComplex *)calloc( 1, sizeof( DSPSplitComplex ) );
	
	//NB, we get fftSizeOver2+1 results, packed into fftSizeOver2 slots. The last is empty. We unpack it ourselfs and repack it before Inverse FFT
	complexData->realp = (float *)calloc( numberOfResults, sizeof( float ) );
    complexData->imagp = (float *)calloc( numberOfResults, sizeof( float ) );
	vDSP_ctoz( (DSPComplex *)myData, (vDSP_Stride)2, complexData, (vDSP_Stride)1, (vDSP_Length)fftSizeOver2 ); // input is now even odd

	// Do Forward FFT
	vDSP_fft_zrip( mFFTSetup, complexData, (vDSP_Stride)1, mLog2FFTSize, FFT_FORWARD );

	// unpack the data we have 513 complex values packed into 512 value
	complexData->realp[fftSizeOver2] = complexData->imagp[0];
	complexData->imagp[0] = 0;

	/*  values are between -2048 - +2048. scale it by  2n. */
	BOOL _shouldScale = NO;
    float scale;
	if(_shouldScale){
		float scale = (float) 1.0 / (2 * fftSize);
		vDSP_vsmul( complexData->realp, 1, &scale, complexData->realp, 1, numberOfResults );
		vDSP_vsmul( complexData->imagp, 1, &scale, complexData->imagp, 1, numberOfResults );
	} else {
		scale = 1;
	}
	float maxComplexValue = 2 * fftSize * scale;

	// magnitude test
	float maxMag = sqrtf( maxComplexValue*maxComplexValue + maxComplexValue*maxComplexValue ); // 2048 = 2896.309326, 1 = 1.4142
	
	// calculate magnitudes 0 - 2048 (sqrt(sin^2+cos^2))
	float *outputMags = (float *)calloc( numberOfResults, sizeof(float));
	vDSP_zvabs( complexData, (vDSP_Stride)1, outputMags, (vDSP_Stride)1, (vDSP_Length)numberOfResults ); 		

	// values -2048 - +2048 ?

	// complexData is now packed wierdly - 513 - (YES! fftSizeOver2 + 1)  COMPLEX value (real, imaginary)
	// The first and last imaginary values are always 0! So the last REAL value is in imaginary[0] - cunt!
	for( UInt32 i=0; i<numberOfResults; i++ ) {
		float freq = ((Float32)(i)/(Float32)1024)*44100;
		//	float magnitude_OfUnscaled_1 = 20. * log10( 2. * sqrt(lastReal*lastReal+lastImag*lastImag)/(float)1024.0f);
		//	float magnitude_OfUnscaled_2 = 20. * log10( 2. * sqrt(lastReal*lastReal+lastImag*lastImag))/(float)1024.0f;
		// float phase = 180.f * atan2f( lastReal, lastImag ) / (float)M_PI - 90.f;
		NSLog(@"freq %f: %f - %f : Mag. %f", freq, complexData->realp[i], complexData->imagp[i], outputMags[i] );
	}


	/*
	 * INVERSE
	*/
	// pack the data
	complexData->imagp[0] = complexData->realp[fftSizeOver2];
	complexData->realp[fftSizeOver2] = 0;

	// inverse FFT
    vDSP_fft_zrip( mFFTSetup, complexData, (vDSP_Stride)1, mLog2FFTSize, FFT_INVERSE );
	
	// interleave the complex values into 1 array which should now be the same as the original but 2048(?)
    vDSP_ztoc( complexData, 1, (DSPComplex *)myInverseOuputData, 2, fftSizeOver2 );

	// output is now between -2048 and +2048 (Well depends if we did the scale or not)
	for( UInt32 i=0; i<fftSize; i++ ) {
		NSLog(@"Output %f ", myInverseOuputData[i] );
	}
	
	/* Clean up */
	vDSP_destroy_fftsetup(mFFTSetup);
	free( complexData->realp );
	free( complexData->imagp );
	free( complexData );
	free( myData );
	free( myInverseOuputData );
}

/* This will Crash (Radix8 problem) and i dont know why it wont catch it */
- (void)test1DFFTForLength4 {
	
	UInt32 fftSize = 16;
	UInt32 fftSizeOver2 = 8;
	UInt32 overlapBetweenFrames = 2;
	UInt32 numberOfChannes = 1;
	UInt32 mMaxFramesPerSlice = 8;
	UInt32 numberOfResults = fftSizeOver2+1;
	
	vDSP_Length mLog2FFTSize = 2; // (2^10 == 1024 ) 
	
	// spoof some input data
	float *myData = (float *)calloc( fftSize, sizeof( float ) );
	float *myInverseOuputData = (float *)calloc( fftSize, sizeof( float ) );
	
	for( UInt32 i=0; i<fftSize; i++ ) {
		float evenOdd = i & 1;
		if(evenOdd==0)
			evenOdd = -1.0f;
		myData[i] = 1*evenOdd;
	}
	
	// reusable twiddle values
	FFTSetup mFFTSetup = vDSP_create_fftsetup( mLog2FFTSize, 4 );
	
	// A real array A = {A[0],...,A[n]} must be transformed into an even-odd array AEvenOdd = {A[0],A[2],...,A[n-1],A[1],A[3],...A[n]} by means of the call vDSP_ctoz
	DSPSplitComplex *complexData = (DSPSplitComplex *)calloc( 1, sizeof( DSPSplitComplex ) );
	
	//NB, we get fftSizeOver2+1 results, packed into fftSizeOver2 slots. The last is empty. We unpack it ourselfs and repack it before Inverse FFT
	complexData->realp = (float *)calloc( 1024, sizeof( float ) );
    complexData->imagp = (float *)calloc( 1024, sizeof( float ) );
	vDSP_ctoz( (DSPComplex *)myData, (vDSP_Stride)2, complexData, (vDSP_Stride)1, (vDSP_Length)fftSizeOver2 ); // input is now even odd

	/* Disabled
	// Do Forward FFT
	STAssertThrows( vDSP_fft_zrip( mFFTSetup, complexData, (vDSP_Stride)1, mLog2FFTSize, FFT_FORWARD ), @"radix8 shit");
	 */
	
	/* Clean up */
	vDSP_destroy_fftsetup(mFFTSetup);
	free( complexData->realp );
	free( complexData->imagp );
	free( complexData );
	free( myData );
	free( myInverseOuputData );
}


@end
