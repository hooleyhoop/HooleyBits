//
//  IntKeyDictionaryTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 04/09/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "IntKeyDictionary.h"


@interface IntKeyDictionaryTests : SenTestCase {
	
}

@end

@implementation IntKeyDictionaryTests


- (void)testAddObject {
	
	NSObject *ob1 = [[[NSObject alloc] init] autorelease];
	NSObject *ob2 = [[[NSObject alloc] init] autorelease];
	IntKeyDictionary *dict = [[IntKeyDictionary alloc] init];
	[dict addObject:ob1 forIntKey:77];
	[dict addObject:ob2 forIntKey:99];
	
	STAssertTrue( [dict objectForIntKey:77]==ob1, nil );
	STAssertTrue( [dict objectForIntKey:99]==ob2, nil );
	
	STAssertTrue( [dict objectForIntKey:100]==nil, nil );

	[dict release];
}



	
	
@end
