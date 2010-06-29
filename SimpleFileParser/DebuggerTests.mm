//
//  DebuggerTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 29/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


#import "TokenArray.h"
#import "SHDebugger.h"

@interface DebuggerTests : SenTestCase {
	
}

@end


@implementation DebuggerTests

- (void)testRunLLDB {
	
	[[[SHDebugger alloc] init] goforit];
	sleep(20000);
	STFail(@"Yay");
}


@end
