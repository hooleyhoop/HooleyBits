//
//  SHMemoryBlock.h
//  MachoLoader
//
//  Created by Steven Hooley on 18/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
@class MemorySectionIndexStructure;


@interface SHMemoryBlock : NSObject {

    struct MemSectionIndexes *_sizeAndPoisition;
}

@property (readonly) char		*startAddr;
@property (readonly) uint64		length;

- (id)initWithStart:(char *)memAddr length:(uint64)len;

- (NSComparisonResult)compareStartAddress:(SHMemoryBlock *)seg;
- (NSComparisonResult)compareStartAddressToAddress:(char *)otherAddress;

- (char *)lastAddress;


@end
