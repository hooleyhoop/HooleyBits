//
//  AmplitudeCurve.h
//  iphonePlay
//
//  Created by steve hooley on 16/03/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "SHooleyObject.h"

@class LWEnvelope;
@interface AmplitudeCurve : SHooleyObject {

	LWEnvelope *envelope;

	CGFloat _referenceAmplitude;
	CGFloat _maxAmp, _minAmp;
}

@property (nonatomic, readwrite) CGFloat minAmp, maxAmp;

+ (CGFloat)decibelToAmplitudeOverReferenceAmplitude:(CGFloat)decibel;

- (CGFloat)_decibelEarResponceForFrequency:(CGFloat)freq;

- (CGFloat)_earAmplitudeResponceForFrequency:(CGFloat)freq;

- (CGFloat)mapEarResponseToAmplitudeForFreq:(CGFloat)freq;

@end
