//
//  StringCounterTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 14/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>
#import "StringCounter.h"

@interface StringCounterTests : SenTestCase {
	
	StringCounter *_sc;
}

@end


@implementation StringCounterTests

- (void)setUp {
	_sc = [[StringCounter alloc] init];
}

- (void)tearDown {
	[_sc release];
}

- (void)testBasicOperation {
	
	[_sc add:@"hello"];
	[_sc add:@"hello"];
	[_sc add:@"hello"];
	[_sc add:@"cat"];
	[_sc add:@"cat"];
	[_sc add:@"dog"];
	[_sc add:@"dog"];
	[_sc add:@"fish"];
	
	[_sc sort];
	NSArray *sortedCounts = [_sc sortedCounts];
	STAssertTrue( [sortedCounts count]==3, @"%i", [sortedCounts count] );
	STAssertTrue( [[sortedCounts objectAtIndex:0] intValue]==3, @"%i", [[sortedCounts objectAtIndex:0] intValue] );
	STAssertTrue( [[sortedCounts objectAtIndex:1] intValue]==2, @"%i", [[sortedCounts objectAtIndex:1] intValue] );
	STAssertTrue( [[sortedCounts objectAtIndex:2] intValue]==1, @"%i", [[sortedCounts objectAtIndex:2] intValue] );

	NSArray *sortedStrings = [_sc sortedStrings];
	STAssertTrue( [sortedStrings count]==4, @"%i", [sortedStrings count] );
	STAssertTrue( [[sortedStrings objectAtIndex:0] isEqualToString:@"hello"], @"%@", [sortedStrings objectAtIndex:0] );
	STAssertTrue( [[sortedStrings objectAtIndex:1] isEqualToString:@"cat"], @"%@", [sortedStrings objectAtIndex:0] );
	STAssertTrue( [[sortedStrings objectAtIndex:2] isEqualToString:@"dog"], @"%@", [sortedStrings objectAtIndex:0] );
	STAssertTrue( [[sortedStrings objectAtIndex:3] isEqualToString:@"fish"], @"%@", [sortedStrings objectAtIndex:0] );
}

@end
