//
//  IntHash.h
//  MachoLoader
//
//  Created by Steven Hooley on 04/09/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//



@interface IntHash : NSObject {
	CFMutableDictionaryRef _intLookup;
}

- (void)addInt:(int64_t)intVal forIntKey:(int64_t)intKey;

-  (int64_t)intForIntKey:(int64_t)intKey;

@end
