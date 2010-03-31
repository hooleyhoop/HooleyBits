//
//  NoteBase.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/31/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "NoteBase.h"
#import "Staff.h"
#import "Measure.h"

@implementation NoteBase

- (int)getDuration {
	return duration;
}

- (BOOL)getDotted {
	return dotted;
}

- (void)setDuration:(int)_duration {
	duration = _duration;
}

//- (void)setDotted:(BOOL)_dotted {
//	
//	[[[self undoManager] prepareWithInvocationTarget:self] setDotted:dotted];
//	dotted = _dotted;
//	Measure *measure = [staff getMeasureContainingNote:self];
//	[measure refreshNotes:self];
//	[measure grabNotesFromNextMeasure];
//}
//
//- (void)setDottedSilently:(BOOL)_dotted{
//	dotted = _dotted;
//}

- (Staff *)getStaff{
	return staff;
}

- (void)setStaff:(Staff *)_staff{
	staff = _staff;
}

- (NSUndoManager *)undoManager {

	return [[[self getStaff].song document] undoManager];
}

//- (void)sendChangeNotification{
//	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"modelChanged" object:self]];
//}

- (float)getEffectiveDuration {
	
	if([self getDuration] == 0) {
		return 0;
	}
	float effDuration = 3.0 / (float)[self getDuration];
	if([self getDotted]){
		 effDuration *= 1.5;
	}
	return effDuration;
}

- (BOOL)canBeInChord {
	return YES;
}

//- (BOOL)isTriplet{
//	return [self getDuration] % 3 == 0;
//}
//
//- (BOOL)isPartOfFullTriplet{
//	return [self getContainingTriplet] != nil;
//}
//
//- (BOOL)isDrawBars{
//	return NO;
//}
//
//- (NSArray *)getContainingTriplet{
//	// find first triplet note in sequence leading up to this note
//	NoteBase *curr = self;
//	NoteBase *prev;
//	for(prev = [staff noteBefore:curr]; prev != nil && [prev isTriplet]; prev = [staff noteBefore:curr]){
//		curr = prev;
//	}
//	BOOL foundSelf = NO;
//	float tripletDuration = 0;
//	NSMutableArray *triplet = [NSMutableArray array];
//	// try to construct a full triplet
//	while([curr isTriplet]){
//		if(curr == self){
//			foundSelf = YES;
//		}
//		[triplet addObject:curr];
//		tripletDuration += [curr getEffectiveDuration];
//		// tripletDuration / 3.0 gives the "real" effective duration
//		// reciprocal of that is the denominator of the duration
//		// a full triplet has been completed if the denominator is a power of 2.
//		float denom = 3.0 / tripletDuration;
//		int denomAsInt = (int)denom;
//		if((denom - floor(denom) < 0.005) &&
//		   (denomAsInt & (denomAsInt - 1)) == 0){
//			if(foundSelf){
//				return triplet;
//			}
//			[triplet removeAllObjects];
//			tripletDuration = 0;
//		}
//		curr = [staff noteAfter:curr];
//	}
//	return nil;	
//}
//
//- (float)addToMIDITrack:(MusicTrack *)musicTrack atPosition:(float)pos
//	   withKeySignature:(KeySignature *)sig accidentals:(NSMutableDictionary *)accidentals
//			  transpose:(int)transposition onChannel:(int)channel{
//	[self doesNotRecognizeSelector:_cmd];
//	return 0;
//}
//
//- (void)addToLilypondString:(NSMutableString *)string accidentals:(NSMutableDictionary *)accidentals{
//	NSArray *triplet = [self getContainingTriplet];
//	if([triplet objectAtIndex:0] == self){
//		[string appendString:@"\\times 2/3 {"];
//	}
//	[self addNoteToLilypondString:string accidentals:accidentals];
//	if([triplet lastObject] == self){
//		[string appendString:@"}"];
//	}
//}
//
//- (void)addNoteToLilypondString:(NSMutableString *)string accidentals:(NSMutableDictionary *)accidentals{
//	[self doesNotRecognizeSelector:_cmd];
//}
//
//- (void)transposeBy:(int)numLines{
//	[self doesNotRecognizeSelector:_cmd];
//}
//
//- (void)transposeBy:(int)numHalfSteps oldSignature:(KeySignature *)oldSig newSignature:(KeySignature *)newSig{
//	[self doesNotRecognizeSelector:_cmd];
//}

