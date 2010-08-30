//
//  YAMLParser.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 29/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "YAMLParser.h"
#import <yaml/yaml.h>
#import "CFDictCallbacks.h"


@interface YAMLParser ()

- (void)pushDict:(NSDictionary *)dict;
- (void)popDict;

- (void)endMapping:(yaml_event_t)e;	
- (void)newMapping:(yaml_event_t)e;
- (void)addScalar:(yaml_event_t)e;
			
@end

@implementation YAMLParser

@synthesize rootDictionary=_rootDict;

- (id)initWithFilePath:(NSString *)val {
	
	self = [super init];
	if(self){
		NSError *error;
		NSString *fileContents = [NSString stringWithContentsOfFile:val encoding:NSUTF8StringEncoding error:&error];
	
		/* Create the Parser object. */
		yaml_parser_t parser;
		yaml_parser_initialize(&parser);
		
		/* Set a string input. */
		const char *input = [fileContents UTF8String];
		size_t length = strlen(input);
		
		yaml_parser_set_input_string( &parser, (const unsigned char *)input, length );

		yaml_event_t event;
		
		CFDictionaryKeyCallBacks dkc = [CFDictCallbacks nonRetainingDictionaryKeyCallbacks];
		CFDictionaryValueCallBacks dvc = [CFDictCallbacks nonRetainingDictionaryValueCallbacks];
		_rootDict = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &dkc, &dvc );
		
		_dictStack = [[NSMutableArray alloc] init];
		[self pushDict:_rootDict];
		 
		/* Read the event sequence. */
		int done = 0;
		while (!done) {
			
			/* Get the next event. */
			if (!yaml_parser_parse(&parser, &event))
				goto error;
			
			/*
			 ...
			 Process the event.
			 ...
			 */
			NSString *hmm;
			
			switch ( event.type ) {
				case YAML_STREAM_START_EVENT:
					//				NSLog(@"start stream");
					break;
				case YAML_STREAM_END_EVENT:
					done = YES;
					//				NSLog(@"end stream");
					break;
				case YAML_DOCUMENT_START_EVENT:
					//				NSLog(@"document start");
					break;
				case YAML_DOCUMENT_END_EVENT:
					//				NSLog(@"document end");
					break;
				case YAML_MAPPING_START_EVENT:
					[self newMapping:event];
					break;
				case YAML_MAPPING_END_EVENT:
					[self endMapping:event];
					break;
				case YAML_SCALAR_EVENT:
					[self addScalar:event];
					break;
				case YAML_SEQUENCE_START_EVENT:
					//				NSLog(@"YAML_SEQUENCE_START_EVENT");
					break;
				case YAML_SEQUENCE_END_EVENT:
					//				NSLog(@"YAML_SEQUENCE_END_EVENT");
					break;
				case YAML_ALIAS_EVENT:
					//				NSLog(@"YAML_ALIAS_EVENT");
					hmm = [NSString stringWithCString:(char *)event.data.alias.anchor encoding:NSASCIIStringEncoding];
					//				NSLog(@"YAML_SCALAR_EVENT %@", hmm );
					break;
				default:
					[NSException raise:@"YAML ERROR" format:@""];
					break;
			}
			
			/* The application is responsible for destroying the event object. */
			yaml_event_delete(&event);
			
		}

	error:
		yaml_parser_delete(&parser);
		
	}
	return self;
}


- (void)dealloc {

	CFRelease(_rootDict);
	[_dictStack release];
	[_key release];
	[_value release];
	[super dealloc];
}

	
- (void)newMapping:(yaml_event_t)e {
	
	NSLog(@"New Map");

	_state = 0;
	if (_key) {
		NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithCapacity:3];
		[_currentDict setObject:newDict forKey:_key];
		
		[self pushDict:newDict];
		
		[_key release];
		_key = nil;
	}
}

- (void)endMapping:(yaml_event_t)e {
	
	NSLog(@"End Map");

	[self popDict];
	// NSAssert( _state==6, @"_state is fucked");
//	CFDictionaryAddValue( _opcodeLookup, [_opcodeDict objectForKey:@"instruction"], _opcodeDict );
}

// This looks horrible, but what i am doing is going to some lengths to ensure keys are shared instead of replicated many times in each opcode dictionary
- (void)addScalar:(yaml_event_t)e {
	
	BOOL oddOrEven = _state & 1;
	NSLog(@"Scalar: %s %i", e.data.scalar.value, oddOrEven);

	if(!oddOrEven) {
		[_key release];
		_key = [[NSString stringWithCString:(char *)e.data.scalar.value encoding:NSASCIIStringEncoding] retain];
	} else {
		[_value release];
		_value = [[NSString stringWithCString:(char *)e.data.scalar.value encoding:NSASCIIStringEncoding] retain];
		
		// we want to reuse keys
		[_currentDict setObject:_value forKey:_key];
	}
	
	_state++;
}

- (void)pushDict:(NSDictionary *)dict {

	[_dictStack addObject:dict];
	_currentDict = (NSMutableDictionary *)dict;
}

- (void)popDict {

	if([_dictStack count]) {
		[_dictStack removeLastObject];
		_currentDict = [_dictStack lastObject];
	}
}
@end
