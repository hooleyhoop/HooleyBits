//
//  SHAudioSinWave.h
//  SHExtras
//
//  Created by Steven Hooley on 25/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"

#define SENDDACS_NO 0           /* return values for sys_send_dacs() */
#define SENDDACS_YES 1 
#define SENDDACS_SLEPT 2

@interface SHAudioSinWave : QCPatch {

	QCNumberPort *inputFreq;

	int _sampleRate;
	int _schedblocksize;
    int _sleepgrain;
	int _schedadvance;
	double _time_per_dsp_tick;
	
	
	// OSCIL 1
	double _phase1;// = 0;
	double _freqZ1;// = 0.07123;
	double _freq1;// = 0.07123;
	double _amp1;// = 0.5;
	double _ampZ1;// = 0.5;
	
}

- (void) sched_tick:(double) next_sys_tim;

@end
