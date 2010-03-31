//
//  MidiInLoopTests.m
//  MidiInLoop
//
//  Created by steve hooley on 09/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MidiInLoopTests.h"
#import "MidiInLoop.h"

@implementation MidiInLoopTests

- (void)setUp {
    
}

- (void)tearDown {
    
}

- (void)testFingerPositions {
    
    /* try a sysEx */
    STAssertTrue( [MidiInLoop agReceiveMode]==NO, @"Wrong");
    addMidiByte( 240 );
    STAssertTrue( [MidiInLoop agReceiveMode]==YES, @"Wrong");
    addMidiByte( 67 );
    addMidiByte( 127 );
    addMidiByte( 0 );
    addMidiByte( 0 );
    addMidiByte( 1 );
    addMidiByte( 6 );   // string
    addMidiByte( 50 );  // note
    addMidiByte( 247 );
    STAssertTrue( [MidiInLoop agReceiveMode]==NO, @"Wrong");

    /* try a note */
    addMidiByte( 144 );
    STAssertTrue( [MidiInLoop agReceiveMode]==YES, @"Wrong");
    addMidiByte( 50 );  // note
    addMidiByte( 64 );  // velocity
    STAssertTrue( [MidiInLoop agReceiveMode]==NO, @"Wrong");

    struct _sysEx *lastSysEx = [MidiInLoop currentSysEx];
    struct _noteOn *lastNote = [MidiInLoop currentNote];
    STAssertTrue( lastSysEx!=nil, @"doh" );
    STAssertTrue( lastNote!=nil, @"doh" );
    
    STAssertTrue( lastSysEx->bytes[0]==240, @"Fucked Up");
    STAssertTrue( lastSysEx->bytes[1]==67, @"Fucked Up");
    STAssertTrue( lastSysEx->bytes[2]==127, @"Fucked Up");
    STAssertTrue( lastSysEx->bytes[3]==0, @"Fucked Up");
    STAssertTrue( lastSysEx->bytes[4]==0, @"Fucked Up");
    STAssertTrue( lastSysEx->bytes[5]==1, @"Fucked Up");
    STAssertTrue( lastSysEx->bytes[6]==6, @"Fucked Up");
    STAssertTrue( lastSysEx->bytes[7]==50, @"Fucked Up");
    STAssertTrue( lastSysEx->bytes[8]==247, @"Fucked Up");
    
    STAssertTrue( lastNote->bytes[0]==144, @"Fucked Up");
    STAssertTrue( lastNote->bytes[1]==50, @"Fucked Up");
    STAssertTrue( lastNote->bytes[2]==64, @"Fucked Up");
    
    /* Test that we ignore all msgs except sysEx and NoteOn */
    addMidiByte( 189 );
    STAssertTrue( [MidiInLoop agReceiveMode]==NO, @"Wrong");

}

@end
