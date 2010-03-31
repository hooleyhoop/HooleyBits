//
//  KeySignature.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/16/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "KeySignature.h"
#import "Note.h"
#import "Clef.h"

static int majorSharps[18] = {3, -1, -1, 5, -1, 0, 7, -1, 2, -1, -1, 4, -1, 6, -1, 1, -1, -1};
static int majorFlats[18] = {-1, -1, 2, -1, 7, 0, -1, 5, -1, -1, 3, -1, 1, -1, 6, -1, -1, 4};
static int minorSharps[18] = {0, 7, -1, 2, -1, -1, 4, -1, -1, 6, -1, 1, -1, 3, -1, -1, 5, -1};
static int minorFlats[18] = {0, -1, 5, -1, -1, 3, -1, -1, 1, -1, 6, -1, 4, -1, -1, 2, -1, 7};
static int root[18] = {0, 1, 1, 2, 2, 3, 4, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11, 11};
static int base[7] = {0, 2, 4, 5, 7, 9, 11};
static int sharpLocs[7] = {3, 0, 4, 1, 5, 2, 6};
static int sharpVisLocs[7] = {8, 5, 9, 6, 3, 7, 4};
static int flatLocs[7] = {6, 2, 5, 1, 4, 0, 3};
static int flatVisLocs[7] = {4, 7, 3, 6, 2, 5, 1};

@implementation KeySignature

+ (id)getSignatureWithSharps:(int)sharps minor:(BOOL)minorArg {

	static NSMutableDictionary *cachedMajorSharps;
	static NSMutableDictionary *cachedMinorSharps;
	if(nil == cachedMajorSharps){
		cachedMajorSharps = [[NSMutableDictionary dictionaryWithCapacity:8] retain];
	}
	if(nil == cachedMinorSharps){
		cachedMinorSharps = [[NSMutableDictionary dictionaryWithCapacity:8] retain];
	}
	NSMutableDictionary *cachedSharps = minorArg ? cachedMinorSharps : cachedMajorSharps;
	id sig = [cachedSharps objectForKey:[NSNumber numberWithInt:sharps]];
	if(nil == sig){
		int pitches[7];
		int i;
		for(i=0; i<7; i++){
			pitches[i] = base[i];
		}
		for(i=0; i<sharps; i++){
			pitches[sharpLocs[i]]++;		
		}
		sig = [[[KeySignature alloc] initWithPitches:pitches sharps:sharps flats:0 minor:minorArg] autorelease];
		[cachedSharps setObject:sig forKey:[NSNumber numberWithInt:sharps]];
	}
	return sig;
}

+ (id)getSignatureWithFlats:(int)flats minor:(BOOL)minorArg {
    
	static NSMutableDictionary *cachedMajorFlats;
	static NSMutableDictionary *cachedMinorFlats;
	if(nil == cachedMajorFlats){
		cachedMajorFlats = [[NSMutableDictionary dictionaryWithCapacity:8] retain];
	}
	if(nil == cachedMinorFlats){
		cachedMinorFlats = [[NSMutableDictionary dictionaryWithCapacity:8] retain];
	}
	NSMutableDictionary *cachedFlats = minorArg ? cachedMinorFlats : cachedMajorFlats;
	id sig = [cachedFlats objectForKey:[NSNumber numberWithInt:flats]];
	if(nil == sig){
		int pitches[7];
		int i;
		for(i=0; i<7; i++){
			pitches[i] = base[i];
		}
		for(i=0; i<flats; i++){
			pitches[flatLocs[i]]--;		
		}
		sig = [[[KeySignature alloc] initWithPitches:pitches sharps:0 flats:flats minor:minorArg] autorelease];
		[cachedFlats setObject:sig forKey:[NSNumber numberWithInt:flats]];
	}
	return sig;
}

//+ (id)getMajorSignatureAtIndexFromA:(int)index{
//	int sharps = majorSharps[index];
//	if(sharps == -1){
//		int flats = majorFlats[index];
//		if(flats == -1){
//			return nil;
//		} else{
//			return [KeySignature getSignatureWithFlats:flats minor:NO];
//		}
//	} else{
//		return [KeySignature getSignatureWithSharps:sharps minor:NO];
//	}
//}
//
//+ (id)getMinorSignatureAtIndexFromA:(int)index{
//	int sharps = minorSharps[index];
//	if(sharps == -1){
//		int flats = minorFlats[index];
//		if(flats == -1){
//			return nil;
//		} else{
//			return [KeySignature getSignatureWithFlats:flats minor:YES];
//		}
//	} else{
//		return [KeySignature getSignatureWithSharps:sharps minor:YES];
//	}
//}
//
//- (BOOL)isEqualTo:(id)other{
//	if(![other isKindOfClass:[self class]]){
//		return false;
//	}
//	int i;
//	for(i = 0; i < 8; i++){
//		if(pitches[i] != [other getPitchAtPosition:i]){
//			return false;
//		}
//	}
//	return true;
//}
//
//- (int)distanceFrom:(KeySignature *)otherSig{
//	int thisRoot = root[[self getIndexFromA]];
//	int otherRoot = root[[otherSig getIndexFromA]];
//	if(thisRoot < otherRoot){
//		int distance = otherRoot - thisRoot;
//		if(distance < 12 - distance){
//			return -distance;
//		} else {
//			return 12 - distance;
//		}
//	} else {
//		int distance = thisRoot - otherRoot;
//		if(distance < 12 - distance){
//			return distance;
//		} else {
//			return distance - 12;
//		}
//	}
//}
//
//- (int)getIndexFromA{
//	int i;
//	if(sharps != 0){
//		if(!_minor){
//			for(i=0; i<18; i++){
//				if(majorSharps[i] == sharps) return i;
//			}			
//		} else{
//			for(i=0; i<18; i++){
//				if(minorSharps[i] == sharps) return i;
//			}			
//		}
//		return 0;
//	} else if(flats != 0){
//		if(!_minor){
//			for(i=0; i<18; i++){
//				if(majorFlats[i] == flats) return i;
//			}
//		} else{
//			for(i=0; i<18; i++){
//				if(minorFlats[i] == flats) return i;
//			}			
//		}
//		return 0;
//	} else if(_minor){
//		return 0;
//	} else{
//		return 5;
//	}
//}

