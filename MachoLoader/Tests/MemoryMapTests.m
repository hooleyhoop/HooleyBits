//
//  MemoryMapTests.m
//  MachoLoader
//
//  Created by Steven Hooley on 16/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "Segment.h"
#import "MemoryMap.h"
#import "Section.h"

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

- (void)testSegments {

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

- (void)testSections {
	
	Segment *seg1 = [Segment name:@"seg1" start:0 length:100];
	Segment *seg2 = [Segment name:@"seg2" start:100 length:100];
	Segment *seg3 = [Segment name:@"seg3" start:200 length:100];
	
	[_mm insertSegment:seg1];
	[_mm insertSegment:seg2];
	[_mm insertSegment:seg3];
	
	Section *sec1 = [Section name:@"sec1" segment:@"seg1" start:1 length:9];
	Section *sec2 = [Section name:@"sec2" segment:@"seg1" start:20 length:9];
	Section *sec3 = [Section name:@"sec3" segment:@"seg1" start:30 length:9];
	
	Section *sec4 = [Section name:@"sec4" segment:@"seg2" start:101 length:9];
	Section *sec5 = [Section name:@"sec5" segment:@"seg2" start:120 length:9];

	Section *sec6 = [Section name:@"sec6" segment:@"seg3" start:201 length:9];
	Section *sec7 = [Section name:@"sec7" segment:@"seg3" start:220 length:9];
	
	Section *messedUpSec = [Section name:@"messedUpSec" segment:@"seg1" start:1000 length:9];

	[_mm insertSection:sec4];
	[_mm insertSection:sec6];
	[_mm insertSection:sec2];
	[_mm insertSection:sec1];
	[_mm insertSection:sec3];
	[_mm insertSection:sec7];
	[_mm insertSection:sec5];
	STAssertThrows( [_mm insertSection:messedUpSec], @"not contained by segment" );

	STAssertTrue( [_mm sectionForAddress:1]==sec1, nil );
	STAssertTrue( [_mm sectionForAddress:21]==sec2, nil );
	STAssertTrue( [_mm sectionForAddress:34]==sec3, nil );
	STAssertTrue( [_mm sectionForAddress:102]==sec4, nil );
	STAssertTrue( [_mm sectionForAddress:120]==sec5, nil );
	STAssertTrue( [_mm sectionForAddress:205]==sec6, nil );
	STAssertTrue( [_mm sectionForAddress:222]==sec7, nil );
	STAssertTrue( [_mm sectionForAddress:0]==nil, nil );
}


@end
