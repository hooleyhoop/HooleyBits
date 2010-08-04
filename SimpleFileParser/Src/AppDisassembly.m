//
//  AppDisassembly.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 04/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "AppDisassembly.h"

#import "CodeBlockFactory.h"
#import "CodeBlockStore.h"
#import "DissasemblerGroker.h"
#import "LinesInStringIterator.h"

@implementation AppDisassembly

+ (id)createFromOtoolOutput:(NSString *)fileString {

	id processedFile = [[[self alloc] initWithOtoolOutput:fileString] autorelease];
	return processedFile;
}

- (id)initWithOtoolOutput:(NSString *)fileString {
	
	self = [super init];
	if(self){
		
		_codeBlockStore = [[CodeBlockStore alloc] init];
		_codeBlockfactory = [[CodeBlockFactory alloc] init];
		[_codeBlockfactory setStore:_codeBlockStore];
		_groker = [[DissasemblerGroker alloc] init];
		
		[_groker setDelegate:_codeBlockfactory];
		
		
		// feed lines to DissasemblerGroker
		LinesInStringIterator *lineIterator = [LinesInStringIterator iteratorWithString:fileString];
		[lineIterator setConsumer:_groker];
		[lineIterator doIt];
	}
	return self;
}

- (void)dealloc {

	[super dealloc];
}

@end
