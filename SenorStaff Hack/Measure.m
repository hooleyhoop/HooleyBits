//
//  Measure.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

//#import <Chomp/Chomp.h>
#import "Measure.h"
#import "Note.h"
#import "Chord.h"
//#import "Clef.h"
//#import "DrumKit.h"
#import "Staff.h"
#import "TimeSignature.h"
//#import "TempoData.h"
//#import "NSView+Fade.h"
//@class MeasureDraw;
//@class DrumMeasureDraw;
//@class MeasureController;
//@class DrumMeasureController;

@interface Measure (PrivateMethods)
//- (void)updateKeySigPanel;
@end

@implementation Measure

@synthesize staff = _staff;
@synthesize keySignature = keySig;

- (id)initWithStaff:(Staff *)staff {
    
	if((self = [super init])){
		notes = [[NSMutableArray array] retain];
		_staff = staff;
		cachedNoteGroups = nil;
	}
	return self;
}

- (void)dealloc {
    
//	[clef release];
	[keySig release];
	[notes release];
//	[anim release];
	[cachedNoteGroups release];
	[super dealloc];
}

- (void)clearCaches {
	[cachedNoteGroups release];
	cachedNoteGroups = nil;
}

- (Staff *)getStaff {
	return _staff;
}

- (NSUndoManager *)undoManager{
	return [[self.staff.song document] undoManager];
}

- (void)sendChangeNotification {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"modelChanged" object:self]];
}

- (NSMutableArray *)notes {
	return notes;
}

- (NoteBase *)getFirstNote {
	return [notes objectAtIndex:0];
}

- (void)prepUndo {
	[[[self undoManager] prepareWithInvocationTarget:self] setNotes:[NSMutableArray arrayWithArray:notes]];	
}

- (void)setNotes:(NSMutableArray *)_notes {
    
	[self clearCaches];
	[self prepUndo];
	if(![notes isEqual:_notes]){
		[notes release];
		notes = [_notes retain];
		[_staff cleanEmptyMeasures];
	}
	[self sendChangeNotification];
}

- (float)getTotalDuration {
    
	float totalDuration = 0;
	NSEnumerator *notesEnum = [notes objectEnumerator];
	id note;
	while(note = [notesEnum nextObject]){
		totalDuration += [note getEffectiveDuration];
	}
	return totalDuration;
}

- (void)addNote:(NoteBase *)_note atIndex:(float)index tieToPrev:(BOOL)tieToPrev {
    
	[self clearCaches];
	[self prepUndo];
	if(((int)(index * 2)) % 2 == 0){
		if(![_note canBeInChord]){
			[self addNote:_note atIndex:(index - 0.5) tieToPrev:tieToPrev];
		} else {
			[[self undoManager] setActionName:@"changing note to chord"];
			[self addNote:_note toChordAtIndex:index];
		}
	} else{
		Note *firstAddedNote = [self addNotesInternal:[NSArray arrayWithObject:_note] atIndex:index consolidate:NO];
		Measure *measure = [_staff getMeasureContainingNote:firstAddedNote];
		if(tieToPrev){
			Note *tie = [_staff findPreviousNoteMatching:firstAddedNote inMeasure:measure];
			[firstAddedNote tieFrom:tie];
			[tie tieTo:firstAddedNote];
		}
		if([measure isFull]) 
            [_staff getMeasureAfter:measure createNew:YES];
	}
}

//- (NoteBase *)addNotes:(NSArray *)_notes atIndex:(float)index{
//	[self clearCaches];
//	[self prepUndo];
//	return [self addNotesInternal:_notes atIndex:index consolidate:YES];
//}

- (NoteBase *)addNotesInternal:(NSArray *)_notes atIndex:(float)index consolidate:(BOOL)consolidate {
	[self clearCaches];
	NSEnumerator *notesEnum = [_notes reverseObjectEnumerator];
	NoteBase *note;
	index = ceil(index);
	
	// break tie if necessary
	Note *prevNote = nil, *nextNote = nil;
	if(index-1 >= 0){
		prevNote = [notes objectAtIndex:index-1];
		nextNote = [prevNote getTieTo];
	} else if(index < [notes count]){
		nextNote = [notes objectAtIndex:index];
		prevNote = [nextNote getTieFrom];		
	}
	if(prevNote != nil && nextNote != nil && ![_notes containsObject:prevNote] && ![_notes containsObject:nextNote]){
		if([prevNote isEqualTo:[_notes objectAtIndex:0]]){
			[prevNote tieTo:[_notes objectAtIndex:0]];
			[[_notes objectAtIndex:0] tieFrom:prevNote];
		} else{
			[prevNote tieTo:nil];
		}
		if([nextNote isEqualTo:[_notes lastObject]]){
			[[_notes lastObject] tieTo:nextNote];
			[nextNote tieFrom:[_notes lastObject]];
		} else{
			[nextNote tieFrom:nil];
		}
	}
	
	NoteBase *lastNoteAdded = nil;
	while(note = [notesEnum nextObject]){
		if(consolidate && [note getTieFrom] != nil && [notes containsObject:[note getTieFrom]]){
			[self consolidateNote:note];
		} else{
			[notes insertObject:note atIndex:index];
			lastNoteAdded = note;
		}
	}
	if(consolidate && [lastNoteAdded getTieTo] != nil && [notes containsObject:[lastNoteAdded getTieTo]]){
		[notes removeObject:[lastNoteAdded getTieTo]];
		[self consolidateNote:[lastNoteAdded getTieTo]];
	}
	if(index >= [notes count]) return nil;
	NoteBase *rtn = [notes objectAtIndex:index];
	return [self refreshNotes:rtn];
}

