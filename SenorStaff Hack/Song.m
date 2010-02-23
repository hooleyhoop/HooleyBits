//
//  Song.m
//  Music Editor
//
//  Created by Konstantine Prevas on 5/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "Song.h"
#import "Staff.h"
#import "Measure.h"
#import "TempoData.h"
#import "TimeSignature.h"
//#import "CompoundTimeSig.h"
//#import <AudioToolbox/AudioToolbox.h>
//#import <Chomp/Chomp.h>
//#import "Chord.h"
//#import "Note.h"
//#import "NoteBase.h"
//#import "Repeat.h"
//#import "CompoundTimeSig.h"

#import "MIDIUtil.h"

@implementation Song

@synthesize document = _document;

- (id)initWithDocument:(MusicDocument *)doc {
    
	if((self = [super init])){
		_document = doc;
		tempoData = [[NSMutableArray arrayWithObject:[[TempoData alloc] initWithTempo:120 withSong:self]] retain];
		staffs = [[NSMutableArray arrayWithObject:[[Staff alloc] initWithSong:self]] retain];
//		[[staffs objectAtIndex:0] setName:@"Staff 1"];
		timeSigs = [[NSMutableArray arrayWithObject:[TimeSignature timeSignatureWithTop:4 bottom:4]] retain];
//		repeats = [[NSMutableArray array] retain];
//		playerPosition = -1;
//        [self initMIDI];
	}
	return self;
}

- (id)initFromMIDI:(NSData *)data withDocument:(MusicDocument *)doc {
    
	if((self = [self initWithDocument: doc])){
		[MIDIUtil readSong:self fromMIDI:data];
	}
	return self;
}

//- (void)initMIDI{
//	if (NewMusicPlayer(&musicPlayer) != noErr) {
//		[NSException raise:@"main" format:@"Cannot create music player."];
//	}
//	if (NewMusicSequence(&musicSequence) != noErr){
//		[NSException raise:@"main" format:@"Cannot create music sequence."];
//	}
//	if (MusicPlayerSetSequence(musicPlayer, musicSequence) != noErr) {
//		NSLog(@"Cannot set sequence for music player.");
//		return;
//	}
//	if (NewMusicPlayer(&feedbackPlayer) != noErr) {
//		[NSException raise:@"main" format:@"Cannot create music player."];
//	}
//	if (NewMusicSequence(&feedbackSequence) != noErr){
//		[NSException raise:@"main" format:@"Cannot create music sequence."];
//	}
//	if (MusicPlayerSetSequence(feedbackPlayer, feedbackSequence) != noErr) {
//		NSLog(@"Cannot set sequence for music player.");
//		return;
//	}
//	if (MusicSequenceNewTrack(feedbackSequence, &feedbackTrack) != noErr) {
//		[NSException raise:@"main" format:@"Cannot create music track."];
//	}
//	MusicPlayerPreroll(feedbackPlayer);
//}

- (void)dealloc {
    
	[staffs release];
	[tempoData release];
	[timeSigs release];
//	[repeats release];
	[super dealloc];
}

- (NSUndoManager *)undoManager{
	return [_document undoManager];
}

//- (void)sendChangeNotification{
//	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"modelChanged" object:self]];
//}

- (NSMutableArray *)staffs{
    
	return staffs;
}

- (void)prepUndo{
    
	[[[self undoManager] prepareWithInvocationTarget:self] setStaffsAndRefresh:[NSMutableArray arrayWithArray:staffs]];
}

- (void)setStaffsAndRefresh:(NSMutableArray *)staffsArg {
    
	[self setStaffs:staffsArg];
	[self refreshTimeSigs];
	[self refreshTempoData];
}

- (void)setStaffs:(NSMutableArray *)staffsArg {
    
	[self prepUndo];
	[self willChangeValueForKey:@"staffs"];
	if(![staffs isEqual:staffsArg]){
		[staffs release];
		staffs = [staffsArg retain];
	}
	[self didChangeValueForKey:@"staffs"];
}

- (Staff *)addStaff {
    
	[self prepUndo];
	Staff *staff = [self doAddStaff];
	[staff setName:[NSString stringWithFormat:@"Staff %d", [staffs count]]];
	[self refreshTimeSigs];
	[self refreshTempoData];
	return staff;
}

