//
//  AGMsgFilter.m
//  MidiInLoop
//
//  Created by steve hooley on 10/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AGMsgFilter.h"
#import "NeckViewControl.h"
#import <AudioToolbox/AudioToolbox.h>


static NeckViewControl      *_neckViewControl;
static int midiStartFret[] = {64, 59, 55, 50, 45, 40};
static AudioUnit            _synthUnit;
static AUGraph              _graph;

@implementation AGMsgFilter

// This call creates the Graph and the Synth unit...
+ (void)createAUGraph
{
    AUNode synthNode, outNode, limiterNode;
    
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
    
// require_noerr (result = AUGraphAddNode (_graph, &cd, &limiterNode), home);
    
	cd.componentType = kAudioUnitType_Output;
	cd.componentSubType = kAudioUnitSubType_DefaultOutput;  
	require_noerr (result = AUGraphAddNode (_graph, &cd, &outNode), home);
	
	require_noerr (result = AUGraphOpen (_graph), home);
	
//	require_noerr (result = AUGraphConnectNodeInput (_graph, synthNode, 0, limiterNode, 0), home);
//	require_noerr (result = AUGraphConnectNodeInput (_graph, limiterNode, 0, outNode, 0), home);

    require_noerr (result = AUGraphConnectNodeInput (_graph, synthNode, 0, outNode, 0), home);

    
	// ok we're good to go - get the Synth Unit...
	require_noerr (result = AUGraphNodeInfo(_graph, synthNode, 0, &_synthUnit), home);
home:
	return;
}

+ (void)initialize {
    if(!_graph){
        OSStatus result;
        [self createAUGraph];
        // ok we're set up to go - initialize and start the graph
        require_noerr (result = AUGraphInitialize(_graph), home);
        UInt8 midiChannelInUse = 0; //we're using midi channel 1...

//        //set our bank
//        require_noerr (result = MusicDeviceMIDIEvent(_synthUnit, 
//                                                     kMidiMessage_ControlChange << 4 | midiChannelInUse, 
//                                                     kMidiMessage_BankMSBControl, 0,
//                                                     0/*sample offset*/), home);
//        
//        require_noerr (result = MusicDeviceMIDIEvent(_synthUnit, 
//                                                     kMidiMessage_ProgramChange << 4 | midiChannelInUse, 
//                                                     0/*prog change num*/, 0,
//                                                     0/*sample offset*/), home);
        
        CAShow (_graph); // prints out the graph so we can see what it looks like...
        
        require_noerr (result = AUGraphStart (_graph), home);
    }
home:
	return;
}

+ (void)addNoteOnMsg:(struct _noteOn *)noteOnMsg {
    
// some stuff i know
// vel 16 is put finger down
// vel 0 is take finger off
// notes dont get turned off they just fade out - when you play a new stroke on that string you get a note off then new note on
// hammer ons are weird - the ag makes a quieter and quieter noise but the note on msg is always at the original strike velocity
    
    int vel = noteOnMsg->bytes[2];
    
//    if(vel==0){

        int string =  noteOnMsg->bytes[0] - 143;    // 149 Low e, 48 a, 147 d, 146 g, 145 b, 144 e
        int fret = noteOnMsg->bytes[1] - midiStartFret[string-1];
    
      NSLog(@"note on string:%i fret:%i", string, vel );
	OSStatus result;
	UInt8 midiChannelInUse = string; //we're using midi channel 1...
	UInt32 noteOnCommand = 	kMidiMessage_NoteOn << 4 | midiChannelInUse;
    require_noerr (result = MusicDeviceMIDIEvent(_synthUnit, noteOnCommand, noteOnMsg->bytes[1], vel, 0), home);

//	UInt32 pitchChange = kMidiMessage_PitchBend << 4 | channel;
//	require_noerr (result = MusicDeviceMIDIEvent(synthUnit, pitchChange, byte1, byte2, 0), home);
    
	[_neckViewControl noteOnSrting:string fret:fret withVelocity:vel];
    
home:
	return;
}

// pluck
// 240.67.127 - 0.0.5 - string, note, 247

// finger down
// 240.67.127 - 0.0.1 - string, note, 247
// 240.67.127 - 0.0.3 - string, note, 247

// finger up
// 240.67.127 - 0.0.2 - string, note, 247
// 240.67.127 - 0.0.4 - string, note, 247
+ (void)addSysExMsg:(struct _sysEx *)sysExMsg {
    
 //   sysExKind   = 5
 //   string      = 6
 //   fret        = 7

    int kind  = sysExMsg->bytes[5];
    int string = sysExMsg->bytes[6];
    int arg2 = sysExMsg->bytes[7];
    if(kind==5){
        int strokeVelocity = arg2;
      //  NSLog(@"pluck: %i strokeVelocity: %i",  string, strokeVelocity );
    } else if(kind==1){
        int fret = arg2 - midiStartFret[string-1]-12;
       // NSLog(@"finger down?: %i arg2: %i",  string, fret );
    }
    else if(kind==3){
        int fret = arg2 - midiStartFret[string-1]-12;
      //  NSLog(@"finger down?: %i arg2: %i",  string, fret );
    }
    else if(kind==2){
        int fret = arg2 - midiStartFret[string-1]-12;
        //NSLog(@"finger up?: %i arg2: %i",  string, fret );
    }
    else if(kind==4){
        int fret = arg2 - midiStartFret[string-1]-12;
 //       NSLog(@"finger up?: %i arg2: %i",  string, fret );
    }
}
 
+ (void)setNeckViewController:(NeckViewControl *)nvc {
    _neckViewControl = nvc;
}

@end
