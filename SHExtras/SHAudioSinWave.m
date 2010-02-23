//
//  SHAudioSinWave.m
//  SHExtras
//
//  Created by Steven Hooley on 25/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHAudioSinWave.h"
#import "s_audio.h"

static double sys_time;
int sched_diddsp;

@implementation SHAudioSinWave


#pragma mark -
#pragma mark class methods
//=========================================================== 
// + timeMode:
//=========================================================== 
+ (int)timeMode {
	return 1;		//Forces continuous execution
}

//=========================================================== 
// + executionMode:
//=========================================================== 
+ (int) executionMode
{
	return 1; // "I am a Generator/Modifier"
}

//=========================================================== 
// + allowsSubpatches:
//=========================================================== 
+ (BOOL)allowsSubpatches
{
	return FALSE;
}

#pragma mark init methods
- (id)initWithIdentifier:(id)fp8
{
	if (![super initWithIdentifier:fp8])
		return nil;

	_sampleRate = 44100;
	_schedblocksize = DEFDACBLKSIZE;
	_sleepgrain = 5000;
	_schedadvance = 5000;
	_time_per_dsp_tick = 20480;		
			
	/* replace the buffer in outAttribure with the global 'sys_soundout' */
//temp	[(id)[portAudioOut value] replaceDataBuffer:sys_soundout length:512];

	// register with the run loop our critical routine that needs calling each time through the loop before evaluate
	//	- (int) advanceTimePerFrame		 
//temp	SEL theSelector					= @selector(advanceTimePerFrame);
//temp	NSMethodSignature *aSignature	= [[self class] instanceMethodSignatureForSelector:theSelector];
//temp	_advanceTimeInvocation			= [[NSInvocation invocationWithMethodSignature:aSignature]retain];
//temp	[_advanceTimeInvocation setSelector:theSelector];			
//temp	[_advanceTimeInvocation setTarget:self];	// invocation doesnt retain arguments
	// [anInvocation setArgument:nil atIndex:2];	// 		
//temp	[aNG addAdvanceTimeInvocation:_advanceTimeInvocation];


	return self;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark action methods
//=========================================================== 
// - setup:
//=========================================================== 
- (id)setup:(id)fp8
{
	NSLog(@"SHGlobalVar.. setup");
	[super setup:fp8];

	int audioindev		= 0;
	int chindev			= 2;
	int audiooutdev		= 0;
	int choutdev		= 2;
	
	// OSCIL 1
	_phase1 = 0;
	_freqZ1 = 0.07123;
	_freq1 = 0.07123;
	_amp1 = 0.5;
	_ampZ1 = 0.5;
	_freq1 = 0.07123;
	
	// when we delete this node we should turn this off...
	// Of Course this is now blocking.. this isnt strictly necasary.. !!!!!
// void sys_open_audio(int naudioindev, int *audioindev, int nchindev, int *chindev, int naudiooutdev, int *audiooutdev, int nchoutdev, int *choutdev, int rate, int advance, int enable);
	sys_open_audio(1,&audioindev,1,&chindev,1,&audiooutdev,1,&choutdev, _sampleRate , DEFDACBLKSIZE ,1);
	
	return fp8;
}

//=========================================================== 
// - cleanup:
//=========================================================== 
- (void)cleanup:(id)fp8
{
	NSLog(@"SHGlobalVar.. cleanup");
	// doesnt work very well(!) with multiple instances as of yet
	sys_close_audio();
	
	[super cleanup:fp8];
}

//=========================================================== 
// - execute:
//=========================================================== 
- (BOOL)execute:(QCOpenGLContext*)openGLcontext time:(double)currentTime arguments:(id)args
{

	int timeforwardResult = pa_send_dacs();
	if (timeforwardResult != SENDDACS_NO)
		[self sched_tick:(sys_time + _time_per_dsp_tick)];

	return TRUE;
}

/* take the scheduler forward one DSP tick, also handling clock timeouts */
- (void) sched_tick:(double) next_sys_time
{
//    int countdown = 5000;
//    while (clock_setlist && clock_setlist->c_settime < next_sys_time)
//    {
//        t_clock *c = clock_setlist;
//        sys_time = c->c_settime;
//        clock_unset(clock_setlist);
//        outlet_setstacklim();
//        (*c->c_fn)(c->c_owner);
//        if (!countdown--)
//        {
//            countdown = 5000;
//            sys_pollgui();
//        }
//        if ([_executionThread cancelled])
//           return;
//    }
    sys_time = next_sys_time;
   [self evaluate]; // was dsp_tick() in pd;
    sched_diddsp++;
}


// ===========================================================
// - evaluate:
// ===========================================================
- (void) evaluate
{
//
//	float *in1Buff = (float *)[[leftSignalIn value] floatData];
//	float *in2Buff = (float *)[[rightSignalIn value] floatData];
//
//	// NB. To avoid calling the accessor method and causing an infinite loop we must do this naughty thing
//	id val = portAudioOut->_value;
//	float *outBuff = (float *)[val floatData];
//	int n = DEFDACBLKSIZE;
//	
//	for (; n; n -= 8, in1Buff += 8, in2Buff += 8, outBuff += 8)
//	{
//		float f0 = in1Buff[0], f1 = in1Buff[1], f2 = in1Buff[2], f3 = in1Buff[3];
//		float f4 = in1Buff[4], f5 = in1Buff[5], f6 = in1Buff[6], f7 = in1Buff[7];
//
//		float g0 = in2Buff[0], g1 = in2Buff[1], g2 = in2Buff[2], g3 = in2Buff[3];
//		float g4 = in2Buff[4], g5 = in2Buff[5], g6 = in2Buff[6], g7 = in2Buff[7];
//
//		outBuff[0] = f0 + g0; outBuff[1] = f1 + g1; outBuff[2] = f2 + g2; outBuff[3] = f3 + g3;
//		outBuff[4] = f4 + g4; outBuff[5] = f5 + g5; outBuff[6] = f6 + g6; outBuff[7] = f7 + g7;
//	}
//	sys_soundout



   // sinewavedef*	def = defptr; // get access to Sinewave's data
    int i;
        
    // int numSamples = def->deviceBufferSize / def->deviceFormat.mBytesPerFrame;
    
    // assume floats for now....
    float *out = sys_soundout;
    
    for (i=0; i<DEFDACBLKSIZE; ++i) 
	{
    
        float wave = sin(_phase1) * _ampZ1;		// generate sine wave
        _phase1 = _phase1 + _freqZ1;			// increment phase
        
        // write output
        *out++ = wave;		// left channel
        *out++ = wave;			// right channel
        
        // de-zipper controls
        _ampZ1  = 0.001 * _amp1  + 0.999 * _ampZ1;
        _freqZ1 = 0.001 * _freq1 + 0.999 * _freqZ1;
    }
	

}



// ===========================================================
// - initInputs:
// ===========================================================
- (void)initInputs
{	
	// makes a default SHNumber attribute
//	leftSignalIn	= [[[SHInputAttribute alloc] initWithParentNodeGroup:self isUserAdded:NO]autorelease];
//	rightSignalIn	= [[[SHInputAttribute alloc] initWithParentNodeGroup:self isUserAdded:NO]autorelease];
//
//	// NSLog(@"PDDac.m: operand1 %@", operand1);
//	[self addNodeToNodeGroup: (SHNode*)leftSignalIn];
//	[self addNodeToNodeGroup: (SHNode*)rightSignalIn];
//
//	// NSLog(@"PDDac.m: Added inputs, number of inputs is %i", [self numberOfInputs] );
//	
//	// Change the default name that is assigned when added to node group
//	[leftSignalIn setName:@"leftSignalIn"];
//	[rightSignalIn setName:@"rightSignalIn"];
//	
//	[leftSignalIn setDataType:@"PDSignal" withArgument:@"mono"];
//	[rightSignalIn setDataType:@"PDSignal" withArgument:@"mono"];
}

// ===========================================================
// - initOutputs:
// ===========================================================
- (void)initOutputs
{	
//	portAudioOut = [[[SHOutputAttribute alloc] initWithParentNodeGroup:self isUserAdded:NO]autorelease];
//	[self addNodeToNodeGroup: (SHNode*)portAudioOut];
//	// Change the default name that is assigned when added to node group
//	[portAudioOut setName:@"portAudioOut"];
//	
//	/* We dont really need to set the buffer length as we are going to replace the buffer with 'sys_soundout' after initialization */
//	[portAudioOut setDataType:@"PDSignal" withArgument:@"stereoInterleaved"];
}



#pragma mark accessor methods





@end
