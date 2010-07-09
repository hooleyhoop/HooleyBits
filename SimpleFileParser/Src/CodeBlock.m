//
//  CodeBlock.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 28/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "CodeBlock.h"
#import "CodeLine.h"

@interface CodeBlock()
- (id)initWithName:(NSString *)name;
@end

@implementation CodeBlock

+ (id)blockWithName:(NSString *)name {
	return [[[self alloc] initWithName:name] autorelease];
}

- (id)initWithName:(NSString *)name {

	self = [super init];
	if(self){
		_name = [name retain];
		_lineStore = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {

	[_name release];
	[_lineStore release];
	[super dealloc];
}

- (NSUInteger)insertionIndexFor:(CodeLine *)insertObject {
	
	NSUInteger low = 0;
	NSUInteger high  = [_lineStore count];
	NSUInteger index = low;
	
    while( index < high ) {
        const NSUInteger mid = (index + high)/2;
        id test = [_lineStore objectAtIndex: mid];
		NSInteger result = [test compareAddress:insertObject];
        if ( result < 0) {
            index = mid + 1;
        } else {
            high = mid;
        }
    }
	return index;
}

- (void)pushLine:(CodeLine *)arg {
	
	NSParameterAssert(arg);
	[_lineStore addObject:arg];
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

- (NSUInteger)endAddress {
	
	return [[self lastLine] address];
}

- (CodeLine *)firstLine {

	NSAssert( [_lineStore count]>0, @"codeBlock is empty!");
	return [_lineStore objectAtIndex:0];
}

- (CodeLine *)lastLine {
	
	NSAssert( [_lineStore count]>0, @"codeBlock is empty!");
	return [_lineStore lastObject];
}

- (NSString *)name {
	return _name;
}

- (NSUInteger)lineCount {
	return [_lineStore count];
}

- (CodeLine *)lineAtIndex:(NSUInteger)ind {
	return [_lineStore objectAtIndex:ind];
}

@end
