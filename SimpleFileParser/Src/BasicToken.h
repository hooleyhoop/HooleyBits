//
//  BasicToken.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 13/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "TokenArray.h"	

#define MAX_TOKEN_LENGTH 16

@interface BasicToken : NSObject {

	@public
	enum TokenType _type;
	uint _tokenLength;
	char _value[MAX_TOKEN_LENGTH];
}

+ (id)tokenWithType:(enum TokenType)arg1 value:(char)arg2;
+ (id)tokenWithType:(enum TokenType)arg1 value:(char *)arg2 length:(NSUInteger)l;

- (id)initWithType:(enum TokenType)arg1 value:(char)arg2;
- (id)initWithType:(enum TokenType)arg1 value:(char *)arg2 length:(NSUInteger)l;

- (void)append:(char)value;
- (void)append:(char *)value length:(uint)l;

- (NSString *)outputString;
- (NSString *)patternString;

- (enum TokenType)type;
- (uint)length;
- (char *)value;

- (BOOL)isValidHexNumComponent;
- (BOOL)isValidStartHexNumComponent;
- (NSUInteger)hexAsInt;

@end
