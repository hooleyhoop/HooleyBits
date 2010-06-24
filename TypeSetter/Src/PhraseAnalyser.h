//
//  PhraseAnalyser.h
//  TypeSetter
//
//  Created by Steven Hooley on 24/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//



@interface PhraseAnalyser : NSObject {

	NSString	*_string;
	NSArray		*_words;
}

+ (id)analyserWithString:(NSString *)srcString;
- (NSUInteger)phraseCount;

- (NSUInteger)wordCount;
- (NSArray *)words;

- (NSArray *)phrases;

@end
