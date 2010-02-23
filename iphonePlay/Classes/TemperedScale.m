//
//  TemperedScale.m
//  iphonePlay
//
//  Created by steve hooley on 12/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "TemperedScale.h"


@implementation TemperedScale

+ (TemperedScale *)temperedScale {
	return [[[TemperedScale alloc] init] autorelease];
}

- (void)dealloc {
	
	[super dealloc];
}

- (double)hzForStepsAboveA4:(int)steps {

	return [self hzForStepsAbove440:steps];
}

- (double)hzForStepsAbove440:(int)steps {

	// f = 2n/12 × 440 Hz
	return pow(2.0, steps/12.0)*440.0;
}

// p = 69 + 12 × log2 (f / (440 Hz))
- (double)midiNoteForHz:(double)freq {

	return 69 + 12 * log2(freq/440.0);
}

@end
