//
//  HexToken.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@interface HexToken : NSObject {

	@public
		char		*_originalValue;
		NSString	*_stringVal;
		NSUInteger	_intVal;
}

+ (HexToken *)hexTokenWithCString:(const char *)hexStr;

- (const char *)originalValue;

- (NSUInteger)intVal;

@end
