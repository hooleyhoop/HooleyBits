//
//  MemoryMapTests.m
//  MachoLoader
//
//  Created by Steven Hooley on 16/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "Segment.h"
#import "MemoryMap.h"

@interface MemoryMapTests : SenTestCase {
	
	MemoryMap *_mm;
}

@end


@implementation MemoryMapTests

- (void)setUp {
	_mm = [[MemoryMap alloc] init];
}

- (void)tearDown {
	[_mm release];
}

- (void)test {

	Segment *seg1 = [Segment name:@"seg1" start:10 length:2];
	Segment *seg2 = [Segment name:@"seg2" start:20 length:5];
	Segment *seg3 = [Segment name:@"seg3" start:30 length:100];
	Segment *fakeSeg = [Segment name:@"fakeSeg" start:0 length:100];

	[_mm insertSegment:seg2];
	[_mm insertSegment:seg1];
	[_mm insertSegment:seg3];
	STAssertThrows( [_mm insertSegment:fakeSeg], @"This should overlap which isnt allowed" );
	
	STAssertTrue( [_mm segmentForAddress:0]==nil, nil );
	STAssertTrue( [_mm segmentForAddress:10]==seg1, nil );
	STAssertTrue( [_mm segmentForAddress:11]==seg1, nil );
	STAssertTrue( [_mm segmentForAddress:12]==nil, nil );
	STAssertTrue( [_mm segmentForAddress:20]==seg2, nil );
	STAssertTrue( [_mm segmentForAddress:24]==seg2, nil );
	STAssertTrue( [_mm segmentForAddress:25]==nil, nil );
	STAssertTrue( [_mm segmentForAddress:30]==seg3, nil );
}

@end
