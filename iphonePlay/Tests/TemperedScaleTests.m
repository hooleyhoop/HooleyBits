//
//  TemperedScaleTests.m
//  iphonePlay
//
//  Created by steve hooley on 12/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//


#import "GTMSenTestCase.h"
#import <OCMock/OCMock.h>
#define HC_SHORTHAND
#import <hamcrest/hamcrest.h>
#import "TemperedScale.h"
#import "SHooleyObject.h"

@interface TemperedScaleTests : SenTestCase {
	
	TemperedScale *tScale;
}

@end


@implementation TemperedScaleTests

- (void)setUp {
	
	tScale = [[TemperedScale alloc] init];
}

- (void)tearDown {
	
	[tScale release];
}

// f = 2n/12 × 440 Hz
- (void)testFrequencies {
	
	// - (double)hzForStepsAbove440:(int)steps;
	// - (double)hzForStepsAboveA4:(int)steps;
	
	// 1.0		Unison				1:1		*
	// 1.067	Minor second		16:15
	// 1.125	Major second		9:8
	// 1.2		Minor third			6:5		*
	// 1.25		Major third			5:4		*
	// 1.33		Perfect fourth		4:3		*
	// 1.4		Diminished fifth	7:5
	// 1.5		Perfect fifth		3:2		*
	// 1.6		Minor sixth			8:5		*
	// 1.66		Major sixth			5:3		*
	// 1.75		Minor seventh		7:4
	// 1.875	Major seventh		15:8
	// 2.0		Octave				2:1		*
	
	// All notes calculated from 440
	STAssertEqualsWithAccuracy( [tScale hzForStepsAbove440:0], 440.0, 0.01f, @"0 steps should be equal %f", (float)([tScale hzForStepsAbove440:0]) );		// A	1:1		440Hz	*Unison
	
	STAssertEqualsWithAccuracy( [tScale hzForStepsAbove440:1], 466.16, 0.01f, @"1 steps should be equal %f", (float)([tScale hzForStepsAbove440:1]) );		// A#	16:15	469.3	 Minor second
	STAssertEqualsWithAccuracy( [tScale hzForStepsAbove440:2], 493.88, 0.01f, @"2 steps should be equal %f", (float)([tScale hzForStepsAbove440:2]) );		// B	9:8		495		 Major second
	STAssertEqualsWithAccuracy( [tScale hzForStepsAbove440:3], 523.2511, 0.01f, @"3 steps should be equal %f", (float)([tScale hzForStepsAbove440:3]) );	// C	6:5		528		*Minor third
	STAssertEqualsWithAccuracy( [tScale hzForStepsAbove440:4], 554.37, 0.01f, @"4 steps should be equal %f", (float)([tScale hzForStepsAbove440:4]) );		// C#	5:4		550		*Major third
	STAssertEqualsWithAccuracy( [tScale hzForStepsAbove440:5], 587.33, 0.01f, @"5 steps should be equal %f", (float)([tScale hzForStepsAbove440:5]) );		// D	4:3		586		*Perfect fourth
	STAssertEqualsWithAccuracy( [tScale hzForStepsAbove440:6], 622.25, 0.01f, @"6 steps should be equal %f", (float)([tScale hzForStepsAbove440:6]) );		// D#	7:5		616		 Diminished fifth
	
	STAssertEqualsWithAccuracy( [tScale hzForStepsAbove440:7], 659.26, 0.01f, @"7 steps should be equal %f", (float)([tScale hzForStepsAbove440:7]) );		// E	3:2		660Hz	*Perfect fifth

	STAssertEqualsWithAccuracy( [tScale hzForStepsAbove440:8], 698.46, 0.01f, @"8 steps should be equal %f", (float)([tScale hzForStepsAbove440:8]) );		// F	8:5		704		*Minor sixth
	STAssertEqualsWithAccuracy( [tScale hzForStepsAbove440:9], 739.99, 0.01f, @"9 steps should be equal %f", (float)([tScale hzForStepsAbove440:9]) );		// F#	5:3		733		*Major sixth
	STAssertEqualsWithAccuracy( [tScale hzForStepsAbove440:10], 783.99, 0.01f, @"10 steps should be equal %f", (float)([tScale hzForStepsAbove440:10]) );	// G	7:4		770		Minor seventh
	STAssertEqualsWithAccuracy( [tScale hzForStepsAbove440:11], 830.61, 0.01f, @"11 steps should be equal %f", (float)([tScale hzForStepsAbove440:11]) );	// G#	15:8	825		Major seventh

	STAssertEqualsWithAccuracy( [tScale hzForStepsAbove440:12], 880.0, 0.01f, @"12 steps should be equal %f", (float)([tScale hzForStepsAbove440:12]) );	// A	2:1		880Hz *Octave
	
	// negative steps
	STAssertEqualsWithAccuracy( [tScale hzForStepsAbove440:-4], 349.2290, 0.01f, @"-4 steps should be equal %f", (float)([tScale hzForStepsAbove440:-4]) );
}


- (void)testMidiNoteForHz {
	
	// - (double)midiNoteForHz:(double)freq;
	
	STAssertEqualsWithAccuracy( [tScale midiNoteForHz:440.0], 69.0, 0.01f, @"should be but is %f", (float)[tScale midiNoteForHz:440.0] );
	STAssertEqualsWithAccuracy( [tScale midiNoteForHz:466.16], 70.0, 0.01f, @"should be but is %f", (float)[tScale midiNoteForHz:466.16] );
	STAssertEqualsWithAccuracy( [tScale midiNoteForHz:493.88], 71.0, 0.01f, @"should be but is %f", (float)[tScale midiNoteForHz:493.88] );
	STAssertEqualsWithAccuracy( [tScale midiNoteForHz:523.2511], 72.0, 0.01f, @"should be but is %f", (float)[tScale midiNoteForHz:523.2511] );
	STAssertEqualsWithAccuracy( [tScale midiNoteForHz:554.37], 73.0, 0.01f, @"should be but is %f", (float)[tScale midiNoteForHz:554.37] );
	STAssertEqualsWithAccuracy( [tScale midiNoteForHz:587.33], 74.0, 0.01f, @"should be but is %f", (float)[tScale midiNoteForHz:587.33] );
	STAssertEqualsWithAccuracy( [tScale midiNoteForHz:622.25], 75.0, 0.01f, @"should be but is %f", (float)[tScale midiNoteForHz:622.25] );
	STAssertEqualsWithAccuracy( [tScale midiNoteForHz:659.26], 76.0, 0.01f, @"should be but is %f", (float)[tScale midiNoteForHz:659.26] );
	STAssertEqualsWithAccuracy( [tScale midiNoteForHz:698.46], 77.0, 0.01f, @"should be but is %f", (float)[tScale midiNoteForHz:698.46] );
	STAssertEqualsWithAccuracy( [tScale midiNoteForHz:739.99], 78.0, 0.01f, @"should be but is %f", (float)[tScale midiNoteForHz:739.99] );
	STAssertEqualsWithAccuracy( [tScale midiNoteForHz:783.99], 79.0, 0.01f, @"should be but is %f", (float)[tScale midiNoteForHz:783.99] );
	STAssertEqualsWithAccuracy( [tScale midiNoteForHz:830.61], 80.0, 0.01f, @"should be but is %f", (float)[tScale midiNoteForHz:830.61] );
	STAssertEqualsWithAccuracy( [tScale midiNoteForHz:880.0], 81.0, 0.01f, @"should be but is %f", (float)[tScale midiNoteForHz:880.0] );
}



@end
