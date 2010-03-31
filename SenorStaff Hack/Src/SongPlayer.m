//
//  SongPlayer.m
//  SenorStaff Hack
//
//  Created by steve hooley on 18/06/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "SongPlayer.h"
#import "SimpleSong.h"
#import "SimpleNote.h"
#import "MidiInterface.h"

@implementation SongPlayer

@synthesize songToPlay = _songToPlay;

- (id)initWithSong:(SimpleSong *)value {

	self = [super init];
	if(self){
		self.songToPlay = value;
	}
	return self;
}

- (void)play {
	
	[MidiInterface startAudio];
	
	[_songToPlay moveToFirstEvent];
	NSLog(@"playing %i notegroups", [_songToPlay countOfNoteGroups]);
	
	
	for(NSUInteger i=0; i<[_songToPlay countOfNoteGroups]; i++){
//	-- make some noise
		NSUInteger eventTime = _songToPlay.currentEventTime;
		NSLog(@"Notes at time %i", eventTime);
		NSArray *allNoteGroupsForRange = [_songToPlay notesFromCurrentTimeWithRangeLength:0];

		for(NSSet *eachNoteGroup in allNoteGroupsForRange){
			[MidiInterface playNoteGroup:eachNoteGroup];
		}

		[_songToPlay moveToNextEvent];
	}
	
	[MidiInterface stopAudio];
}


@end
