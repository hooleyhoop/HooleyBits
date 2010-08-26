//
//  IndirectSymbolTableTests.m
//  MachoLoader
//
//  Created by Steven Hooley on 25/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "IntKeyDictionary.h"


@interface IndirectSymbolTableTests : SenTestCase {
	
	IntKeyDictionary *_symbolTable;
}

@end


@implementation IndirectSymbolTableTests

- (void)setUp {
	_symbolTable = [[IntKeyDictionary alloc] init];
}

- (void)tearDown {
	[_symbolTable release];
}


- (void)testUseIntKey {

	NSObject *ob1 = [[NSObject alloc] init];
	NSObject *ob2 = [[NSObject alloc] init];
	
	[_symbolTable addObject:ob1 forIntKey:0x21];
	[_symbolTable addObject:ob2 forIntKey:0x22];
	
	NSObject *result1 = [_symbolTable objectForIntKey:0x21];
	NSObject *result2 = [_symbolTable objectForIntKey:0x22];

	STAssertTrue( result1==ob1, nil );
	STAssertTrue( result2==ob2, nil );
	STAssertTrue( result1!=ob2, nil );

	[ob1 release];
	[ob2 release];
}

@end
