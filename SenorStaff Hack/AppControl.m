//
//  AppControl.m
//  SenorStaff Hack
//
//  Created by steve hooley on 20/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
//#import <Carbon/Carbon.h>
//#import "memory.h"
//#import <iostream>
//#import <fstream>
#import "AppControl.h"
#import <FScript/FScript.h>
#import "MusicDocument.h"
#import "SimpleSong.h"
#import "SongPlayer.h"
#import "MidiLoader.h"

// using namespace std;

//#include "allegro.h"

static AppControl *cachedAppControl;

@implementation AppControl

@synthesize testDoc;

+ (AppControl *)cachedAppControl {
    
    return cachedAppControl;
}

- (void)dealloc {
	[testDoc release];
	[super dealloc];
}

#warning! Tell don't ask!
- (void)awakeFromNib {

    cachedAppControl = self;
    
    /* load FScript */
	[[NSApp mainMenu] addItem:[[[FScriptMenuItem alloc] init] autorelease]];

	if(NSClassFromString(@"SimpleNoteTests")==nil)
	{
		MidiLoader *ml = [MidiLoader midiLoader];
		[ml prepareDefaultFile];

		testDoc = [[MusicDocument alloc] init];
		SimpleSong *emptySong = [[[SimpleSong alloc] init] autorelease];
		[ml addDataToSong:emptySong];
		
		testDoc.song = emptySong;
			
		SongPlayer *songPlayer = [[SongPlayer alloc] initWithSong:emptySong];
		[songPlayer play];
	}
}

@end
