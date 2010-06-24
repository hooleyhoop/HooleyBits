//
//  PhraseAnalyser.m
//  TypeSetter
//
//  Created by Steven Hooley on 24/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "PhraseAnalyser.h"

#pragma mark -
NSArray *worderize( NSString *aLine ) {
	
	NSArray *components = [aLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSMutableArray *betterComponents = [NSMutableArray array];
	[components enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
		if([obj isEqualToString:@""])
			return;
		[betterComponents addObject:obj];
	}];
	return betterComponents;
}

#pragma mark -
@implementation PhraseAnalyser

+ (id)analyserWithString:(NSString *)srcString {

	return [[[self alloc] initWithString:srcString] autorelease];
}

- (id)initWithString:(NSString *)srcString {

	self = [super init];
	if(self){
		_string = [srcString copy];
		_words = [worderize(_string) retain];
	}
	return self;
}

- (void)dealloc {

	[_string release];
	[_words release];
	[super dealloc];
}

- (NSArray *)phrases {
	
	NSMutableArray *phrases = [NSMutableArray arrayWithCapacity:[self phraseCount]];
	
	for( NSUInteger i=0; i<[_words count]; i++ ) {
		NSString *rootWord = [_words objectAtIndex:i];
		[phrases addObject:rootWord];
		
		for(NSUInteger j=i+1; j<[_words count]; j++ ) {
			NSString *nextWord = [_words objectAtIndex:j];
			rootWord = [NSString stringWithFormat:@"%@ %@", rootWord, nextWord];
			[phrases addObject:rootWord];
		}
	}
	NSAssert( [self phraseCount]==[phrases count], @"oh yeah fucked up somewhere" );
	return phrases;
}

- (NSUInteger)phraseCount {

	NSUInteger limit = [self wordCount];
	NSUInteger result = 0;
	for(NSUInteger i=1; i<=limit; i++){
		result +=i;
	}
	return result;
}

- (NSArray *)words {
	return _words;
}

- (NSUInteger)wordCount {
  	return [_words count];
}

@end
