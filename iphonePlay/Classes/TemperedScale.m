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

- (CGFloat)hzForStepsAboveA4:(int)steps {

	return [self hzForStepsAbove440:steps];
}

- (CGFloat)hzForStepsAbove440:(int)steps {

	// f = 2n/12 × 440 Hz
	return powf(2.0f, steps/12.0f)*440.0f;
}

// p = 69 + 12 × log2 (f / (440 Hz))
- (CGFloat)midiNoteForHz:(CGFloat)freq {

	return 69 + 12 * log2f(freq/440.0f);
}

@end
