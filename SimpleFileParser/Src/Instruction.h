//
//  Instruction.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 15/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


@interface Instruction : NSObject {

	NSDictionary	*_values; // weak reference to global dictionary
}

+ (id)instructionWithDict:(NSDictionary *)instrInfo;
- (id)initWithDict:(NSDictionary *)instrInfo;

- (NSString *)name;
- (NSString *)instruction;

- (NSString *)printWithArgs:(NSArray *)args;

@end
