//
//  HexValueHash.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "HexValueHash.h"
#import "HexToken.h"
#import "CFDictCallbacks.h"

@implementation HexValueHash

+ (HexValueHash *)cachedHexValueHash {
	
	static HexValueHash *_cached;
	if(_cached==nil)
		_cached = [[HexValueHash alloc] init];
	return _cached;
}

+ (HexToken *)valueForHexString:(const char *)hexStr {

	return [[self cachedHexValueHash] valueForHexString:hexStr];
}

- (id)init {
	
	self = [super init];
	if(self){
		CFDictionaryKeyCallBacks cStringKeyCallbacks = [CFDictCallbacks cStringDictionaryKeyCallbacks];
		_hexLookup = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &cStringKeyCallbacks, &kCFTypeDictionaryValueCallBacks );
	}
	return self;
}

- (void)dealloc {

	CFRelease(_hexLookup);
	[super dealloc];
}

- (HexToken *)valueForHexString:(const char *)hexStr {

	HexToken *result = (HexToken *)CFDictionaryGetValue( _hexLookup, hexStr );
	if( result==nil ) {
		result = [HexToken hexTokenWithCString:hexStr];
		CFDictionaryAddValue( _hexLookup, result->_originalValue, result );
	}
	NSAssert(result, @"grudddnch");
	return result;
}

@end
