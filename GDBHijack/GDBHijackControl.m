//
//  GDBHijackControl.m
//  GDBHijack
//
//  Created by steve hooley on 29/01/2008.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "GDBHijackControl.h"

@implementation GDBHijackControl

+ (void)load {
	NSLog(@"loading GDBHack %@", NSStringFromClass([self class]) ); 
}

+ (void)initialize {
	NSLog(@"initialize GDBHack");
	[GDBHijackControl installFScriptMenu];
}

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		
		/* watch for project changes */
	//	PBXProject currentProj = [[NSApplication sharedApplication] currentProject]
//		PBXProjectDocument currDoc = [[NSApplication sharedApplication] currentProjectDocument]
//		BOOL isDebugging = [currDoc isDebugging];
//		BOOL isRunning = [currDoc isRunning];
//		
//		NSArray* orderedSourceDocuments = [[[NSApplication sharedApplication] orderedSourceDocuments];
//		
//		-- look for one that is PBXDisassemblyFileDocument AND isInProject: 
//		
//		search window for PBXExtendedOutlineView, (registers view) this has a dataSource that is PBXDebugStackFrameViewModule
//		
//		search window for PBXExtendedTableView, (Thread view) this has a dataSource that is PBXDebugThreadViewModule
//		
//		both have sessionModule - PBXDebugSessionModule - 6fe8dc0
//		
//		
//		--- PBXDebugThreadViewModule ---
//		- (PBXLSThread *)thread
//		
//		--- PBXDebugStackFrameViewModule ---
//		- (PBXLSStackFrame *)stackFrame
//		
//		--- PBXLSStackFrame ---
//		- (NSString *)disassemblyFrameName
//		- (NSString *)disassemblyFunctionName
//		
//		--- PBXLSThread ---
//		- (NSString *)displayName		"Thread-1"
//		- (NSString *)displayName		"Suspended after step"
//
//
//		--- PBXDebugSessionModule ---
//		- (PBXDebugCLIModule *)consoleModule
//		- (BOOL)debugTaskNextInstructionIsValid
//		- (void)debugTaskNextInstruction
//		- (BOOL)debugTaskStepInstructionIsValid
//		- (void)debugTaskStepInstruction
//		- (BOOL)isDebugging
//		- (XCGlobalVariableBrowserModule *)globalVariableModule
//		- (XCMemoryBrowserModule *)memoryBrowserModule
//		- (PBXDebugProcessViewModule *)processViewModule
//
//
//		--- PBXDebugCLIModule ---
//		- (void)setInputText:(NSString *)value
//		- (PBXTtyText *)ttyTExtView
//		reset
//		- (PBXTSCharacterStream *)characterStreamFromTTY -- Use this to send commands!
//		
//		--- PBXTtyText ---
//		x setInputText:
//		x PBX_insertNewlineAndIndentWithEnter:YES	// execute the input
//		inputTExtRange
//		lastLineTextRange
//		rangeBeforeLastLineText
    }
    return self;
}

+(void)installFScriptMenu {

	NSLog(@"installFScriptMenu");

    if (!NSClassFromString(@"FScriptMenuItem"))	
	{
		NSLog(@"FSCript not loaded");

		NSString* fscriptPath = @"/Library/Frameworks/FScript.framework";
		BOOL loadFScript = NO;
		// Check for the existence of the FScript framework:
		if ([[NSFileManager defaultManager] fileExistsAtPath:fscriptPath])
			loadFScript = YES;
		else {
			fscriptPath = [@"~/Library/Frameworks/FScript.framework" stringByExpandingTildeInPath];
			if ([[NSFileManager defaultManager] fileExistsAtPath:fscriptPath])
				loadFScript = YES;
		}
		if (loadFScript) {
			[[NSBundle bundleWithPath:fscriptPath] load];
		} else
			NSLog(@"Couldn't find FScript");	
	}
	NSLog(@"FSCript already loaded loaded");

	[[NSApp mainMenu] addItem:[[[NSClassFromString(@"FScriptMenuItem") alloc] init] autorelease]];

}


@end
