//
//  CodeBlocksEnumerator.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 11/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "CodeBlocksEnumerator.h"
#import "CodeBlockStore.h"
#import "CodeBlock.h"
#import "CodeLine.h"

@implementation CodeBlocksEnumerator

- (id)initWithCodeBlockStore:(CodeBlockStore *)internalRep {

	self = [super init];
	if(self){
		_internalRep = [internalRep retain];

		_currentBlockIndex = 0;
		_currentLineIndex = -1;
	}
	return self;
}

- (void)dealloc {

	[_internalRep release];
	[super dealloc];
}

- (NSString *)nextLine {

	if(_currentBlockIndex>=[_internalRep blockCount])
		return nil;
	CodeBlock *block = [_internalRep blockAtIndex:_currentBlockIndex];
	NSAssert(block, @"should have a block at that index");

	NSString *lineString = nil;
	if( _currentLineIndex==-2 ) {
		lineString = @"\n";
		_currentLineIndex++;
	} else if( _currentLineIndex==-1 ) {
		lineString = [block prettyBlockTitle];
		_currentLineIndex++;
	} else {

		if(_currentLineIndex >= [block lineCount]) {
			_currentBlockIndex++;
			_currentLineIndex = -2;
			lineString = [self nextLine];
		} else {

			CodeLine *line = [block lineAtIndex:_currentLineIndex];
			NSAssert(line, @"should have a block at that index");
			lineString = [line prettyString];
			_currentLineIndex++;
		}

	}
	return lineString;
}


@end
