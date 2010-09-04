//
//  IntHashTests.m
//  MachoLoader
//
//  Created by Steven Hooley on 04/09/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "IntHash.h"

@interface IntHashTests : SenTestCase {
	
}

@end


@implementation IntHashTests

- (void)testIntHashStuff {
	
	IntHash *dict = [[IntHash alloc] init];
	[dict addInt:(NSInteger)11 forIntKey:(NSInteger)77];
	[dict addInt:12 forIntKey:99];
	
	STAssertTrue( [dict intForIntKey:77]==11, @"%i", [dict intForIntKey:77] );
	STAssertTrue( [dict intForIntKey:99]==12, nil );
	
	STAssertTrue( [dict intForIntKey:100]==INT32_MAX, nil );
	
	[dict release];
}

@end
