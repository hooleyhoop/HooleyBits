//
//  MemoryMap.h
//  MachoLoader
//
//  Created by Steven Hooley on 16/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class Segment;

@interface MemoryMap : NSObject {

	NSMutableArray *_segmentStore;

}

- (void)insertSegment:(Segment *)seg;
- (Segment *)segmentForAddress:(NSUInteger)memAddr;

@end
