//
//  MidiInLoop.h
//  MidiInLoop
//
//  Created by steve hooley on 05/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef struct _noteOn {
    int index;
    int bytes[3];
} noteOn;

typedef struct _sysEx {
    int index;
    int bytes[9];
} sysEx;

extern inline void addMidiByte( int byte );

@interface MidiInLoop : NSObject {

}

+ (struct _sysEx *)currentSysEx;
+ (struct _noteOn *)currentNote;
+ (BOOL)agReceiveMode;

@end
