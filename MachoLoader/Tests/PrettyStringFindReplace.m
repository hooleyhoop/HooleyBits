//
//  PrettyStringFindReplace.m
//  MachoLoader
//
//  Created by Steven Hooley on 20/09/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#include "StringManipulation.h"



@interface PrettyStringFindReplace : SenTestCase {
	
}

@end


@implementation PrettyStringFindReplace


- (void)testItShouldParse1Arg {

	char *inStr = "stackPush( @1 )";
	char *arg1 = "cuckoo";
		
	char *newStr = replaceArgsInStr( inStr, arg1, NULL, NULL );
	int result = strcmp(newStr, "stackPush( cuckoo )");
	STAssertTrue( result==0, @"%i", result );
	
	free(newStr);
}

- (void)testItShouldParse2Args {
	
	char *inStr = "stackPush( @1 @2 )";
	char *arg1 = "cuckoo";
	char *arg2 = "poo";
	
	char *newStr = replaceArgsInStr( inStr, arg1, arg2, NULL );
	int result = strcmp(newStr, "stackPush( cuckoo poo )");
	STAssertTrue( result==0, @"%i", result );
	
	free(newStr);
}

- (void)testItShouldParse3Args {
	
	char *inStr = "stackPush( @1 @2 @3 )";
	char *arg1 = "cuckoo";
	char *arg2 = "poo";
	char *arg3 = "sapphire";

	char *newStr = replaceArgsInStr( inStr, arg1, arg2, arg3 );
	int result = strcmp(newStr, "stackPush( cuckoo poo sapphire )");
	STAssertTrue( result==0, @"%i", result );
	
	free(newStr);
}

- (void)testItShouldParse2UnorderedArgs {
	
	char *inStr = "@1 = @1 + @2";
	char *arg1 = "cuckoo";
	char *arg2 = "poo";
	
	char *newStr = replaceArgsInStr( inStr, arg1, arg2, NULL );
	int result = strcmp(newStr, "cuckoo = cuckoo + poo");
	STAssertTrue( result==0, @"%i", result );
	
	free(newStr);
}

- (void)testItShouldParse3UnorderedArgs {
	
	char *inStr = "shit @3 = @1 +(@3*@2)";
	char *arg1 = "cuckoo";
	char *arg2 = "poo";
	char *arg3 = "carrot";

	char *newStr = replaceArgsInStr( inStr, arg1, arg2, arg3 );
	int result = strcmp(newStr, "shit carrot = cuckoo +(carrot*poo)");
	STAssertTrue( result==0, @"%i", result );
	
	free(newStr);
}

- (void)testItBalksIfTooManyArgs {

	char *inStr = "@1@2";
	STAssertThrows( replaceArgsInStr( inStr, "cuckoo", "poo", "carrot" ), @"should be Too many args");
}

- (void)testItBalksIfTooFewArgs {
	
	char *inStr = "@1@2";
	STAssertThrows( replaceArgsInStr( inStr, "cuckoo", NULL, NULL ), @"should be Too many args");
}

@end
