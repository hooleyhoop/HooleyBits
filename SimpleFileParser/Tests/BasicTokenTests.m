//
//  BasicTokenTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 13/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "BasicToken.h"


@interface BasicTokenTests : SenTestCase {
	
}

@end

@implementation BasicTokenTests

- (void)test_isValidHexNumComponent {
	// - (BOOL)isValidHexNumComponent

	char letters[16];
	strcpy( letters, "abcdef" );
	BasicToken *tok1 = [BasicToken tokenWithType:lowerCaseChar value:lettes length:6];
	STAssertTrue([tok1 isValidHexNumComponent], @"doh");
}

- (void)testTokenWithType {
	// + (id)tokenWithType:(enum TokenType)arg1 value:(char)arg2

	BasicToken *tok = [BasicToken tokenWithType:lowerCaseChar value:'a'];
	[tok append:'b'];
	NSString *stringValue = [tok outputString];
	STAssertTrue( [stringValue isEqualToString:@"lwrCC:ab"], @"%@", stringValue );
}

- (void)testAppend {
	
	char aString[16];
	strcpy( aString, "steve");
	BasicToken *tok = [BasicToken tokenWithType:lowerCaseChar value:'a'];
	[tok append:aString length:5];
	NSString *stringValue = [tok outputString];
	STAssertTrue( [stringValue isEqualToString:@"lwrCC:asteve"], @"%@", stringValue );
}

@end
