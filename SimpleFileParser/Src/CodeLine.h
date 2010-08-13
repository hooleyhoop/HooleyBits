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
	Instruction		*_instruction;
	
	NSString		*_tempInstruction;
	NSString		*_tempArgs;
}

+ (id)lineWithAddress:(NSUInteger)addrr;
+ (id)lineWithAddress:(NSUInteger)addrr instruction:(NSString *)temp;
+ (id)lineWithAddress:(NSUInteger)addrr instruction:(NSString *)temp1 args:(NSString *)temp2;

- (id)initWithAddress:(NSUInteger)addrr;
- (id)initWithAddress:(NSUInteger)addrr instruction:(NSString *)temp;
- (id)initWithAddress:(NSUInteger)addrr instruction:(NSString *)temp1 args:(NSString *)temp2;

- (NSComparisonResult)compareAddress:(CodeLine *)arg;
- (NSComparisonResult)compareAddressToAddress:(NSUInteger)addr;

- (NSUInteger)address;

- (NSString *)prettyString;

@end
