//
//  CodeLine.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 28/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "CodeLine.h"


@implementation CodeLine

+ (id)lineWithAddress:(NSUInteger)addrr {
	return [[[self alloc] initWithAddress:addrr] autorelease];
}

+ (id)lineWithAddress:(NSUInteger)addrr instruction:(NSString *)temp {
	return [[[self alloc] initWithAddress:addrr instruction:temp] autorelease];
}

- (id)initWithAddress:(NSUInteger)addrr {

	return [self initWithAddress:addrr instruction:nil];
}

- (id)initWithAddress:(NSUInteger)addrr instruction:(NSString *)temp {
	
	self = [super init];
	if(self){
		_address = addrr;
		_tempInstruction = [temp retain];
	}
	return self;
}

- (NSComparisonResult)compareAddress:(CodeLine *)arg {
	
	NSUInteger otherAddress = arg->_address;
	return [self compareAddressToAddress:otherAddress];
}

- (NSComparisonResult)compare:(CodeLine *)arg {
	
	return [self compareAddress:arg];
}

- (NSComparisonResult)compareAddressToAddress:(NSUInteger)addr {
	
	if( addr>_address )
		return (NSComparisonResult)NSOrderedAscending;
	else if( addr<_address ) 
		return (NSComparisonResult)NSOrderedDescending;
	return (NSComparisonResult)NSOrderedSame;
}

- (NSUInteger)address {
	return _address;
}

- (NSString *)prettyString {
	return _tempInstruction;
}

@end
