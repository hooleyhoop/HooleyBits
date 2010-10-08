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
- (Segment *)segmentForAddress:(char *)memAddr;

- (void)insertSection:(Section *)sec;
- (Section *)sectionForAddress:(char *)memAddr;

- (char *)lastAddress;

@end
