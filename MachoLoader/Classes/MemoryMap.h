//
//  MemoryMap.h
//  MachoLoader
//
//  Created by Steven Hooley on 16/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class Segment, Section, MemoryBlockStore;

@interface MemoryMap : NSObject {

	@public
	MemoryBlockStore *_segmentStore;
}

- (void)insertSegment:(Segment *)seg;
- (Segment *)segmentForAddress:(uint64)memAddr;

- (void)insertSection:(Section *)sec;
- (Section *)sectionForAddress:(uint64)memAddr;

- (uint64)lastAddress;

@end
