//
//  CodeBlocksEnumerator.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 11/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class CodeBlockStore;

@interface CodeBlocksEnumerator : NSObject {

	CodeBlockStore	*_internalRep;
	NSUInteger		_currentBlockIndex;
	NSInteger		_currentLineIndex;
}

- (id)initWithCodeBlockStore:(CodeBlockStore *)internalRep;
- (NSString *)nextLine;

@end
