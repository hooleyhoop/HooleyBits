//
//  MidiLoader.m
//  SenorStaff Hack
//
//  Created by Steven Hooley on 6/23/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import "MidiLoader.h"
#import "SimpleSong.h"
#import "MIDIUtil.h"

@implementation MidiLoader

+ (MidiLoader *)midiLoader {
	return [[[MidiLoader alloc] init] autorelease];
}

- (void)prepareDefaultFile {
	
	NSString *testMidiFile = [[NSBundle mainBundle] pathForResource:@"bars - 1 2 3 4" ofType:@"mid"];
	NSAssert(testMidiFile!=nil, @"File not found");
    _midiData = [[NSData dataWithContentsOfFile:testMidiFile] retain];
}

- (void)addDataToSong:(SimpleSong *)aSong {
	
	[MIDIUtil parseMidiData:_midiData intoSong:aSong];
}


@end
