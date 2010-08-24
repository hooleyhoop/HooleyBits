//
//  HexToken.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
@class SymbolicInfo;

@interface HexToken : NSObject {

	@public
		char			*_originalValue;
		NSString		*_stringVal;
		NSUInteger		_intVal;
	
		SymbolicInfo	*_symbolicInfo;
}

@property (readonly) char *originalValue;
@property (readonly) NSString *stringVal;
@property (readonly) NSUInteger intVal;
@property (retain) SymbolicInfo *symbolicInfo;

+ (HexToken *)hexTokenWithCString:(const char *)hexStr;

@end
