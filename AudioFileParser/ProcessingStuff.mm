//
//  ProcessingStuff.m
//  AudioFileParser
//
//  Created by steve hooley on 21/12/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "ProcessingStuff.h"
#import <vecLib/vecLib.h>
#import "CABufferList.h"
#import "SHCASpectralProcessor.h"
#import "AudioFileParser.h"
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/ExtendedAudioFile.h>

#import "BacwardsProcessTests.h"

static SHCASpectralProcessor *_mSpectralProcessor;

extern void callBackFunction_storeMagnitudes( SpectralBufferList* inSpectra, void* inUserData );

@implementation ProcessingStuff

+ (SHCASpectralProcessor *)mSpectralProcessor {
	return _mSpectralProcessor;
}

- (id)init {
	
	self = [super init];
	if(self){
		UInt32 fftSize = 1024;				//1024
		UInt32 overlapBetweenFrames = 512;
		UInt32 numberOfChannes = 1;
		
		// This is a random guess
		UInt32 mMaxFramesPerSlice = 1024;

		_mSpectralProcessor = new SHCASpectralProcessor( fftSize, overlapBetweenFrames, numberOfChannes, mMaxFramesPerSlice);
		_mSpectralProcessor->SetSpectralFunction( &callBackFunction_storeMagnitudes, (void *)self );
		
		_allFFTMagnitudes = [[NSPointerArray pointerArrayWithWeakObjects] retain];
		
		// TEMP
		_backwardsProcessor = [[BacwardsProcessTests alloc] init];

	}
	return self;
}

- (void)dealloc {
	
	[_backwardsProcessor release];
	[_allFFTMagnitudes release];
	[super dealloc];
}

- (void)processSomeAudio:(UInt32)inFramesToProcess :(AudioBufferList *)inputBufList {
		
//	[self calcMaxAndMin:inFramesToProcess :inputBufList];
	[self doFFT:inFramesToProcess :inputBufList];
	
// just experimenting
[_backwardsProcessor doBackwardsFFT];
}

// Calculate MAX and MIN
- (void)calcMaxAndMin:(UInt32)inFramesToProcess :(AudioBufferList *)inputBufList {

	AudioBuffer singleBuffer = inputBufList->mBuffers[0];
	Float32 max;
	Float32 min;
	vDSP_maxmgv((Float32 *)singleBuffer.mData, 1, &max, inFramesToProcess);
	vDSP_minmgv((Float32 *)singleBuffer.mData, 1, &min, inFramesToProcess);
//	NSLog(@"MAX - %f, MIN - %f", max, min);
}

