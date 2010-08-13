//
//  ArgumentScanner.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 14/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class TokenArray, Argument;

@interface ArgumentScanner : NSObject {

	NSMutableArray *allArguments;
	
}

+ (id)scannerWithTokens:(TokenArray *)tks;

- (id)initWithTokens:(TokenArray *)tks;

- (NSUInteger)count;

- (Argument *)argumentAtIndex:(NSUInteger)index;

- (NSString *)temp_toString;

@end
