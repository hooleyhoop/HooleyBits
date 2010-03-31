//
//  Chord.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 9/30/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "Chord.h"
//#import <Chomp/Chomp.h>
@class ChordDraw;
@class ChordController;

@implementation Chord

- (id)initWithStaff:(Staff *)_staff {
	if(self = [super init]){
		staff = _staff;
		notes = [[NSMutableArray arrayWithCapacity:3] retain];
	}
	return self;
}

- (id)initWithStaff:(Staff *)_staff withNotes:(NSMutableArray *)_notes {
	if(self = [super init]){
		staff = _staff;
		notes = [[NSMutableArray arrayWithArray:_notes] retain];
	}
	return self;
}

- (id)initWithStaff:(Staff *)_staff withNotes:(NSArray *)_notes copyItems:(BOOL)_copyItems {
	if(self = [super init]){
		staff = _staff;
		notes = [[[NSMutableArray alloc] initWithArray:_notes copyItems:_copyItems] retain];
	}
	return self;
}

//- (id)copyWithZone:(NSZone *)zone{
//	return [[Chord allocWithZone:zone] initWithStaff:staff withNotes:notes copyItems:YES];
//}
//
//- (void)setStaff:(Staff *)_staff{
//	[super setStaff:_staff];
//	[[notes do] setStaff:_staff];
//}
//
//- (int)getDuration{
//	if([notes count] > 0){
//		return [[notes objectAtIndex:0] getDuration];
//	} else{
//		return 0;
//	}
//}

- (BOOL)getDotted {
	
	if([notes count] > 0){
		return [[notes objectAtIndex:0] getDotted];
	} else{
		return NO;
	}
}

//- (BOOL)isDrawBars{
//	if([notes count] > 0){
//		return [[notes objectAtIndex:0] isDrawBars];
//	} else{
//		return NO;
//	}
//}

- (void)setDuration:(int)_duration{

	NoteBase *note;
	for (note in notes) {
		[note setDuration:_duration];
	}
}

//- (void)setDotted:(BOOL)_dotted {
//
//	NoteBase *note;
//	for (note in notes) {
//		[note setDotted:_dotted];
//	}
//}

//- (void)setDottedSilently:(BOOL)_dotted {
//
//	NoteBase *note;
//	for (note in notes) {
//		[note setDottedSilently:_dotted];
//	}
//}

//- (float)addToMIDITrack:(MusicTrack *)musicTrack atPosition:(float)pos
//	   withKeySignature:(KeySignature *)sig accidentals:(NSMutableDictionary *)accidentals
//			  transpose:(int)transposition onChannel:(int)channel{
//	[[notes do] addToMIDITrack:musicTrack atPosition:pos withKeySignature:sig 
//				   accidentals:accidentals transpose:transposition onChannel:channel];
//	return 4.0 * [self getEffectiveDuration] / 3;
//}
//
//- (void)transposeBy:(int)numLines{
//	[[notes do] transposeBy:numLines];
//}
//
//- (void)transposeBy:(int)numHalfSteps oldSignature:(KeySignature *)oldSig newSignature:(KeySignature *)newSig{
//	[[notes do] transposeBy:numHalfSteps oldSignature:oldSig newSignature:newSig];
//}

- (void)prepareForDelete{

	[notes makeObjectsPerformSelector:@selector(prepareForDelete)];
}

- (void)sendChangeNotification{
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"modelChanged" object:self]];
}

- (NSArray *)subtractDuration:(float)maxDuration {
	
	NSMutableArray *remainingNotes = [NSMutableArray array];
    NoteBase *nt;
    for(nt in notes){
        [remainingNotes addObject:[nt subtractDuration:maxDuration]];
    }
	NSMutableArray *remainingChords = [[NSMutableArray arrayWithCapacity:[remainingNotes count]] autorelease];
	int i;
	for(i=0; i<[[remainingNotes objectAtIndex:0] count]; i++)
    {
		NSMutableArray *newChordNotes = [NSMutableArray array];
		NSEnumerator *notesEnum = [remainingNotes objectEnumerator];
		id noteArr;
		while(noteArr = [notesEnum nextObject]){
			if([noteArr count] > i){
				[newChordNotes addObject:[noteArr objectAtIndex:i]];
			}
		}
		[remainingChords addObject:[[[Chord alloc] initWithStaff:staff withNotes:newChordNotes] autorelease]];
	}
	return remainingChords;
}

- (void)tryToFill:(float)maxDuration {

    NoteBase *nt;
    for (nt in notes){
        [nt tryToFill:maxDuration];
    }
}

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

- (NSArray *)notes {
	return notes;
}

//- (NoteBase *)highestNote{
//	NoteBase *highestNote = nil;
//	NSEnumerator *notesEnum = [notes objectEnumerator];
//	id note;
//	while(note = [notesEnum nextObject]){
//		if(highestNote == nil || [note isHigherThan:highestNote]){
//			highestNote = note;
//		}
//	}
//	return highestNote;
//}
//
//- (NoteBase *)lowestNote{
//	NoteBase *lowestNote = nil;
//	NSEnumerator *notesEnum = [notes objectEnumerator];
//	id note;
//	while(note = [notesEnum nextObject]){
//		if(lowestNote == nil || [note isLowerThan:lowestNote]){
//			lowestNote = note;
//		}
//	}
//	return lowestNote;
//}

