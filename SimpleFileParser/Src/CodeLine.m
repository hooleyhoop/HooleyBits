//
//  CodeLine.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 28/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "CodeLine.h"
#import "Instruction.h"
#import "Argument.h"

@implementation CodeLine

@synthesize arguments=_arguments;

+ (id)lineWithAddress:(NSUInteger)addrr {
	return [[[self alloc] initWithAddress:addrr] autorelease];
}

+ (id)lineWithAddress:(NSUInteger)addrr instruction:(Instruction *)temp {
	return [[[self alloc] initWithAddress:addrr instruction:temp] autorelease];
}

+ (id)lineWithAddress:(NSUInteger)addrr instruction:(Instruction *)temp1 args:(NSArray *)temp2 {
	return [[[self alloc] initWithAddress:addrr instruction:temp1 args:temp2] autorelease];
}

- (id)initWithAddress:(NSUInteger)addrr {
	return [self initWithAddress:addrr instruction:nil args:nil];
}

- (id)initWithAddress:(NSUInteger)addrr instruction:(Instruction *)temp {
	return [self initWithAddress:addrr instruction:temp args:nil];
}

- (id)initWithAddress:(NSUInteger)addrr instruction:(Instruction *)opCodeInfo args:(NSArray *)temp2 {

	self = [super init];
	if(self){
		_address = addrr;
		_instruction = [opCodeInfo retain];
		_arguments = [temp2 retain];
	}
	return self;
}

- (void)dealloc {
		
	[_instruction release];
	[_arguments release];
	[super dealloc];
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
	
	NSString *workingOnIt = [_instruction printWithArgs:_arguments];
	return workingOnIt;
}



@end
