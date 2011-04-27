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

- (id)initWithStart:(char *)memAddr length:(uint64)len;

- (NSComparisonResult)compareStartAddress:(SHMemoryBlock *)seg;
- (NSComparisonResult)compareStartAddressToAddress:(char *)otherAddress;

- (void)shrinkToLength:(uint64)newLength;

- (char *)startAddress;
- (char *)lastAddress;
- (uint64)length;


@end
