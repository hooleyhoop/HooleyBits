//
//  OtoolDisassemblyParser.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 04/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "OtoolDisassemblyParser.h"
#import "CodeBlockFactory.h"
#import "CodeBlockStore.h"
#import "SourceLineCategorizer.h"
#import "LinesInStringIterator.h"
#import "StringCounter.h"
#import "CodeLine.h"
#import "HexConversions.h"
#import "TokenArray.h"
#import "ArgumentScanner.h"
#import "InstructionHash.h"
#import "Instruction.h"
#import "StringCounter.h"
#import "BasicToken.h"
#import "HexToken.h"
#import "HexValueHash.h"
#import "HexLookup.h"
#import "Argument.h"

@interface OtoolDisassemblyParser ()

- (CodeLine *)_tokeniseLine:(NSString *)aLine;
@end

#pragma mark -
@implementation OtoolDisassemblyParser

@synthesize codeBlockStore = _codeBlockStore;

+ (CodeBlockStore *)constructInternalRepresentation:(NSString *)fileString {

	OtoolDisassemblyParser *parser = [self OtoolDisassemblyParserWithSrcString:fileString];
	return parser.codeBlockStore;
}

+ (id)OtoolDisassemblyParserWithSrcString:(NSString *)fileString {
	
	return [[[self alloc] initWithSrcString:fileString] autorelease];
}

- (id)initWithSrcString:(NSString *)fileString {

	self = [super init];
	if(self) {
		
//		_instructionHash = [instHash retain];
		
		_codeBlockStore = [[CodeBlockStore store] retain];
		_codeBlockfactory = [[CodeBlockFactory factoryWithStore:_codeBlockStore] retain];

		SourceLineCategorizer *groker = [SourceLineCategorizer grokerWithDelegate:self];
		[LinesInStringIterator feedLines:fileString to:groker];
	}
	return self;
}

- (void)dealloc {

	[_codeBlockStore release];
	[_codeBlockfactory release];
	[_instructionHash release];

	[super dealloc];
}


- (void)constructLine:(NSString *)lineText {
	
//	CodeLine *line = [self _tokeniseLine:lineText];
//	[_codeBlockfactory addCodeLine:line];
}

- (void)processSrcLine:(NSString *)lineText type:(enum srcLineType)lineType {

	switch (lineType) {
		case BLOCK_TITLE:
			[_codeBlockfactory newCodeBlockWithName:lineText];
			break;
		case BLOCK_LINE:
			[self constructLine:lineText];
			break;
			
		default:
			[NSException raise:@"Unknown Src Line type" format:@"%i", lineType];
			break;
	}	
}

// -- exactly how much should we do here?
- (CodeLine *)_tokeniseLine:(NSString *)aLine {
		
//putback	NSArray *components = worderize( aLine );

	// not optional
	// NSString *lineOffset = [components objectAtIndex:0];
//putback	NSString *address = [components objectAtIndex:1];
	// NSString *code = [components objectAtIndex:2];
//putback	NSString *opcode = [components objectAtIndex:3];

	// Instructions are cached - ie you should always get the same Instruction back for the same opcode
//putback	Instruction *instr = [_instructionHash instructionForOpcode:opcode];
	
//putback	NSString *arguments=nil, *functionHint=nil;
//putback	NSArray *allArgs = nil;

	// optional
//putback	if([components count]>=5)
//putback	{
//putback		arguments = [components objectAtIndex:4];
//putback		TokenArray *tkns1 = [TokenArray tokensWithString:arguments];
//putback		[tkns1 secondPass];
//putback		ArgumentScanner *scanner = [ArgumentScanner scannerWithTokens:tkns1];
		
//putback		allArgs = [scanner.allArguments copy];
//putback		NSAssert([allArgs count]<=3, @"we should formalise this - there is never more than 2 - we dont need an array");
//putback	}
//putback	if([components count]>=6)
//putback		functionHint = [components objectAtIndex:5];

//putback	NSUInteger addressInt = hexStringToInt(address);
//putback	CodeLine *newLine = [CodeLine lineWithAddress:addressInt instruction:instr args:allArgs];
//putback	return newLine;
	return nil;
}



@end

