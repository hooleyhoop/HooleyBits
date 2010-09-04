//
//  CFDictCallbacks.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


@interface CFDictCallbacks : NSObject {

}

+ (CFDictionaryKeyCallBacks)nonRetainingDictionaryKeyCallbacks;
+ (CFDictionaryKeyCallBacks)cStringDictionaryKeyCallbacks;
+ (CFDictionaryKeyCallBacks)intKeyCallbacks;

+ (CFDictionaryValueCallBacks)nonRetainingDictionaryValueCallbacks;
+ (CFDictionaryValueCallBacks)intValCallbacks;

@end
