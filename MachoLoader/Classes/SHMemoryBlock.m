//
//  SHMemoryBlock.m
//  MachoLoader
//
//  Created by Steven Hooley on 18/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "SHMemoryBlock.h"
#import "MemorySectionIndexStructure.h"


@implementation SHMemoryBlock

- (id)initWithStart:(char *)memAddr length:(uint64)len {
	
	self = [super init];
	if(self){
        _sizeAndPoisition = new_MemSectionIndexes( memAddr, len );
	}
	return self;
}

- (void)dealloc {
	free( _sizeAndPoisition );
	[super dealloc];
}

// return 2 new blocks
// at the moment this assumes you want SHMemoryBlocks and not subclasses
- (struct SplitData)splitAtAddress:(char *)splitAddr {
        
    struct SplitData result;
    
    uint64 newPart1Length = splitAddr - _sizeAndPoisition->start;
    uint64 remainingLength = _sizeAndPoisition->length-newPart1Length;
    char *part2Start = _sizeAndPoisition->start+newPart1Length;
    
    NSAssert( newPart1Length>0, nil );
    NSAssert( remainingLength>0, nil );

    SHMemoryBlock *newBlock1 = [[[SHMemoryBlock alloc] initWithStart:_sizeAndPoisition->start length:newPart1Length] autorelease];
    SHMemoryBlock *newBlock2 = [[[SHMemoryBlock alloc] initWithStart:part2Start length:remainingLength] autorelease];    
    
    result.blk1 = newBlock1;
    result.blk2 = newBlock2;
    return result;
}

- (NSComparisonResult)compareStartAddress:(SHMemoryBlock *)seg {
	
	char *otherAddress = [seg startAddress];
	return [self compareStartAddressToAddress:otherAddress];
}

- (NSComparisonResult)compareStartAddressToAddress:(char *)otherAddress {
	
	if( otherAddress>_sizeAndPoisition->start )
		return (NSComparisonResult)NSOrderedAscending;
	else if( otherAddress<_sizeAndPoisition->start ) 
		return (NSComparisonResult)NSOrderedDescending;
	return (NSComparisonResult)NSOrderedSame;
}

- (char *)startAddress {
    return _sizeAndPoisition->start;
}

- (char *)lastAddress {
	return _sizeAndPoisition->start+_sizeAndPoisition->length-1;
}

- (uint64)length {
    return _sizeAndPoisition->length;
}

- (BOOL)containsAddress:(char *)addr {
    return addr >= _sizeAndPoisition->start && addr <= [self lastAddress];
}

@end