- (Staff *)doAddStaff {
    
	Staff *staff = [[Staff alloc] initWithSong:self];
	[staffs addObject:staff];
	return staff;
}

- (void)removeStaff:(Staff *)staff {
    
	[self prepUndo];
	[self willChangeValueForKey:@"staffs"];
	[staffs removeObject:staff];
//	[staff cleanPanels];
	if([staffs count] == 0){
		[self doAddStaff];
	}
	[self refreshTimeSigs];
	[self refreshTempoData];
	[self didChangeValueForKey:@"staffs"];
}

- (int)numberOfMeasures {
    
	int numMeasures = 0;
	NSEnumerator *staffEnum = [staffs objectEnumerator];
	Staff *staff;
	while(staff = [staffEnum nextObject]){
		if([staff.measures count] > numMeasures){
			numMeasures = [staff.measures count];
		}
	}
	return numMeasures;
}

//- (float)getTempoAt:(int)measureIndex{
//	TempoData *data = [tempoData objectAtIndex:measureIndex];
//	while([data empty]){
//		data = [tempoData objectAtIndex:--measureIndex];
//	}
//	return [data tempo];
//}

- (void)refreshTempoData {
    
	[self willChangeValueForKey:@"tempoData"];
	int numMeasures = [self numberOfMeasures];
	while([tempoData count] < numMeasures){
		[tempoData addObject:[[TempoData alloc] initEmptyWithSong:self]];
	}
	while([tempoData count] > numMeasures){
//		TempoData *tempo = [tempoData lastObject];
//		[tempo removePanel];
		[tempoData removeLastObject];
	}
	[self didChangeValueForKey:@"tempoData"];
}

- (NSMutableArray *)tempoData {
    
	return tempoData;
}

//- (void)setTempoData:(NSMutableArray *)_tempoData{
//	if(![tempoData isEqual:_tempoData]){
//		[tempoData release];
//		tempoData = [_tempoData retain];
//	}
//}
//
//- (NSMutableArray *)timeSigs{
//	return timeSigs;
//}

- (void)setTimeSigs:(NSMutableArray *)_timeSigs {
    
	if(![timeSigs isEqual:_timeSigs]){
		[timeSigs release];
		timeSigs = [_timeSigs retain];
	}
}

- (void)doSetTimeSignature:(TimeSignature *)sig atIndex:(int)measureIndex {
    
	[[[self undoManager] prepareWithInvocationTarget:self] doSetTimeSignature:[timeSigs objectAtIndex:measureIndex] atIndex:measureIndex];
	[timeSigs replaceObjectAtIndex:measureIndex withObject:sig];
//	NSEnumerator *staffsEnum = [staffs objectEnumerator];
//	id staff;
//	while(staff = [staffsEnum nextObject]){
//		[[staff measureAtIndex:measureIndex] updateTimeSigPanel];
//	}	
}

- (void)setTimeSignature:(TimeSignature *)sig atIndex:(int)measureIndex {

	float oldTotal = [[self getEffectiveTimeSignatureAt:measureIndex] getMeasureDuration];
	float secondOldTotal = [[self getEffectiveTimeSignatureAt:(measureIndex+1)] getMeasureDuration];
	[self doSetTimeSignature:sig atIndex:measureIndex];
	NSEnumerator *staffsEnum = [staffs objectEnumerator];
	Staff *staff;
	while(staff = [staffsEnum nextObject]){
		if([staff.measures count] > measureIndex){
			Measure *measure = [staff measureAtIndex:measureIndex];
			[measure timeSignatureChangedFrom:oldTotal to:[[measure getEffectiveTimeSignature] getMeasureDuration]];
			measure = [staff getMeasureAfter:measure createNew:NO];
			[measure timeSignatureChangedFrom:secondOldTotal to:[[measure getEffectiveTimeSignature] getMeasureDuration]];
		}
	}	
}

- (TimeSignature *)getTimeSignatureAt:(int)measureIndex {
	return [timeSigs objectAtIndex:measureIndex];
}

