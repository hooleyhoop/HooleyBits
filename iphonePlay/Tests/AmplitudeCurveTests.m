//
//  AmplitudeCurveTests.m
//  iphonePlay
//
//  Created by Steven Hooley on 3/14/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import "GTMSenTestCase.h"
#import "AmplitudeCurve.h"

@interface AmplitudeCurveTests : SenTestCase {
	
	AmplitudeCurve *ac;
}

@end


@implementation AmplitudeCurveTests

- (void)setUp {
	
	ac = [[AmplitudeCurve alloc] init];
}

- (void)tearDown {
	[ac release];
}

- (void)test_decibelEarResponceForFrequency {
	//- (CGFloat)_decibelEarResponceForFrequency:(CGFloat)freq

	STAssertEqualsWithAccuracy( [ac _decibelEarResponceForFrequency:0.], (CGFloat)0., 0.01, @"no - %f", [ac _decibelEarResponceForFrequency:0.] );
	STAssertEqualsWithAccuracy( [ac _decibelEarResponceForFrequency:31.5], (CGFloat)-38.0, 0.01, @"no - %f", [ac _decibelEarResponceForFrequency:31.5] );
	STAssertEqualsWithAccuracy( [ac _decibelEarResponceForFrequency:125.], (CGFloat)-16.0, 0.01, @"no - %f", [ac _decibelEarResponceForFrequency:125.] );
	STAssertEqualsWithAccuracy( [ac _decibelEarResponceForFrequency:250.], (CGFloat)-9.123, 0.01, @"no - %f", [ac _decibelEarResponceForFrequency:250.] );
	STAssertEqualsWithAccuracy( [ac _decibelEarResponceForFrequency:500.], (CGFloat)-4.0, 0.01, @"no - %f", [ac _decibelEarResponceForFrequency:500.] );
	STAssertEqualsWithAccuracy( [ac _decibelEarResponceForFrequency:2000.], (CGFloat)2.0, 0.01, @"no - %f", [ac _decibelEarResponceForFrequency:2000.] );
	STAssertEqualsWithAccuracy( [ac _decibelEarResponceForFrequency:5000.], (CGFloat)0.7, 0.01, @"no - %f", [ac _decibelEarResponceForFrequency:5000.] );
	STAssertEqualsWithAccuracy( [ac _decibelEarResponceForFrequency:8000.], (CGFloat)-2.0, 0.01, @"no - %f", [ac _decibelEarResponceForFrequency:8000.] );
	STAssertEqualsWithAccuracy( [ac _decibelEarResponceForFrequency:9000.], (CGFloat)-2.66, 0.01, @"no - %f", [ac _decibelEarResponceForFrequency:9000.] );
}

- (void)testDecibelToAmplitudeOverReferenceAmplitude {
	//+ (CGFloat)decibelToAmplitudeOverReferenceAmplitude:(CGFloat)decibel

	STAssertEqualsWithAccuracy( [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-40.], (CGFloat)0., 0.01, @"no - %f", [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-40.] );
	STAssertEqualsWithAccuracy( [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-35.], (CGFloat)0.0177, 0.01, @"no - %f", [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-35.] );
	STAssertEqualsWithAccuracy( [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-30.], (CGFloat)0.0316, 0.01, @"no - %f", [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-30.] );
	STAssertEqualsWithAccuracy( [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-25.], (CGFloat)0.0562, 0.01, @"no - %f", [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-25.] );
	STAssertEqualsWithAccuracy( [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-20.], (CGFloat)0.1, 0.01, @"no - %f", [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-20.] );
	STAssertEqualsWithAccuracy( [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-15.], (CGFloat)0.1778, 0.01, @"no - %f", [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-15.] );
	STAssertEqualsWithAccuracy( [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-10.], (CGFloat)0.3162, 0.01, @"no - %f", [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-10.] );
	STAssertEqualsWithAccuracy( [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-5.], (CGFloat)0.5623, 0.01, @"no - %f", [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:-5.] );
	STAssertEqualsWithAccuracy( [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:0.], (CGFloat)1.0, 0.01, @"no - %f", [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:0.] );
	STAssertEqualsWithAccuracy( [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:5.], (CGFloat)1.778, 0.01, @"no - %f", [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:5.] );
	STAssertEqualsWithAccuracy( [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:10.], (CGFloat)3.162, 0.01, @"no - %f", [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:10.] );
}

