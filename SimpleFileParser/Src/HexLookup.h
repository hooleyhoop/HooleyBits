//
//  HexLookup.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
@class HexToken, MachoLoader;

/* 
 * Store one-off HexTokens that have been filled out with relevant info from a lookup in macho-loader
*/
@interface HexLookup : NSObject {

	@public
		CFMutableDictionaryRef	_filledOutHexTokens;
		MachoLoader				*_machLoader;
}

+ (void)prepareWith:(MachoLoader *)mach;
+ (HexLookup *)cachedHexLookup;

+ (HexToken *)tokenForHexString:(const char *)hexStr;
- (HexToken *)tokenForHexString:(const char *)hexStr;

@end
