//
//  HexToken.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@interface HexToken : NSObject {

}

+ (HexToken *)hexTokenWithCString:(const char *)hexStr;

@end
