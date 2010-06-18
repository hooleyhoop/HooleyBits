//
//  InputParseTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 09/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "TokenArray.h"
#import "SHDebugger.h"

@interface InputParseTests : SenTestCase {
	
}

@end


@implementation InputParseTests


- (void)testParseArguments {
	
	[[[SHDebugger alloc] init] goforit];
	sleep(20000);
	STFail(@"Yay");
}

@end


