//
//  MidiInLoop.m
//  MidiInLoop
//
//  Created by steve hooley on 05/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MidiInLoop.h"
#import <Foundation/Foundation.h>
#include <CoreMIDI/MIDIServices.h>
#include <CoreFoundation/CFRunLoop.h>
#include <stdio.h>
#import "AGMsgFilter.h"

@implementation MidiInLoop

MIDIPortRef		gOutPort = NULL;
MIDIEndpointRef	gDest = NULL;
int				gChannel = 0;

static struct _noteOn   *_currentNote;
static struct _sysEx    *_currentSysEx;
enum currentMsgType { SYSEX, NOTEON }; 

/* at the moment we are only keeping reference to the most recent note and most recent sysex */

static enum currentMsgType _currentMsgType;
static BOOL _agReceiveMode;

extern inline void clockTick() {

    // what have we got?
    _agReceiveMode = false;
}

extern inline void newNoteMSg( int byte ) {
    
    if(_currentNote)
        free(_currentNote);
    _currentNote = (noteOn *) malloc(sizeof(noteOn));
    _currentNote->index = 0;
    _currentNote->bytes[_currentNote->index++] = byte;
    _currentMsgType = NOTEON;
}

extern inline void newSysExMSg( int byte ) {

    if(_currentSysEx)
        free(_currentSysEx);
    _currentSysEx = (sysEx*) malloc(sizeof(sysEx));
    _currentSysEx->index = 0;
    _currentSysEx->bytes[_currentSysEx->index++] = byte;
    _currentMsgType = SYSEX;
}

extern void processDataByte( int byte ) {

    // was the last created object a note?
    if( _currentMsgType==NOTEON)
    {
        // -- is this data object complete?
        if(_currentNote->index<3){
            _currentNote->bytes[_currentNote->index++] = byte; // add new byte to current note
            if(_currentNote->index==3){
                //finished note
                [AGMsgFilter addNoteOnMsg: _currentNote];
                _agReceiveMode=NO;
            }
        }
        else
            [NSException raise:@"Note Overflow" format:@"trying to add too many data to note"];
            
    // was the last created object a sysex?
    } else if( _currentMsgType==SYSEX ) {
        // -- is this data object complete?
        if(_currentSysEx->index<9){
            _currentSysEx->bytes[_currentSysEx->index++] = byte; // add new byte to current msg
            if(_currentSysEx->index==9){
                //finished sysex
                [AGMsgFilter addSysExMsg: _currentSysEx];
                _agReceiveMode=NO;
            }
        } else
            [NSException raise:@"SysEx Overflow" format:@"trying to add too many data to sysex"];
    }
}

extern inline void addMidiByte( int packetData ) {

//    static int count =0;
//    if(count++<100)
//        NSLog(@"%i", packetData);
    
    if(packetData>127) {
        // status

        if(packetData==240) {
            // begin sysEx
            _agReceiveMode = true;
            newSysExMSg( packetData );
            
        }else if(packetData==247) {
            // end sysex
            processDataByte( packetData ); // this will end the sysex message but if future we may want to support sysEx of Arbitrary length and have a specific close msg
            _agReceiveMode = false;

        } else if(packetData>143 && packetData<150) {
            // note on
            _agReceiveMode = true;
            newNoteMSg( packetData );
        }
    } else if(_agReceiveMode==true) {
        // data
        processDataByte( packetData );
    }
}

static void	MyReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	if (gOutPort != NULL && gDest != NULL) 
    {
		MIDIPacket *packet = (MIDIPacket *)pktlist->packet;	// remove const (!)
        int numberOfPackets = pktlist->numPackets;
        
		for( unsigned int j=0; j<numberOfPackets; ++j )
        {
            for( int i=0; i<packet->length; ++i ) {
                
               // filter out clock ticks and active sense 
                if( i==0 && packet->data[0]==248)
                {
                    // clock tick
                    clockTick();
                    
                } else if( i==0 && packet->data[0]==254 ){
                    // active sense
                    _agReceiveMode = false;

                } else {
                    // everything else
                    addMidiByte( packet->data[i] );
                }
            }
            
          //   NSString *allPackets = [NSString string];
//       
//             if([allPackets length]>0)
//             {
//             allPackets = [NSString stringWithFormat:@"%@ . %i", allPackets, packet->data[i] ];
//             else
//             allPackets = [NSString stringWithFormat:@"%i", packet->data[i] ];
// 
//             }
//             allPackets = [allPackets stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//
//             //           if( [[allPackets substringToIndex:1] isEqualToString:@"0"])
//             NSLog(@"%@", allPackets );
//             lastWasMsg = YES;
//             
//             } else if(lastWasMsg){
//             
//             NSLog(@" ");
//             lastWasMsg = NO;
//             }
             
            
			packet = MIDIPacketNext(packet);
		}
	}
    [pool release];
}

