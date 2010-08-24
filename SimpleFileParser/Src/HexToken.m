//
//  HexToken.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "HexToken.h"
#import "HexConversions.h"


@implementation HexToken

+ (HexToken *)hexTokenWithCString:(const char *)hexStr {
	return [[[self alloc] initWithCString:hexStr] autorelease];
}

- (id)initWithCString:(const char *)hexStr {

	self = [super init];
	if(self){
		_originalValue = malloc(sizeof hexStr);
		strcpy(_originalValue, hexStr);
		
		_stringVal = [[NSString stringWithCString:_originalValue encoding:NSUTF8StringEncoding] retain];
		_intVal = hexStringToInt( _stringVal );
	}
	return self;
}

- (void)dealloc {
	free(_originalValue);
	[_stringVal release];
	[super dealloc];
}

- (const char *)originalValue {
	return _originalValue;
}

- (NSUInteger)intVal {
	return _intVal;
}

@end
