//
//  BNZHex.m
//  BNZHex
//
// Created by Trevor Johns
/*
 Copyright (c) 2006, Big Nerd Ranch, Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of Big Nerd Ranch, Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#import "Hex.h"

@implementation NSData (BNZHex)

+ (NSData *) dataWithHexString: (NSString *)hexString
{	
	// Hex Lookup Table
	unsigned char HEX_LOOKUP[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 
		6, 7, 8, 9, 0, 0, 0, 0, 0, 0, 0, 10, 11, 12, 13, 14, 15, 0, 0, 
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		0, 0, 0, 10, 11, 12, 13, 14, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	
	// If we have an odd number of characters, add an extra digit, rounding the
	// size of the NSData up to the nearest byte
	if ([hexString length] % 2 == 1)  {
		hexString = [NSString stringWithFormat:@"0%@", hexString]; 
	}
	
	// Iterate through the string, adding each character (equivilent to 1/2 
	// byte) to the NSData result
	NSUInteger i;
	char current;
	const NSUInteger size = [hexString length] / 2;
	const char * stringBuffer = [hexString cStringUsingEncoding:NSASCIIStringEncoding];
	NSMutableData* result = [NSMutableData dataWithLength:size];
	char * resultBuffer = [result mutableBytes];
	for (i = 0; i < size; i++) {
		// Get first character, use as high order bits
		current = stringBuffer[i * 2];
		resultBuffer[i] = HEX_LOOKUP[(int)current] << 4;
		
		// Get second character, use as low order bits
		current = stringBuffer[(i * 2) + 1];
		resultBuffer[i] = resultBuffer[i] | HEX_LOOKUP[(int)current];
	}
	
	return [NSData dataWithData:result];
}

- (NSData *) initWithHexString: (NSString *)hexString
{
	return [self initWithData:[NSData dataWithHexString:hexString]];	
}

- (NSString *)hexString {

	const char *data = [self bytes];
	NSMutableString *result;
	NSString *immutableResult;

	// Iterate through NSData's buffer, converting every byte into hex
	// and appending the result to a string.
	result = [[NSMutableString alloc] init];
	for( NSUInteger i=0; i<[self length]; i++) {
		[result appendFormat:@"%02x", data[i] & 0xff];
	}

	immutableResult = [NSString stringWithString:result];
	[result release];
	return immutableResult;
}

NSUInteger hexCharHash(const char *str) {
	
	NSUInteger hash = 5381;
	int c;
	
	while(c=*str++)
		hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
	return hash;
}

@end