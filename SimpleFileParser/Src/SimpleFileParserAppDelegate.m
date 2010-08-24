//
//  SimpleFileParserAppDelegate.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 09/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "SimpleFileParserAppDelegate.h"
#import "AppDisassembly.h"
#import "InstructionLookup.h"
#import "MachoLoader.h"
#import "HexLookup.h"

@implementation SimpleFileParserAppDelegate

@synthesize window = _window;
@synthesize machLoader = _ml;

// registers
// %eip = next instruction address

// http://programminggroundup.blogspot.com/2007/01/appendix-b-common-x86-instructions.html
// http://siyobik.info/index.php?module=x86

+ (NSArray *)_disabled_knownInstructions {
	
	static NSArray *knownInstructions;
	if(knownInstructions == nil)
		knownInstructions = [[NSArray arrayWithObjects:

							
nil] retain];
	return knownInstructions;
}

/* Useful Dyld enviro variables */
// DYLD_PRINT_BINDINGS 
// DYLD_NO_PIE
// DYLD_PRINT_SEGMENTS
// DYLD_PRINT_LIBRARIES

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	// strip the app to desired architectire
	// ditto --rsrc --arch i386 /Applications/Foo.app /Application/Foo-i386.app

	[[NSApp mainMenu] addItem:[[[NSClassFromString(@"FScriptMenuItem") alloc] init] autorelease]];

	[InstructionLookup testParseYAML];
	 
	NSString *pathToApp = @"/Applications/6-386.app/Contents/MacOS/6-386";
	_ml = [[MachoLoader alloc] initWithPath:pathToApp];
	
	[HexLookup prepareWith:_ml];

	NSError *outError;
	NSString *pathToInputFile = [@"~/Desktop/testData_tiny.txt" stringByExpandingTildeInPath];
	NSURL *absoluteURL = [NSURL fileURLWithPath:pathToInputFile isDirectory:NO];
	NSString *fileString = [NSString stringWithContentsOfURL:absoluteURL encoding:NSMacOSRomanStringEncoding error:&outError];
	
	_dissasembled = [[AppDisassembly alloc] initWithOtoolOutput:fileString];
	[_dissasembled goOnDoYourWorst:_ml];
	
	// This is asyncronous. Need to rethink some stuff
	[_dissasembled outputToFile:[@"~/Desktop/undisassembled.txt" stringByExpandingTildeInPath]];


//err! where has it gone?	_unknownArguments = [[NSMutableSet setWithCapacity:100] retain];
	
//err! where has it gone?	_allOpCodeFormats = [[[StringCounter alloc] init] autorelease];
//err! where has it gone?	_allArgumentFormats = [[[StringCounter alloc] init] autorelease];
	

	
	// otool
	// otool -t /Applications/Foo.app/Contents/MacOS/Foo >> data.txt			-- just data
	// otool -t -v -V /Applications/Foo.app/Contents/MacOS/Foo >> data.txt		-- decompiled
	// otool -t -v -V /Applications/Foo.app/Contents/MacOS/Foo >> data.txt		-- decompiled with symbols
	

	

	 


	// -- read it a line at a time. -- try niave aproach
//	int reverseSort = NO;
	
//	NSArray *allUnknownArguments = [_unknownArguments allObjects];
//	allUnknownArguments = [allUnknownArguments sortedArrayUsingFunction:alphabeticSort context:&reverseSort];
//	NSLog(@"%@", allUnknownArguments);
	
//err! where has it gone?	NSArray *allUnknownInstructions = [_unknownInstructions allObjects];
//err! where has it gone?	allUnknownInstructions = [allUnknownInstructions sortedArrayUsingFunction:alphabeticSort context:&reverseSort];
//err! where has it gone?	if([allUnknownInstructions count])
//err! where has it gone?		NSLog(@"WARNING! UNKNOWN %@", allUnknownInstructions);

	
	// sort using a selector
//	NSArray *allInstructSets = [_allInstructions allValues];
//	for( NSSet *eachSet in allInstructSets ){
//		NSArray *allInstruct = [eachSet allObjects];
//		allInstruct = [allInstruct sortedArrayUsingFunction:alphabeticSort context:&reverseSort];
	//	NSLog(@"woo %@", allInstruct );
//	}
	
//err! where has it gone?	[_allArgumentFormats sort];
//err! where has it gone?	NSArray *allPatternCounts = [_allArgumentFormats sortedCounts];
//err! where has it gone?	NSArray *allPatternStrings = [_allArgumentFormats sortedStrings];

//	NSAssert([allPatternCounts count]==[allPatternStrings count], @"nah %i, %i", [allPatternCounts count],[allPatternStrings count] );
	
//err! where has it gone?	for( NSUInteger i=0; i<[allPatternStrings count]; i++ ) {
//err! where has it gone?		NSLog(@"%@", [allPatternStrings objectAtIndex:i] );
//err! where has it gone?	}
	
//	NSString *mostFrequentFormat;
//	uint occurance=0, maxOccurance = 0;

//	NSArray *allKeys = [_allArgumentFormats allKeys];
//	for( NSString *each in allKeys ){
//		occurance = [[_allArgumentFormats objectForKey:each] intValue];
//		if(occurance>maxOccurance){
//			maxOccurance = occurance;
//			mostFrequentFormat = each;
//		}
//	}
	
	// Best explanation of Registers http://www.delorie.com/djgpp/doc/ug/asm/about-386.html

//	NSLog(@"Most frequent format is %@ - %i", mostFrequentFormat, maxOccurance );


		
	
//	Most frequent format is: movl 0xff ( %r ) , %r - 67263   -----  movl 0x10(%ebp),%ebx -- ebx = *(ebp+0x10) --    base = *(StackFrame_BasePointer+0x10)

	// -- sort by operator
	
	// -- output
}


// read the arguments
// substitute movl for op2 = op1
// process the arguments into the instruction string




@end
