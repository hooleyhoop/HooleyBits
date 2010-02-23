//
//  Measure.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/4/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class NoteBase;
@class Clef;
//@class DrumKit;
@class Staff;
@class KeySignature;
@class TimeSignature;
//@class Repeat;
#import <AudioToolbox/AudioToolbox.h>

@interface Measure : NSObject { //<NSCoding> {
    
	Staff *_staff;
	Clef *_clef;
	KeySignature *keySig;
	NSMutableArray *notes;
//	NSViewAnimation *anim;
//	
//	IBOutlet NSView *keySigPanel;
//	IBOutlet NSPopUpButton *keySigLetter;
//	IBOutlet NSPopUpButton *keySigMajMin;
//	IBOutlet NSButton *keySigTranspose;
//	
//	IBOutlet NSView *timeSigPanel;
//	IBOutlet NSTextField *timeSigTopText;
//	IBOutlet NSStepper *timeSigTopStep;
//	IBOutlet NSPopUpButton *timeSigBottom;
//	IBOutlet NSTextField *timeSigSecondTopText;
//	IBOutlet NSStepper *timeSigSecondTopStep;
//	IBOutlet NSPopUpButton *timeSigSecondBottom;
//	IBOutlet NSButton *timeSigInnerClose;
//	IBOutlet NSButton *timeSigExpand;
	
	NSArray *cachedNoteGroups;
}

@property (assign, readonly, nonatomic) Staff *staff;
@property (readonly, nonatomic) KeySignature *keySignature;

- (id)initWithStaff:(Staff *)staff;

- (Staff *)getStaff;

//- (NSUndoManager *)undoManager;

- (NSMutableArray *)notes;
- (NoteBase *)getFirstNote;
- (void)setNotes:(NSMutableArray *)_notes;
- (void)addNote:(NoteBase *)_note atIndex:(float)index tieToPrev:(BOOL)tieToPrev;
//- (NoteBase *)addNotes:(NSArray *)_notes atIndex:(float)index;
- (NoteBase *)addNotesInternal:(NSArray *)_notes atIndex:(float)index consolidate:(BOOL)consolidate;
- (void)removeNoteAtIndex:(float)x temporary:(BOOL)temp;
- (void)removeNote:(NoteBase *)note temporary:(BOOL)temp;

- (void)addNote:(NoteBase *)newNote toChordAtIndex:(float)index;
//- (void)removeNote:(NoteBase *)note fromChordAtIndex:(float)index;
- (NoteBase *)refreshNotes:(NoteBase *)rtn;
- (float)getTotalDuration;
- (BOOL)isEmpty;
- (BOOL)isFull;
- (void)consolidateNote:(NoteBase *)note;

//- (BOOL)isStartRepeat;
//- (BOOL)isEndRepeat;
//- (int)getNumRepeats;
//- (void)setStartRepeat:(BOOL)_startRepeat;
//- (void)setEndRepeat:(int)_numRepeats;
//- (void)removeEndRepeat;
//- (BOOL)followsOpenRepeat;
//- (Repeat *)getRepeatEndingHere;
//
//- (Clef *)getClef;
//- (DrumKit *)getDrumKit;
//- (Clef *)getEffectiveClef;
- (void)setClef:(Clef *)clef;

//- (KeySignature *)getKeySignature;
- (KeySignature *)getEffectiveKeySignature;
- (void)setKeySignature:(KeySignature *)sig;
//- (void)keySigDelete;
//- (Measure *)getPreviousMeasureWithKeySignature;

- (TimeSignature *)getTimeSignature;
//- (BOOL)hasTimeSignature;
- (TimeSignature *)getEffectiveTimeSignature;
- (void)timeSignatureChangedFrom:(float)oldTotal to:(float)newTotal;
//- (void)timeSigDelete;
//
//- (BOOL)isShowingKeySigPanel;
//- (NSView *)getKeySigPanel;
//
//- (BOOL)isShowingTimeSigPanel;
//- (NSView *)getTimeSigPanel;
//- (void)updateTimeSigPanel;

- (NoteBase *)getNoteBefore:(NoteBase *)source;

//- (BOOL)isIsolated:(NoteBase *)note;
//- (NSArray *)getNoteGroups;
//
//- (float)notestartDuration:(NoteBase *)note;
//- (NSPoint)getNotePosition:(NoteBase *)note;
//- (int)getNumberOfNotesStartingAfter:(float)startDuration before:(float)endDuration;
//- (NoteBase *)getClosestNoteBefore:(float)targetDuration;
//- (NoteBase *)getClosestNoteAfter:(float)targetDuration;
//
//- (void)transposeBy:(int)numLines;
//- (void)transposeBy:(int)numHalfSteps oldSignature:(KeySignature *)oldSig newSignature:(KeySignature *)newSig;
//
//- (IBAction)keySigChanged:(id)sender;
//- (IBAction)keySigClose:(id)sender;

//- (IBAction)timeSigTopChanged:(id)sender;
//- (IBAction)timeSigBottomChanged:(id)sender;
//- (IBAction)timeSigSecondTopChanged:(id)sender;
//- (IBAction)timeSigSecondBottomChanged:(id)sender;
//- (IBAction)timeSigClose:(id)sender;
//- (IBAction)timeSigExpand:(id)sender;
//- (IBAction)timeSigCollapse:(id)sender;
//
//- (void)cleanPanels;

- (NSMutableDictionary *)getAccidentalsAtPosition:(float)pos;

//- (float)addToMIDITrack:(MusicTrack *)musicTrack atPosition:(float)pos
//			  transpose:(int)transposition onChannel:(int)channel notesToPlay:(id)selection;
//- (void)addToLilypondString:(NSMutableString *)string;
//- (void)addToMusicXMLString:(NSMutableString *)string;
//
//- (Class)getViewClass;
//- (Class)getControllerClass;

@end
