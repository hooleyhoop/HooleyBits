//
//  InstructionLookup.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 12/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "InstructionLookup.h"
#import "CFDictCallbacks.h"
#import <yaml/yaml.h>


@implementation InstructionLookup

static CFMutableDictionaryRef _opcodeLookup;
static NSMutableDictionary *_opcodeDict;
static NSUInteger _state;
static NSString *_key, *_value;

+ (void)newMapping:(yaml_event_t)e {
	
	// we never want to release this
	_opcodeDict = [[NSMutableDictionary dictionaryWithCapacity:3] retain];
	_state = 0;
}

+ (void)endMapping:(yaml_event_t)e {

	// NSAssert( _state==6, @"_state is fucked");
	CFDictionaryAddValue( _opcodeLookup, [_opcodeDict objectForKey:@"instruction"], _opcodeDict );
}

// This looks horrible, but what i am doing is going to some lengths to ensure keys are shared instead of replicated many times in each opcode dictionary
+ (void)addScalar:(yaml_event_t)e {

	BOOL oddOrEven = _state & 1;
	// TODO: will leak the last value and key
	if(!oddOrEven) {
		[_key release];
		_key = [[NSString stringWithCString:(char *)e.data.scalar.value encoding:NSASCIIStringEncoding] retain];
	} else {
		[_value release];
		_value = [[NSString stringWithCString:(char *)e.data.scalar.value encoding:NSASCIIStringEncoding] retain];
	}

	switch(_state) {
		case 0:
			NSAssert( [_key isEqualToString:@"instruction"], @"der" );
			break;
		case 1:
			[_opcodeDict setObject:_value forKey:@"instruction"];
			break;
		case 2:
			NSAssert( [_key isEqualToString:@"name"], @"der" );
			break;
		case 3:
			[_opcodeDict setObject:_value forKey:@"name"];
			break;
		case 4:
			NSAssert( [_key isEqualToString:@"description"], @"der"  );
			break;
		case 5:
			[_opcodeDict setObject:_value forKey:@"description"];
			break;
		case 6:
			NSAssert( [_key isEqualToString:@"format"], @"der"  );
			break;
		case 7:
			[_opcodeDict setObject:_value forKey:@"format"];
			break;
			
		default:
			[NSException raise:@"Unknown state" format:@"%i", _state];
			break;
	}
	_state++;

	NSString *hmm = [NSString stringWithCString:(char *)e.data.scalar.value encoding:NSASCIIStringEncoding];
//	NSLog(@"YAML_SCALAR_EVENT %@", hmm );
}


+ (void)testParseYAML {

	CFDictionaryKeyCallBacks dkc = [CFDictCallbacks nonRetainingDictionaryKeyCallbacks];
	CFDictionaryValueCallBacks dvc = [CFDictCallbacks nonRetainingDictionaryValueCallbacks];
	_opcodeLookup = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &dkc, &dvc );

	NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"opcode" ofType:@"yaml"];
	NSAssert( filePath, @"Error loading opcode file" );
	
	NSError *error;
	NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
	
	yaml_parser_t parser;
	yaml_event_t event;
	
	int done = 0;
	
	/* Create the Parser object. */
	yaml_parser_initialize(&parser);
	
	/* Set a string input. */
	const char *input = [fileContents UTF8String];
	size_t length = strlen(input);
	
	yaml_parser_set_input_string( &parser, (const unsigned char *)input, length );
	
	/* Read the event sequence. */
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
	
	/* Destroy the Parser object. */
	yaml_parser_delete(&parser);
	
	//	return 1;
	
	/* On error. */
error:
	
	/* Destroy the Parser object. */
	yaml_parser_delete(&parser);
	
	//	return 0;
}

+ (NSDictionary *)infoForInstructionString:(NSString *)instruction {

	NSDictionary *result = (NSDictionary *)CFDictionaryGetValue( _opcodeLookup, instruction );
	if(!result)
		[NSException raise:@"Unknown Opcode" format:@"Error: Cant find %@ in opcode lookup", instruction];
	return result;
}

@end