- (void)consolidateNote:(NoteBase *)note {

	[self clearCaches];
	NoteBase *oldNote = [note getTieFrom];
	int index = [notes indexOfObject:oldNote];
	NoteBase *noteToAdd = [note copy];
	float targetDuration = [oldNote getEffectiveDuration] + [note getEffectiveDuration];
	[noteToAdd tryToFill:targetDuration];

	NSMutableArray *remainingNotes = [NSMutableArray array];
	float totalDuration = [noteToAdd getEffectiveDuration];
	NoteBase *lastNote = noteToAdd;
	while(totalDuration < targetDuration){
		NoteBase *additionalNote = [lastNote copy];
		[additionalNote tryToFill:(targetDuration - totalDuration)];
		[lastNote tieTo:additionalNote];
		[additionalNote tieFrom:lastNote];
		lastNote = additionalNote;
		totalDuration += [additionalNote getEffectiveDuration];
		[remainingNotes addObject:additionalNote];
	}
	
	[noteToAdd tieFrom:[oldNote getTieFrom]];
	[[oldNote getTieFrom] tieTo:noteToAdd];
	
	if([remainingNotes count] > 0){		
		[[remainingNotes lastObject] tieTo:[note getTieTo]];
		[[note getTieTo] tieFrom:[remainingNotes lastObject]];
	
		[notes insertObjects:remainingNotes atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index + 1, [remainingNotes count])]];
	} else {
		[[note getTieTo] tieFrom:noteToAdd];
		[noteToAdd tieTo:[note getTieTo]];
	}
	
	[notes replaceObjectAtIndex:index withObject:noteToAdd];
}

- (NoteBase *)refreshNotes:(NoteBase *)rtn {

	[self clearCaches];
	float totalDuration = [self getTotalDuration];
	float maxDuration = [[self getEffectiveTimeSignature] getMeasureDuration];
	NSMutableArray *notesToPush = [NSMutableArray array];
	//	while we have too many notes
	while(totalDuration > maxDuration){
		float toRemove = totalDuration - maxDuration;
		NoteBase *lastNote = [notes lastObject];
//			if the last note is longer than we need to remove
		if([lastNote getEffectiveDuration] > toRemove){
//				remove the last note
			[notes removeLastObject];
//				get a note which is as close as possible to (but still less than) the amount we need to remove
			NoteBase *noteToPush = [lastNote copy];
			[noteToPush tryToFill:toRemove];
//				get an array of notes resulting from removing that note from the original note
			NSArray *remainingNotes = [lastNote subtractDuration:[noteToPush getEffectiveDuration]];
//				tie the last of those notes to the note we're adding
			[notes removeObject:lastNote];
			if([remainingNotes count] > 0){
				[[remainingNotes lastObject] tieTo:noteToPush];
				[noteToPush tieFrom:[remainingNotes lastObject]];
				//				add the last note to the next measure
				[notesToPush insertObject:noteToPush atIndex:0];
				//				tie the last note to whatever the old note was tied to
				[noteToPush tieTo:[lastNote getTieTo]];
				[[lastNote getTieTo] tieFrom:noteToPush];
				//				tie the first note from whatever the old note was tied from
				[[remainingNotes objectAtIndex:0] tieFrom:[lastNote getTieFrom]];
				[[lastNote getTieFrom] tieTo:[remainingNotes objectAtIndex:0]];
				//				add the array of notes to this measure
				[notes addObjectsFromArray:remainingNotes];
				//				if we just removed the first note added, update the pointer
				if(lastNote == rtn){
					rtn = [remainingNotes objectAtIndex:0];
				}
			}
		} else {
//				remove the last note
			[notes removeLastObject];
//				add it to the next measure
			[notesToPush insertObject:lastNote atIndex:0];
		}
		totalDuration = [self getTotalDuration];
	}
	
	if([notesToPush count] > 0){
		Measure *nextMeasure = [_staff getMeasureAfter:self createNew:YES];
		[nextMeasure prepUndo];
		[nextMeasure addNotesInternal:notesToPush atIndex:0 consolidate:YES];
	}
	
	return rtn;
}

