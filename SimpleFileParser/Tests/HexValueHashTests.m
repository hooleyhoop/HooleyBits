//
//  HexValueHashTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "HexToken.h"
#import "HexValueHash.h"

@interface HexValueHashTests : SenTestCase {
	
}

@end

@implementation HexValueHashTests



- (void)testValueForHexString {
		
	HexToken *aHexToken1 = [HexValueHash valueForHexString:"abcd0"];
	HexToken *aHexToken2 = [HexValueHash valueForHexString:"abcd1"];
	HexToken *aHexToken3 = [HexValueHash valueForHexString:"abcd0"];
	
	STAssertTrue(aHexToken1==aHexToken3, nil);
	STAssertTrue(aHexToken1!=aHexToken2, nil);
}

@end
