//
//  AppDisassembly.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 04/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class CodeBlockFactory, DissasemblerGroker, CodeBlockStore;

@interface AppDisassembly : NSObject {

	CodeBlockFactory	*_codeBlockfactory;
	DissasemblerGroker	*_groker;
	CodeBlockStore		*_codeBlockStore;
	
}

+ (id)createFromOtoolOutput:(NSString *)fileString;

- (id)initWithOtoolOutput:(NSString *)fileString;

@end
