//
//  InstructionLookup.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 12/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "InstructionLookup.h"
#import <yaml/yaml.h>


@implementation InstructionLookup

- (void)testParseYAML {
	
	NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"opcode" ofType:@"yaml"];
	
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
				NSLog(@"start stream");
				break;
				
			case YAML_STREAM_END_EVENT:
				done = YES;
				NSLog(@"end stream");
				break;
				
			case YAML_DOCUMENT_START_EVENT:
				NSLog(@"document start");
				break;
				
			case YAML_DOCUMENT_END_EVENT:
				NSLog(@"document end");
				break;
				
			case YAML_MAPPING_START_EVENT:
				NSLog(@"YAML_MAPPING_START_EVENT");
				break;
				
			case YAML_MAPPING_END_EVENT:
				NSLog(@"YAML_MAPPING_END_EVENT");
				break;
				
			case YAML_SCALAR_EVENT:
				hmm = [NSString stringWithCString:event.data.scalar.value];
				NSLog(@"YAML_SCALAR_EVENT %@", hmm );
				break;
				
			case YAML_SEQUENCE_START_EVENT:
				NSLog(@"YAML_SEQUENCE_START_EVENT");
				break;
				
			case YAML_SEQUENCE_END_EVENT:
				NSLog(@"YAML_SEQUENCE_END_EVENT");
				break;
				
			case YAML_ALIAS_EVENT:
				NSLog(@"YAML_ALIAS_EVENT");
				hmm = [NSString stringWithCString:event.data.alias.anchor];
				NSLog(@"YAML_SCALAR_EVENT %@", hmm );
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


@end