- (void)doFFT:(UInt32)inFramesToProcess :(AudioBufferList *)inputBufList {

	AudioBufferList *outputBufList = (AudioBufferList *)calloc(1, sizeof(AudioBufferList));
	outputBufList->mNumberBuffers = 1;	
	AudioBuffer *aBuf = outputBufList->mBuffers;
	aBuf->mNumberChannels=1;
	aBuf->mDataByteSize = inFramesToProcess*sizeof(Float32);
	Float32 *aSingleBlock =  (Float32 *)calloc(1024, sizeof(Float32));
	aBuf->mData = aSingleBlock;	
	
//	bool success = _mSpectralProcessor->ProcessForwards(inFramesToProcess, inputBufList);
	/* Temporarily see what we get out */
	_mSpectralProcessor->Process(inFramesToProcess, inputBufList, outputBufList);

	[self addDataToWriteFile:outputBufList :1024];

	Float32 *mMinAmp = (Float32*) calloc(inputBufList->mNumberBuffers, sizeof(Float32));
	Float32 *mMaxAmp = (Float32*) calloc(inputBufList->mNumberBuffers, sizeof(Float32));

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

static ExtAudioFileRef captureFile;

- (void)openWriteFile {
	
	const char *outputPath = "/Users/shooley/process.caf";

	// create the capture file
	CFURLRef url = CFURLCreateFromFileSystemRepresentation(NULL, (Byte *)outputPath, strlen(outputPath), false);
	if(!url) {
		[NSException raise:@"can't parse file path" format:@""];
	}
	// prepare a 16-bit int file format, sample channel count and sample rate
	AudioStreamBasicDescription dstFormat;
	dstFormat.mSampleRate = 44100.0f;
	dstFormat.mChannelsPerFrame = 1;
	dstFormat.mFormatID = kAudioFormatLinearPCM;
	dstFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger; // little-endian
	dstFormat.mBitsPerChannel = 16;
	dstFormat.mBytesPerPacket = dstFormat.mBytesPerFrame = 2 * dstFormat.mChannelsPerFrame;
	dstFormat.mFramesPerPacket = 1;
	AudioChannelLayout* chanLayout = [[AudioFileParser afp] inputChannelLayout];
	NSAssert( nil!=chanLayout, @"fuck" );
	OSStatus result = ExtAudioFileCreateWithURL( url, kAudioFileCAFType, &dstFormat, chanLayout, kAudioFileFlags_EraseFile, &captureFile );
	if(result!=noErr)
	[NSException raise:@"ExtAudioFileCreateWithURL" format:@""];
	CFRelease (url);

	// set the capture file's client format to be the canonical format from the queue
	AudioStreamBasicDescription *captureFormat = [[AudioFileParser afp] captureFormat];
	NSAssert( nil!=captureFormat, @"fuck" );
	result = ExtAudioFileSetProperty( captureFile, kExtAudioFileProperty_ClientDataFormat, sizeof(AudioStreamBasicDescription), captureFormat );
	if(result!=noErr)
		[NSException raise:@"set ExtAudioFile client format" format:@""];
}

- (void)addDataToWriteFile:(AudioBufferList *)captureABL :(UInt32)writeFrames
{
	// write to the file
	OSStatus result = ExtAudioFileWrite( captureFile, writeFrames, captureABL );
	if(result!=noErr)
		[NSException raise:@"ExtAudioFileWrite" format:@""];
}

- (void)closeWriteFile {
	
	OSStatus result = ExtAudioFileDispose(captureFile);
	if(result!=noErr)
		[NSException raise:@"ExtAudioFileDispose failed" format:@""];
}

//long bin;
//for( bin=0; bin<=transformLength/2; bin++ ) 
//{
//	frequency[bin] = (float)bin * samplerate / (float)transformLength;
//	
//	magnitude[bin] = 20. * log10( 2. * sqrt( sinPart[bin] * sinPart[bin] + cosPart[bin] * cosPart[bin] ) / (float)transformLength;
//	
//	phase[bin] = 180. * atan2( sinPart[bin], cosPart[bin] ) / M_PI - 90.;
//}
	
	
static Float32 maxamp = 0.0f;
void callBackFunction_storeMagnitudes( SpectralBufferList *inSpectra, void *inUserData ) {
		
	DSPSplitComplex mDSPSplitComplex = inSpectra->mDSPSplitComplex[0];
	float *realp = mDSPSplitComplex.realp;
	float *imagp = mDSPSplitComplex.imagp;
	static Float32 maxRealp = 0.0f;

	for( int i=0;i<1024; i++ ){
//		if( realp[i]>maxRealp ) {
			maxRealp = realp[i];
//			printf("realp: %f - \n", realp[i]);
//		}
	}
	
	UInt32 length = 512;
	
	ProcessingStuff *ps = (ProcessingStuff *)inUserData;
	SHCASpectralProcessor *sp = [ProcessingStuff mSpectralProcessor];
	
	AudioBufferList *bl_ptr = (AudioBufferList *)calloc(1, sizeof(AudioBufferList));
	bl_ptr->mNumberBuffers = 1;

//	AudioBuffer *aBuf_ptr = (AudioBuffer *)calloc(1, sizeof(AudioBuffer));
	AudioBuffer *aBuf_ptr = bl_ptr->mBuffers;

	// generate some fake data
	aBuf_ptr->mNumberChannels = 1;
	aBuf_ptr->mDataByteSize = sizeof(Float32)*length;
	Float32 *outputFreqs_ptr = (Float32 *)calloc( 512, sizeof(Float32));
	Float32 *outputMags_ptr = (Float32 *)calloc( 512, sizeof(Float32));
	aBuf_ptr->mData = outputMags_ptr;
	
//	bl_ptr->mBuffers[0] = *aBuf_ptr;
	
	Float32 min, max;
	sp->GetMagnitude( bl_ptr, &min, &max );
	sp->GetFrequencies( outputFreqs_ptr, 44100.0f);
	
	[ps storeMagnitudes:outputMags_ptr];
	
	// suely this should be 102? not 512 - which it actually is
	for( int i=0;i<1024; i++ )
	{
	//	imagp[i] = imagp[i]=0;
		
		/* Show freqs */
//			printf("Freq: %f - \n", outputFreqs_ptr[i]);
		
	
//put back		if(outputMags_ptr[i]>2.0f){
	//		realp[i] = realp[i]/2.0f;
//put back			if (outputMags_ptr[i]>maxamp) {
//put back				maxamp = outputMags_ptr[i];
//put back				printf("**NEW maxamp : %f - \n", maxamp);
//put back			}
			
	//		printf("%f, %f - Amp: %f - \n", realp[i], imagp[i], outputMags_ptr[i]);

//put back		}
	}

	free(outputFreqs_ptr);

//	free(aBuf_ptr);
	free(bl_ptr);
}

- (void)storeMagnitudes:(Float32 *)mags {
	[_allFFTMagnitudes addPointer:mags];	
}

- (NSPointerArray *)allFFTMagnitudes {
	return _allFFTMagnitudes;	
}

@end