- (void)grabNotesFromNextMeasure {
    
	[self clearCaches];
	if([_staff getLastMeasure] == self)
        return;
	Measure *nextMeasure = [_staff getMeasureAfter:self createNew:YES];
	[nextMeasure prepUndo];
	float totalDuration = [self getTotalDuration];
	float maxDuration = [[self getEffectiveTimeSignature] getMeasureDuration];
	while(totalDuration < maxDuration && ![nextMeasure isEmpty]){
		float durationToFill = maxDuration - totalDuration;
		NoteBase *nextNote = [nextMeasure getFirstNote];
		[nextMeasure removeNoteAtIndex:0 temporary:YES];
		NoteBase *noteToAdd;
		if([nextNote getEffectiveDuration] <= durationToFill){
			noteToAdd = nextNote;
		} else{
			noteToAdd = [nextNote copy];
			if(![noteToAdd tryToFill:durationToFill]){
				break;
			}
			NSArray *remainingNotes = [nextNote subtractDuration:[noteToAdd getEffectiveDuration]];
			if([remainingNotes count] > 0){
				[nextMeasure addNotesInternal:remainingNotes atIndex:0 consolidate:YES];
				[nextMeasure grabNotesFromNextMeasure];
				[noteToAdd tieFrom:[nextNote getTieFrom]];
				[[nextNote getTieFrom] tieTo:noteToAdd];
				[noteToAdd tieTo:[remainingNotes objectAtIndex:0]];
				[[remainingNotes objectAtIndex:0] tieFrom:noteToAdd];
				[[remainingNotes lastObject] tieTo:[nextNote getTieTo]];
				[[nextNote getTieTo] tieFrom:[remainingNotes lastObject]];
			}
		}
		if([noteToAdd getTieFrom] != nil && [notes containsObject:[noteToAdd getTieFrom]]){
			[self consolidateNote:noteToAdd];
		} else{
			[notes addObject:noteToAdd];				
		}
		totalDuration = [self getTotalDuration];
	}
}

- (void)removeNoteAtIndex:(float)x temporary:(BOOL)temp {
    
	[self clearCaches];
	NoteBase *note = [notes objectAtIndex:floor(x)];
	[self removeNote:note temporary:temp];
}

- (void)removeNote:(NoteBase *)note temporary:(BOOL)temp {
    
	[self clearCaches];
	[self prepUndo];
	if(!temp){
		[note prepareForDelete];
	}
	[notes removeObject:note];
	if(!temp){
		[self grabNotesFromNextMeasure];
		[_staff cleanEmptyMeasures];
		[self sendChangeNotification];
	}	
}

- (void)addNote:(NoteBase *)newNote toChordAtIndex:(float)index {

	[self clearCaches];
	NoteBase *note = [notes objectAtIndex:index];
	if([note isKindOfClass:[Chord class]]){
		[(Chord *)note addNote:newNote];
	} else{
		[newNote setDuration:[note getDuration]];
//		[newNote setDotted:[note getDotted]];
		NSMutableArray *chordNotes = [NSMutableArray arrayWithObjects:note, newNote, nil];
		Chord *chord = [[[Chord alloc] initWithStaff:_staff withNotes:chordNotes] autorelease];
		[notes replaceObjectAtIndex:index withObject:chord];
	}
}

//- (void)removeNote:(NoteBase *)note fromChordAtIndex:(float)index{
//	[self clearCaches];
//	NoteBase *chord = [notes objectAtIndex:index];
//	if([chord isKindOfClass:[Chord class]]){
//		if([[chord notes] containsObject:note]){
//			if([[chord notes] count] > 2){
//				[chord removeNote:note];
//			} else{
//				Note *otherNote = nil;
//				NSEnumerator *chordNotes = [[chord notes] objectEnumerator];
//				while(otherNote = [chordNotes nextObject]){
//					if(otherNote != note){
//						[notes replaceObjectAtIndex:index withObject:otherNote];
//						break;
//					}
//				}
//			}
//		}
//	} else{
//		[self removeNoteAtIndex:index temporary:NO];
//	}
//}

- (BOOL)isEmpty {
	return [notes count] == 0;
}

- (BOOL)isFull {

	float totalDuration = 0.0;
	NSEnumerator *notesEnum = [notes objectEnumerator];
	id note;
	while(note = [notesEnum nextObject]){
		totalDuration += [note getEffectiveDuration];
	}
	return totalDuration == [[self getEffectiveTimeSignature] getMeasureDuration];
}

