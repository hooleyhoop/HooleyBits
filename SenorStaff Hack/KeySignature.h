//
//  KeySignature.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/16/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Clef;

@interface KeySignature : NSObject {
    
	int _pitches[7];
	int _sharps, _flats;
	BOOL _minor;
}

//+ (id)getMajorSignatureAtIndexFromA:(int)index;
//+ (id)getMinorSignatureAtIndexFromA:(int)index;
+ (id)getSignatureWithSharps:(int)sharps minor:(BOOL)_minor;
+ (id)getSignatureWithFlats:(int)flats minor:(BOOL)minor;

- (id)initWithPitches:(int *)_pitches sharps:(int)_sharps flats:(int)_flats minor:(BOOL)_minor;

- (int)getPitchAtPosition:(int)position;
- (int)getAccidentalAtPosition:(int)position;

- (int)positionForPitch:(int)pitch preferAccidental:(int)accidental;
- (int)accidentalForPitch:(int)pitch atPosition:(int)position;

//- (int)getNumSharps;
//- (int)getNumFlats;
//- (NSArray *)getSharpsWithClef:(Clef *)clef;
//- (NSArray *)getFlatsWithClef:(Clef *)clef;
//
//- (int)distanceFrom:(KeySignature *)otherSig;
//
//- (int)getIndexFromA;
- (BOOL)isMinor;

//- (void)addToLilypondString:(NSMutableString *)string;
//- (void)addToMusicXMLString:(NSMutableString *)string;

@end
