//
//  TokenArray.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 10/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "TokenArray.h"
#import "BasicToken.h"

#pragma mark -
@interface TokenArray ()
- (void)_tokenizeString:(NSString *)arg;
@end

#pragma mark -
@implementation TokenArray

+ (id)tokensWithString:(NSString *)arg {
	return [[[self alloc] initWithString:arg] autorelease];
}

- (id)initWithString:(NSString *)arg {

	self = [super init];
	_tokenArray = [[NSMutableArray alloc] initWithCapacity:16];
	[self _tokenizeString:arg];
	return self;
}

- (void)dealloc {

	[_tokenArray release];
	[super dealloc];
}

- (void)_tokenizeString:(NSString *)arg {
	
	const char *cString = [arg UTF8String];

	// remember strlen doesn't include the null
	size_t length = strlen(cString);
	for( NSUInteger i=0; i<length; i++ )
	{
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
			case '$':
				[self insertDollar];
				break;
			case ':':
				[self insertColon];
				break;				
			case '?':
				[self insertQuestionMark];
				i=length; // we are done - this line is junk
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
- (void)insertOpenBracketToken {

	[_tokenArray addObject:[BasicToken tokenWithType:openBracket value:'(']];
}

- (void)insertCloseBracketToken {

	[_tokenArray addObject:[BasicToken tokenWithType:closeBracket value:')']];
}

- (void)insertCommaToken {

	[_tokenArray addObject:[BasicToken tokenWithType:comma value:',']];
}

- (void)insertAsterisk {

	[_tokenArray addObject:[BasicToken tokenWithType:asterisk value:'*']];
}

- (void)insertPercent {

	[_tokenArray addObject:[BasicToken tokenWithType:percent value:'%']];
}

- (void)insertDollar {

	[_tokenArray addObject:[BasicToken tokenWithType:dollar value:'$']];
}

- (void)insertColon {
	
	[_tokenArray addObject:[BasicToken tokenWithType:colon value:':']];
}


- (void)insertQuestionMark {
	
	[_tokenArray addObject:[BasicToken tokenWithType:questionMarkChar value:'?']];
}

#pragma mark Long Tokens 

- (void)_addToToken:(NSMutableArray *)arrayPtr :(enum TokenType)type :(char)val {

	BasicToken *currentTok = nil;
	NSUInteger tokCount = [_tokenArray count];
	if(tokCount)
		currentTok = [_tokenArray objectAtIndex:tokCount-1];
	if( currentTok && currentTok->_type==type )
		[currentTok append:val];
	else
		[_tokenArray addObject:[BasicToken tokenWithType:type value:val]];
}

- (void)insertDecimalChar:(char)val {
	
	[self _addToToken:_tokenArray :decimalNum :val];
}

- (void)insertUppercaseChar:(char)val {

	[self _addToToken:_tokenArray :upperCaseChar :val];
}

- (void)insertLowercaseChar:(char)val {

	[self _addToToken:_tokenArray :lowerCaseChar :val];
}

#pragma mark -

- (void)_parseRegisterNames:(NSUInteger)startIndex {
	
	NSUInteger count = [_tokenArray count];
	for( NSUInteger i=startIndex; i<(count-1); i++ )
	{
		BasicToken *tok = [_tokenArray objectAtIndex:i];
		
		if( tok.type==questionMarkChar )
			return;
			
		if( tok.type==percent ){
			BasicToken *nextTok = [_tokenArray objectAtIndex:i+1];
			if( nextTok.type==questionMarkChar )
				return;
			
			if( nextTok.type==lowerCaseChar || nextTok.type==questionMarkChar ){
				
				// -- these two tokens are a register
				BasicToken *registerToken = [BasicToken tokenWithType:registerVal value:nextTok.value length:nextTok.length];
				[_tokenArray removeObjectAtIndex:i+1];
				[_tokenArray replaceObjectAtIndex:i withObject:registerToken];
				
				NSUInteger nextPlaceToStart = i+1;
			
				//-- is the next token a small decimal number? - rememeber count has changed
				if( i+1 < [_tokenArray count] ){
					BasicToken *nextNextTok = [_tokenArray objectAtIndex:i+1];
					if(nextNextTok.type==decimalNum){
						[_tokenArray removeObjectAtIndex:i+1];
						[registerToken append:nextNextTok.value length:nextNextTok.length];
					}
				}
				
				[self _parseRegisterNames:nextPlaceToStart];
				return;
			}
		}
	}	
}

- (void)_parseHexNumbers:(NSUInteger)startIndex {
	
	NSUInteger count = [_tokenArray count];
	for( NSUInteger i=startIndex; i<count-1; i++ )
	{
		BasicToken *tok = [_tokenArray objectAtIndex:i];
		if( tok.type==questionMarkChar )
			return;
			
		if( tok.type==decimalNum && tok.length==1 && tok.value[0]=='0' )
		{
			BasicToken *nextTok = [_tokenArray objectAtIndex:i+1];
			if( nextTok.type==questionMarkChar )
				return;

			if( [nextTok isValidStartHexNumComponent] )
			{
				NSMutableIndexSet *indexesToRemove = [NSMutableIndexSet indexSet];

				BasicToken *hexToken = nil;

				// -- first char must be x
				// -- remove IT
				char *thisVal;
				uint thisValLength = nextTok.length;
				if(thisValLength>1){
					thisVal = nextTok.value+1;
					thisValLength = thisValLength-1;
					hexToken = [BasicToken tokenWithType:hexNum value:thisVal length:thisValLength];
				}

				[indexesToRemove addIndex:i+1];
					
				for( NSUInteger j=i+2; j<count; j++ )
				{
					BasicToken *nextTok = [_tokenArray objectAtIndex:j];
					if( [nextTok isValidHexNumComponent] )
					{
						if(!hexToken)
							hexToken = [BasicToken tokenWithType:hexNum value:nextTok.value length:nextTok.length];
						else
							[hexToken append:nextTok.value length:nextTok.length];
					
						[indexesToRemove addIndex:j];
					} else {
						break;
					}

				}
				
				[_tokenArray removeObjectsAtIndexes:indexesToRemove];
				[_tokenArray replaceObjectAtIndex:i withObject:hexToken];

				[self _parseHexNumbers:i];
				return;
			}
		}
	}	
}

// Search for consequtive tokens that should be compounded
- (void)secondPass {

	[self _parseRegisterNames:0];
	[self _parseHexNumbers:0];
}

#pragma mark -

- (NSString *)outputString {

	NSString *blergh = @"";
	for( BasicToken* each in _tokenArray ) 
	{
		NSString *value = [each outputString];
		if([blergh length]==0)
			blergh = value;
		else
			blergh = [NSString stringWithFormat:@"%@ %@", blergh, value];
	}
	return blergh;	
}

- (NSString *)pattern {

	NSString *blergh = @"";
	for( BasicToken* each in _tokenArray ) 
	{
		NSString *value = [each patternString];
		if([blergh length]==0)
			blergh = value;
		else
			blergh = [NSString stringWithFormat:@"%@ %@", blergh, value];
	}
	return blergh;
}



- (NSString *)description {
	
	NSString *blergh = [super description];
	return [NSString stringWithFormat:@"%@ - %@", blergh, [self outputString]];
}

- (NSUInteger)count {
	return [_tokenArray count];
}

- (BasicToken *)tokenAtIndex:(NSUInteger)i {
	return [_tokenArray objectAtIndex:i];
}


@end
