/*
 *  StringManipulation.c
 *  MachoLoader
 *
 *  Created by Steven Hooley on 20/09/2010.
 *  Copyright 2010 Tinsal Parks. All rights reserved.
 *
 */
#import "StringManipulation.h"

char *replaceArgsInStr( char *inStr, char *arg1, char *arg2, char *arg3 ) {
	
	NSCParameterAssert(inStr);
	NSCParameterAssert(arg1);
	
	NSUInteger inStrLen = strlen(inStr)+1;
	NSUInteger arg1Len = strlen(arg1);
	
	NSUInteger arg2Len = 0;
	NSUInteger arg3Len = 0;
	NSUInteger numberOfArgs = 1;
	
	if(arg3){
		arg3Len = strlen(arg3);
		arg2Len = strlen(arg2);		
		numberOfArgs = 3;
	} else if(arg2) {
		arg2Len = strlen(arg2);
		numberOfArgs = 2;		
	}
	
	NSUInteger lengthOfSearchToken = 2;
	
	// Although we can only have 3 args, each arg could appear any number of times, eg x = x + x + x
	// This means we can only calculate new string length via a pre-pass. Shit
	NSUInteger foundArg = 0;
	NSUInteger lengthOfInsertedArgStrings = 0;
	BOOL foundArg1=NO, foundArg2=NO, foundArg3=NO;
	for(NSUInteger i=0;i<inStrLen;i++) {
		char chari = inStr[i];
		if (chari=='@') {
			foundArg++;
			i++;
			char charNum = inStr[i];
			NSUInteger argNum = charNum - '0';

			switch (argNum) {
				case 1:
					lengthOfInsertedArgStrings = lengthOfInsertedArgStrings + arg1Len;
					foundArg1 = YES;
					break;
				case 2:
					lengthOfInsertedArgStrings = lengthOfInsertedArgStrings + arg2Len;
					foundArg2 = YES;
					break;
				case 3:
					lengthOfInsertedArgStrings = lengthOfInsertedArgStrings + arg3Len;
					foundArg3 = YES;
					break;					
				default:
					[NSException raise:@"Uknown arg index for replacement" format:nil];					
					break;
			}
		}
	}
	// sanity checks
	switch (numberOfArgs) {
		case 1:
			if( foundArg1==NO || foundArg2==YES || foundArg3==YES ) {
				[NSException raise:@"Fucked up the number of args or something" format:nil];					
			}
			break;
		case 2:
			if( foundArg1==NO || foundArg2==NO || foundArg3==YES ) {
				[NSException raise:@"Fucked up the number of args or something" format:nil];					
			}
			break;
		case 3:
			if( foundArg1==NO || foundArg2==NO || foundArg3==NO ) {
				[NSException raise:@"Fucked up the number of args or something" format:nil];					
			}
			break;			
		default:
			[NSException raise:@"Uknown arg index for replacement" format:nil];								
			break;
	}
	
	NSUInteger newStringLen = inStrLen + lengthOfInsertedArgStrings - (lengthOfSearchToken*numberOfArgs);
	char *newStr = calloc(1,newStringLen);
	
	NSUInteger indexOfToken = 0;
	NSUInteger currentDst = (NSUInteger)newStr;
	NSUInteger currentSrc = (NSUInteger)inStr;
	NSUInteger tokensFound = 0;
	
	while( indexOfToken<inStrLen ) {
		
		char *p = strchr((char const *)currentSrc,'@');
		if (p==NULL) {
			indexOfToken = inStrLen;
			// copy the tail
			NSUInteger endOffset = inStrLen - (currentSrc-(NSUInteger)inStr);
			strncpy( (void *)currentDst, (void *)currentSrc, endOffset );
			
		} else {
			tokensFound++;
			indexOfToken = (NSUInteger)p-(NSUInteger)currentSrc;
			
			// which arg goes here? Get the number following the @
			char argNumChar1 = ((char *)currentSrc)[indexOfToken+1];
			int argNum1 = argNumChar1 - '0';
			
			//copy the bit before the @
			strncpy( (void *)currentDst, (void *)currentSrc, indexOfToken );
			currentSrc = currentSrc + indexOfToken+lengthOfSearchToken;
			currentDst = currentDst+indexOfToken;
			
			//add in the replacement
			switch (argNum1) {
				case 1:
					strncpy( (void *)currentDst, arg1, arg1Len );
					currentDst = currentDst+arg1Len;
					break;
				case 2:
					strncpy( (void *)currentDst, arg2, arg2Len );
					currentDst = currentDst+arg2Len;
					break;
				case 3:
					strncpy( (void *)currentDst, arg3, arg3Len );
					currentDst = currentDst+arg3Len;
					break;					
				default:
					// [NSException raise:@"Uknown arg index for replacement" format:@"%i", argNum];
					NSLog(@"something got mangled? %i", argNum1);
					break;
			}
		}
		
	}
	NSCAssert( newStr[newStringLen-1]=='\0', @"Output String not null terminated?" );
	
	return newStr;
}
