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

- (void)addInt:(NSInteger)intVal forIntKey:(NSInteger)intKey;

-  (NSInteger)intForIntKey:(NSInteger)intKey;

@end
