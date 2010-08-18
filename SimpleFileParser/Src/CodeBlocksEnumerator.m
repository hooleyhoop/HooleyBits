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
#import "Argument.h"

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
			
			/* very primitive filtering */
			BOOL passesFilter = NO;
			NSArray *args = line.arguments;
			if (args && [args count]) {
				// one argument can contain more than one Hex number 0xff ( %r , %r , 66 )
				for( Argument *each in args ) {
					if([each containsHexNum]){
						NSUInteger decValue = [each hexAsInt];
						if(decValue>4096)
						{
							id ob1 = [NSApplication sharedApplication];
							id ob2 = [ob1 delegate];
							id ob3 = [ob2 machLoader];
							NSString *segment = [ob3 segmentForAddress:decValue];
							NSLog(segment);
						}
						passesFilter = YES;
					}
				}
			}
			_currentLineIndex++;
			/* end very primitive filtering */
			if(passesFilter)
				lineString = [line prettyString];
			else
				lineString = [self nextLine];
		}

	}
	return lineString;
}


@end
