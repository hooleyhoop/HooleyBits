//
//  IntKeyDictionary.m
//  MachoLoader
//
//  Created by Steven Hooley on 25/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "IntKeyDictionary.h"
#import "CFDictCallbacks.h"

@implementation IntKeyDictionary


- (id)init {

	self = [super init];
	if(self){
		
		CFDictionaryKeyCallBacks KeyCallbacks = [CFDictCallbacks intKeyCallbacks];
		CFDictionaryValueCallBacks valueCallbacks = kCFTypeDictionaryValueCallBacks;
		
		_symbolLookup = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &KeyCallbacks, &valueCallbacks );
	}
	return self;
}

- (void)dealloc {

	CFRelease(_symbolLookup);
	[super dealloc];
}

- (void)addObject:(NSObject *)ob1 forIntKey:(uint64)key {
	CFDictionaryAddValue( _symbolLookup, &key, ob1 );
}

- (NSObject *)objectForIntKey:(uint64)key {
	return (NSObject *)CFDictionaryGetValue( _symbolLookup, (const void *)&key );
}

@end
