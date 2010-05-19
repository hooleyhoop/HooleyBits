//
//  TemperedScale.h
//  iphonePlay
//
//  Created by steve hooley on 12/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "SHooleyObject.h"
#import "NoteLookupProtocol.h"

@interface TemperedScale : SHooleyObject <NoteLookupProtocol> {

}

+ (TemperedScale *)temperedScale;

// f = 2^(n/12) × 440 Hz
- (CGFloat)hzForStepsAbove440:(int)steps;
- (CGFloat)hzForStepsAboveA4:(int)steps;

// p = 69 + 12 × log2 (f / (440 Hz))
- (CGFloat)midiNoteForHz:(CGFloat)freq;

@end
