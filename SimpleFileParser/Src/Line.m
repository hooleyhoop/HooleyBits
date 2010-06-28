//
//  Line.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 28/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "Line.h"


@implementation Line

+ (id)lineWithAddress:(NSUInteger)addrr {
	return [[[self alloc] initWithAddress:addrr] autorelease];
}

- (id)initWithAddress:(NSUInteger)addrr {
	
	self = [super init];
	if(self){
		_address = addrr;
	}
	return self;
}

- (NSComparisonResult)compareAddress:(Line *)arg {
	
	NSUInteger otherAddress = arg->_address;
	if( otherAddress>_address )
		return (NSComparisonResult)NSOrderedAscending;
	else if( otherAddress<_address ) 
		return (NSComparisonResult)NSOrderedDescending;
	return (NSComparisonResult)NSOrderedSame;
}

- (NSComparisonResult)compare:(Line *)arg {
	
	NSUInteger otherAddress = arg->_address;
	if( otherAddress>_address )
		return (NSComparisonResult)NSOrderedAscending;
	else if( otherAddress<_address ) 
		return (NSComparisonResult)NSOrderedDescending;
	return (NSComparisonResult)NSOrderedSame;
}

@end
