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

@interface OtoolDisassemblyParser ()

- (void)_tokeniseLine:(NSString *)aLine;
@end

#pragma mark -
@implementation OtoolDisassemblyParser

@synthesize codeBlockStore = _codeBlockStore;

+ (id)constructInternalRepresentation:(NSString *)fileString {

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

- (void)processSrcLine:(NSString *)lineText type:(enum srcLineType)lineType {

	switch (lineType) {
		case BLOCK_TITLE:
			[_codeBlockfactory newCodeBlockWithName:lineText];
			break;
		case BLOCK_LINE:
			[self _tokeniseLine:lineText];
			[_codeBlockfactory addCodeLine:lineText];
			break;
			
		default:
			[NSException raise:@"Unknown Src Line type" format:@"%i", lineType];
			break;
	}	
}

// TODO: -- here
- (void)_tokeniseLine:(NSString *)aLine {
	
	NSString *instruction=nil, *arguments=nil, *functionHint=nil;
	
	NSArray *components = worderize( aLine );
	
	// not optional
	id lineOffset = [components objectAtIndex:0];
	id address = [components objectAtIndex:1];
	id code = [components objectAtIndex:2];
	instruction = [components objectAtIndex:3];
	
	// optional
	if([components count]>=5)
		arguments = [components objectAtIndex:4];
	if([components count]>=6)
		functionHint = [components objectAtIndex:5];
	
	if(instruction){
		BOOL isKnown = [self isKnownInstruction:instruction];
		if(!isKnown){
			[_unknownInstructions addObject:instruction];
			return;
		}
		// eh ? What is this shit?		[self processInstruction:instruction argument:arguments];
	}
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

