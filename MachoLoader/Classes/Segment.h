//
//  Segment.h
//  MachoLoader
//
//  Created by Steven Hooley on 16/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class Section, MemoryBlockStore;

#import "SHMemoryBlock.h"

@interface Segment : SHNamedMemoryBlock {

	MemoryBlockStore	*_sectionStore;
}

+ (id)name:(NSString *)name start:(char *)memAddr length:(uint64)len;

- (id)initWithName:(NSString *)name start:(char *)memAddr length:(uint64)len;

- (void)insertSection:(Section *)sec;
- (Section *)sectionForAddress:(char *)memAddr;

@end
