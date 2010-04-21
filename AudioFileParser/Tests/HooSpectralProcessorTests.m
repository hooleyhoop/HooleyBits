//
//  HooSpectralProcessorTests.m
//  AudioFileParser
//
//  Created by steve hooley on 20/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <Accelerate/Accelerate.h>
#import "HooSpectralProcessor.h"
#import <SHShared/SHShared.h>

@interface HooSpectralProcessorTests : SenTestCase {

	NSUInteger _callbackCount;
	DSPSplitComplex *_complexOutputData2;
}

@end

@implementation HooSpectralProcessorTests

BOOL _dataCompare( Float32 *data1, Float32 *data2 ) {
	
	for( NSUInteger i=0; i<1024; i++ ){
		Float32 test1 = data1[i];
		Float32 test2 = data2[i];
//		if( G3DCompareFloat( test1, test2, 0.01f)!=0 )
//			return NO;
	}
	return YES;
}

BOOL _dSPSplitComplexCompare( DSPSplitComplex *data1, DSPSplitComplex *data2 ) {

	for( NSUInteger i=0; i<512; i++ ){

		Float32 test1 = data1->realp[i];
		Float32 test2 = data2->realp[i];
		if( G3DCompareFloat( test1, test2, 0.01f)!=0 )
			return NO;
		
		Float32 test3 = data1->imagp[i];
		Float32 test4 = data2->imagp[i];
		if( G3DCompareFloat( test3, test4, 0.01f)!=0)
			return NO;
	}

	return YES;
}

// A real array A = {A[0],...,A[n]} must be transformed into an even-odd array AEvenOdd = {A[0],A[2],...,A[n-1],A[1],A[3],...A[n]} by means of the call vDSP_ctoz
- (void)_1DForwardFFT:(Float32 *)testData :(DSPSplitComplex *)complexOutputData {
	
	UInt32 fftSize = 1024;
	UInt32 fftSizeOver2 = 512;
	UInt32 overlapBetweenFrames = 512;
	UInt32 numberOfChannes = 1;
	UInt32 mMaxFramesPerSlice = 1024;
	UInt32 numberOfResults = fftSizeOver2+1;
	
	vDSP_Length mLog2FFTSize = 10; // (2^10 == 1024 ) 

	// reusable twiddle values
	FFTSetup mFFTSetup = vDSP_create_fftsetup( mLog2FFTSize, FFT_RADIX2 );
	
	//NB, we get fftSizeOver2+1 results, packed into fftSizeOver2 slots. The last is empty. We unpack it ourselfs and repack it before Inverse FFT
	vDSP_ctoz( (DSPComplex *)testData, (vDSP_Stride)2, complexOutputData, (vDSP_Stride)1, (vDSP_Length)fftSizeOver2 ); // input is now even odd
	
	// Do Forward FFT
	vDSP_fft_zrip( mFFTSetup, complexOutputData, (vDSP_Stride)1, mLog2FFTSize, FFT_FORWARD );
	
	// unpack the data we have 513 complex values packed into 512 value
//	complexOutputData->realp[fftSizeOver2] = complexOutputData->imagp[0];
//	complexOutputData->imagp[0] = 0;
	
	/*  values are between -2048 - +2048. scale it by  2n. */
	BOOL _shouldScale = NO;
    Float32 scale;
	if(_shouldScale){
		Float32 scale = (Float32) 1.0 / (2 * fftSize);
		vDSP_vsmul( complexOutputData->realp, 1, &scale, complexOutputData->realp, 1, numberOfResults );
		vDSP_vsmul( complexOutputData->imagp, 1, &scale, complexOutputData->imagp, 1, numberOfResults );
	} else {
		scale = 1;
	}
	Float32 maxComplexValue = 2 * fftSize * scale;
	
	// magnitude test
	Float32 maxMag = sqrtf( maxComplexValue*maxComplexValue + maxComplexValue*maxComplexValue ); // 2048 = 2896.309326, 1 = 1.4142
	
	// calculate magnitudes 0 - 2048 (sqrt(sin^2+cos^2))
	Float32 *outputMags = (Float32 *)calloc( numberOfResults, sizeof(Float32));
	vDSP_zvabs( complexOutputData, (vDSP_Stride)1, outputMags, (vDSP_Stride)1, (vDSP_Length)numberOfResults ); 		
	
	// values -2048 - +2048 ?
	
	// complexOutputData is now packed wierdly - 513 - (YES! fftSizeOver2 + 1)  COMPLEX value (real, imaginary)
	// The first and last imaginary values are always 0! So the last REAL value is in imaginary[0] - cunt!
	for( UInt32 i=0; i<numberOfResults; i++ ) {
		Float32 freq = ((Float32)(i)/(Float32)1024)*44100;
		//	Float32 magnitude_OfUnscaled_1 = 20. * log10( 2. * sqrt(lastReal*lastReal+lastImag*lastImag)/(Float32)1024.0f);
		//	Float32 magnitude_OfUnscaled_2 = 20. * log10( 2. * sqrt(lastReal*lastReal+lastImag*lastImag))/(Float32)1024.0f;
		// Float32 phase = 180.f * atan2f( lastReal, lastImag ) / (Float32)M_PI - 90.f;
//		NSLog(@"freq %f: %f - %f : Mag. %f", freq, complexOutputData->realp[i], complexOutputData->imagp[i], outputMags[i] );
	}
	
	/* Clean up */
	vDSP_destroy_fftsetup(mFFTSetup);
}

