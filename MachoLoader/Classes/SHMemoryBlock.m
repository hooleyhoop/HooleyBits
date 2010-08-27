//
//  SHMemoryBlock.m
//  MachoLoader
//
//  Created by Steven Hooley on 18/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "SHMemoryBlock.h"


@implementation SHMemoryBlock

@synthesize name=_name;
@synthesize startAddr=_startAddr;
@synthesize length=_length;

- (id)initWithName:(NSString *)name start:(NSUInteger)memAddr length:(NSUInteger)len {
	
	self = [super init];
	if(self){
		_name = [name retain];
		_startAddr = memAddr;
		_length = len;
	}
	return self;
}

- (void)dealloc {
	
	[_name release];
	[super dealloc];
}

- (NSComparisonResult)compareStartAddress:(SHMemoryBlock *)seg {
	
	NSUInteger otherAddress = seg.startAddr;
	return [self compareStartAddressToAddress:otherAddress];
}

- (NSComparisonResult)compareStartAddressToAddress:(NSUInteger)otherAddress {
	
	if( otherAddress>_startAddr )
		return (NSComparisonResult)NSOrderedAscending;
	else if( otherAddress<_startAddr ) 
		return (NSComparisonResult)NSOrderedDescending;
	return (NSComparisonResult)NSOrderedSame;
}

- (NSUInteger)lastAddress {
	return _startAddr+_length-1;
}


@end
