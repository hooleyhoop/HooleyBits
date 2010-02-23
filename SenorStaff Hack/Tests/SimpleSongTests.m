//
//  SimpleSongTests.m
//  SenorStaff Hack
//
//  Created by Steven Hooley on 6/20/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>
#import "SimpleSong.h"
#import "SimpleNote.h"

@interface SimpleSongTests : SenTestCase {
	
	SimpleSong *_simpleSong;
	SimpleNote *_note1, *_note2, *_note3, *_note4, *_note5, *_note6, *_note7;
}

@end@implementation SimpleSongTests

- (void)setUp {
	_simpleSong = [[SimpleSong alloc] init];
	
	CGFloat vel = 1.0f;
	_note1 = [SimpleNote noteWithPitch:1 velocity:vel];
	_note2 = [SimpleNote noteWithPitch:2 velocity:vel];
	_note3 = [SimpleNote noteWithPitch:3 velocity:vel];
	_note4 = [SimpleNote noteWithPitch:4 velocity:vel];
	_note5 = [SimpleNote noteWithPitch:5 velocity:vel];
	_note6 = [SimpleNote noteWithPitch:6 velocity:vel];
	_note7 = [SimpleNote noteWithPitch:7 velocity:vel];

	// {0}, { 10, 10, 10 }, { 11 }, { 12, 12 }
	STAssertTrue([_simpleSong _correctIndexForInsertionAtTime:10]==0, @"hmm %i", [_simpleSong _correctIndexForInsertionAtTime:10]);
	[_simpleSong addNote:_note2 atTime:10];
	STAssertTrue([_simpleSong _correctIndexForInsertionAtTime:10]==0, @"hmm %i", [_simpleSong _correctIndexForInsertionAtTime:10]);
	[_simpleSong addNote:_note3 atTime:10];
	[_simpleSong addNote:_note4 atTime:10];
	
	STAssertTrue([_simpleSong _correctIndexForInsertionAtTime:12]==1, @"hmm %i", [_simpleSong _correctIndexForInsertionAtTime:12]);
	[_simpleSong addNote:_note6 atTime:12];
	[_simpleSong addNote:_note7 atTime:12];
	
	STAssertTrue([_simpleSong _correctIndexForInsertionAtTime:0]==0, @"hmm %i", [_simpleSong _correctIndexForInsertionAtTime:0]);
	[_simpleSong addNote:_note1 atTime:0];

	STAssertTrue([_simpleSong _correctIndexForInsertionAtTime:11]==2, @"hmm %i", [_simpleSong _correctIndexForInsertionAtTime:11]);
	[_simpleSong addNote:_note5 atTime:11];
}

- (void)tearDown {
	[_simpleSong release];
}

- (void)testCountOfNoteGroups {
// - (NSUInteger)countOfNoteGroups:(NSUInteger)t1
	STAssertTrue([_simpleSong countOfNoteGroups]==4, @"%i", [_simpleSong countOfNoteGroups]);
}

- (void)testNodeGroupAtIndex {
// - (NSSet *)nodeGroupAtIndex:(NSUInteger)ind
	
	NSSet *group1 = [_simpleSong nodeGroupAtIndex:0];
	NSSet *group2 = [_simpleSong nodeGroupAtIndex:1];
	NSSet *group3 = [_simpleSong nodeGroupAtIndex:2];
	NSSet *group4 = [_simpleSong nodeGroupAtIndex:3];
	
	STAssertTrue([group1 count]==1, @"%i", [group1 count]);
	STAssertTrue([group2 count]==3, @"%i", [group2 count]);
	STAssertTrue([group3 count]==1, @"%i", [group3 count]);
	STAssertTrue([group4 count]==2, @"%i", [group4 count]);

	STAssertTrue([group1 containsObject:_note1], @"doh");
	
	STAssertTrue([group2 containsObject:_note2], @"doh");
	STAssertTrue([group2 containsObject:_note3], @"doh");
	STAssertTrue([group2 containsObject:_note4], @"doh");
	
	STAssertTrue([group3 containsObject:_note5], @"doh");

	STAssertTrue([group4 containsObject:_note6], @"doh");
	STAssertTrue([group4 containsObject:_note7], @"doh");
}

