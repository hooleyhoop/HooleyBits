//
//  OtoolDisassemblyParser.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 04/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "iParseSrc.h"

@class CodeBlockStore, CodeBlockFactory, StringCounter;

@interface OtoolDisassemblyParser : NSObject <iParseSrc> {

	CodeBlockStore		*_codeBlockStore;
	CodeBlockFactory	*_codeBlockfactory;
	
	StringCounter		*_stringCounter;	
}

@property (retain) CodeBlockStore *codeBlockStore;

+ (CodeBlockStore *)constructInternalRepresentation:(NSString *)fileString;
+ (id)OtoolDisassemblyParserWithSrcString:(NSString *)fileString;

- (id)initWithSrcString:(NSString *)fileString;

@end
