//
//  MemoryMap.m
//  MachoLoader
//
//  Created by Steven Hooley on 16/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "MemoryMap.h"
#import "Segment.h"
#import "Section.h"
#import "MemoryBlockStore.h"

@implementation MemoryMap

- (id)init {

	self = [super init];
	if(self){
		_segmentStore = [[MemoryBlockStore alloc] init];
	}
	return self;
}

- (void)dealloc {

	[_segmentStore release];
	[super dealloc];
}

- (void)insertSegment:(Segment *)seg {

	[_segmentStore insertMemoryBlock:seg];
}

- (void)insertSection:(Section *)sec {
	
	Segment *containerSeg = [self segmentForAddress:sec.startAddr];
	if( [sec.segmentName isEqualToString:containerSeg.name]==NO )
		[NSException raise:@"Fucked up so,mewhere" format:@""];
	
	[containerSeg insertSection:sec];
}

- (Section *)sectionForAddress:(NSUInteger)memAddr {

	Segment *containerSeg = [self segmentForAddress:memAddr];
	Section *sec = [containerSeg sectionForAddress:memAddr];
	return sec;
}

- (Segment *)segmentForAddress:(NSUInteger)memAddr {

	return (Segment *)[_segmentStore blockForAddress:memAddr];
}

- (NSUInteger)lastAddress {
	return [_segmentStore lastAddress];
}
@end
