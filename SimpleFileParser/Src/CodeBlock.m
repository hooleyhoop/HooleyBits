//
//  CodeBlock.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 28/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "CodeBlock.h"
#import "CodeLine.h"

@implementation CodeBlock

+ (id)block {
	return [[[self alloc] init] autorelease];
}

- (id)init {

	self = [super init];
	if(self){
		_lineStore = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {

	[_lineStore release];
	[super dealloc];
}

- (NSUInteger)insertionIndexFor:(CodeLine *)arg {

	return 0;
}

- (void)pushLine:(CodeLine *)arg {
	[_lineStore addObject:arg];
}

- (void)insertLine:(CodeLine *)arg {
	
	NSUInteger ind = [self insertionIndexFor:arg];
}

- (NSComparisonResult)compareStartAddress:(CodeBlock *)aBlock {
	
	return [[_lineStore objectAtIndex:0] compareAddress:[aBlock firstLine]];
}

- (NSComparisonResult)compareStartToAddress:(NSUInteger)addr {

	return [[_lineStore objectAtIndex:0] compareAddressToAddress:addr];
}

- (NSUInteger)startAddress {

	return [[self firstLine] address];
}

- (CodeLine *)firstLine {

	NSAssert( [_lineStore count]>0, @"codeBlock is empty!");
	return [_lineStore objectAtIndex:0];
}


@end
