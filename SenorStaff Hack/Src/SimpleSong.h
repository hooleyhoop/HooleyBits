//
//  SimpleSong.h
//  SenorStaff Hack
//
//  Created by Steven Hooley on 6/21/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SimpleNote, MidiLoader;

@interface SimpleSong : NSObject <NSCoding> {

	NSUInteger _currentEventTime, _indexForNotesAtCurrentEventTime;
	NSMutableDictionary *_objectsAndKeys;
	NSMutableArray	*_orderedArray;
}

@property (readonly) NSUInteger currentEventTime;

- (id)initWithMIDILoader:(MidiLoader *)ml;

- (void)addNote:(SimpleNote *)n1 atTime:(NSUInteger)t1;

- (void)moveToFirstEvent;
- (void)moveToNextEvent;

- (NSUInteger)_correctIndexForInsertionAtTime:(NSUInteger)t1;

- (NSArray *)notesFromCurrentTimeWithRangeLength:(NSUInteger)rangeFromCurrentTime;

- (NSUInteger)countOfNoteGroups;
- (NSSet *)nodeGroupAtIndex:(NSUInteger)ind;

@end