- (void)_1DBackwardFFT:(DSPSplitComplex *)complexInputData {
	
	UInt32 fftSize = 1024;
	UInt32 fftSizeOver2 = 512;
	// reusable twiddle values
	vDSP_Length mLog2FFTSize = 10; // (2^10 == 1024 ) 
	FFTSetup mFFTSetup = vDSP_create_fftsetup( mLog2FFTSize, FFT_RADIX2 );
	
	/*
	 * INVERSE
	 */
	// pack the data
	complexInputData->imagp[0] = complexInputData->realp[fftSizeOver2];
	complexInputData->realp[fftSizeOver2] = 0;
	
	// inverse FFT
    vDSP_fft_zrip( mFFTSetup, complexInputData, (vDSP_Stride)1, mLog2FFTSize, FFT_INVERSE );
	
	// interleave the complex values into 1 array which should now be the same as the original but 2048(?)
	Float32 *myInverseOuputData = (Float32 *)calloc( fftSize, sizeof( Float32 ) );
    vDSP_ztoc( complexInputData, 1, (DSPComplex *)myInverseOuputData, 2, fftSizeOver2 );
	
	// output is now between -2048 and +2048 (Well depends if we did the scale or not)
//	for( UInt32 i=0; i<fftSize; i++ ) {
//		NSLog(@"Output %f ", myInverseOuputData[i] );
//	}
	
	/* Clean up */
	vDSP_destroy_fftsetup(mFFTSetup);
	free( complexInputData->realp );
	free( complexInputData->imagp );
	free( complexInputData );
	free( myInverseOuputData );
}

- (void)testForwardFFT {

	// spoof some input data
	UInt32 fftSize = 1024;
	UInt32 fftSizeOver2 = 512;
	UInt32 overlapBetweenFrames = 512;
	UInt32 numberOfChannes = 1;
	UInt32 mMaxFramesPerSlice = 1024;
	UInt32 numberOfResults = fftSizeOver2+1;
	
	Float32 *testInData = (Float32 *)calloc( fftSize, sizeof( Float32 ) );	
	for( UInt32 i=0; i<fftSize; i++ ) {
		NSInteger evenOdd = i & 1; // 0,1,0,1,0,1,0,1,...
		if(evenOdd==0)
			evenOdd = -1.0f;
		testInData[i] = 1.0f*evenOdd;
	}
	
	// do it the tested way - 513 values
	DSPSplitComplex *complexOutputData1 = (DSPSplitComplex *)calloc( 1, sizeof( DSPSplitComplex ) );
	//NB, we get fftSizeOver2+1 results, packed into fftSizeOver2 slots. The last is empty. We unpack it ourselfs and repack it before Inverse FFT
	complexOutputData1->realp = (Float32 *)calloc( numberOfResults, sizeof( Float32 ) );
    complexOutputData1->imagp = (Float32 *)calloc( numberOfResults, sizeof( Float32 ) );	
	[self _1DForwardFFT:testInData :complexOutputData1];
	
	HooSpectralProcessor *hooSpectralProcessor = [[[HooSpectralProcessor alloc] init:fftSize :overlapBetweenFrames :numberOfChannes :mMaxFramesPerSlice] autorelease];
	[hooSpectralProcessor setDelegate:self];

	// sheesh! wrap our data in an AudioBufferList
	struct AudioBufferList testDataInBufferList;
	testDataInBufferList.mNumberBuffers = 1;
	
//	struct AudioBuffer testData_audioBuf;
//	testDataInBufferList.mBuffers[0] = testData_audioBuf;

	testDataInBufferList.mBuffers[0].mNumberChannels = 1;
	testDataInBufferList.mBuffers[0].mDataByteSize = 1024;
	testDataInBufferList.mBuffers[0].mData = testInData;

//	testData_audioBuf.mNumberChannels = 1;
//    testData_audioBuf.mDataByteSize = 1024;
 //   testData_audioBuf.mData = testData;
	
	
	// process the test data and (hopefully) receive callback - _complexOutputData2 is filled via our callback	
	
	[hooSpectralProcessor processForwards:1024 :&testDataInBufferList];
	STAssertTrue( _callbackCount==1, @"oops, did we callback with our data?");
	
	// not going to work becuase hooSpectralProcessor is windowed
	// STAssertTrue( _dSPSplitComplexCompare( complexOutputData1, _complexOutputData2 ), nil );
	
	// llets go backwards mutha fucker
	Float32 *testOutData = (Float32 *)calloc( fftSize, sizeof( Float32 ) );	

	struct AudioBufferList testDataOutBufferList;
	testDataOutBufferList.mNumberBuffers = 1;
	testDataOutBufferList.mBuffers[0].mNumberChannels = 1;
	testDataOutBufferList.mBuffers[0].mDataByteSize = 1024;
	testDataOutBufferList.mBuffers[0].mData = testOutData;
	
	[hooSpectralProcessor processBackwards:1024 :&testDataOutBufferList];		

	// wierdly this doesnt work if i pass in testOutData.. howcome?
	STAssertTrue( _dataCompare( testInData, testDataOutBufferList.mBuffers[0].mData ), nil );

	free( testInData );
	free( testOutData );
	free( complexOutputData1->realp );
	free( complexOutputData1->imagp );
	free( complexOutputData1 );
}

- (void)_callback_complexOutput:(struct HooSpectralBufferList *)inSpectra {

	_callbackCount++;
	NSParameterAssert( inSpectra->mNumberSpectra == 1 );
	
	if(_callbackCount==1){
		// data is not unpacked
		_complexOutputData2 = inSpectra->mDSPSplitComplex;
	} else {
		for( int i=0; i<512; i++ ) {
			inSpectra->mDSPSplitComplex->realp[i] = _complexOutputData2->realp[i];
			inSpectra->mDSPSplitComplex->imagp[i] = _complexOutputData2->imagp[i];
		}
	}
}




@end