- (TimeSignature *)getEffectiveTimeSignatureAt:(int)measureIndex {
	if(measureIndex >= [self numberOfMeasures]){
		return nil;
	}
	int prevMeasureIndex = measureIndex;
	while([[self getTimeSignatureAt:prevMeasureIndex] isKindOfClass:[NSNull class]]){
		if(prevMeasureIndex == 0) return [TimeSignature timeSignatureWithTop:4 bottom:4];
		prevMeasureIndex--;
	}
	return [[self getTimeSignatureAt:prevMeasureIndex] getTimeSignatureAfterMeasures:(measureIndex - prevMeasureIndex)];
}

//- (BOOL)isCompoundTimeSignatureAt:(int)measureIndex{
//	int prevMeasureIndex = measureIndex;
//	while([[self getTimeSignatureAt:prevMeasureIndex] isKindOfClass:[NSNull class]]){
//		if(prevMeasureIndex == 0) return [TimeSignature timeSignatureWithTop:4 bottom:4];
//		prevMeasureIndex--;
//	}
//	return [[self getTimeSignatureAt:prevMeasureIndex] isKindOfClass:[CompoundTimeSig class]];
//}

- (void)refreshTimeSigs {
    
	[self willChangeValueForKey:@"timeSigs"];
	int numMeasures = [self numberOfMeasures];
	while([timeSigs count] < numMeasures){
		[timeSigs addObject:[NSNull null]];
	}
	while([timeSigs count] > numMeasures){
		[timeSigs removeLastObject];
	}
	[self didChangeValueForKey:@"timeSigs"];
}

