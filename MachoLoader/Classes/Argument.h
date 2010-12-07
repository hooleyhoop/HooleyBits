//
//  Argument.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 14/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class BasicToken;

@interface Argument : NSObject {

	NSMutableArray *_allTokens;
}

@property (readonly) NSMutableArray *allTokens;

+ (id)emptyArgument;

- (void)addToken:(BasicToken *)tok;
- (void)replaceToken:(BasicToken *)oldTok with:(BasicToken *)newTok;

- (NSString *)output;
- (NSString *)pattern;

@end
