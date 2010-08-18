//
//  MemoryMap.m
//  MachoLoader
//
//  Created by Steven Hooley on 16/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "MemoryMap.h"
#import "Segment.h"

@implementation MemoryMap

- (id)init {

	self = [super init];
	if(self){
		_segmentStore = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {

	[_segmentStore release];
	[super dealloc];
}

- (NSUInteger)findInsertionPt:(Segment *)seg {
	
	NSUInteger low = 0;
	NSUInteger high  = [_segmentStore count];
	NSUInteger index = low;
	
	while( index < high ) {
		const NSUInteger mid = (index + high)/2;
		Segment *test = [_segmentStore objectAtIndex: mid];
		NSInteger result = [test compareStartAddress:seg];
		if ( result < 0) {
			index = mid + 1;
		} else {
			high = mid;
		}
	}
	return index;
}

- (void)insertSegment:(Segment *)seg {

	NSUInteger ind = [self findInsertionPt:seg];
	
	// sanity check
	if( ind<[_segmentStore count] ){
		Segment *existingObjectAtThatIndex = [_segmentStore objectAtIndex:ind];
		if( [seg lastAddress]<[existingObjectAtThatIndex startAddress]==NO )
			[NSException raise:@"Addresses have colided" format:@""];
	}
	
	[_segmentStore insertObject:seg atIndex:ind];
}

- (Segment *)segmentForAddress:(NSUInteger)memAddr {

	NSUInteger low = 0;
	NSUInteger high  = [_segmentStore count];
	NSInteger index = low;
	BOOL hit = NO;

	while( index < high ) {
		const NSUInteger mid = (index + high)/2;
		Segment *test = [_segmentStore objectAtIndex: mid];
		NSInteger result = [test compareStartAddressToAddress:memAddr];
		if ( result < 0) {
			index = mid + 1;
		} else if( result==0 ) {
			high = mid;
			hit = YES;
		} else {
			high = mid;
		}
	}
	if(!hit)
		index = index-1;
	if(index==-1)
		return nil;
	Segment *test = [_segmentStore objectAtIndex: index];
	if( memAddr>=[test startAddress] && memAddr<=[test lastAddress] )
		return test;
	return nil;
}

@end
