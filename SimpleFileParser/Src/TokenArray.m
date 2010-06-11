//
//  TokenArray.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 10/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "TokenArray.h"

#pragma mark -
@interface TokenArray ()
- (void)_tokenizeString:(NSString *)arg;
@end

#pragma mark -
@implementation TokenArray

- (id)initWithString:(NSString *)arg {

	[self _tokenizeString:arg];
	return self;
}

- (void)_tokenizeString:(NSString *)arg {
	
	const char *cString = [arg UTF8String];
	size_t length = strlen(cString);
	for( uint i=0; i<length; i++ ){

		char val = cString[i];
		
		switch( val ) {
			case '(':
				[self insertOpenBracketToken];
				break;
			case ')':
				[self insertCloseBracketToken];
				break;
			case ',':
				[self insertCommaToken];
				break;
			case '*':
				[self insertAsterisk];
				break;
			case '%':
				[self insertPercent];
				break;
			default:
				if(val>=0x30 && val<=0x39)
					[self insertDecimalChar:val];
				else if(val>=0x41 && val<=0x5A)
					[self insertUppercaseChar:val];
				else if(val>=0x61 && val<=0x7a)
					[self insertLowercaseChar:val];
				else
					[NSException raise:@"UNHandled Char" format:@"%c", val];
			break;
		}
	}
}


#pragma mark 1 char Tokens
void _add1CharToken( struct BasicTokenArray *arrayPtr, enum TokenType type, char value ){
	
	// Close current token if needed (if current token is not empty)
	uint currentTok = arrayPtr->tokenCount;
	if(arrayPtr->tokens[currentTok].tokenLength)
		arrayPtr->tokenCount++;
	
	// Add the bracket token
	currentTok = arrayPtr->tokenCount;
	arrayPtr->tokens[currentTok].type = type;
	arrayPtr->tokens[currentTok].tokenLength = 1;
	arrayPtr->tokens[currentTok].value[0] = value;
}

- (void)insertOpenBracketToken {

	_add1CharToken( &_tokenArray, openBracket, '(' );
}

- (void)insertCloseBracketToken {

	_add1CharToken( &_tokenArray, closeBracket, ')' );
}

- (void)insertCommaToken {

	_add1CharToken( &_tokenArray, comma, ',' );
}

- (void)insertAsterisk {

	_add1CharToken( &_tokenArray, asterisk, '*' );
}

- (void)insertPercent {

	_add1CharToken( &_tokenArray, percent, '%' );
}

	
#pragma mark Long Tokens 

void _newTokenIfTypeRequiresIt( struct BasicTokenArray *arrayPtr, enum TokenType type ) {
	
	uint currentTok = arrayPtr->tokenCount;
	enum TokenType currentType = arrayPtr->tokens[currentTok].type;

	if( currentType!=type ) {
		// Close current token
		arrayPtr->tokenCount++;
		currentTok = arrayPtr->tokenCount;
		arrayPtr->tokens[currentTok].type = type;
	}
}

void addToToken( struct BasicTokenArray *arrayPtr, char val ) {

	uint currentTok = arrayPtr->tokenCount;
	uint currentTokPos = arrayPtr->tokens[currentTok].tokenLength;
	arrayPtr->tokens[currentTok].value[currentTokPos] = val;
	arrayPtr->tokens[currentTok].tokenLength++;
}

- (void)insertDecimalChar:(char)val {
	
	_newTokenIfTypeRequiresIt( &_tokenArray, decimalNum );
	addToToken(  &_tokenArray, val );
}

- (void)insertUppercaseChar:(char)val {

	_newTokenIfTypeRequiresIt( &_tokenArray, upperCaseChar );
	addToToken(  &_tokenArray, val );
}

- (void)insertLowercaseChar:(char)val {

	_newTokenIfTypeRequiresIt( &_tokenArray, lowerCaseChar );
	addToToken(  &_tokenArray, val );
}

#pragma mark -
NSString* tokenTypeAsString( enum TokenType type ) {
	
	NSString *typeString = nil;
	switch(type){
		case decimalNum:
			typeString = @"decNm";
			break;
		case upperCaseChar:
			typeString = @"uprCC";
			break;
		case lowerCaseChar:
			typeString = @"lwrCC";
			break;
		case openBracket:
			typeString = @"opBRK";
			break;
		case closeBracket:
			typeString = @"clBRK";
			break;
		case comma:
			typeString = @"comma";
			break;
		case asterisk:
			typeString = @"astrx";
			break;
		case dollar:
			typeString = @"dollr";
			break;
		case percent:
			typeString = @"prcnt";
			break;
		default:
			[NSException raise:@"Dont know what this tosken type is" format:@"%i", type];
			break;

	}
	return typeString;
}

- (NSString *)description {
	
	NSString *blergh = @""; //This makes it more difficult to compare in tests - [super description];
	for(uint i=0; i<=_tokenArray.tokenCount; i++) {
		struct BasicToken thisToken = _tokenArray.tokens[i];
		NSString* typeName = tokenTypeAsString( thisToken.type );
		NSString* value = [NSString stringWithCharacters:thisToken.value length:thisToken.tokenLength];
		blergh = [NSString stringWithFormat:@"%@ %@:%@", blergh, typeName, value];
	}
	return blergh;
}


@end
