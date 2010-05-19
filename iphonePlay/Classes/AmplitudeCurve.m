//
//  AmplitudeCurve.m
//  iphonePlay
//
//  Created by steve hooley on 16/03/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "AmplitudeCurve.h"
#import "LWEnvelope.h"


@implementation AmplitudeCurve

@synthesize minAmp=_minAmp, maxAmp=_maxAmp;

- (id)init {
	
	self=[super init];
	if(self){
		// frequency / decibel curve
		envelope = [[LWEnvelope lWEnvelopeWithPoint:CGPointMake(0, 0)] retain];
		[envelope curveToPoint:CGPointMake(31.5f, -38.0f)];
		[envelope curveToPoint:CGPointMake(125, -16)];
		[envelope curveToPoint:CGPointMake(500, -4)];
		[envelope curveToPoint:CGPointMake(2000, 2)];
		[envelope curveToPoint:CGPointMake(8000, -2)];
		
		[envelope setPreBehavoir:5];
		[envelope setPostBehavoir:5];
		
		_referenceAmplitude = 0.6f;		// when we convert from decibels to amplitudes all value are amp/_referenceAmplitude. ie _referenceAmplitude is a scaleFactor
		_minAmp = 0.3f, _maxAmp = 0.6f;	// we will then map the amplitude value to this range
	}
	return self;
}

- (void)dealloc {
	
	[envelope release];
	[super dealloc];
}

- (CGFloat)_decibelEarResponceForFrequency:(CGFloat)freq {
	
	CGFloat val = [envelope evalAtTime:freq];
	return val;
}

// dB = 20*log(amplitude/amplitude_reference)

// -6.0205db = 20* log(0.5amp/1.0amp)

// invLog(-6.0205db/20) = Xamp/1.0amp

// 10^(-6.0205db/20) = Xamp/1.0amp
+ (CGFloat)decibelToAmplitudeOverReferenceAmplitude:(CGFloat)decibel {
	return powf( 10.0f, decibel/20.0f ); //  = Xamp/1.0amp;
}

- (CGFloat)_earAmplitudeResponceForFrequency:(CGFloat)freq {
	
	CGFloat val = [self _decibelEarResponceForFrequency:freq];
	return [AmplitudeCurve decibelToAmplitudeOverReferenceAmplitude:val] / _referenceAmplitude;
}

- (CGFloat)mapEarResponseToAmplitudeForFreq:(CGFloat)freq {

	CGFloat maxEarResponse = 2.2f;
	CGFloat highValue = _maxAmp-_minAmp;
		
	CGFloat earAmp = [self _earAmplitudeResponceForFrequency:freq];

	// get a value between 0 and (maxAmp-minAmp)
	CGFloat normalValue = earAmp * (highValue / maxEarResponse);
	CGFloat oneMinusNormal = highValue-normalValue;
	CGFloat offsetValue = _minAmp + oneMinusNormal;
	return offsetValue;
}

@end
