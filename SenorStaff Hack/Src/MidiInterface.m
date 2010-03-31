//
//  MidiInterface.m
//  SenorStaff Hack
//
//  Created by Steven Hooley on 6/25/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import "MidiInterface.h"
#import <CoreServices/CoreServices.h> //for file stuff
#import <unistd.h> // used for usleep...
#import <AudioUnit/AudioUnit.h>
#import <AudioToolBox/AudioToolBox.h>
#import "SimpleNote.h"

@interface MidiInterface (private_methods)
+ (void)createAUGraph;
+ (void)startGraph;
@end

@implementation MidiInterface

AudioUnit _synthUnit;
AUGraph _graph;
UInt8 midiChannelInUse = 0; //we're using midi channel 1...

+ (void)startAudio {
	
	if( !_graph ) {
		[self createAUGraph];
		[self startGraph];
	}
}

+ (void)stopAudio {

	if( _graph ) {
		AUGraphStop(_graph); // stop playback - AUGraphDispose will do that for us but just showing you what to do
		DisposeAUGraph(_graph);
		_graph = nil;
	}
}

// This call creates the Graph and the Synth unit...
+ (void)createAUGraph {

    AUNode synthNode, limiterNode, outNode;
	
	OSStatus result;
	//create the nodes of the graph	
	ComponentDescription cd;
	cd.componentManufacturer = kAudioUnitManufacturer_Apple;
	cd.componentFlags = 0;
	cd.componentFlagsMask = 0;
	
	require_noerr (result = NewAUGraph(&_graph), home);
	
	cd.componentType = kAudioUnitType_MusicDevice;
	cd.componentSubType = kAudioUnitSubType_DLSSynth;
	
	require_noerr (result = AUGraphAddNode (_graph, &cd, &synthNode), home);
	
	cd.componentType = kAudioUnitType_Effect;
	cd.componentSubType = kAudioUnitSubType_PeakLimiter;  
	
	require_noerr (result = AUGraphAddNode (_graph, &cd, &limiterNode), home);
	
	cd.componentType = kAudioUnitType_Output;
	cd.componentSubType = kAudioUnitSubType_DefaultOutput;  
	require_noerr (result = AUGraphAddNode (_graph, &cd, &outNode), home);
	
	require_noerr (result = AUGraphOpen (_graph), home);
	
	require_noerr (result = AUGraphConnectNodeInput (_graph, synthNode, 0, limiterNode, 0), home);
	require_noerr (result = AUGraphConnectNodeInput (_graph, limiterNode, 0, outNode, 0), home);
	
	// ok we're good to go - get the Synth Unit...
	require_noerr (result = AUGraphNodeInfo(_graph, synthNode, 0, &_synthUnit), home);
home:
	return;
}

+ (void)startGraph {
	
	NSAssert(_graph, @"we need");
	
	OSStatus result;

	// ok we're set up to go - initialize and start the graph
	require_noerr (result = AUGraphInitialize(_graph), home);
	
	//set our bank
	require_noerr (result = MusicDeviceMIDIEvent(_synthUnit, kMidiMessage_ControlChange << 4 | midiChannelInUse, kMidiMessage_BankMSBControl, 0, 0/*sample offset*/), home);
	require_noerr (result = MusicDeviceMIDIEvent(_synthUnit, kMidiMessage_ProgramChange << 4 | midiChannelInUse, 0/*prog change num*/, 0, 0/*sample offset*/), home);
	
	CAShow (_graph); // prints out the graph so we can see what it looks like...
	require_noerr (result = AUGraphStart (_graph), home);
home:
	return;	
}

+ (void)playNoteGroup:(NSSet *)noteGroup {

	OSStatus result;
	UInt32 noteOnCommand = 	kMidiMessage_NoteOn << 4 | midiChannelInUse;

	for(SimpleNote *eachNote in noteGroup){
		//	UInt32 onVelocity = 127;
		printf ("Playing Note: Status: 0x%lX, Note: %ld, Vel: %ld\n", noteOnCommand, (UInt32)eachNote.pitch, (UInt32)eachNote.velocity);
		require_noerr (result = MusicDeviceMIDIEvent(_synthUnit, noteOnCommand, (UInt32)eachNote.pitch, (UInt32)eachNote.velocity, 0), home);
	}
	
	// sleep for a 0.5 second
	usleep (0.5 * 1000 * 1000);

	for(SimpleNote *eachNote in noteGroup){
		require_noerr (result = MusicDeviceMIDIEvent(_synthUnit, noteOnCommand, eachNote.pitch, 0, 0), home);
	}

home:
	return;
}



@end
