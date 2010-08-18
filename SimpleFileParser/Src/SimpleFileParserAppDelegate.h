//
//  SimpleFileParserAppDelegate.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 09/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

// Playing with this http://developer.apple.com/mac/library/documentation/DeveloperTools/Reference/Assembler/060-i386_Addressing_Modes_and_Assembler_Instructions/i386_intructions.html#//apple_ref/doc/uid/TP30000825-TPXREF101

@class StringCounter, AppDisassembly, MachoLoader;

@interface SimpleFileParserAppDelegate : NSObject <NSApplicationDelegate> {

    NSWindow			*_window;

	NSMutableSet		*_unknownArguments;

	StringCounter		*_allInstructions;
	StringCounter		*_allOpCodeFormats;
	StringCounter		*_allArgumentFormats;

	AppDisassembly		*_dissasembled;
	MachoLoader			*_ml; 
}

@property (assign) IBOutlet NSWindow *window;
@property (readonly) MachoLoader *machLoader;

@end
