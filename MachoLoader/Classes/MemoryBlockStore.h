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

- (void)insertMemoryBlock:(SHMemoryBlock *)memBlock;
- (SHMemoryBlock *)blockForAddress:(uint64)memAddr;

- (uint64)lastAddress;

@end
