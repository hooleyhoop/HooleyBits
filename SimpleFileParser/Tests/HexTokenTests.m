//
//  HexTokenTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "HexToken.h"

@interface HexTokenTests : SenTestCase {
	
}

@end


@implementation HexTokenTests

- (void)testHexTokenWithCString {
	// + (HexToken *)hexTokenWithCString:(const char *)hexStr
	
	HexToken *test = [HexToken hexTokenWithCString:"a"];
	STAssertNotNil(test, nil);
}

@end
