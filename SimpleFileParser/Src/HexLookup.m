//
//  HexLookup.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "HexLookup.h"
#import "HexValueHash.h"
#import "HexToken.h"
#import "CFDictCallbacks.h"
#import "MachoLoader.h"

@implementation HexLookup

+ (void)prepareWith:(MachoLoader *)mach {
	
	HexLookup *cached = [self cachedHexLookup];
	cached->_machLoader = mach;
}

+ (HexLookup *)cachedHexLookup {
	
	static HexLookup *_cached;
	if(_cached==nil)
		_cached = [[HexLookup alloc] init];
	return _cached;
}

+ (HexToken *)tokenForHexString:(const char *)hexStr {
	return [[self cachedHexLookup] tokenForHexString:hexStr];
}

- (id)init {
	
	self = [super init];
	if(self){
		CFDictionaryKeyCallBacks dkc = [CFDictCallbacks cStringDictionaryKeyCallbacks];
		_filledOutHexTokens = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &dkc, &kCFTypeDictionaryValueCallBacks );
	}
	return self;
}

- (void)dealloc {
	
	CFRelease(_filledOutHexTokens);
	[super dealloc];
}

// perform the lokup in the mach-o file for a hex string
- (HexToken *)tokenForHexString:(const char *)hexStr {

	HexToken *result = (HexToken *)CFDictionaryGetValue( _filledOutHexTokens, hexStr );
	if(!result){
		// make a new one
		result = [HexValueHash valueForHexString:hexStr];
		NSUInteger decValue = result->_intVal;
		if(decValue>=4096)
		{
			// Fill in the info gleaned from mach-o lookup
			SymbolicInfo *symInfo = [_machLoader symbolicInfoForAddress:decValue];
			if(symInfo)
				[result setSymbolicInfo:symInfo];
		}
		// cache the value
		CFDictionaryAddValue( _filledOutHexTokens, result->_originalValue, result );
	} 
//	else {
//		NSLog(@"Found duplicated Hex balue %@",result->_stringVal );
//	}
	NSAssert(result, @"garamouch3");
	return result;
}



@end