- (void)test_correctIndexForInsertionAtTime {
//- (NSUInteger)_correctIndexForInsertionAtTime:(NSUInteger)t1

	STAssertTrue([_simpleSong _correctIndexForInsertionAtTime:0]==0, @"hmm %i", [_simpleSong _correctIndexForInsertionAtTime:0]);
	STAssertTrue([_simpleSong _correctIndexForInsertionAtTime:5]==1, @"hmm %i", [_simpleSong _correctIndexForInsertionAtTime:5]);
	STAssertTrue([_simpleSong _correctIndexForInsertionAtTime:10]==1, @"hmm %i", [_simpleSong _correctIndexForInsertionAtTime:10]);
	STAssertTrue([_simpleSong _correctIndexForInsertionAtTime:13]==4, @"hmm %i", [_simpleSong _correctIndexForInsertionAtTime:13]);
}

- (void)testMoveToNextEvent {
	// - (void)moveToFirstEvent
	//- (void)moveToNextEvent
	
	[_simpleSong moveToFirstEvent];
	STAssertTrue(_simpleSong.currentEventTime==0, @"doh %i", _simpleSong.currentEventTime);
	[_simpleSong moveToNextEvent];
	STAssertTrue(_simpleSong.currentEventTime==10, @"doh %i", _simpleSong.currentEventTime);
	[_simpleSong moveToNextEvent];
	STAssertTrue(_simpleSong.currentEventTime==11, @"doh %i", _simpleSong.currentEventTime);
	[_simpleSong moveToNextEvent];
	STAssertTrue(_simpleSong.currentEventTime==12, @"doh %i", _simpleSong.currentEventTime);
	[_simpleSong moveToNextEvent];
	STAssertTrue(_simpleSong.currentEventTime==0, @"doh %i", _simpleSong.currentEventTime);
}

- (void)testNotesFromCurrentTimeWithRangeLength {
	// - (NSArray *)notesFromCurrentTimeWithRangeLength:(NSUInteger)rangeFromCurrentTime {
	
	[_simpleSong moveToFirstEvent];
	NSArray *notes = [_simpleSong notesFromCurrentTimeWithRangeLength:1];
	STAssertTrue([notes count]==1, @"should have 1 note group %i", [notes count]);
	STAssertTrue([[notes lastObject] count]==1, @"note group should have one note" );
	STAssertTrue([[notes lastObject] containsObject:_note1], @"wrong note?" );

	notes = [_simpleSong notesFromCurrentTimeWithRangeLength:0];
	STAssertTrue([notes count]==1, @"should have 1 note group %i", [notes count]);
	STAssertTrue([[notes lastObject] count]==1, @"note group should have one note" );
	STAssertTrue([[notes lastObject] containsObject:_note1], @"wrong note?" );
	
	[_simpleSong moveToNextEvent];
	notes = [_simpleSong notesFromCurrentTimeWithRangeLength:0];
	STAssertTrue([notes count]==1, @"should have 1 note group %i", [notes count]);
	STAssertTrue([[notes lastObject] count]==3, @"note group should have three notes" );
	
	notes = [_simpleSong notesFromCurrentTimeWithRangeLength:2];
	STAssertTrue([notes count]==3, @"should have 3 note groups %i", [notes count]);
	STAssertTrue([[notes lastObject] count]==2, @"last note group should have 2 notes" );
}

- (void)testEncode_Decode {
		
	NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:_simpleSong];
	STAssertNotNil(archive, @"ooch");
	
	SimpleSong *song2 = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
	STAssertNotNil(song2, @"ooch");
	
	STAssertTrue([song2 countOfNoteGroups]==4, @"%i", [song2 countOfNoteGroups]);
	[song2 moveToFirstEvent];
	[song2 moveToNextEvent];
	NSArray *notes = [song2 notesFromCurrentTimeWithRangeLength:0];
	STAssertTrue([notes count]==1, @"should have 1 note group %i", [notes count]);
	STAssertTrue([[notes lastObject] count]==3, @"note group should have three notes" );
}

@end