//- (BOOL)isIsolated:(NoteBase *)note{
//	NSEnumerator *groups = [[self getNoteGroups] objectEnumerator];
//	id group;
//	while(group = [groups nextObject]){
//		if([group containsObject:note]){
//			return false;
//		}
//	}
//	return true;
//}
//
//- (NSArray *)getNoteGroups{
//	if(cachedNoteGroups != nil) {
//		return cachedNoteGroups;
//	}
//	NSMutableArray *groups = [NSMutableArray array];
//	NSMutableArray *group = [NSMutableArray array];
//	NSEnumerator *notesEnum = [notes objectEnumerator];
//	id note;
//	float durationSoFar = 0;
//	while(note = [notesEnum nextObject]){
//		durationSoFar += [note getEffectiveDuration];
//		if([note isDrawBars]){
//			if([note isPartOfFullTriplet] &&
//			   [[note getContainingTriplet] objectAtIndex:0] == note){
//				if([group count] > 1){
//					[groups addObject:group];
//				}
//				group = [NSMutableArray array];				
//			}
//			[group addObject:note];
//			// durationSoFar / 3.0 gives the "real" effective duration
//			// we're at a quarter note boundary if it's a multiple of 1/4.
//			float realDuration = durationSoFar / 3.0;
//			if((realDuration * 4 - floor(realDuration * 4) < 0.005) || ([note isPartOfFullTriplet] &&
//																		[[note getContainingTriplet] lastObject] == note)){
//				if([group count] > 1){
//					[groups addObject:group];
//				}
//				group = [NSMutableArray array];				
//			}
//		} else {
//			if([group count] > 1){
//				[groups addObject:group];
//			}
//			group = [NSMutableArray array];
//		}
//	}
//	if([group count] > 1){
//		[groups addObject:group];
//	}
//	cachedNoteGroups = [groups retain];
//	return groups;
//}
//
//- (int)indexInStaff{
//	return [self.staff.measures indexOfObject:self];
//}
//
//- (BOOL)isStartRepeat{
//	return [self.staff.song repeatStartsAt:[self indexInStaff]];
//}
//
//- (BOOL)isEndRepeat{
//	return [self.staff.song repeatEndsAt:[self indexInStaff]];
//}
//
//- (int)getNumRepeats{
//	return [self.staff.song numRepeatsEndingAt:[self indexInStaff]];
//}
//
//- (void)setStartRepeat:(BOOL)_startRepeat{
//	if(_startRepeat){
//		[[self undoManager] setActionName:@"inserting repeat"];
//		[self.staff.song startNewRepeatAt:[self indexInStaff]];		
//	} else {
//		[[self undoManager] setActionName:@"removing repeat"];
//		[self.staff.song removeRepeatStartingAt:[self indexInStaff]];
//	}
//}
//
//- (void)setEndRepeat:(int)_numRepeats{
//	if([self isEndRepeat]){
//		[[self undoManager] setActionName:@"setting repeat number"];
//	} else {		
//		[[self undoManager] setActionName:@"inserting repeat"];
//		[self.staff.song endRepeatAt:[self indexInStaff]];
//	}
//	[self.staff.song setNumRepeatsEndingAt:[self indexInStaff] to:_numRepeats];
//}
//
//- (void)removeEndRepeat{
//	[[self undoManager] setActionName:@"removing repeat"];
//	[self.staff.song removeEndRepeatAt:[self indexInStaff]];
//}
//
//- (BOOL)followsOpenRepeat{
//	return [self.staff.song repeatIsOpenAt:[self indexInStaff]];
//}
//
//- (Repeat *)getRepeatStartingHere{
//	return [self.staff.song repeatStartingAt:[self indexInStaff]];
//}
//
//- (Repeat *)getRepeatEndingHere{
//	return [self.staff.song repeatEndingAt:[self indexInStaff]];
//}
//
//- (Clef *)getClef{
//	return clef;
//}
//
//- (Clef *)getEffectiveClef{
//	return [staff getClefForMeasure:self];
//}

- (void)setClef:(Clef *)clef {
    
	if(![_clef isEqual:clef]){
		[[[self undoManager] prepareWithInvocationTarget:self] setClef:clef];
		[_clef release];
		_clef = [clef retain];
		[self sendChangeNotification];
	}
}

- (KeySignature *)getEffectiveKeySignature {
	return [_staff getKeySignatureForMeasure:self];
}

