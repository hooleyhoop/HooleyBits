//
//  InputParseTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 09/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <ParseKit/ParseKit.h>
#import "TokenArray.h"

@interface InputParseTests : SenTestCase {
	
}

@end


@implementation InputParseTests


- (void)testParseArguments {
	
	NSString *s = @"*0x004fb883(%ebx,%eax,4)";
	
	// PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
	// PKToken *eof = [PKToken EOFToken];
	// PKToken *tok = nil;
	
	// while ((tok = [t nextToken]) != eof) {
		// NSLog(@"(%@) (%.1f) : %@", tok.stringValue, tok.floatValue, [tok debugDescription]);
	// }
	
	// My way
	TokenArray *tokensFromThisString  = [[[TokenArray alloc] initWithString:s] autorelease];
	NSLog(@"%@", tokensFromThisString);

	
	STFail(@"Yay");
}

@end


