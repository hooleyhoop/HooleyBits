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

- (void)addInt:(NSInteger)intVal forIntKey:(NSInteger)intKey {
	CFDictionaryAddValue( _intLookup, &intKey, &intVal );
}

-  (NSInteger)intForIntKey:(NSInteger)intKey {

	NSInteger result = INT32_MAX;
	NSInteger *resultPtr = (NSInteger *)CFDictionaryGetValue( _intLookup, (const void *)&intKey );
	if(resultPtr!=NULL)
		result = *resultPtr;
	return result;	
}


@end
