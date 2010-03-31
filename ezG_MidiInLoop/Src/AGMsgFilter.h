//
//  AGMsgFilter.h
//  MidiInLoop
//
//  Created by steve hooley on 10/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MidiInLoop.h"

@class NeckViewControl;

enum {
	kMidiMessage_ControlChange 		= 0xB,
	kMidiMessage_ProgramChange 		= 0xC,
	kMidiMessage_BankMSBControl 	= 0,
	kMidiMessage_BankLSBControl		= 32,
	kMidiMessage_NoteOn 			= 0x9
};

@interface AGMsgFilter : NSObject {
    
 //   IBOutlet NeckViewControl *_neckViewControl;
}

static struct _noteOn   *_currentNote;
static struct _sysEx    *_currentSysEx;

+ (void)addNoteOnMsg:(struct _noteOn *)noteOnMsg;
+ (void)addSysExMsg:(struct _sysEx *)sysExMsg;

+ (void)setNeckViewController:(NeckViewControl *)nvc;

@end
