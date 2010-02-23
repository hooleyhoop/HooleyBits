
Things we learnt
----------------

// Adding and removing callbacks doesn't require AUGraphUpdate
Boolean outIsUpdated = NO;
RequireNoErr( AUGraphUpdate( _audioGraph, &outIsUpdated));




OSStatus renderInput(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
	UnsignedWide start, end;
	Microseconds(&start);
	
	// we can set up pre and post render calls if we like
	// kAudioUnitRenderAction_PostRender
	// keep all other busses quiet for now
	//	if(inBusNumber != 1) {
	//		memset(ioData->mBuffers[0].mData, 0, ioData->mBuffers[0].mDataByteSize);
	//		return noErr;
	//	}
	static Float32 phase = 0.0;
	static Float32 freq = 0.032;
	
	//the total amount of data requested by the AudioConverter
	//	UInt32 bytesCopied = *ioNumberDataPackets * gMaxPacketSize;
	//alloc a small buffer for the AudioConverter to use.
	
	//	void *gSourceBuffer = (void *)calloc( sizeof(SInt32), inNumberFrames );
	
	
	//	struct SynthData* myData = (struct SynthData *)inRefCon; // get access to Sinewave's data
	
	//! we should make use of this - kAudioUnitRenderAction_OutputIsSilence
	
	//	UInt32 bufSamples = d.bufs[inBusNumber].numFrames << 1;
	
	//	logInfo(@"in is %i", inBusNumber);		// 1 of numInputs
	// logInfo(@"in is %i", inNumberFrames);	// 512
	
	//float *in = d.bufs[inBusNumber].data;
	
	//logInfo(@"iobufferlist number %i", ioData->mNumberBuffers);
	Fixed *outA = (Fixed *)ioData->mBuffers[0].mData;
	//	outA = gSourceBuffer;
	//	ioData->mBuffers[0].mData = gSourceBuffer;
	//	float *outB = (float*)ioData->mBuffers[1].mData;
	
    // load instance vars into registers
	//    double phase = myData->phase;
	//    double amp = defptr->amp;
	//    double pan = defptr->pan;
	//   double freq = myData->freq;
	//	
	//    double ampz = defptr->ampz;
	//    double panz = defptr->panz;
	//    double freqz = defptr->freqz;
	//    
	//    int numSamples = defptr->deviceBufferSize / defptr->deviceFormat.mBytesPerFrame;
	
	// assume floats for now....
	//   float *out = outOutputData->mBuffers[0].mData;
	
	for (UInt32 i=0; i<inNumberFrames; ++i) 
	{
		//		double wave = sin(phase);		// generate sine wave
		//	wave = (ShortFixed)wave;
		phase = phase + freq;			// increment phase
		//			
		//			// write output
		//			*out++ = wave * (1.0-panz);		// left channel
		//		float downsampledWave = (float)(wave*0.1f);
		//		Fixed new = (Fixed)FloatToFixed(downsampledWave);
		
		if (inBusNumber==0) {
			
			static float blurg1=0;
			static BOOL dir1 = 0;
			static float increment1 = 1;
			// 8.24 ? 8 bits for integer - 24 float -ie -128.0f -- +128.0f  ??
			if(dir1)
				blurg1=blurg1+increment1;
			else
				blurg1=blurg1-increment1;
//			outA[i] = FloatToFixed(blurg1);
			
			static int limit1= 20;
			if(blurg1>limit1 || blurg1<(limit1*-1))
				dir1 = !dir1;
		} else {
			
			static float blurg2 = 0;
			static BOOL dir2 = 0;
			static float increment2 = 3.5f;
			if(dir2)
				blurg2=blurg2+increment2;
			else
				blurg2=blurg2-increment2;
	//		outA[i] = FloatToFixed(blurg2);
			
			static int limit2= 127;
			if(blurg2>limit2 || blurg2<(limit2*-1))
				dir2 = !dir2;
		}
		// printf("%f\n", downsampledWave);
		
		//		mDataByteSize = 
		
		
		//			// de-zipper controls
		//			panz  = 0.001 * pan  + 0.999 * panz;
		//			ampz  = 0.001 * amp  + 0.999 * ampz;
		//			freqz = 1.000 * freq + 0.000 * freqz;
		
		//outA[i] = arc4random()/(unsigned)RAND_MAX*1.0f;
		//outB[i] = arc4random()/(unsigned)RAND_MAX*1.0f;
	}
    
    // save registers back to object
	//    myData->phase = phase;
	//	printf("phase is %f\n", myData->phase);
	//    d->freqz = freqz;
	//    d->ampz = ampz;
	//    d->panz = panz;
    
	
	
	
	
	
	//	} else {
	//		UInt32 phase = d.bufs[inBusNumber].phase;
	//		for (UInt32 i=0; i<inNumberFrames; ++i) 
	//		{
	//			outA[i] = in[phase++];
	//			outB[i] = in[phase++];
	//			if (phase >= bufSamples) phase = 0;
	//		}
	//		d.bufs[inBusNumber].phase = phase;
	//	}
	
	Microseconds(&end);
	
	double microsecondsForDsp = end.lo - start.lo;
	double microsecondsForBuffer = 1000000. * inNumberFrames / mSampleRate;
	
	double cpuLoadPercent = 100. * microsecondsForDsp / microsecondsForBuffer;
	
	return noErr;
}
struct SynthData myDatas[5];