- (void)setKeySignature:(KeySignature *)sigArg {
    
	if(![keySig isEqual:sigArg]){
		[[[self undoManager] prepareWithInvocationTarget:self] setKeySignature:keySig];
		[keySig release];
		keySig = [sigArg retain];
//		[self updateKeySigPanel];
		[self sendChangeNotification];
	}
}

//- (void)keySigDelete{
//	[self setKeySignature:nil];
//}
//
//- (Measure *)getPreviousMeasureWithKeySignature{
//	return [_staff getMeasureWithKeySignatureBefore:self];
//}
//
- (TimeSignature *)getTimeSignature {
	return [_staff getTimeSignatureForMeasure:self];
}

//- (BOOL)hasTimeSignature{
//	return ![[self getTimeSignature] isKindOfClass:[NSNull class]];
//}
//
- (TimeSignature *)getEffectiveTimeSignature {
	return [_staff getEffectiveTimeSignatureForMeasure:self];
}

- (void)timeSignatureChangedFrom:(float)oldTotal to:(float)newTotal {
    
	[self clearCaches];
	if(newTotal < oldTotal){
		[self prepUndo];
		[self refreshNotes:nil];
	} else{
		[self prepUndo];
		[self grabNotesFromNextMeasure];
	}
//	[self updateTimeSigPanel];
}

//- (BOOL)isShowingKeySigPanel{
//	return keySigPanel != nil && ![keySigPanel isHidden];
//}
//
//- (NSView *)getKeySigPanel{
//	if(keySigPanel == nil){
//		[NSBundle loadNibNamed:@"KeySigPanel" owner:self];
//		[keySigPanel setHidden:YES];
//	}
//	return keySigPanel;
//}
//
//- (BOOL)isShowingTimeSigPanel{
//	return timeSigPanel != nil && ![timeSigPanel isHidden];
//}
//
//- (NSView *)getTimeSigPanel{
//	if(timeSigPanel == nil){
//		[NSBundle loadNibNamed:@"TimeSigPanel" owner:self];
//		[timeSigPanel setHidden:YES];
//	}
//	return timeSigPanel;
//}

- (NoteBase *)getNoteBefore:(NoteBase *)source {

	int index = [notes indexOfObject:source];
	if(index != NSNotFound && index > 0){
		return [notes objectAtIndex:index-1];
	}
	NSEnumerator *notesEnum = [notes objectEnumerator];
	id note;
	while(note = [notesEnum nextObject]){
		if([note isKindOfClass:[Chord class]] && [[note notes] containsObject:source]){
			return [self getNoteBefore:note];
		}
	}
	return nil;
}

//- (float)notestartDuration:(NoteBase *)note{
//	float start = 0;
//	NSEnumerator *notesEnum = [notes objectEnumerator];
//	id currNote;
//	while((currNote = [notesEnum nextObject]) && currNote != note){
//		start += [currNote getEffectiveDuration];
//	}
//	return start;
//}
//
//- (NSPoint)getNotePosition:(NoteBase *)note{
//	float start = 0;
//	NSEnumerator *notesEnum = [notes objectEnumerator];
//	id currNote;
//	while((currNote = [notesEnum nextObject]) && currNote != note){
//		start += [currNote getEffectiveDuration];
//	}
//	return NSMakePoint(start, [note getEffectiveDuration]);
//}
//
//- (int)getNumberOfNotesStartingAfter:(float)startDuration before:(float)endDuration{
//	float duration = 0;
//	int count = 0;
//	NSEnumerator *notesEnum = [notes objectEnumerator];
//	id currNote;
//	while((currNote = [notesEnum nextObject]) && duration < endDuration){
//		if(duration > startDuration){
//			count++;
//		}
//		duration += [currNote getEffectiveDuration];
//	}
//	return count;
//}
//
//- (NoteBase *)getClosestNoteBefore:(float)targetDuration{
//	NSEnumerator *notesEnum = [notes objectEnumerator];
//	id currNote;
//	float duration = 0;
//	while(currNote = [notesEnum nextObject]){
//		duration += [currNote getEffectiveDuration];
//		if(duration > targetDuration){
//			return currNote;
//		}
//	}
//	return nil;
//}
//
//- (NoteBase *)getClosestNoteAfter:(float)targetDuration{
//	NSEnumerator *notesEnum = [notes objectEnumerator];
//	id currNote;
//	float duration = 0;
//	while(currNote = [notesEnum nextObject]){
//		if(duration > targetDuration){
//			return currNote;
//		}
//		duration += [currNote getEffectiveDuration];
//	}
//	if([_staff getLastMeasure] == self){
//		return nil;
//	}
//	NSArray *nextMeasureNotes = [[_staff getMeasureAfter:self createNew:YES] notes];
//	if([nextMeasureNotes count] == 0){
//		return nil;
//	}
//	return [nextMeasureNotes objectAtIndex:0];
//}
//
//- (void)transposeBy:(int)numLines{
//	[self clearCaches];
//	[[notes do] transposeBy:numLines];
//}
//
//- (void)transposeBy:(int)numHalfSteps oldSignature:(KeySignature *)oldSig newSignature:(KeySignature *)newSig{
//	[self clearCaches];
//	[[notes do] transposeBy:numHalfSteps oldSignature:oldSig newSignature:newSig];
//}
//
//- (IBAction)keySigChanged:(id)sender{
//	[self clearCaches];
//	[[self undoManager] setActionName:@"changing key signature"];
//	KeySignature *newSig;
//	if([[[keySigMajMin selectedItem] title] isEqual:@"major"]){
//		newSig = [KeySignature getMajorSignatureAtIndexFromA:[keySigLetter indexOfSelectedItem]];
//		if(newSig == nil){
//			newSig = [KeySignature getMinorSignatureAtIndexFromA:[keySigLetter indexOfSelectedItem]];
//			[keySigMajMin selectItemWithTitle:@"minor"];
//		}
//	} else{
//		newSig = [KeySignature getMinorSignatureAtIndexFromA:[keySigLetter indexOfSelectedItem]];
//		if(newSig == nil){
//			newSig = [KeySignature getMajorSignatureAtIndexFromA:[keySigLetter indexOfSelectedItem]];
//			[keySigMajMin selectItemWithTitle:@"major"];
//		}
//	}
//	if([keySigTranspose state] == NSOnState){
//		[_staff transposeFrom:keySig to:newSig startingAt:self];		
//	}
//	Measure *prev = [_staff getMeasureBefore:self];
//	if(prev != nil && [[prev getEffectiveKeySignature] isEqualTo:newSig]){
//		[self keySigDelete];
//	} else {
//		[self setKeySignature:newSig];
//	}
//	[self sendChangeNotification];
//}

