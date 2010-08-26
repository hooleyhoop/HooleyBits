//
//  IntKeyDictionary.m
//  MachoLoader
//
//  Created by Steven Hooley on 25/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "IntKeyDictionary.h"


@implementation IntKeyDictionary

const void *shIntKeyRetain( CFAllocatorRef allocator, const void *ptr ) {
	
	void *newKey = malloc(sizeof ptr);
	memcpy(newKey,ptr,sizeof ptr);
    return newKey;
}

void shIntKeyRelease( CFAllocatorRef allocator, const void *ptr ) {
	free((void *)ptr);
}

Boolean shIntKeyEqual( const void *value1,const void *value2 ) {
	
	int *val1Ptr = (int *)value1;
	int val1 = *val1Ptr;
	
	int *val2Ptr = (int *)value2;
	int val2 = *val2Ptr;
	
	return val1==val2;
}

CFHashCode shIntKeyHash( const void *value  ) {
	
	int *hashPtr = (int *)value;
	int hash = *hashPtr;
	return (CFHashCode)hash;
}

- (id)init {

	self = [super init];
	if(self){
		
		CFDictionaryKeyCallBacks KeyCallbacks = kCFTypeDictionaryKeyCallBacks;
		KeyCallbacks.retain = shIntKeyRetain;
		KeyCallbacks.release = shIntKeyRelease;
		KeyCallbacks.copyDescription = NULL;
		KeyCallbacks.equal = shIntKeyEqual;
		KeyCallbacks.hash = shIntKeyHash;
		
		CFDictionaryValueCallBacks valueCallbacks = kCFTypeDictionaryValueCallBacks;
		
		_symbolLookup = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &KeyCallbacks, &valueCallbacks );
	}
	return self;
}

- (void)dealloc {

	CFRelease(_symbolLookup);
	[super dealloc];
}

- (void)addObject:(NSObject *)ob1 forIntKey:(NSUInteger)key {
	CFDictionaryAddValue( _symbolLookup, &key, ob1 );
}

- (NSObject *)objectForIntKey:(NSUInteger)key {
	return (NSObject *)CFDictionaryGetValue( _symbolLookup, (const void *)&key );
}

@end