struct SndBuf
{
	AudioStreamBasicDescription asbd;
	float *data;
	UInt32 numFrames;
	UInt32 phase;
	NSString *name;
};

struct SynthData
{
	int numbufs;
	struct SndBuf bufs[MAXBUFS];
	int select;
	
	double phase;
	double freq;
};


//void ark_readUnitText(Component _component, ComponentDescription *tempDesc )
//{
//	// I know this is ugly, welcome to the arcane arts.
//	char name[255];
//	char info[255];
//	Handle nameHandle = NewHandle(255); 
//	Handle infoHandle = NewHandle(255);
//	OSStatus ret = GetComponentInfo(_component, tempDesc, nameHandle, infoHandle, NULL);
//	if(ret == noErr) {
//		CopyPascalStringToC((ConstStr255Param)(*nameHandle),name);
//		CopyPascalStringToC((ConstStr255Param)(*infoHandle),info);
//	}
//
//	DisposeHandle(nameHandle);
//	DisposeHandle(infoHandle);
//}

//	myDatas[0].phase = 0; // 0x01811c14
//	myDatas[0].freq = 100 * 2. * 3.14159265359 / 44100.0f;

//	myDatas[1].phase = 0;	// 0x01811dec
//	myDatas[1].freq = 440 * 2. * 3.14159265359 / 44100.0f;

//	myDatas[2].phase = 0;	// 0x01811dec
//	myDatas[2].freq = 800 * 2. * 3.14159265359 / 44100.0f;

OSStatus result = noErr;

//	kMultiChannelMixerParam_Volume
//	kMultiChannelMixerParam_Enable

//	id classInfoPlist = NULL;
//	UInt32 dataSize = sizeof(classInfoPlist);

CFArrayRef factoryPresets = NULL;
UInt32 size = sizeof(factoryPresets);
//	result = AudioUnitGetProperty(output, kAudioUnitProperty_FactoryPresets, kAudioUnitScope_Global, 0, &factoryPresets, &size);
//	if (result != noErr) {
//		const char * statStr = GetMacOSStatusErrorString(result);
//		const char * statCommentStr = GetMacOSStatusCommentString(result);
//
//		printf("AudioUnitGetProperty %s %s\n", GetMacOSStatusErrorString(result), GetMacOSStatusCommentString(result));
//		return;
//	}
//	if(result == noErr){
//		NSArray *_presets = (NSArray*)factoryPresets;
//		logInfo(@"Mixer has %i presets", [_presets count]);
//	}

