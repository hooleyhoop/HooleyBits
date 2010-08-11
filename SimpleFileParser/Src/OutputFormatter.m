//
//  OutputFormatter.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 10/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "OutputFormatter.h"
#import "CodeBlock.h"
#import "CodeLine.h"
#import "FileWriter.h"
#import "CodeBlocksEnumerator.h"
#import "GenericTimer.h"

@interface OutputFormatter ()

@end

#pragma mark -
@implementation OutputFormatter


+ (id)outputFormatterWithCodeBlockStore:(CodeBlockStore *)internalRep fileName:(NSString *)fn owner:(id)hmm {
	
	return [[[self alloc] initWithCodeBlockStore:internalRep fileName:fn owner:hmm] autorelease];
}

- (id)initWithCodeBlockStore:(CodeBlockStore *)internalRep fileName:(NSString *)fn owner:(NSObject <iAmOutputFormatterCallback>*)hmm {
	
	self = [super init];
	if(self){
		_owner = hmm;
		_codeBlockEnumerator = [[CodeBlocksEnumerator alloc] initWithCodeBlockStore:internalRep];
		_filePath = [fn retain];
	}
	return self;
}

- (void)dealloc {

	NSAssert(_fileWriter==nil, @"still writing?");

	[_filePath release];
	[_codeBlockEnumerator release];
	[super dealloc];
}

- (void)print {

	_outputTimer = [[GenericTimer alloc] init];
	
	_fileWriter = [[FileWriter alloc] init];
	
	[_fileWriter asyncCreateOutputFile:_filePath];
	[_fileWriter setLineSrc:_codeBlockEnumerator selector:@selector(nextLine)];
	[_fileWriter whenFinishedTarget:self callback:@selector(_didFinish)];
}

- (void)_didFinish {
	
	[_fileWriter release];
	_fileWriter = nil;
	
	[_outputTimer close]; //187 secs, 52

	[_owner _outputFormatterDidFinish];
	
}

@end
