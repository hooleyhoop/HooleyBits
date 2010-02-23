//
//  MidiInterface.h
//  SenorStaff Hack
//
//  Created by Steven Hooley on 6/25/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// some MIDI constants:
enum {
	kMidiMessage_ControlChange 		= 0xB,
	kMidiMessage_ProgramChange 		= 0xC,
	kMidiMessage_BankMSBControl 	= 0,
	kMidiMessage_BankLSBControl		= 32,
	kMidiMessage_NoteOn 			= 0x9
};


@interface MidiInterface : NSObject {

}

+ (void)startAudio;
+ (void)stopAudio;

+ (void)playNoteGroup:(NSSet *)noteGroup;

@end
