//
//  CodeLine.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 28/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
@class Instruction;

@interface CodeLine : NSObject {

	NSUInteger		_address;
	NSString		*_tempInstruction;
	Instruction		*_instruction;
}

+ (id)lineWithAddress:(NSUInteger)addrr;
+ (id)lineWithAddress:(NSUInteger)addrr instruction:(NSString *)temp;

- (id)initWithAddress:(NSUInteger)addrr;
- (id)initWithAddress:(NSUInteger)addrr instruction:(NSString *)temp;

- (NSComparisonResult)compareAddress:(CodeLine *)arg;
- (NSComparisonResult)compareAddressToAddress:(NSUInteger)addr;

- (NSUInteger)address;

- (NSString *)prettyString;

@end
