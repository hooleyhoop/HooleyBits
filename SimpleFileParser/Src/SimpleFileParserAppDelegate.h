//
//  SimpleFileParserAppDelegate.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 09/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

// Playing with this http://developer.apple.com/mac/library/documentation/DeveloperTools/Reference/Assembler/060-i386_Addressing_Modes_and_Assembler_Instructions/i386_intructions.html#//apple_ref/doc/uid/TP30000825-TPXREF101

@interface SimpleFileParserAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	
	NSMutableSet *_unknownInstructions;
	NSMutableSet *_unknownArguments;

	NSMutableDictionary *_allInstructions;
}

@property (assign) IBOutlet NSWindow *window;

@end
