//
//  Segment.m
//  MachoLoader
//
//  Created by Steven Hooley on 16/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "Segment.h"


@implementation Segment

@synthesize name=_name;

+ (id)name:(NSString *)name start:(NSUInteger)memAddr length:(NSUInteger)len {
	
	return [[[self alloc] initWithName:name start:memAddr length:len] autorelease];
}

- (id)initWithName:(NSString *)name start:(NSUInteger)memAddr length:(NSUInteger)len {

	self = [super init];
	if(self){
		_startAddr = memAddr;
		_length = len;
		_name = [name retain];
	}
	return self;
}

- (void)dealloc {
	[_name release];
	[super dealloc];
}

- (NSComparisonResult)compareStartAddress:(Segment *)seg {

	NSUInteger otherAddress = seg->_startAddr;
	return [self compareStartAddressToAddress:otherAddress];
}

- (NSComparisonResult)compareStartAddressToAddress:(NSUInteger)otherAddress {

	if( otherAddress>_startAddr )
		return (NSComparisonResult)NSOrderedAscending;
	else if( otherAddress<_startAddr ) 
		return (NSComparisonResult)NSOrderedDescending;
	return (NSComparisonResult)NSOrderedSame;
}

- (NSUInteger)startAddress {
	return _startAddr;
}

- (NSUInteger)lastAddress {
	return _startAddr+_length-1;
}

@end
