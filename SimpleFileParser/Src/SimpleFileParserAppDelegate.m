woah! In the 32bit abi every function has this signiture

pushl		  %ebp				Pushes the value of the stack frame pointer (EBP) onto the stack.
movl		  %esp,%ebp		Sets the stack frame pointer to the value of the stack pointer (ESP)
pushl		  %edi				Pushes the values of the registers that must be preserved (EDI, ESI, and EBX) onto the stack.
pushl		  %esi
pushl		  %ebx
subl		  $0x3c,%esp		Allocates space in the stack frame for local storage.

... 

addl		  $0x3c,%esp		Deallocates the space used for local storage in the stack.
popl		  %ebx				Restores the preserved registers (EDI, ESI, EBX, EBP) by popping the values saved on the stack by the prolog
popl		  %esi
popl		  %edi
leave		
ret								Returns


try a system call and see if it uses calll - NO, it uses callq

execve(path, args, NSPlatform_environ());

look at instructions folling calll for returned results eax


this is useful
http://www.powerbasic.com/support/help/pbcc/addressing_and_pointers.htm

Basically
…you have put the address of a variable into the EAX register.  When you take the next step and put that address into a variable of its own, you will have a POINTER to the address:

LEA EAX, MyVar
MOV lpMyVar, EAX

> lpMyVar = &MyVar		// lea followed by mov is getting an address


take a look at what this disassembler can do
http://www.hex-rays.com/compare.shtml



//
//  SimpleFileParserAppDelegate.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 09/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "SimpleFileParserAppDelegate.h"
#import "AppDisassembly.h"
#import "RegisterLookup.h"
#import "InstructionLookup.h"
#import "MachoLoader.h"
#import "HexLookup.h"
#import "GenericTimer.h"
#import "InstructionHash.h"

@implementation SimpleFileParserAppDelegate

@synthesize window = _window;
@synthesize machLoader = _ml;

//http://programminggroundup.blogspot.com/2007/01/appendix-c-important-system-calls.html
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

	// list architectures in app
	// lipo -info /Applications/Foo.app
	// file /Applications/Foo.app

	// strip the app to desired architectire
	// lipo remove ppc /Applications/Foo.app -output /Applications/Foo.app_thin
	// ditto --rsrc --arch i386 /Applications/Foo.app /Application/Foo-i386.app

	[[NSApp mainMenu] addItem:[[[NSClassFromString(@"FScriptMenuItem") alloc] init] autorelease]];
	
	InstructionLookup *instructionLookup = [[InstructionLookup alloc] init];
	RegisterLookup *registerLookup = [[RegisterLookup alloc] init];
	
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
		[instructionLookup parseYAML];
	}];
	//you can add more blocks
	[operation addExecutionBlock:^{
		[registerLookup parseYAML];
	}];
	[queue addOperation:operation];

	NSString *pathToApp = @"/Applications/6-386.app/Contents/MacOS/6-386";
	_ml = [[MachoLoader alloc] initWithPath:pathToApp];
	[_ml readFile];
	[HexLookup prepareWith:_ml];
	
	[queue waitUntilAllOperationsAreFinished];
	[queue release];
		
	// Read the output of otool
	NSError *outError;
	NSString *pathToInputFile = [@"~/Desktop/testData_huge.txt" stringByExpandingTildeInPath];
	NSURL *absoluteURL = [NSURL fileURLWithPath:pathToInputFile isDirectory:NO];
	NSString *fileString = [NSString stringWithContentsOfURL:absoluteURL encoding:NSMacOSRomanStringEncoding error:&outError];

	_dissasembled = [[AppDisassembly alloc] initWithOtoolOutput:fileString 
															   :[InstructionHash cachedInstructionHashWithLookup:instructionLookup]
															   :_ml];

	[_dissasembled ripIt];
	
//	GenericTimer *readTimer = [[[GenericTimer alloc] init] autorelease];
//	[readTimer close]; // 19 seconds just to iterate over each line (no processing)
	

	NSLog(@"done");

//	[_dissasembled reformat];

	// This is asyncronous. Need to rethink some stuff
//	[_dissasembled outputToFile:[@"~/Desktop/undisassembled.txt" stringByExpandingTildeInPath]];


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