//- (void)timeSigChangedAtIndex:(int)measureIndex top:(int)top bottom:(int)bottom{
//	TimeSignature *sig = [TimeSignature timeSignatureWithTop:top bottom:bottom];
//	[self setTimeSignature:sig atIndex:measureIndex];
//}
//
//- (void)timeSigChangedAtIndex:(int)measureIndex top:(int)top bottom:(int)bottom secondTop:(int)secondTop secondBottom:(int)secondBottom{
//	TimeSignature *sig = [[[CompoundTimeSig alloc] initWithFirstSig:[TimeSignature timeSignatureWithTop:top bottom:bottom]
//														 secondSig:[TimeSignature timeSignatureWithTop:secondTop bottom:secondBottom]] autorelease];
//	[self setTimeSignature:sig atIndex:measureIndex];
//}
//
//- (void)timeSigDeletedAtIndex:(int)measureIndex{
//	[self setTimeSignature:[NSNull null] atIndex:measureIndex];	
//}
//
//- (void)setRepeats:(NSArray *)_repeats{
//	[[[self undoManager] prepareWithInvocationTarget:self] setRepeats:[repeats copy]];
//	if(![repeats isEqual:_repeats]){
//		[repeats release];
//		repeats = [_repeats retain];
//	}
//}
//
//- (Repeat *)repeatStartingAt:(int)measureIndex{
//	NSEnumerator *repeatsEnum = [repeats objectEnumerator];
//	id repeat;
//	while(repeat = [repeatsEnum nextObject]){
//		if([repeat startMeasure] == measureIndex){
//			return repeat;
//		}
//	}
//	return nil;
//}
//
//- (BOOL)repeatStartsAt:(int)measureIndex{
//	return [self repeatStartingAt:measureIndex] != nil;
//}
//
//- (Repeat *)repeatEndingAt:(int)measureIndex{
//	NSEnumerator *repeatsEnum = [repeats objectEnumerator];
//	id repeat;
//	while(repeat = [repeatsEnum nextObject]){
//		if([repeat endMeasure] == measureIndex){
//			return repeat;
//		}
//	}
//	return nil;
//}
//
//- (BOOL)repeatEndsAt:(int)measureIndex{
//	return [self repeatEndingAt:measureIndex] != nil;
//}
//
//- (int)numRepeatsEndingAt:(int)measureIndex{
//	return [[self repeatEndingAt:measureIndex] numRepeats];
//}
//
//- (BOOL)repeatIsOpenAt:(int)measureIndex{
//	NSEnumerator *repeatsEnum = [repeats objectEnumerator];
//	id repeat;
//	while(repeat = [repeatsEnum nextObject]){
//		if([repeat endMeasure] == -1 && [repeat startMeasure] <= measureIndex){
//			return YES;
//		}
//	}
//	return NO;
//}
//
//- (void)startNewRepeatAt:(int)measureIndex{
//	if(![self repeatStartsAt:measureIndex]){
//		[[[self undoManager] prepareWithInvocationTarget:self] setRepeats:[repeats copy]];
//		Repeat *repeat = [[[Repeat alloc] initWithSong:self] autorelease];
//		[repeats addObject:repeat];
//		[repeat setStartMeasure:measureIndex];
//	}
//}
//
//- (void)endRepeatAt:(int)measureIndex{
//	Repeat *repeat = nil;
//	int index = measureIndex;
//	while(repeat == nil && index >= 0){
//		repeat = [self repeatStartingAt:index];
//		index--;
//	}
//	[repeat setEndMeasure:measureIndex];
//}
//
//- (void)setNumRepeatsEndingAt:(int)measureIndex to:(int)numRepeats{
//	[[self repeatEndingAt:measureIndex] setNumRepeats:numRepeats];
//}
//
//- (void)removeEndRepeatAt:(int)measureIndex{
//	Repeat *repeat = [self repeatEndingAt:measureIndex];
//	[repeat setEndMeasure:-1];
//	[repeat countClose:nil];
//}
//
//- (void) removeRepeatStartingAt:(int)measureIndex{
//	[[[self undoManager] prepareWithInvocationTarget:self] setRepeats:[repeats copy]];
//	Repeat *repeat = [self repeatStartingAt:measureIndex];
//	[repeat countClose:nil];
//	[repeats removeObject:repeat];
//}
//
//- (void)soloPressed:(BOOL)solo onStaff:(Staff *)staff{
//	[[staffs do] setCanMute:(!solo)];
//	[staff setCanMute:YES];
//}
//
//- (void)playFeedbackNote:(NoteBase *)note atPosition:(float)pos inMeasure:(Measure *)measure 
//		withExistingNote:existingNote toEndpoint:(MIDIEndpointRef)endpoint{
//	if(playerPosition != -1){
//		return;
//	}
//	BOOL isPlaying;
//	MusicPlayerIsPlaying(feedbackPlayer, &isPlaying);
//	if(isPlaying){
//		MusicPlayerStop(feedbackPlayer);
//	}
//	MusicTrackClear(feedbackTrack, 0.0, MAXFLOAT);
//	NSDictionary *accidentals = [measure getAccidentalsAtPosition:pos];
//	KeySignature *keySig = [measure getEffectiveKeySignature];
//	int channel = [[measure getStaff] realChannel];
//	playerEnd = [note addToMIDITrack:&feedbackTrack atPosition:0 withKeySignature:keySig
//						 accidentals:accidentals transpose:[[measure getStaff] transposition] onChannel:channel];
//	[existingNote addToMIDITrack:&feedbackTrack atPosition:0 withKeySignature:keySig
//					 accidentals:accidentals transpose:[[measure getStaff] transposition] onChannel:channel];
//	MIDIMetaEvent metaEvent = { 0x2f, 0, 0, 0, 0, { 0 } };
//	if (MusicTrackNewMetaEvent(feedbackTrack, 13.0, &metaEvent) != noErr) {
//		NSLog(@"Cannot add end of track meta event to track.");
//		return;
//	}
//	if(endpoint != nil){
//		if (MusicSequenceSetMIDIEndpoint(feedbackSequence, endpoint) != noErr)
//			[NSException raise:@"setMIDIEndpoint" format:@"Can't set midi endpoint for music sequence"];
//	}
//	
//	MusicPlayerSetTime(feedbackPlayer, 0.0);
//	
//	if (MusicPlayerStart(feedbackPlayer) != noErr) {
//		NSLog(@"Cannot start music player - %d.", MusicPlayerStart(feedbackPlayer));
//	}
//
//}
//
//- (float)addTracksToSequenceWithSelection:(id)selection includeAll:(BOOL)includeAll{
//	NSEnumerator *staffsEnum = [staffs objectEnumerator];
//	playerOffset = 0;
//	float maxLength = 0;
//	id staff;
//	while(staff = [staffsEnum nextObject]){
//		if(includeAll || ![staff mute]){
//			float length = [staff addTrackToMIDISequence:&musicSequence notesToPlay:selection];
//			if(length > maxLength){
//				maxLength = length;
//			}
//			if(selection != nil && length > 0){
//				NSEnumerator *measures = [staff.measures objectEnumerator];
//				id measure;
//				BOOL found = NO;
//				while(measure = [measures nextObject]){
//					NSEnumerator *notes = [[measure notes] objectEnumerator];
//					id note;
//					while(note = [notes nextObject]){
//						if(note == selection || ([selection respondsToSelector:@selector(containsObject:)] && [selection containsObject:note])){
//							found = YES;
//							break;
//						}
//						playerOffset += 4.0 * [note getEffectiveDuration] / 3;
//					}
//					if(found){
//						break;
//					}
//				}
//			}
//		}
//		if([staff solo] && !includeAll){
//			break;
//		}
//	}
//	MusicTrack tempoTrack;
//	if (MusicSequenceGetTempoTrack(musicSequence, &tempoTrack) != noErr)
//		[NSException raise:@"main" format:@"Cannot get tempo track."];
//	
//	NSEnumerator *tempoEnum = [tempoData objectEnumerator];
//	id tempo;
//	float time = 0;
//	float currTempo = 0;
//	int i = 0;
//	while(tempo = [tempoEnum nextObject]){
//		if(![tempo empty]){
//			MusicTrackNewExtendedTempoEvent(tempoTrack, time, [tempo tempo]);
//			currTempo = [tempo tempo];
//		}
//		int j = 0;
//		while([[staffs objectAtIndex:j].measures count] <= i){
//			j++;
//		}
//		time += [[[staffs objectAtIndex:j] measureAtIndex:i] getTotalDuration] * 4 / 3;
//		i++;
//	}
//	
//	return maxLength;
//}
//
//- (void)cleanMIDI{
//	int tracks;
//	
//	int i = 0;
//	for(MusicSequenceGetTrackCount(musicSequence, &tracks); tracks > 0; MusicSequenceGetTrackCount(musicSequence, &tracks)){
//		MusicTrack track;
//		MusicSequenceGetIndTrack(musicSequence, 0, &track);
//		MusicSequenceDisposeTrack(musicSequence, track);
//	}	
//}
//
//- (void)playToEndpoint:(MIDIEndpointRef)endpoint notesToPlay:(id)selection{
//
//	float maxLength = [self addTracksToSequenceWithSelection:selection includeAll:NO];
//	
//	playerEnd = maxLength + 5; // add 5 beats for decay
//	
//	if(endpoint != nil){
//		if (MusicSequenceSetMIDIEndpoint(musicSequence, endpoint) != noErr)
//			[NSException raise:@"setMIDIEndpoint" format:@"Can't set midi endpoint for music sequence"];
//	}
//	
//	MusicPlayerSetTime(musicPlayer, 0.0);
//	MusicPlayerPreroll(musicPlayer);
//
//	if (MusicPlayerStart(musicPlayer) != noErr) {
//		NSLog(@"Cannot start music player.");
//	}
//	
//	musicPlayerPoll = [[NSTimer scheduledTimerWithTimeInterval:.02 target:self
//													  selector:@selector(pollMusicPlayer:)
//													  userInfo:nil
//													   repeats:YES] retain];
//	
//}
//
//- (void)playToEndpoint:(MIDIEndpointRef)endpoint{
//	[self playToEndpoint:endpoint notesToPlay:nil];
//}
//
//- (void)stopPlaying{
//	if(musicPlayerPoll != nil){
//		[musicPlayerPoll invalidate];
//		[musicPlayerPoll release];
//		musicPlayerPoll = nil;
//	}
//	playerPosition = -1;
//	if (MusicPlayerStop(musicPlayer) != noErr) {
//		NSLog(@"Cannot stop music player.");
//		return;
//	}
//	[self cleanMIDI];
//}
//
//- (void)pollMusicPlayer:(NSTimer *)timer{
//	MusicPlayerGetTime(musicPlayer, &playerPosition);
//	if(playerPosition >= playerEnd){
//		playerPosition = -1;
//		[self stopPlaying];
//	}
//	[self sendChangeNotification];
//}
//
//- (double)getPlayerPosition{
//	return playerOffset + playerPosition;
//}
//
//- (double)getPlayerEnd{
//	return playerOffset + playerEnd;
//}
//
//- (NSData *)asMIDIData{
//	[self stopPlaying];
//	[self addTracksToSequenceWithSelection:nil includeAll:YES];
//	NSData *data;
//#ifdef __BIG_ENDIAN__
//	CFDataRef dataRef;
//	if (MusicSequenceSaveSMFData(musicSequence, &dataRef, 480) != noErr) {
//		[NSException raise:@"main" format:@"Cannot save SMF data."];
//	}
//	data = [(NSData *)dataRef autorelease];
//#else
//	data = [MIDIUtil writeSequenceToData:musicSequence];
//#endif
//	[self cleanMIDI];
//	return data;
//}
//
//- (NSData *)asLilypond{
//	NSMutableString *string = [NSMutableString string];
//	[string appendString:@"\\version \"2.10.25\"\n"];
//	[string appendString:@"\\score {\n<<\n"];
//	[[staffs do] addToLilypondString:string];
//	[string appendString:@">>\n}\n"];
//	return [string dataUsingEncoding:NSUTF8StringEncoding];
//}
//
//- (void) appendMusicXMLHeaderToString:(NSMutableString *)string forStaff:(Staff *)staff{
//	[string appendFormat:@"<score-part id=\"P%d\">\n", [staffs indexOfObject:staff]];
//	[string appendFormat:@"<part-name>%@</part-name>\n", [staff name]];
//	if([staff isDrums]){
//		[[staff drumKit] appendMusicXMLHeaderToString:string];
//	} else {
//		[string appendFormat:@"<midi-instrument id=\"P%dI\">\n", [staffs indexOfObject:staff]];
//		[string appendFormat:@"<midi-channel>%d</midi-channel>\n", [staff channel]];
//		[string appendString:@"</midi-instrument>\n"];
//	}
//	[string appendString:@"</score-part>\n"];
//}
//
//- (void) appendMusicXMLToString:(NSMutableString *)string forStaff:(Staff *)staff{
//	[string appendFormat:@"<part id=\"P%d\">\n", [staffs indexOfObject:staff]];
//	[staff addToMusicXMLString:string];
//	[string appendString:@"</part>\n"];
//}
//
//- (NSData *)asMusicXML{
//	NSMutableString *string = [NSMutableString string];
//	[string appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n<!DOCTYPE score-partwise PUBLIC \"-//Recordare//DTD MusicXML 1.1 Partwise//EN\" \"http://www.musicxml.org/dtds/partwise.dtd\">"];
//	[string appendString:@"<score-partwise version=\"1.1\">\n"];
//	[string appendString:@"<part-list>\n"];
//	[[self doSelf] appendMusicXMLHeaderToString:string forStaff:[staffs each]];
//	[string appendString:@"</part-list>\n"];
//	[[self doSelf] appendMusicXMLToString:string forStaff:[staffs each]];
//	[string appendString:@"</score-partwise>"];
//	return [string dataUsingEncoding:NSUTF8StringEncoding];
//}
//
//- (void)encodeWithCoder:(NSCoder *)coder{
//	[coder encodeObject:staffs forKey:@"staffs"];
//	[coder encodeObject:tempoData forKey:@"tempoData"];
//	NSArray *timeSigsToCode = [[TimeSignature collectSelf] asNSNumberArray:[timeSigs each]];
//	[coder encodeObject:timeSigsToCode forKey:@"timeSigs"];
//	[coder encodeObject:repeats forKey:@"repeats"];
//}
//
//- (id)initWithCoder:(NSCoder *)coder{
//	if(self = [super init]){
//		[self setStaffs:[coder decodeObjectForKey:@"staffs"]];
//		NSEnumerator *staffEnum = [staffs objectEnumerator];
//		id staff;
//		while(staff = [staffEnum nextObject]){
//			[staff setSong:self];
//		}
//		[self setTempoData:[coder decodeObjectForKey:@"tempoData"]];
//		NSArray *_sigs = [coder decodeObjectForKey:@"timeSigs"];
//		timeSigs = [[[TimeSignature collectSelf] fromNSNumberArray:[_sigs each]] retain];
//		[self refreshTimeSigs];
//		[self setRepeats:[coder decodeObjectForKey:@"repeats"]];
//		playerPosition = -1;
//		[self initMIDI];
//	}
//	return self;
//}
//
//
//- (NSString *) description {
//	NSMutableString *str = [NSMutableString string];
//	[[self doSelf] appendMusicXMLToString:str forStaff:[staffs each]];
//	return str;
//}

@end
