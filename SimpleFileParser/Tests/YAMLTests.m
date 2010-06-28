//
//  YAMLTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 28/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


#import <yaml/yaml.h>


@interface YAMLTests : SenTestCase {
	
}

@end


@implementation YAMLTests

extern int yaml_parser_initialize(yaml_parser_t *parser);

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
		
		/* Are we finished? */
		done = (event.type == YAML_STREAM_END_EVENT);
		
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