- (BOOL)isMinor{
	return _minor;
}

- (int)getPitchAtPosition:(int)position {
	return _pitches[position];
}

- (int)getAccidentalAtPosition:(int)position {
    
	if(_pitches[position] < base[position]) return FLAT;
	if(_pitches[position] > base[position]) return SHARP;
	return NO_ACC;
}

- (int)positionForPitch:(int)pitch preferAccidental:(int)accidental {
	int i;
	if(accidental == SHARP){
		if(_pitches[6] + 1 == pitch && [self getAccidentalAtPosition:6] != SHARP){
			return 6;
		}
		for(i=0; i < 7; i++){
			if(_pitches[i] + 1 == pitch && [self getAccidentalAtPosition:i] != SHARP){
				return i;
			}
		}
	} else if(accidental == FLAT){
		if(_pitches[0] - 1 == pitch - 12 && [self getAccidentalAtPosition:0] != FLAT){
			return 0;
		}
		for(i=0; i < 7; i++){
			if(_pitches[i] - 1 == pitch && [self getAccidentalAtPosition:i] != FLAT){
				return i;
			}
		}
	}
	for(i=0; i < 7; i++){
		if(_pitches[i] >= pitch){
			if(_pitches[i] > pitch && [self getAccidentalAtPosition:i] == FLAT){
				return (i-1) % 7;
			}
			return i;
		}
	}
	return 0;
}

- (int)accidentalForPitch:(int)pitch atPosition:(int)position {
    
	int pitchAtPos = [self getPitchAtPosition:position];
	if(pitchAtPos > pitch || (pitch == 11 && pitchAtPos == 0)){
		if([self getAccidentalAtPosition:position] == SHARP){
			return NATURAL;
		} else if([self getAccidentalAtPosition:position] == FLAT){
			return NO_ACC;
		}
		return FLAT;
	} else if(pitchAtPos < pitch || (pitchAtPos == 11 && pitch == 0)){
		if([self getAccidentalAtPosition:position] == FLAT){
			return NATURAL;
		} else if([self getAccidentalAtPosition:position] == SHARP){
			return NO_ACC;
		}
		return SHARP;
	} else {
		return NO_ACC;
	}
}

//- (int)getNumSharps{
//	return sharps;
//}
//
//- (int)getNumFlats{
//	return flats;
//}
//
//- (NSArray *)getSharpsWithClef:(Clef *)clef{
//	NSMutableArray *sharpsArray = [NSMutableArray arrayWithCapacity:sharps];
//	int i;
//	for(i=0; i<sharps; i++){
//		[sharpsArray addObject:[[[NSNumber alloc] initWithInt:(sharpVisLocs[i] + [clef getKeySigOffset])] autorelease]];
//	}
//	return sharpsArray;
//}
//
//- (NSArray *)getFlatsWithClef:(Clef *)clef{
//	NSMutableArray *flatsArray = [NSMutableArray arrayWithCapacity:flats];
//	int i;
//	for(i=0; i<flats; i++){
//		[flatsArray addObject:[[[NSNumber alloc] initWithInt:(flatVisLocs[i] + [clef getKeySigOffset])] autorelease]];
//	}
//	return flatsArray;
//}

- (id)initWithPitches:(int *)pitchesArg sharps:(int)sharpsArg flats:(int)flatsArg minor:(BOOL)minorArg {
    
	if(self = [super init]){
		int i;
		for(i=0; i<7; i++){
			_pitches[i] = pitchesArg[i];
		}
		_sharps = sharpsArg;
		_flats = flatsArg;
		_minor = minorArg;
	}
	return self;
}

//- (void)addToLilypondString:(NSMutableString *)string{
//	NSString *lyPitches[] = {@"a", @"ais", @"bes", @"b", @"ces", @"c", @"cis", @"des", @"d", @"dis", @"ees", @"e", @"f", @"fis", @"ges", @"g", @"gis", @"aes"};
//	[string appendFormat:@"\\key %@ \\%@ ", lyPitches[[self getIndexFromA]], (_minor ? @"minor" : @"major")];
//}
//
//- (void)addToMusicXMLString:(NSMutableString *)string{
//	[string appendString:@"<key>\n"];
//	if(flats != 0){
//		[string appendFormat:@"<fifths>-%d</fifths>\n", flats];
//	} else {
//		[string appendFormat:@"<fifths>%d</fifths>\n", sharps];
//	}
//	if(_minor){
//		[string appendString:@"<mode>minor</mode>\n"];
//	} else {
//		[string appendString:@"<mode>major</mode>\n"];
//	}
//	[string appendString:@"</key>\n"];
//}

@end
