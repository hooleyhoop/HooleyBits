//
//  CodeBlockFactoryTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 01/07/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "CodeBlockFactory.h"

@interface CodeBlockFactoryTests : SenTestCase {
	
	CodeBlockFactory *_fac;
}

@end


@implementation CodeBlockFactoryTests

- (void)setUp {
	_fac = [[CodeBlockFactory alloc] init];
}

- (void)tearDown {
	[_fac release];
}

- (void)testNewCodeBlockWithName {
	// - (void)newCodeBlockWithName:(NSString *)funcName
	
	[_fac newCodeBlockWithName:@"steve"];
	STFail(@"todo");
}

- (void)testAddCodeLine {
	// - (void)addCodeLine:(NSString *)codeLine
	
	[_fac addCodeLine:@"dodod"];
	STFail(@"todo");
}


@end
