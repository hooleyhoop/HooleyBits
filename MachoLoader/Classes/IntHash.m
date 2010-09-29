//
//  IntHash.m
//  MachoLoader
//
//  Created by Steven Hooley on 04/09/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "IntHash.h"
#import "CFDictCallbacks.h"

@implementation IntHash


- (id)init {
	
	self = [super init];
	if(self){
		
		CFDictionaryKeyCallBacks KeyCallbacks = [CFDictCallbacks intKeyCallbacks];
		CFDictionaryValueCallBacks valueCallbacks = [CFDictCallbacks intValCallbacks];
		
		_intLookup = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &KeyCallbacks, &valueCallbacks );
	}
	return self;
}

- (void)dealloc {
	
	CFRelease(_intLookup);
	[super dealloc];
}

- (void)addInt:(int64_t)intVal forIntKey:(int64_t)intKey {

	CFDictionaryAddValue( _intLookup, &intKey, &intVal );
}

-  (int64_t)intForIntKey:(int64_t)intKey {

	int64_t result = INT32_MAX;
	int64_t *resultPtr = (int64_t *)CFDictionaryGetValue( _intLookup, (const void *)&intKey );
	if(resultPtr!=NULL)
		result = *resultPtr;
	return result;	
}


@end
