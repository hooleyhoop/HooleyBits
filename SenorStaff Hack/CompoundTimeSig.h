//
//  CompoundTimeSig.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 1/8/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TimeSignature.h"

@interface CompoundTimeSig : TimeSignature {
	TimeSignature *firstSig, *secondSig;
}

-(id)initWithFirstSig:(TimeSignature *)_firstSig secondSig:(TimeSignature *)_secondSig;

-(TimeSignature *)firstSig;
-(TimeSignature *)secondSig;

@end
