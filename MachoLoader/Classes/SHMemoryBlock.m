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

@synthesize startAddr=_startAddr;
@synthesize length=_length;

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
	
	char *otherAddress = seg.startAddr;
	return [self compareStartAddressToAddress:otherAddress];
}

- (NSComparisonResult)compareStartAddressToAddress:(char *)otherAddress {
	
	if( otherAddress>_startAddr )
		return (NSComparisonResult)NSOrderedAscending;
	else if( otherAddress<_startAddr ) 
		return (NSComparisonResult)NSOrderedDescending;
	return (NSComparisonResult)NSOrderedSame;
}

- (char *)lastAddress {
	return _startAddr+_length-1;
}


@end