- (void)setNotes:(NSMutableArray *)_notes {
	[self prepUndo];
	if(![notes isEqual:_notes]){
		[notes release];
		notes = [_notes retain];
	}
	[self sendChangeNotification];
}

- (void)prepUndo{
	[[[self undoManager] prepareWithInvocationTarget:self] setNotes:[NSMutableArray arrayWithArray:notes]];	
}

- (void)addNote:(NoteBase *)note {
	
	[self prepUndo];
	if([self getDuration] != 0){
		[note setDuration:[self getDuration]];		
//		[note setDotted:[self getDotted]];
	}
	if([note respondsToSelector:@selector(notes)])
    {
        NSArray *someNotes = [note notes];
        NoteBase *nt;
        for(nt in someNotes){
            [notes addObject:nt];
        }
	} else {
		[notes addObject:note];
	}
	[self sendChangeNotification];
}

//- (void)removeNote:(NoteBase *)note{
//	[self prepUndo];
//	[notes removeObject:note];
//	[self sendChangeNotification];
//}

- (int)getEffectivePitchWithKeySignature:(KeySignature *)keySig priorAccidentals:(NSMutableDictionary *)accidentals {
    
    NoteBase *nt;
    for(nt in notes){
        [nt  getEffectivePitchWithKeySignature:keySig priorAccidentals:accidentals];
    }
	return 0;
}

- (NoteBase *)getNoteMatching:(NoteBase *)note {
	
	NSEnumerator *notesEnum = [notes objectEnumerator];
	id chordNote;
	while(chordNote = [notesEnum nextObject]){
		if([chordNote respondsToSelector:@selector(pitchMatches:)] && [chordNote pitchMatches:note]){
			return chordNote;
		}
	}
	return nil;
}

//- (int)getLastPitch{
//	return [[notes objectAtIndex:0] getLastPitch];
//}
//
//- (int)getLastOctave{
//	return [[notes objectAtIndex:0] getLastOctave];
//}
//
//- (void)setPitch:(int)pitch octave:(int)octave finished:(BOOL)finished{
//	int delta = (octave * 7 + pitch) - ([[notes objectAtIndex:0] getLastOctave] * 7 + [[notes objectAtIndex:0] getLastPitch]);
//	NSEnumerator *notesEnum = [notes objectEnumerator];
//	id note;
//	while(note = [notesEnum nextObject]){
//		int lastPitch = [note getLastPitch];
//		int lastOctave = [note getLastOctave];
//		int newAbsPitch = (lastOctave * 7 + lastPitch) + delta;
//		int newPitch = newAbsPitch % 7;
//		int newOctave = newAbsPitch / 7;
//		[note setPitch:newPitch octave:newOctave finished:finished];
//	}
//}
//
//- (void)addNoteToLilypondString:(NSMutableString *)string accidentals:(NSMutableDictionary *)accidentals{
//	if(![staff isDrums]){
//		[string appendString:@"<"];
//		NSEnumerator *notesEnum = [notes objectEnumerator];
//		id note;
//		while(note = [notesEnum nextObject]){
//			[note addPitchToLilypondString:string accidentals:accidentals];
//			if([note getTieTo] != nil){
//				[string appendString:@"~"];
//			}
//			[string appendString:@" "];
//		}
//		[string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
//		[string appendString:@">"];
//		[self addDurationToLilypondString:string];
//		[string appendString:@" "];
//	} else {
//		[string appendString:@"<<"];
//		NSEnumerator *notesEnum = [notes objectEnumerator];
//		id note;
//		while(note = [notesEnum nextObject]){
//			[note addPitchToLilypondString:string accidentals:accidentals];
//			[note addDurationToLilypondString:string];
//			[string appendString:@" "];
//		}
//		[string appendString:@">> "];
//	}
//}
//
//- (void)addToMusicXMLString:(NSMutableString *)string accidentals:(NSMutableDictionary *)accidentals{
//	NSEnumerator *notesEnum = [notes objectEnumerator];
//	BOOL first = YES;
//	id note;
//	while(note = [notesEnum nextObject]){
//		[note addToMusicXMLString:string accidentals:accidentals chord:(!first)];
//		first = NO;
//	}
//}
//
//- (void)encodeWithCoder:(NSCoder *)coder{
//	[coder encodeObject:notes forKey:@"notes"];
//}
//
//- (id)initWithCoder:(NSCoder *)coder{
//	if(self = [super init]){
//		[self setNotes:[coder decodeObjectForKey:@"notes"]];
//	}
//	return self;
//}
//
//- (Class)getViewClass{
//	return [ChordDraw class];
//}
//
//- (Class)getControllerClass{
//	return [ChordController class];
//}

- (void)dealloc {
    
	[notes release];
	notes = nil;
	[super dealloc];
}

@end
