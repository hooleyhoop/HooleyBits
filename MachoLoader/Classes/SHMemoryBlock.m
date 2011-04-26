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

- (void)shrinkToLength:(uint64)newLength {
    NSParameterAssert( newLength<_sizeAndPoisition->length );
    _sizeAndPoisition->length = newLength;
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

@end
