//
//  AppDisassembly.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 04/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "iAmOutputFormatterCallback.h"

@class CodeBlockStore, OutputFormatter, MachoLoader, InstructionHash, OtoolDisassemblyParser, MachoLoader;

@interface AppDisassembly : NSObject <iAmOutputFormatterCallback> {

	NSString				*_fileString;
	OtoolDisassemblyParser	*_disassembleParser;
	MachoLoader				*_ml;
	CodeBlockStore			*_internalRepresentation;
	
	// wish this wasn't here - wrong level
	OutputFormatter			*_of;
}

// + (id)createFromOtoolOutput:(NSString *)fileString :(InstructionHash *)instHash;

- (id)initWithOtoolOutput:(NSString *)fileString :(InstructionHash *)instHash :(MachoLoader *)ml;

- (void)ripIt;
- (void)gleanInfo:(MachoLoader *)lookup;
- (void)reformat;

- (void)outputToFile:(NSString *)fileName;

@end
