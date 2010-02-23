//
//  Staff.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/7/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//@class Clef;
@class KeySignature;
@class TimeSignature;
@class Measure;
@class NoteBase;
@class Note;
//@class Chord;
@class Song;
//@class DrumKit;
//@class StaffVerticalRulerComponent;
#import <AudioToolbox/AudioToolbox.h>

@interface Staff : NSObject { //<NSCoding> {
    
	NSMutableArray *_measures;
	Song *song;
	NSString *_name;
//	int transposition;
	int channel;
//	IBOutlet StaffVerticalRulerComponent *rulerView;
	BOOL mute, solo, canMute;
//	DrumKit *drumKit;
//	
//	MusicTrack musicTrack;
}

@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSMutableArray *measures;
@property (assign, nonatomic) Song *song;

- (id)initWithSong:(Song *)songArg;

//- (int)transposition;
//- (void)setTransposition:(int)_transposition;
//- (StaffVerticalRulerComponent *)rulerView;
//- (IBAction)deleteSelf:(id)sender;
//
//- (Clef *)getClefForMeasure:(Measure *)measure;
- (KeySignature *)getKeySignatureForMeasure:(Measure *)measure;
- (TimeSignature *)getTimeSignatureForMeasure:(Measure *)measure;
- (TimeSignature *)getEffectiveTimeSignatureForMeasure:(Measure *)measure;
//- (BOOL)isCompoundTimeSignatureAt:(Measure *)measure;

- (void)addMeasure:(Measure *)measure;
- (void)removeMeasure:(Measure *)measure;
//- (Measure *)addMeasure;
- (Measure *)getLastMeasure;
- (Measure *)measureAtIndex:(unsigned)index;
- (Measure *)getMeasureAfter:(Measure *)measure createNew:(BOOL)createNew;
- (Measure *)getMeasureBefore:(Measure *)measure;
//- (Measure *)getMeasureWithKeySignatureBefore:(Measure *)measure;
- (void)cleanEmptyMeasures;

//- (void)transposeFrom:(KeySignature *)oldSig to:(KeySignature *)newSig startingAt:(Measure *)measure;

- (Measure *)getMeasureContainingNote:(NoteBase *)note;
//- (Chord *)getChordContainingNote:(NoteBase *)note;

- (Note *)findPreviousNoteMatching:(Note *)source inMeasure:(Measure *)measure;
//- (NoteBase *)noteBefore:(NoteBase *)note;
//- (NoteBase *)noteAfter:(NoteBase *)note;
//
//- (NSArray *)notesBetweenNote:(id)note1 andNote:(id)note2;

- (void)removeLastNote;

//- (void)cleanPanels;

- (BOOL)isDrums;
//- (void)setIsDrums:(BOOL)isDrums;
//- (DrumKit *)drumKit;
//- (IBAction)editDrumKit:(id)sender;
//
//- (void)toggleClefAtMeasure:(Measure *)measure;
//- (void)timeSigChangedAtMeasure:(Measure *)measure top:(int)top bottom:(int)bottom;
//- (void)timeSigChangedAtMeasure:(Measure *)measure top:(int)top bottom:(int)bottom secondTop:(int)secondTop secondBottom:(int)secondBottom;
//- (void)timeSigDeletedAtMeasure:(Measure *)measure;
//
//- (BOOL)canMute;
//- (void)setCanMute:(BOOL)enabled;
//
//- (BOOL)mute;
//- (BOOL)solo;
//- (void)setMute:(BOOL)_mute;
//- (void)setSolo:(BOOL)_solo;
//
//- (int)channel;
- (void)setChannel:(int)_channel;

//- (float)addTrackToMIDISequence:(MusicSequence *)musicSequence notesToPlay:(id)selection;
//- (void)addToLilypondString:(NSMutableString *)string;
//- (void)addToMusicXMLString:(NSMutableString *)string;
//
//- (Class)getViewClass;
//- (Class)getControllerClass;

@end
