//
//  SHMemoryBlock.h
//  MachoLoader
//
//  Created by Steven Hooley on 18/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


@interface SHMemoryBlock : NSObject {

	char			*_startAddr;
	uint64			_length;
	NSString		*_name;
}

@property (readonly) NSString	*name;
@property (readonly) char		*startAddr;
@property (readonly) uint64		length;

- (id)initWithName:(NSString *)name start:(char *)memAddr length:(uint64)len;

- (NSComparisonResult)compareStartAddress:(SHMemoryBlock *)seg;
- (NSComparisonResult)compareStartAddressToAddress:(char *)otherAddress;

- (char *)lastAddress;


@end
