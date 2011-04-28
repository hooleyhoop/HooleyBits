//
//  MemoryBlockStore.h
//  MachoLoader
//
//  Created by Steven Hooley on 18/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class SHMemoryBlock;

@interface MemoryBlockStore : NSObject {

	@public
	NSMutableArray *_memoryBlockStore;
}

- (NSUInteger)findInsertionPt:(SHMemoryBlock *)memBlock;

- (void)insertMemoryBlock:(SHMemoryBlock *)memBlock;
- (SHMemoryBlock *)blockForAddress:(char *)memAddr;

- (SHMemoryBlock *)memoryBlockAtIndex:(int)ind;

- (NSUInteger)itemCount;
- (char *)startAddress;
- (char *)lastAddress;

@end