//- (IBAction)keySigClose:(id)sender {
//	[keySigPanel setHidden:YES withFade:YES blocking:(sender != nil)];
//	if([keySigPanel superview] != nil){
//		[keySigPanel removeFromSuperview];
//	}
//}

//- (void)updateKeySigPanel {
//	KeySignature *sig = [self getEffectiveKeySignature];
//	[keySigLetter selectItemAtIndex:[sig getIndexFromA]];
//	if([sig isMinor]){
//		[keySigMajMin selectItemAtIndex:1];
//	} else{
//		[keySigMajMin selectItemAtIndex:0];
//	}
//}

//- (void)processTimeSignatureChange:(BOOL)compound{
//	[self clearCaches];
//	if(compound){
//		[_staff timeSigChangedAtMeasure:self top:[timeSigTopText intValue] bottom:[[[timeSigBottom selectedItem] title] intValue]
//							 secondTop:[timeSigSecondTopText intValue] secondBottom:[[[timeSigSecondBottom selectedItem] title] intValue]];
//	} else {
//		[_staff timeSigChangedAtMeasure:self top:[timeSigTopText intValue] bottom:[[[timeSigBottom selectedItem] title] intValue]];
//	}
//}
//
//- (IBAction)timeSigTopChanged:(id)sender{
//	[[self undoManager] setActionName:@"changing time signature"];
//	int value = [sender intValue];
//	if(value < 1) value = 1;
//	[timeSigTopStep setIntValue:value];
//	[timeSigTopText setIntValue:value];
//	[self processTimeSignatureChange:[timeSigExpand isHidden]];
//}
//
//- (IBAction)timeSigBottomChanged:(id)sender{
//	[[self undoManager] setActionName:@"changing time signature"];
//	[self processTimeSignatureChange:[timeSigExpand isHidden]];
//}
//
//- (IBAction)timeSigSecondTopChanged:(id)sender{
//	[[self undoManager] setActionName:@"changing time signature"];
//	int value = [sender intValue];
//	if(value < 1) value = 1;
//	[timeSigSecondTopStep setIntValue:value];
//	[timeSigSecondTopText setIntValue:value];
//	[self processTimeSignatureChange:[timeSigExpand isHidden]];
//}
//
//- (IBAction)timeSigSecondBottomChanged:(id)sender{
//	[[self undoManager] setActionName:@"changing time signature"];
//	[self processTimeSignatureChange:[timeSigExpand isHidden]];
//}
//
//- (void)timeSigDelete{
//	[self clearCaches];
//	[[self undoManager] setActionName:@"deleting time signature"];
//	[_staff timeSigDeletedAtMeasure:self];
//}
//
//- (IBAction)timeSigClose:(id)sender{
//	[timeSigPanel setHidden:YES withFade:YES blocking:(sender != nil)];
//	if([timeSigPanel superview] != nil){
//		[timeSigPanel removeFromSuperview];
//	}
//}
//
//- (IBAction)timeSigExpand:(id)sender{
//	[[self undoManager] setActionName:@"changing time signature"];
//	NSRect frame = [timeSigPanel frame];
//	[timeSigPanel setFrame:NSMakeRect(frame.origin.x, frame.origin.y, 180, frame.size.height) blocking:NO];
//	[timeSigInnerClose setHidden:YES withFade:YES blocking:NO];
//	[timeSigExpand setHidden:YES withFade:YES blocking:NO];
//	[self processTimeSignatureChange:YES];
//}
//
//- (IBAction)timeSigCollapse:(id)sender{
//	[[self undoManager] setActionName:@"changing time signature"];
//	NSRect frame = [timeSigPanel frame];
//	[timeSigPanel setFrame:NSMakeRect(frame.origin.x, frame.origin.y, 90, frame.size.height) blocking:NO];
//	[timeSigInnerClose setHidden:NO withFade:YES blocking:NO];
//	[timeSigExpand setHidden:NO withFade:YES blocking:NO];
//	[self processTimeSignatureChange:NO];
//}
//
//- (void)updateTimeSigPanel{
//	TimeSignature *sig = [self getEffectiveTimeSignature];
//	int top = [sig getTop];
//	int bottom = [sig getBottom];
//	[timeSigTopStep setIntValue:top];
//	[timeSigTopText setIntValue:top];
//	[timeSigBottom selectItemWithTitle:[NSString stringWithFormat:@"%d", bottom]];
//	[[timeSigPanel superview] setNeedsDisplay:YES];
//}
//
//- (void)cleanPanels{
//	[self timeSigClose:nil];
//	[self keySigClose:nil];
//}

