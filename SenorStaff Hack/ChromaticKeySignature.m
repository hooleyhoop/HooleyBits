//
//  ChromaticKeySignature.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 12/3/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "ChromaticKeySignature.h"
#import "Note.h"

static ChromaticKeySignature *instance;

@implementation ChromaticKeySignature

+ (KeySignature *)instance {
	if(instance == nil){
		instance = [[ChromaticKeySignature alloc] init];
	}
	return instance;
}

- (int)getPitchAtPosition:(int)position {
	return position;
}

- (int)positionForPitch:(int)pitch preferAccidental:(int)accidental {
	return pitch;
}

- (int)getAccidentalAtPosition:(int)position {
	return NO_ACC;
}

@end