// turn metering ON
//	result = AudioUnitSetProperty(	mixer,
//								  kAudioUnitProperty_MeteringMode,
//								  kAudioUnitScope_Global,
//								  0,
//								  &data,
//								  sizeof(data) );

UInt32 numbuses;
size = sizeof(numbuses);

// set bus counts
// Do we want busses or channels for the multiple inputs?

UInt32 numInputs = 2;
//	printf("set input bus count %lu\n", numInputs);
//	result = AudioUnitSetProperty(	mixer,
//								  kAudioUnitProperty_ElementCount,
//								  kAudioUnitScope_Input,
//								  0,
//								  &numInputs,
//								  sizeof(numInputs) );
//	if (result != noErr) {
//		printf("AudioUnitSetProperty result %lu %4.4s\n", result, (char*)&result);
//		return;
//	}

//  - assert that the mixer has 8 input busses
UInt32 currentInBusCount;
UInt32 propSize = sizeof(currentInBusCount);
result=AudioUnitGetProperty( mixer, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &currentInBusCount, &propSize);
if (result != noErr) {
	printf("AudioUnitSetProperty %s %s\n", GetMacOSStatusErrorString(result), GetMacOSStatusCommentString(result));
	return;
}
NSAssert1(currentInBusCount==8, @"Mixer should have 2 input! - %i", currentInBusCount);

//  - assert that the mixer has 1 output bus
UInt32 currentOutBusCount;
propSize = sizeof(currentOutBusCount);
result=AudioUnitGetProperty( mixer, kAudioUnitProperty_ElementCount, kAudioUnitScope_Output, 0, &currentOutBusCount, &propSize);
if (result != noErr) {
	printf("AudioUnitSetProperty %s %s\n", GetMacOSStatusErrorString(result), GetMacOSStatusCommentString(result));
	return;
}
NSAssert(currentOutBusCount==1, @"Mixer should have one output!");

// Configure Output
// Try using this AudioStreamBasicDescription -- SEE http://www.blackbagops.net/?p=117 use output units first output bus description
// GET OUT_OUT
AudioStreamBasicDescription output_out_desc;
size = sizeof(AudioStreamBasicDescription);
result = AudioUnitGetProperty( output, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &output_out_desc, &size);
if (result != noErr) {
	printf("AudioUnitSetProperty %s %s\n", GetMacOSStatusErrorString(result), GetMacOSStatusCommentString(result));
	return;
}
// mSampleRate = 48000
// mFordmatID = 1819304813 (kAudioFormatLinearPCM)
// mFordmatFlags = 3118 (kAudioFormatFlagsAudioUnitCanonical)
// mBytesPerPacket = 4
// mFramesPerPacket = 1
// mBytesPerFrame = 4
// mChannelsPerFrame = 2
// mBitsPerChannel = 32

// SET OUT_OUT - kAudioUnitErr_PropertyNotWritable

// GET OUT_IN
AudioStreamBasicDescription output_in_desc;
result = AudioUnitGetProperty( output, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &output_in_desc, &size );
if (result != noErr) {
	printf("AudioUnitSetProperty %s %s\n", GetMacOSStatusErrorString(result), GetMacOSStatusCommentString(result));
	return;
}

output_in_desc.mSampleRate = kGraphSampleRate;
output_in_desc.mChannelsPerFrame = 1;

// output_in_desc. 3118 = kAudioFormatFlagsAudioUnitCanonical;

//		output_in_desc.mBitsPerChannel = 8 * sizeof(AudioSampleType);
//try to get it all consistent
// output_in_desc.mBytesPerPacket = 2;	
// output_in_desc.mFramesPerPacket = 1;
// output_in_desc.mBytesPerFrame = sizeof(AudioUnitSampleType);
// output_in_desc.mBitsPerChannel = 16;	

// SET OUT_IN
// result = AudioUnitSetProperty( output, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &output_in_desc, size );
// if (result != noErr) {
//	printf("AudioUnitSetProperty %s %s\n", GetMacOSStatusErrorString(result), GetMacOSStatusCommentString(result));
//	return;
//}

