//
//  BasicToken.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 13/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "BasicToken.h"
#import "HexConversions.h"


@implementation BasicToken

NSString *tokenTypeAsString( enum TokenType type ) {
	
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
		case colon:
			typeString = @"colon";
			break;
		case registerVal:
			typeString = @"rgstr";
			break;
		case hexNum:
			typeString = @"hexNm";
			break;
		case questionMarkChar:
			typeString = @"qsmrk";
			break;
		default:
			[NSException raise:@"Dont know what this tosken type is" format:@"%i", type];
			break;
			
	}
	return typeString;
}

+ (id)tokenWithType:(enum TokenType)arg1 value:(char)arg2 {

	return [[[self alloc] initWithType:arg1 value:arg2] autorelease];
}

+ (id)tokenWithType:(enum TokenType)arg1 value:(char *)arg2 length:(NSUInteger)l {
	
	return [[[self alloc] initWithType:arg1 value:arg2 length:l] autorelease];
}

- (id)initWithType:(enum TokenType)arg1 value:(char)arg2 {
	
	self = [super init];
	_type = arg1;
	_tokenLength = 1;
	_value[0] = arg2;
	return self;
}

- (id)initWithType:(enum TokenType)arg1 value:(char *)arg2 length:(NSUInteger)l {
	
	self = [super init];
	_type = arg1;
	_tokenLength = (uint)l;
	strncpy( _value, arg2, l );
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (void)append:(char)value {
	
	_value[_tokenLength] = value;
	_tokenLength++;
}

- (void)append:(char *)value length:(uint)l {
	
	strcpy( _value+_tokenLength, value);
	_tokenLength+=l;
}

- (NSString *)outputString {
	
	NSString * stringValue = [NSString stringWithCString:_value encoding:NSASCIIStringEncoding];
	NSString * typeName = nil;

	switch( _type ){
		case decimalNum:
		case upperCaseChar:
		case lowerCaseChar:
		case registerVal:
		case hexNum:
			typeName = tokenTypeAsString( _type );
			stringValue = [NSString stringWithFormat:@"%@:%@", typeName, stringValue];
			break;
			
		case openBracket:
		case closeBracket:
		case comma:
		case asterisk:
		case dollar:
		case percent:
		case colon:
			break;
		default:
			[NSException raise:@"Dont know what this tosken type is" format:@"%i", _type];
			break;
			
//TODO		-- must do question mark
	}
	return stringValue;
}

- (NSString *)patternString {

	NSString *typePattern = nil;
	
	switch( _type ){
		case decimalNum:
			typePattern = @"66";
			break;
			
		case upperCaseChar:
			typePattern = @"<error>";
			break;
			
		case lowerCaseChar:
			typePattern = @"<error>";
			break;
	
		case registerVal:
			typePattern = @"%r";
			break;
			
		case hexNum:
			typePattern = @"0xff";
			break;
			
		case openBracket:
			typePattern = @"(";
			break;
			
		case closeBracket:
			typePattern = @")";
			break;
			
		case comma:
			typePattern = @",";
			break;
			
		case asterisk:
			typePattern = @"*";
			break;
			
		case dollar:
			typePattern = @"$";
			break;
			
		case percent:
			typePattern = @"<error>";
			break;
			
		case colon:
			typePattern = @":";
			break;
			
//TODO:			-- do question mark

		default:
			[NSException raise:@"Dont know what this token type is" format:@"%i", _type];
			break;
	}
	return typePattern;
}

- (enum TokenType)type {
	return _type;
}

- (uint)length {
	return _tokenLength;
}

- (char *)value {
	return _value;
}

BOOL _eachValueIs_abcdef( char *value, uint length ) {
	
	for(uint i=0; i<length; i++){
		char val = value[i];
		if( (val>=0x61 && val<=0x66)==NO ) {
			return NO;
		}

	}
	return YES;
}

BOOL _eachValueIs_ABCDEF( char *value, uint length ) {

	for(uint i=0; i<length; i++){
		char val = value[i];
		if( (val>=0x41 && val<=0x46) == NO  ) {
			return NO;
		}
		
	}
	return YES;
}

- (BOOL)isValidHexNumComponent {
	
	if(_type==decimalNum)
		return YES;
	else if(_type==lowerCaseChar)
		return( _eachValueIs_abcdef(_value,_tokenLength));
	else if(_type==upperCaseChar)
		return( _eachValueIs_ABCDEF(_value,_tokenLength));
	return NO;
}

- (BOOL)isValidStartHexNumComponent {

	if( _type==lowerCaseChar && _value[0]=='x' ) {
		return( _eachValueIs_abcdef(_value+1,_tokenLength-1));
	}
	return NO;
}

- (NSUInteger)hexAsInt {

	if( _type==hexNum )
		return hexStringToInt( [NSString stringWithCString:_value encoding:NSUTF8StringEncoding] );

	[NSException raise:@"this shouldnt happen" format:@""];
	return 0;
}

@end