// 240 (sysex) - 67 (0x43) Yamaha id - 127 device id NB i'm sure the length of the msg is there but i cant spot it

// look for 128 and above

// 254 active sense
// 248 clock
// 144-149 note on, note, velocity
// 128-143 note off, note, velocity

// -- sysEx 247 is end of sysEX

// pluck
// 240.67.127 - 0.0.5 - string, note, 247

// finger down
// 240.67.127 - 0.0.1 - string, note, 247
// 240.67.127 - 0.0.3 - string, note, 247

// finger up
// 240.67.127 - 0.0.2 - string, note, 247
// 240.67.127 - 0.0.4 - string, note, 247

// 
// 0.0.1 
// 0.0.3 press down

// 0.0.2 finger up
// 0.0.4

// 0.0.5 pluck string

// 240.67.127 sysEx

- (void)awakeFromNib {
    
    gChannel = 1;

    // create client and ports
    MIDIClientRef client = NULL;
    MIDIClientCreate(CFSTR("MIDI Echo"), NULL, NULL, &client);
    
    MIDIPortRef inPort = NULL;
    MIDIInputPortCreate(client, CFSTR("Input port"), MyReadProc, NULL, &inPort);
    MIDIOutputPortCreate(client, CFSTR("Output port"), &gOutPort);

    // enumerate devices (not really related to purpose of the echo program
    // but shows how to get information about devices)
    int i, n;
    CFStringRef pname, pmanuf, pmodel;
    char name[64], manuf[64], model[64];
    
    n = MIDIGetNumberOfDevices();
    for (i = 0; i < n; ++i) {
        MIDIDeviceRef dev = MIDIGetDevice(i);
        
        MIDIObjectGetStringProperty(dev, kMIDIPropertyName, &pname);
        MIDIObjectGetStringProperty(dev, kMIDIPropertyManufacturer, &pmanuf);
        MIDIObjectGetStringProperty(dev, kMIDIPropertyModel, &pmodel);
        
        CFStringGetCString(pname, name, sizeof(name), 0);
        CFStringGetCString(pmanuf, manuf, sizeof(manuf), 0);
        CFStringGetCString(pmodel, model, sizeof(model), 0);
        CFRelease(pname);
        CFRelease(pmanuf);
        CFRelease(pmodel);
        
        printf("name=%s, manuf=%s, model=%s\n", name, manuf, model);
    }
    
    // open connections from all sources
    n = MIDIGetNumberOfSources();
    printf("%d sources\n", n);
    for (i = 0; i < n; ++i) {
        MIDIEndpointRef src = MIDIGetSource(i);
        MIDIPortConnectSource(inPort, src, NULL);
    }
    
    // find the first destination
    n = MIDIGetNumberOfDestinations();
    if (n > 0)
        gDest = MIDIGetDestination(0);
    
    if (gDest != NULL) {
        MIDIObjectGetStringProperty(gDest, kMIDIPropertyName, &pname);
        CFStringGetCString(pname, name, sizeof(name), 0);
        CFRelease(pname);
        printf("Echoing to channel %d of %s\n", gChannel + 1, name);
    } else {
        printf("No MIDI destinations present\n");
    }
}

+ (struct _sysEx *)currentSysEx {
    return _currentSysEx;
}

+ (struct _noteOn *)currentNote {
    return _currentNote;
}

+ (BOOL)agReceiveMode {
    return _agReceiveMode;   
}
@end
