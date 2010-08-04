//
//  OtoolDisassemblyParser.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 04/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class CodeBlockStore, CodeBlockFactory;

@interface OtoolDisassemblyParser : NSObject {

	CodeBlockStore		*_codeBlockStore;
	CodeBlockFactory	*_codeBlockfactory;
	
	NSMutableSet		*_unknownInstructions;	
}

@property (retain) CodeBlockStore *codeBlockStore;

+ (id)constructInternalRepresentation:(NSString *)fileString;
+ (id)OtoolDisassemblyParserWithSrcString:(NSString *)fileString;

- (id)initWithSrcString:(NSString *)fileString;

@end