- (void)prepareForDelete{
	
}

- (NSArray *)subtractDuration:(float)maxDuration {
	
	NSMutableArray *remainingNotes = [NSMutableArray array];
	float remainingDuration = [self getEffectiveDuration] - maxDuration;
	NoteBase *lastNote = nil;
	while(remainingDuration > 0){
		NoteBase *newNote = [self copy];
		if(![newNote tryToFill:remainingDuration]) {
			break;
		}
		remainingDuration -= [newNote getEffectiveDuration];
		[remainingNotes addObject:newNote];
		[lastNote tieTo:newNote];
		[newNote tieFrom:lastNote];
		lastNote = newNote;
	}
	return remainingNotes;
}

- (BOOL)tryToFill:(float)maxDuration {
	
	if(maxDuration >= 4.5){
		duration = 1;
		dotted = YES;
		return YES;
	} else if(maxDuration >= 3){
		duration = 1;
		dotted = NO;
		return YES;
	} else if(maxDuration >= 2.25){
		duration = 2;
		dotted = YES;
		return YES;
	} else if(maxDuration >= 1.5){
		duration = 2;
		dotted = NO;
		return YES;
	} else if(maxDuration >= 1.0){
		duration = 3;
		dotted = NO;
		return YES;
	} else if(maxDuration >= 0.975){
		duration = 4;
		dotted = YES;
		return YES;
	} else if(maxDuration >= 0.75){
		duration = 4;
		dotted = NO;
		return YES;
	} else if(maxDuration >= 0.5){
		duration = 6;
		dotted = NO;
		return YES;
	} else if(maxDuration >= 0.5625){
		duration = 8;
		dotted = YES;
		return YES;
	} else if(maxDuration >= 0.375){
		duration = 8;
		dotted = NO;
		return YES;
	} else if(maxDuration >= 0.25){
		duration = 12;
		dotted = NO;
		return YES;
	} else if(maxDuration >= 0.28125){
		duration = 16;
		dotted = YES;
		return YES;
	} else if(maxDuration >= 0.1875){
		duration = 16;
		dotted = NO;
		return YES;
	} else if(maxDuration >= 0.125){
		duration = 24;
		dotted = NO;
		return YES;
	} else if(maxDuration >= 0.140625){
		duration = 32;
		dotted = YES;
		return YES;
	} else if(maxDuration >= 0.09375){
		duration = 32;
		dotted = NO;
		return YES;
	} else if(maxDuration >= 0.0625){
		duration = 48;
		dotted = NO;
		return YES;
	}
	return NO;
}

// -- tie methods - do nothing by default
- (void)tieTo:(NoteBase *)note{
	
}

- (NoteBase *)getTieTo{
	return nil;
}

- (void)tieFrom:(NoteBase *)note{
	
}

- (NoteBase *)getTieFrom{
	return nil;
}

//- (void)addDurationToLilypondString:(NSMutableString *)string{
//	int duration = [self getDuration];
//	if(duration % 3 == 0) {
//		duration = duration * 2 / 3;
//	}
//	[string appendFormat:@"%d", duration];
//	if([self getDotted]){
//		[string appendString:@"."];
//	}
//	if([self getTieTo] != nil){
//		[string appendString:@"~"];
//	}
//}
//
//- (void)addToMusicXMLString:(NSMutableString *)string accidentals:(NSMutableDictionary *)accidentals{
//	[self doesNotRecognizeSelector:_cmd];
//}
//
//- (void)addDurationToMusicXMLString:(NSMutableString *)string{
//	int duration = 48 / [self getDuration];
//	if([self getDotted]){
//		duration += duration / 2;
//	}
//	[string appendFormat:@"<duration>%d</duration>\n", duration];
//	if([self isTriplet]){
//		[string appendString:@"<time-modification>\n<actual-notes>3</actual-notes>\n<normal-notes>2</normal-notes>\n</time-modification>\n"];
//	}
//}
//
//- (Class)getViewClass{
//	[self doesNotRecognizeSelector:_cmd];
//	return [NSObject class];
//}
//
//- (Class)getControllerClass{
//	return [NoteController class];
//}
//
//- (NSString *) description {
//	NSMutableString *str = [NSMutableString string];
//	[self addToMusicXMLString:str];
//	return str;
//}

@end
