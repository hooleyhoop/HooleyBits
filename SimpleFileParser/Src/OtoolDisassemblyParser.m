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
#import "InstructionLookup.h"
#import "Instruction.h"

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
		_codeBlockStore = [[CodeBlockStore store] retain];
		_codeBlockfactory = [[CodeBlockFactory factoryWithStore:_codeBlockStore] retain];

		_unknownInstructions = [[NSMutableSet setWithCapacity:100] retain];

		SourceLineCategorizer *groker = [SourceLineCategorizer grokerWithDelegate:self];
		[LinesInStringIterator feedLines:fileString to:groker];
	}
	return self;
}

- (void)dealloc {

	[_codeBlockStore release];
	[_codeBlockfactory release];
	
	[_unknownInstructions release];

	[super dealloc];
}


- (void)constructLine:(NSString *)lineText {
	
	CodeLine *line = [self _tokeniseLine:lineText];
	[_codeBlockfactory addCodeLine:line];
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


- (CodeLine *)_tokeniseLine:(NSString *)aLine {
		
	NSArray *components = worderize( aLine );

	// not optional
	NSString *lineOffset = [components objectAtIndex:0];
	NSString *address = [components objectAtIndex:1];
	NSString *code = [components objectAtIndex:2];
	NSString *instruction = [components objectAtIndex:3];

	NSDictionary *instrInfo = [InstructionLookup infoForInstructionString: instruction];
	Instruction *instr = [Instruction instructionWithDict:instrInfo];
	
	NSString *arguments=nil, *functionHint=nil;
	NSString *tempArgString=nil;

	// optional
	if([components count]>=5) {
		arguments = [components objectAtIndex:4];
		TokenArray *tkns1 = [TokenArray tokensWithString:arguments];
		[tkns1 secondPass];
		ArgumentScanner *scanner = [ArgumentScanner scannerWithTokens:tkns1];
		tempArgString = [scanner temp_toString];
	}
	if([components count]>=6)
		functionHint = [components objectAtIndex:5];

	NSUInteger addressInt = hexStringToInt(address);
	CodeLine *newLine = [CodeLine lineWithAddress:addressInt instruction:instr args:tempArgString];
	return newLine;
	

	
//hmm	if(instruction){
//hmm		BOOL isKnown = [self isKnownInstruction:instruction];
//hmm		if(!isKnown){
//hmm			[_unknownInstructions addObject:instruction];
//hmm			return;
//hmm		}
		// eh ? What is this shit?		[self processInstruction:instruction argument:arguments];
//hmm	}
}


// TODO: Replace knownInstructions with yaml stuff
- (BOOL)isKnownInstruction:(NSString *)instruction {
	
	//Replace With yaml	NSArray *knownInstructions = [DissasemblerGroker knownInstructions];
	//Replace with yaml	BOOL isFound = [knownInstructions containsObject:instruction];
	
	
	//	if(!isFound){
	//		NSLog(@"oopps %i", [knownInstructions indexOfObjectIdenticalTo:instruction]);
	//	}
	return YES;
}

@end