// Moving on to the mixer
// SET MIXER OUT Format
// set Mixer output stream format
AudioStreamBasicDescription mixer_out_desc;
result = AudioUnitGetProperty(	mixer, kAudioUnitProperty_StreamFormat,  kAudioUnitScope_Output, 0,  &mixer_out_desc,  &size );
if (result != noErr) {
	printf("AudioUnitSetProperty result %lu %4.4s\n", result, (char*)&result);
	return;
}

//	mixer_out_desc.mBitsPerChannel = 8 * sizeof(AudioSampleType);
//	mixer_out_desc.mChannelsPerFrame = 1;
//	output_out_desc.mFramesPerPacket = 1;
//	mixer_out_desc.mBytesPerPacket = output_out_desc.mBytesPerFrame = (output_out_desc.mBitsPerChannel + 7) / 8;
//	output_out_desc.mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
//	output_out_desc.mSampleRate = kGraphSampleRate;

// Mixers output format is fixed
//	printf(">>set output format %d\n", 0);
// result = AudioUnitSetProperty(	mixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0,  &mixer_out_desc, sizeof(mixer_out_desc) );
// if (result != noErr) {
// 	printf("AudioUnitSetProperty result %lu %4.4s\n", result, (char*)&result); // kAudioUnitErr_FormatNotSupported	-10868
//	return;
// }

// Are inputs and outputs enabled?
UInt32 enableIO;

// OUTPUT GET
result = AudioUnitGetProperty( output, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 0,  
							  &enableIO,  &size );

result = AudioUnitGetProperty( output,  kAudioOutputUnitProperty_EnableIO,  kAudioUnitScope_Output,  0,   //output element
							  &enableIO,  &size);	

// OUTPUT SET
enableIO = 1;
result = AudioUnitSetProperty( output, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1,  
							  &enableIO, sizeof(enableIO));

//	enableIO = 0;
//	result = AudioUnitSetProperty( output,  kAudioOutputUnitProperty_EnableIO,  kAudioUnitScope_Output,  0,   //output element
//								  &enableIO, sizeof(enableIO));	

// how can supported number of in channels on the mixer be 1?
AUChannelInfo cinfo;
size_t info_size = sizeof(cinfo);
OSStatus err1 = AudioUnitGetProperty( mixer, kAudioUnitProperty_SupportedNumChannels, kAudioUnitScope_Global,  0, &cinfo, &info_size );	


// MIXER INPUTS
for( int i=0; i<2; i++ ) 
{
	struct SynthData* dataForChannel = (struct SynthData*)malloc(sizeof(struct SynthData));
	myDatas[i] = *dataForChannel;
	rcbs.inputProcRefCon = dataForChannel;
	
	// Mixer
	Float32 vol;
	
	// what is out current enabled Status?
	result = AudioUnitGetParameter( mixer, kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, i, &vol );
	
	// what is the current volume?
	result = AudioUnitGetParameter( mixer, kMultiChannelMixerParam_Volume,  kAudioUnitScope_Input, i, &vol );
	
	
	
	
	//kMultiChannelMixerParam_Volume            = 0,
	//	kMultiChannelMixerParam_Enable            = 1,
	//	kMultiChannelMixerParam_PreAveragePower   = 1000,
	//	kMultiChannelMixerParam_PrePeakHoldLevel  = 2000,
	//	kMultiChannelMixerParam_PostAveragePower  = 3000,
	//	kMultiChannelMixerParam_PostPeakHoldLevel = 4000		
	
	
}


// Mixer Output
//Gets the size of the Stream Format Property and if it is writable
Boolean outWritable;
result = AudioUnitGetPropertyInfo( mixer, kAudioUnitProperty_StreamFormat,  kAudioUnitScope_Output, 0, &size,  &outWritable);	


