//
//  SimpleSong.m
//  SenorStaff Hack
//
//  Created by Steven Hooley on 6/21/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import "SimpleSong.h"

@interface SimpleSong (privateMethods) 
- (NSNumber *)_keyForNoteSet:(NSSet *)notes;
- (NSUInteger)_timeForNotesAtIndex:(NSUInteger)noteSetIndex;
@end

@implementation SimpleSong

@synthesize currentEventTime = _currentEventTime;

- (id)init {

	self = [super init];
	if(self){
		_objectsAndKeys = [[NSMutableDictionary alloc] init];
		_orderedArray = [[NSMutableArray alloc] init];
		_currentEventTime = NSNotFound;
		_indexForNotesAtCurrentEventTime = NSNotFound;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	
	self = [super init];
	if(self) {
		
		NSAssert(_objectsAndKeys==nil, @"did init get called?");
		_objectsAndKeys = [[coder decodeObjectForKey:@"objectsAndKeys"] retain];
		_orderedArray = [[coder decodeObjectForKey:@"orderedArray"] retain];;
		_currentEventTime = NSNotFound;
		_indexForNotesAtCurrentEventTime = NSNotFound;		
	}
	return self;
}

- (void)dealloc {
	[_objectsAndKeys release];
	[_orderedArray release];
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder {
	
	[coder encodeObject:_objectsAndKeys forKey:@"objectsAndKeys"];
	[coder encodeObject:_orderedArray forKey:@"orderedArray"];
}

- (NSUInteger)_correctIndexForInsertionAtTime:(NSUInteger)t1 {
	
	// first object goes at zero
	if([_orderedArray count]==0)
		return 0;
	
	// if time is the same as last time then use the same index
	if(t1==_currentEventTime)
		return _indexForNotesAtCurrentEventTime;
	
	NSUInteger searchStartIndex=0;
	NSUInteger searchEndIndex=0;
	
	if(t1<_currentEventTime){
		
		searchStartIndex=0;
		searchEndIndex=_indexForNotesAtCurrentEventTime;

		for(NSUInteger i=searchStartIndex; i<searchEndIndex; i++ )
		{
			NSUInteger time = [self _timeForNotesAtIndex:i];

			// if we already have some notes at this time it is pretty easy
			if(t1==time)
				return i;
			
			// else if we have gone past it.
			else if(t1<time)
				return i;
		}
		[NSException raise:@"we should never get here!" format:@""];
	}
	
	if(t1>_currentEventTime){
		
		searchStartIndex=_indexForNotesAtCurrentEventTime+1;
		searchEndIndex=[_orderedArray count];
	
		for(NSUInteger i=searchStartIndex; i<searchEndIndex; i++ )
		{
			NSUInteger time = [self _timeForNotesAtIndex:i];

			// if we already have some notes at this time it is pretty easy
			if(t1==time)
				return i;
			
			// else if we have gone past it.
			else if(t1<time)
				return i;			
		}
	}
	
	// else stick it at the end
	return [_orderedArray count];
}

- (void)addNote:(SimpleNote *)n1 atTime:(NSUInteger)t1 {
	
	NSAssert([_orderedArray count]==[_objectsAndKeys count], @"going in");

	NSNumber *key = [NSNumber numberWithUnsignedInt:t1];
	NSMutableSet *notesAtTime = [_objectsAndKeys objectForKey:key];
	if(!notesAtTime)
	{
		// this is the first event at this time
		notesAtTime = [NSMutableSet setWithObject:n1];
		NSUInteger correctIndex = [self _correctIndexForInsertionAtTime:t1];
		
		[_objectsAndKeys setObject:notesAtTime forKey:key];
		[_orderedArray insertObject:notesAtTime atIndex:correctIndex];
		
		_indexForNotesAtCurrentEventTime = correctIndex;
		
	} else {
		// we already have this one - yay! - Do we need to remove first?
		NSUInteger currentIndex = [_orderedArray indexOfObjectIdenticalTo:notesAtTime];
		// -- NSAssert(currentIndex!=NSNotFound, @"This should never happen");
		// -- [_orderedArray removeObjectAtIndex:currentIndex];
		// -- [dict removeObjectForKey:key]
		[notesAtTime addObject:n1];
		// -- [_objectsAndKeys setObject:notesAtTime forKey:key];
		// -- [_orderedArray insertObject:notesAtTime atIndex:currentIndex];
		
		_indexForNotesAtCurrentEventTime = currentIndex;
	}
	_currentEventTime = t1;
	
	NSAssert([_orderedArray count]==[_objectsAndKeys count], @"coming out");
}

- (NSNumber *)_keyForNoteSet:(NSSet *)notes {

	NSArray *foundKeys = [_objectsAndKeys allKeysForObject:notes];
	NSAssert(foundKeys && [foundKeys count]==1, @"maybe we should try the more complex delete / add insert?");
	NSNumber *theKey = [foundKeys lastObject];
	return theKey;
}

- (NSUInteger)_timeForNotesAtIndex:(NSUInteger)noteSetIndex {

	NSParameterAssert(noteSetIndex<[self countOfNoteGroups]);
	NSSet *notes = [_orderedArray objectAtIndex:noteSetIndex];
	NSAssert(notes, @"maybe we should try the more complex delete / add insert?");
	NSNumber *timeForNotes = [self _keyForNoteSet:notes];
	NSAssert(timeForNotes, @"must have a key");
	return [timeForNotes unsignedIntValue];
}

- (void)_moveToEventWithIndex:(NSUInteger)eventIndex {
	
	NSParameterAssert(eventIndex<[self countOfNoteGroups]);

	NSUInteger time = [self _timeForNotesAtIndex:eventIndex];
	_currentEventTime = time;
	_indexForNotesAtCurrentEventTime = eventIndex;
}

- (void)moveToFirstEvent {
	[self _moveToEventWithIndex:0];
}

- (void)moveToNextEvent {
	
	NSUInteger nextEventIndex = _indexForNotesAtCurrentEventTime<([self countOfNoteGroups]-1) ? _indexForNotesAtCurrentEventTime+1 : 0;
	[self _moveToEventWithIndex:nextEventIndex];
}

- (NSArray *)notesFromCurrentTimeWithRangeLength:(NSUInteger)rangeFromCurrentTime {
	
	NSMutableArray *includedNoteGroups = [NSMutableArray array];

	for( NSUInteger i=_indexForNotesAtCurrentEventTime; i<[self countOfNoteGroups]; i++){
		NSSet *notesAtTime = [_orderedArray objectAtIndex:i];
		NSUInteger timeOfNotes = [self _timeForNotesAtIndex:i];
		if(timeOfNotes<=_currentEventTime+rangeFromCurrentTime)
			[includedNoteGroups addObject:notesAtTime];
	}
	return includedNoteGroups;
}

- (NSUInteger)countOfNoteGroups {
	
	NSAssert2([_orderedArray count]==[_objectsAndKeys count], @"storage out of sync %i, %i", [_orderedArray count], [_objectsAndKeys count]);
	return [_orderedArray count];
}

- (NSSet *)nodeGroupAtIndex:(NSUInteger)ind {
	NSParameterAssert(ind<[self countOfNoteGroups]);
	return [[[_orderedArray objectAtIndex:ind] copy] autorelease];
}


@end
