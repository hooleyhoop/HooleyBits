//
//  HexValueHash.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class HexToken;

/*
 * Store one-off HexTokens that we can lookup with a cString
*/
@interface HexValueHash : NSObject {

	CFMutableDictionaryRef _hexLookup;
}

+ (HexToken *)valueForHexString:(const char *)hexStr;
- (HexToken *)valueForHexString:(const char *)hexStr;

@end
