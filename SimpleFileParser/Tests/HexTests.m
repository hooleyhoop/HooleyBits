//
//  HexTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 12/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "HexConversions.h"


@interface HexTests : SenTestCase {
	
}

@end


@implementation HexTests

- (void)testHexStringToInt {
	
	NSUInteger data = hexStringToInt(@"ff");
	STAssertTrue( data==255, @"%i", data );
	
	NSUInteger data2 = hexStringToInt(@"ffff");
	STAssertTrue( data2==65535, @"%i", data2 ); 
}
@end
