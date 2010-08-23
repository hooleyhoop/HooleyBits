//
//  SHMemoryBlock.h
//  MachoLoader
//
//  Created by Steven Hooley on 18/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


@interface SHMemoryBlock : NSObject {

	NSUInteger		_startAddr;
	NSUInteger		_length;
	NSString		*_name;
}

@property (readonly) NSString	*name;
@property (readonly) NSUInteger startAddr;

- (id)initWithName:(NSString *)name start:(NSUInteger)memAddr length:(NSUInteger)len;

- (NSComparisonResult)compareStartAddress:(SHMemoryBlock *)seg;
- (NSComparisonResult)compareStartAddressToAddress:(NSUInteger)otherAddress;

- (NSUInteger)lastAddress;


@end
