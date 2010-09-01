//
//  OtoolDisassemblyParser.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 04/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "iParseSrc.h"

@class CodeBlockStore, CodeBlockFactory, InstructionHash;

@interface OtoolDisassemblyParser : NSObject <iParseSrc> {

	NSString			*_title;
	NSMutableArray		*_blockLines;

	CodeBlockStore		*_codeBlockStore;
	CodeBlockFactory	*_codeBlockfactory;

	InstructionHash		*_instructionHash;

	dispatch_group_t	_lineTokenisizing_group;
}

@property (retain) CodeBlockStore *codeBlockStore;

+ (CodeBlockStore *)constructInternalRepresentation:(NSString *)fileString :(InstructionHash *)instHash;
+ (id)OtoolDisassemblyParserWithSrcString:(NSString *)fileString :(InstructionHash *)instHash;

- (id)initWithSrcString:(NSString *)fileString :(InstructionHash *)instHash;

@end
