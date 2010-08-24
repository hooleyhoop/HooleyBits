//
//  HexValueHash.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "HexValueHash.h"
#import "HexToken.h"

@implementation HexValueHash

const void *myKeyRetainCallback( CFAllocatorRef allocator, const void *ptr ) {
    return ptr;
}
Boolean myKeyIsEqualCallBack( const void *value1,const void *value2 ) {
	return strcmp(value1, value2)==0;
}
CFHashCode myKeyHashCallBack( const void *value  ) {
	
	NSUInteger keyHash = *((NSUInteger *)value);
	const char *compareHashPtr = "value";
	NSUInteger compareHash = *((NSUInteger *)compareHashPtr);
	return keyHash;
}

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
		CFDictionaryKeyCallBacks nonRetainingDictionaryKeyCallbacks = kCFTypeDictionaryKeyCallBacks;
		nonRetainingDictionaryKeyCallbacks.retain = myKeyRetainCallback;
		nonRetainingDictionaryKeyCallbacks.release = NULL;
		nonRetainingDictionaryKeyCallbacks.copyDescription = NULL;
		nonRetainingDictionaryKeyCallbacks.equal = myKeyIsEqualCallBack;
		nonRetainingDictionaryKeyCallbacks.hash = NULL;
		
		CFDictionaryValueCallBacks nonRetainingDictionaryValueCallbacks = kCFTypeDictionaryValueCallBacks;
		_hexLookup = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &nonRetainingDictionaryKeyCallbacks, &nonRetainingDictionaryValueCallbacks );
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
		CFDictionaryAddValue( _hexLookup, hexStr, result );
	}
	NSAssert(result, @"grudddnch");
	return result;
}

@end
