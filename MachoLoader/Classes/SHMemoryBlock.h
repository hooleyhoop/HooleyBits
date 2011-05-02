//
//  SHMemoryBlock.h
//  MachoLoader
//
//  Created by Steven Hooley on 18/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
@class MemorySectionIndexStructure;


@interface SHMemoryBlock : NSObject {
@public
    struct MemSectionIndexes *_sizeAndPoisition;
}

struct SplitData {
    SHMemoryBlock *blk1;
    SHMemoryBlock *blk2;
};

- (id)initWithStart:(char *)memAddr length:(uint64)len;

- (NSComparisonResult)compareStartAddress:(SHMemoryBlock *)seg;
- (NSComparisonResult)compareStartAddressToAddress:(char *)otherAddress;

- (struct SplitData)splitAtAddress:(char *)splitAddr;

- (char *)startAddress;
- (char *)lastAddress;
- (uint64)length;

- (BOOL)containsAddress:(char *)addr;

@end
