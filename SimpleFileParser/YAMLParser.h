//
//  YAMLParser.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 29/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//



@interface YAMLParser : NSObject {

	CFMutableDictionaryRef	_rootDict;
	NSUInteger					_state;
	NSString					*_key, *_value;
	
	NSMutableArray			*_dictStack;
	NSMutableDictionary		*_currentDict;
}

@property CFMutableDictionaryRef rootDictionary;

- (id)initWithFilePath:(NSString *)val;

@end