- (NSMutableDictionary *)getAccidentalsAtPosition:(float)pos {
    
	NSMutableDictionary *accidentals = [NSMutableDictionary dictionary];
	int i;
	KeySignature *keySig2 = [self getEffectiveKeySignature];
	for(i = 0; i < pos; i++){
		NoteBase *note = [notes objectAtIndex:i];
		if([note respondsToSelector:@selector(getEffectivePitchWithKeySignature:priorAccidentals:)]){
			[note getEffectivePitchWithKeySignature:keySig2 priorAccidentals:accidentals];			
		}
	}
	return accidentals;
}

//- (float)addToMIDITrack:(MusicTrack *)musicTrack atPosition:(float)pos transpose:(int)transposition onChannel:(int)channel notesToPlay:(id)selection{
//	float initPos = pos;
//	NSEnumerator *noteEnum = [notes objectEnumerator];
//	NSMutableDictionary *accidentals = [NSMutableDictionary dictionary];
//	id note;
//	while(note = [noteEnum nextObject]){
//		if(selection == nil || note == selection || 
//		   ([selection respondsToSelector:@selector(containsObject:)] && [selection containsObject:note])){
//			pos += [note addToMIDITrack:musicTrack atPosition:pos withKeySignature:[self getEffectiveKeySignature]
//							accidentals:accidentals transpose:transposition onChannel:channel];			
//		}
//	}
//	return pos - initPos;
//}
//
//- (void)addToLilypondString:(NSMutableString *)string{
//	TempoData *tempo = [[[_staff song] tempoData] objectAtIndex:[_staff.measures indexOfObject:self]];
//	if(![tempo empty]){
//		[string appendFormat:@"\\tempo 4=%d ", (int)[tempo tempo]];
//	}
//	if([self isStartRepeat]){
//		[string appendFormat:@"\\repeat volta %d {\n", [[self getRepeatStartingHere] numRepeats]];
//	}
//	if(clef != nil && ![_staff isDrums]){
//		[clef addToLilypondString:string];
//	}
//	if(![[self getTimeSignature] isKindOfClass:[NSNull class]]){
//		[[self getTimeSignature] addToLilypondString:string];
//	} else if([_staff isCompoundTimeSignatureAt:self]){
//		[[self getEffectiveTimeSignature] addToLilypondString:string];
//	}
//	if(keySig != nil && ![_staff isDrums]){
//		[keySig addToLilypondString:string];
//	}
//	NSMutableDictionary *accidentals = [NSMutableDictionary dictionary];
//	[[notes do] addToLilypondString:string accidentals:accidentals];
//	if([self isEndRepeat]){
//		[string appendString:@"\n}\n"];
//	}
//}
//
//- (void)addToMusicXMLString:(NSMutableString *)string{
//	int index = [_staff.measures indexOfObject:self];
//	[string appendFormat:@"<measure number=\"%d\">\n", (index + 1)];
//	[string appendString:@"<attributes>\n"];
//	if(index == 0){
//		[string appendString:@"<divisions>48</divisions>\n"];
//		if([_staff transposition] != 0){
//			[string appendFormat:@"<transpose>\n<chromatic>%d</chromatic>\n</transpose>\n", [_staff transposition]];
//		}
//	}
//	if(keySig != nil && ![_staff isDrums]){
//		[keySig addToMusicXMLString:string];
//	}
//	if(![[self getTimeSignature] isKindOfClass:[NSNull class]]){
//		[[self getTimeSignature] addToMusicXMLString:string];
//	} else if([_staff isCompoundTimeSignatureAt:self]){
//		[[self getEffectiveTimeSignature] addToMusicXMLString:string];
//	}
//	if(clef != nil && ![_staff isDrums]){
//		[clef addToMusicXMLString:string];
//	} else if([_staff isDrums]){
//		[string appendString:@"<clef>\n<sign>percussion</sign>\n</clef>\n"];
//	}
//	[string appendString:@"</attributes>\n"];
//	TempoData *tempo = [[[_staff song] tempoData] objectAtIndex:[_staff.measures indexOfObject:self]];
//	if(![tempo empty]){
//		[string appendFormat:@"<sound tempo=\"%d\"/>\n", (int)[tempo tempo]];
//	}
//	if([self isStartRepeat]){
//		[string appendString:@"<barline location=\"left\">\n<bar-style>heavy-light</bar-style>\n<repeat direction=\"forward\"/>\n</barline>"];
//	}
//	NSMutableDictionary *accidentals = [NSMutableDictionary dictionary];
//	[[notes do] addToMusicXMLString:string accidentals:accidentals];
//	if([self isEndRepeat]){
//		[string appendFormat:@"<barline location=\"left\">\n<bar-style>light-heavy</bar-style>\n<repeat direction=\"backward\" times=\"%d\"/>\n</barline>", [self getNumRepeats]];
//	}
//	[string appendString:@"</measure>\n"];
//}
//
//- (void)encodeWithCoder:(NSCoder *)coder{
//	[coder encodeObject:_staff forKey:@"staff"];
//	if(clef == [Clef trebleClef]){
//		[coder encodeObject:@"treble" forKey:@"clef"];
//	}
//	if(clef == [Clef bassClef]){
//		[coder encodeObject:@"bass" forKey:@"clef"];
//	}
//	if(keySig != nil){
//		[coder encodeInt:[keySig getNumFlats] forKey:@"keySigFlats"];
//		[coder encodeInt:[keySig getNumSharps] forKey:@"keySigSharps"];
//		[coder encodeBool:[keySig isMinor] forKey:@"keySigMinor"];
//		if([keySig getNumFlats] == 0 && [keySig getNumSharps] == 0){
//			[coder encodeBool:YES forKey:@"keySigC"];
//		}
//	}
//	[coder encodeObject:notes forKey:@"notes"];
//}
//
//- (id)initWithCoder:(NSCoder *)coder{
//	if(self = [super init]){
//		_staff = [coder decodeObjectForKey:@"staff"];
//		id deClef = [coder decodeObjectForKey:@"clef"];
//		if([deClef isEqualToString:@"treble"]){
//			[self setClef:[Clef trebleClef]];
//		} else if([deClef isEqualToString:@"bass"]){
//			[self setClef:[Clef bassClef]];
//		}
//		int flats = [coder decodeIntForKey:@"keySigFlats"];
//		int sharps = [coder decodeIntForKey:@"keySigSharps"];
//		BOOL minor = [coder decodeBoolForKey:@"keySigMinor"];
//		if(flats > 0){
//			[self setKeySignature:[KeySignature getSignatureWithFlats:flats minor:minor]];
//		} else if(sharps > 0){
//			[self setKeySignature:[KeySignature getSignatureWithSharps:sharps minor:minor]];
//		} else if([coder decodeBoolForKey:@"keySigC"]){
//			[self setKeySignature:[KeySignature getSignatureWithFlats:0 minor:NO]];
//		}
//		[self setNotes:[coder decodeObjectForKey:@"notes"]];
//		[[notes do] setStaff:_staff];
//	}
//	return self;
//}
//
//- (Class)getViewClass{
//	if([_staff isDrums]){
//		return [DrumMeasureDraw class];
//	}
//	return [MeasureDraw class];
//}
//
//- (Class)getControllerClass{
//	if([_staff isDrums]){
//		return [DrumMeasureController class];
//	}
//	return [MeasureController class];
//}
//
//- (NSString *) description {
//	NSMutableString *str = [NSMutableString string];
//	[self addToMusicXMLString:str];
//	return str;
//}

@end
