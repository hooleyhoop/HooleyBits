//
//  CFDictCallbacks.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "CFDictCallbacks.h"
#import "Hex.h"

@implementation CFDictCallbacks

// we neither retain or release items in the dictionary

#pragma mark Callbacks

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

const void *shIntKeyRetain( CFAllocatorRef allocator, const void *ptr ) {
	
	void *newKey = malloc(sizeof ptr);
	memcpy(newKey,ptr,sizeof ptr);
	return newKey;
}

void shIntKeyRelease( CFAllocatorRef allocator, const void *ptr ) {
	free((void *)ptr);
}

const void *myKeyRetainCallback( CFAllocatorRef allocator, const void *ptr ) {
    return ptr;
}

void myPoolRelease( CFAllocatorRef allocator, const void *ptr ) {
}

Boolean myKeyIsEqualCallBack( const void *value1,const void *value2 ) {
	return strcmp(value1, value2)==0;
}

#pragma mark KEY setups
CFHashCode myKeyHashCallBack( const void *value  ) {
	return hexCharHash((char *)value);
}

+ (CFDictionaryKeyCallBacks)nonRetainingDictionaryKeyCallbacks {

	CFDictionaryKeyCallBacks nonRetainingDictionaryKeyCallbacks = kCFTypeDictionaryKeyCallBacks;
	nonRetainingDictionaryKeyCallbacks.retain = myKeyRetainCallback;
	nonRetainingDictionaryKeyCallbacks.release = myPoolRelease;
	return nonRetainingDictionaryKeyCallbacks;
}

+ (CFDictionaryKeyCallBacks)cStringDictionaryKeyCallbacks {
	
	CFDictionaryKeyCallBacks cStringDictionaryKeyCallbacks = kCFTypeDictionaryKeyCallBacks;
	cStringDictionaryKeyCallbacks.retain = myKeyRetainCallback;
	cStringDictionaryKeyCallbacks.release = NULL;
	cStringDictionaryKeyCallbacks.copyDescription = NULL;
	cStringDictionaryKeyCallbacks.equal = myKeyIsEqualCallBack;
	cStringDictionaryKeyCallbacks.hash = myKeyHashCallBack;
	return cStringDictionaryKeyCallbacks;
}

+ (CFDictionaryKeyCallBacks)intKeyCallbacks {

	CFDictionaryKeyCallBacks KeyCallbacks = kCFTypeDictionaryKeyCallBacks;
	KeyCallbacks.retain = shIntKeyRetain;
	KeyCallbacks.release = shIntKeyRelease;
	KeyCallbacks.copyDescription = NULL;
	KeyCallbacks.equal = shIntKeyEqual;
	KeyCallbacks.hash = shIntKeyHash;
	return KeyCallbacks;
}

#pragma mark VALUE setups
+ (CFDictionaryValueCallBacks)nonRetainingDictionaryValueCallbacks {
	
	CFDictionaryValueCallBacks nonRetainingDictionaryValueCallbacks = kCFTypeDictionaryValueCallBacks;
	nonRetainingDictionaryValueCallbacks.retain = myKeyRetainCallback;
	nonRetainingDictionaryValueCallbacks.release = myPoolRelease;
	return nonRetainingDictionaryValueCallbacks;
}

+ (CFDictionaryValueCallBacks)intValCallbacks {
	
	CFDictionaryValueCallBacks valCallbacks = kCFTypeDictionaryValueCallBacks;
	valCallbacks.retain = shIntKeyRetain;
	valCallbacks.release = shIntKeyRelease;
	valCallbacks.copyDescription = NULL;
	valCallbacks.equal = shIntKeyEqual;
	return valCallbacks;
}


@end
