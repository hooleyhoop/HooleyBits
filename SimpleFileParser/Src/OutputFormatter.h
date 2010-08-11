//
//  OutputFormatter.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 10/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "iAmOutputFormatterCallback.h"

@class CodeBlocksEnumerator, CodeBlockStore, FileWriter, GenericTimer;

@interface OutputFormatter : NSObject {

	NSObject <iAmOutputFormatterCallback>	*_owner;
	NSString								*_filePath;
	CodeBlocksEnumerator					*_codeBlockEnumerator;
	
	FileWriter								*_fileWriter;
	GenericTimer							*_outputTimer;
}

+ (id)outputFormatterWithCodeBlockStore:(CodeBlockStore *)internalRep fileName:(NSString *)fn owner:(id)hmm;
- (id)initWithCodeBlockStore:(CodeBlockStore *)internalRep fileName:(NSString *)fn owner:(id)hmm;

- (void)print;

@end
