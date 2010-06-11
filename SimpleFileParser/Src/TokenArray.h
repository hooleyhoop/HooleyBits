//
//  TokenArray.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 10/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define MAX_TOKENS 60
#define MAX_TOKEN_LENGTH 16

enum TokenType {
    decimalNum,		// decNm
	upperCaseChar,	// uprCC
	lowerCaseChar,	// lwrCC
    openBracket,	// opBRK
    closeBracket,	// clBRK
    comma,			// comma
    asterisk,		// astrx
    dollar,			// dollr
    percent			// prcnt
};

struct BasicToken {
	enum TokenType type;
	uint tokenLength;
	unichar value[MAX_TOKEN_LENGTH];
};

struct BasicTokenArray {
	uint tokenCount;
	struct BasicToken tokens[MAX_TOKENS];
};

#pragma mark -
@interface TokenArray : NSObject {

	struct BasicTokenArray _tokenArray;
}

- (id)initWithString:(NSString *)arg;

- (void)insertOpenBracketToken;
- (void)insertCloseBracketToken;
- (void)insertCommaToken;
- (void)insertAsterisk;
- (void)insertPercent;

- (void)insertDecimalChar:(char)val;
- (void)insertUppercaseChar:(char)val;
- (void)insertLowercaseChar:(char)val;

- (NSString *)outputString;

@end