- (void)test_earAmplitudeResponceForFrequency {
	//- (CGFloat)_earAmplitudeResponceForFrequency:(CGFloat)freq
	
	STAssertEqualsWithAccuracy( [ac _earAmplitudeResponceForFrequency:20.], (CGFloat)0.0582, 0.01, @"no - %f", [ac _earAmplitudeResponceForFrequency:20.] );
	STAssertEqualsWithAccuracy( [ac _earAmplitudeResponceForFrequency:80.], (CGFloat)0.0612, 0.01, @"no - %f", [ac _earAmplitudeResponceForFrequency:80.] );
	STAssertEqualsWithAccuracy( [ac _earAmplitudeResponceForFrequency:160.], (CGFloat)0.346, 0.01, @"no - %f", [ac _earAmplitudeResponceForFrequency:160.] );
	STAssertEqualsWithAccuracy( [ac _earAmplitudeResponceForFrequency:320.], (CGFloat)0.757, 0.01, @"no - %f", [ac _earAmplitudeResponceForFrequency:320.] );
	STAssertEqualsWithAccuracy( [ac _earAmplitudeResponceForFrequency:500.], (CGFloat)1.051, 0.01, @"no - %f", [ac _earAmplitudeResponceForFrequency:500.] );
	STAssertEqualsWithAccuracy( [ac _earAmplitudeResponceForFrequency:800.], (CGFloat)1.394, 0.01, @"no - %f", [ac _earAmplitudeResponceForFrequency:800.] );
	STAssertEqualsWithAccuracy( [ac _earAmplitudeResponceForFrequency:1000.], (CGFloat)1.602, 0.01, @"no - %f", [ac _earAmplitudeResponceForFrequency:1000.] );
	STAssertEqualsWithAccuracy( [ac _earAmplitudeResponceForFrequency:2000.], (CGFloat)2.098, 0.01, @"no - %f", [ac _earAmplitudeResponceForFrequency:2000.] );
}

- (void)testMapEarResponseToAmplitudeForFreq {
	// - (CGFloat)mapEarResponseToAmplitudeForFreq:(CGFloat)freq
	
	STAssertEqualsWithAccuracy( [ac mapEarResponseToAmplitudeForFreq:20.], (CGFloat)0.592, 0.01, @"no - %f", [ac mapEarResponseToAmplitudeForFreq:20.] );
	STAssertEqualsWithAccuracy( [ac mapEarResponseToAmplitudeForFreq:80.], (CGFloat)0.591, 0.01, @"no - %f", [ac mapEarResponseToAmplitudeForFreq:80.] );
	STAssertEqualsWithAccuracy( [ac mapEarResponseToAmplitudeForFreq:160.], (CGFloat)0.552, 0.01, @"no - %f", [ac mapEarResponseToAmplitudeForFreq:160.] );
	STAssertEqualsWithAccuracy( [ac mapEarResponseToAmplitudeForFreq:320.], (CGFloat)0.49, 0.01, @"no - %f", [ac mapEarResponseToAmplitudeForFreq:320.] );
	STAssertEqualsWithAccuracy( [ac mapEarResponseToAmplitudeForFreq:500.], (CGFloat)0.456, 0.01, @"no - %f", [ac mapEarResponseToAmplitudeForFreq:500.] );
	STAssertEqualsWithAccuracy( [ac mapEarResponseToAmplitudeForFreq:800.], (CGFloat)0.409, 0.01, @"no - %f", [ac mapEarResponseToAmplitudeForFreq:800.] );
	STAssertEqualsWithAccuracy( [ac mapEarResponseToAmplitudeForFreq:1000.], (CGFloat)0.381, 0.01, @"no - %f", [ac mapEarResponseToAmplitudeForFreq:1000.] );
	STAssertEqualsWithAccuracy( [ac mapEarResponseToAmplitudeForFreq:2000.], (CGFloat)0.313, 0.01, @"no - %f", [ac mapEarResponseToAmplitudeForFreq:2000.] );
}


@end
