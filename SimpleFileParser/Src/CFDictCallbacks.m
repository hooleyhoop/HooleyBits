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

#pragma mark VALUE setups
+ (CFDictionaryValueCallBacks)nonRetainingDictionaryValueCallbacks {
	
	CFDictionaryValueCallBacks nonRetainingDictionaryValueCallbacks = kCFTypeDictionaryValueCallBacks;
	nonRetainingDictionaryValueCallbacks.retain = myKeyRetainCallback;
	nonRetainingDictionaryValueCallbacks.release = myPoolRelease;
	return nonRetainingDictionaryValueCallbacks;
}




@end
