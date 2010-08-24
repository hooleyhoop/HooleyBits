//
//  HexValueHash.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class HexToken;

@interface HexValueHash : NSObject {

	CFMutableDictionaryRef _hexLookup;
}

+ (HexToken *)valueForHexString:(const char *)hexStr;
- (HexToken *)valueForHexString:(const char *)hexStr;

@end
