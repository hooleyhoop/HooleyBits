//
//  MemoryMap.h
//  MachoLoader
//
//  Created by Steven Hooley on 16/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class Segment, Section, MemoryBlockStore;

@interface MemoryMap : NSObject {

	MemoryBlockStore *_segmentStore;
}

- (void)insertSegment:(Segment *)seg;
- (Segment *)segmentForAddress:(NSUInteger)memAddr;

- (void)insertSection:(Section *)sec;
- (Section *)sectionForAddress:(NSUInteger)memAddr;

@end
