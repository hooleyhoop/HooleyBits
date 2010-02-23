//
//  TestSaveAndLoad.m
//  SenorStaff Hack
//
//  Created by steve hooley on 01/09/2008.
//  Copyright 2008 BestBefore Ltd. All rights reserved.
//

#import "MusicDocument.h"
#import "SimpleSong.h"
#import "SimpleNote.h"

#import <SenTestingKit/SenTestingKit.h>


@interface TestSaveAndLoad : SenTestCase {
	
}

@end


@implementation TestSaveAndLoad

- (void)testLoadMidi {

    // bars - 1 2 3 4.mid
//    NSString *testMidiFile = [[NSBundle bundleForClass:[self class]] pathForResource:@"bars - 1 2 3 4" ofType:@"mid"];
//    NSData *midiData = [NSData dataWithContentsOfFile:testMidiFile];
//    
//    MusicDocument *testDoc = [[[MusicDocument alloc] init] autorelease];
//    SimpleSong *emptySong = [[[SimpleSong alloc] initFromMIDI:midiData withDocument:testDoc] autorelease];
//    testDoc.song = emptySong;
//
//	NSMutableArray *staffs = [emptySong staffs];
//    STAssertTrue( [staffs count]==1, @"er? %i", [staffs count] );
//    STAssertTrue( [emptySong numberOfMeasures]==4, @"er? %i", [emptySong numberOfMeasures] );
//	Staff *staff1 = [staffs lastObject];
//	
//	Measure *measure1 = [staff1 measureAtIndex:0];
//	NSLog( @"notes in measure 1 %i", [[measure1 notes] count]);
////--	rest - note - rest - rest
//	
//	Measure *measure2 = [staff1 measureAtIndex:1];
//	NSLog( @"notes in measure 2 %i", [[measure2 notes] count]);
////--	note - rest - note - rest
//	
//	Measure *measure3 = [staff1 measureAtIndex:2];
//	NSLog( @"notes in measure 3 %i", [[measure3 notes] count]);
////	note - rest - note - note	(this last note runs over to the next bar)
//	
//	Measure *measure4 = [staff1 measureAtIndex:3];
//	NSLog( @"notes in measure 4 %i", [[measure4 notes] count]);
//	note - note - note - note
}

@end
