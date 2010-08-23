//
//  AppDisassembly.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 04/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "iAmOutputFormatterCallback.h"

@class CodeBlockStore, OutputFormatter, MachoLoader;

@interface AppDisassembly : NSObject <iAmOutputFormatterCallback> {

	CodeBlockStore		*_internalRepresentation;
	
	// wish this wasn't here - wrong level
	OutputFormatter		*_of;
}

+ (id)createFromOtoolOutput:(NSString *)fileString;

- (id)initWithOtoolOutput:(NSString *)fileString;

- (void)goOnDoYourWorst:(MachoLoader *)lookup;

- (void)outputToFile:(NSString *)fileName;

@end
