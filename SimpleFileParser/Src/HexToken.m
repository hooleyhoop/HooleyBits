//
//  HexToken.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "HexToken.h"
#import "HexConversions.h"
#import "SymbolicInfo.h"

@implementation HexToken

@synthesize originalValue=_originalValue;
@synthesize stringVal=_stringVal;
@synthesize intVal=_intVal;
@synthesize symbolicInfo=_symbolicInfo;

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

- (NSString *)outputString {
	
	NSString *out = nil;
	if(_symbolicInfo) {
		if (_symbolicInfo.stringValue) {
			out = [NSString stringWithFormat:@"%@:%@:%@", _symbolicInfo.segmentName, _symbolicInfo.sectionName, _symbolicInfo.stringValue];
		} else {
			out = [NSString stringWithFormat:@"%@:%@", _symbolicInfo.segmentName, _symbolicInfo.sectionName];
		}

	} else {
		out = _stringVal;
	}
	return out;
}

@end