UInt32 shouldAllocateBuffer = 1;
AudioUnitSetProperty( mixer, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Global, 1, &shouldAllocateBuffer, sizeof(shouldAllocateBuffer));

//    fprintf(stderr, "output mSampleRate = %g\n", output_out_desc.mSampleRate);
//    fprintf(stderr, "output mFormatFlags = %08lX\n", output_out_desc.mFormatFlags);
//    fprintf(stderr, "output mBytesPerPacket = %ld\n", output_out_desc.mBytesPerPacket);
//    fprintf(stderr, "output mFramesPerPacket = %ld\n", output_out_desc.mFramesPerPacket);
//    fprintf(stderr, "output mChannelsPerFrame = %ld\n", output_out_desc.mChannelsPerFrame);
//    fprintf(stderr, "output mBytesPerFrame = %ld\n", output_out_desc.mBytesPerFrame);
//    fprintf(stderr, "output mBitsPerChannel = %ld\n", output_out_desc.mBitsPerChannel);

// New
// Open the output unit
//	AudioComponentDescription output_out_desc;
//	desc.componentType = kAudioUnitType_Output;
//	desc.componentSubType = kAudioUnitSubType_RemoteIO;
//	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
//	desc.componentFlags = 0;
//	desc.componentFlagsMask = 0;
//
//	AudioComponent comp = AudioComponentFindNext(NULL, &desc);
//
//	XThrowIfError(AudioComponentInstanceNew(comp, &inRemoteIOUnit), "couldn't open the remote I/O unit");
//
//	UInt32 one = 1;
//	XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &one, sizeof(one)), "couldn't enable input on the remote I/O unit");
//
//	XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &inRenderProc, sizeof(inRenderProc)), "couldn't set remote i/o render callback");
//
//	UInt32 size = sizeof(outFormat);
//	XThrowIfError(AudioUnitGetProperty(inRemoteIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &outFormat, &size), "couldn't get the remote I/O unit's output client format");
//	XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &outFormat, sizeof(outFormat)), "couldn't set the remote I/O unit's input client format");
//
//	XThrowIfError(AudioUnitInitialize(inRemoteIOUnit), "couldn't initialize the remote I/O unit");
// END NEW

- (IBAction)setInputVolume:(id)sender
{
	UInt32 inputNum = [sender tag] / 100 - 1;
	AudioUnitSetParameter(mixer, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, inputNum, [sender doubleValue] * .01, 0);
}

- (IBAction)setMasterVolume:(id)sender
{
	AudioUnitSetParameter(mixer, kMultiChannelMixerParam_Volume, kAudioUnitScope_Global, 0xFFFFFFFF, [sender doubleValue] * .01, 0);
}

- (IBAction)setMatrixVolume:(id)sender
{
	UInt32 inputNum = [sender tag] / 100 - 1;
	UInt32 outputNum = [sender tag] % 100 - 1;
	UInt32 element = (inputNum << 16) | (outputNum & 0x0000FFFF);
	AudioUnitSetParameter(mixer, kMultiChannelMixerParam_Volume, kAudioUnitScope_Global, element, [sender doubleValue] * .01, 0);
}

- (IBAction)setOutputVolume:(id)sender
{
	kMultiChannelMixerParam_Enable
	UInt32 outputNum = [sender tag] % 100 - 1;
	AudioUnitSetParameter(mixer, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, outputNum, [sender doubleValue] * .01, 0);
}

- (IBAction)enableInput:(id)sender
{
	//	UInt32 inputNum = [sender tag] % 1000 - 1;
	//	AudioUnitSetParameter(mixer, kMatrixMixerParam_Enable, kAudioUnitScope_Input, inputNum, [sender doubleValue], 0);
}

- (IBAction)enableOutput:(id)sender
{
	//	UInt32 outputNum = [sender tag] % 1000 - 1;
	//	AudioUnitSetParameter(mixer, kMatrixMixerParam_Enable, kAudioUnitScope_Output, outputNum, [sender doubleValue], 0);
}





@end
