//
//  SHMemoryBlock.h
//  MachoLoader
//
//  Created by Steven Hooley on 18/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


@interface SHMemoryBlock : NSObject {

	uint64			_startAddr;
	uint64			_length;
	NSString		*_name;
}

@property (readonly) NSString	*name;
@property (readonly) uint64 startAddr;
@property (readonly) uint64 length;

- (id)initWithName:(NSString *)name start:(uint64)memAddr length:(uint64)len;

- (NSComparisonResult)compareStartAddress:(SHMemoryBlock *)seg;
- (NSComparisonResult)compareStartAddressToAddress:(uint64)otherAddress;

- (uint64)lastAddress;


@end
