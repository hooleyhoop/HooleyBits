//
//  HexConversions.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 13/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "HexConversions.h"


@implementation HexConversions

NSUInteger hexStringToInt( NSString *hexString ) {

	unsigned char HEX_LOOKUP[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 
		6, 7, 8, 9, 0, 0, 0, 0, 0, 0, 0, 10, 11, 12, 13, 14, 15, 0, 0, 
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		0, 0, 0, 10, 11, 12, 13, 14, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	
	if ([hexString length] % 2 == 1)  {
		hexString = [NSString stringWithFormat:@"0%@", hexString]; 
	}
	NSUInteger size = [hexString length] / 2;
	const char * stringBuffer = [hexString cStringUsingEncoding:NSASCIIStringEncoding];
	char current;
	NSUInteger result=0;
	for( NSUInteger i=0; i<size; i++) {
		current = stringBuffer[i * 2];
		NSUInteger highBits = HEX_LOOKUP[(int)current] << 4;
		current = stringBuffer[(i * 2) + 1];
		NSUInteger lowBits = HEX_LOOKUP[(int)current];
		result = result<<8 | highBits | lowBits;
	}
	return result;
}

@end
