//
//  TokenArray.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 10/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class BasicToken;

enum TokenType {

    decimalNum,		// decNm
	upperCaseChar,	// uprCC
	lowerCaseChar,	// lwrCC
    openBracket,		// opBRK
    closeBracket,		// clBRK
    comma,				// comma
    asterisk,			// astrx
    dollar,			// dollr
    percent,			// prcnt
    colon,				// colon
	registerVal,		// rgstr
	hexNum				// hexNm
};

#pragma mark -
@interface TokenArray : NSObject {

	NSMutableArray		*_tokenArray;
}

+ (id)tokensWithString:(NSString *)arg;
- (id)initWithString:(NSString *)arg;

- (void)insertOpenBracketToken;
- (void)insertCloseBracketToken;
- (void)insertCommaToken;
- (void)insertAsterisk;
- (void)insertPercent;
- (void)insertDollar;
- (void)insertColon;

- (void)insertDecimalChar:(char)val;
- (void)insertUppercaseChar:(char)val;
- (void)insertLowercaseChar:(char)val;

- (void)secondPass;

- (NSString *)outputString;
- (NSString *)pattern;

- (NSUInteger)count;
- (BasicToken *)tokenAtIndex:(NSUInteger)i;

@end
