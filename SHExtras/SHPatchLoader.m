//
//  SHPatchLoader.m
//  QuartzAudio
//
//  Created by Jonathan del Strother on 01/02/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import "SHPatchLoader.h"
#import "SHNotificationCentre.h"

/*
 *
*/
@implementation SHPatchLoader


+ (void)initialize
{
//	[Notifier poseAsClass:[NSNotificationCenter class]];		handy, but causes the inspector panel to crash if it's open on startup.
}
	
+ (void)registerNodesWithManager:(id)manager
{
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	if(![thisBundle isLoaded])
		[thisBundle load];

	NSArray* allPatches = [NSArray arrayWithObjects:	@"SHGlobalVar", 
														@"SHPhotoshopImport", 
														@"SHUTubePatch", 
														@"SHExecutionModeTest",
														@"BBInterpolationPatch", 
														@"SHHeadlineText", 
														@"BBQTStreamPlayer", 
														@"BBQTSSPlayer",
	//													@"BBFScriptPatch",
														nil];
														
	NSEnumerator *enumerator1 = [allPatches objectEnumerator];
	id aClassName;
	while ((aClassName = [enumerator1 nextObject])) 
	{
		Class thisClass = [thisBundle classNamed: aClassName];

		if(thisClass)
			[manager registerNodeWithClass:thisClass];
	}
		
	
	/* Install fscript menu */
	if (!NSClassFromString(@"FScriptMenuItem"))	{ // Check that it's not already loaded
		NSString* fscriptPath = @"/Library/Frameworks/FScript.framework";
		BOOL loadFScript = NO;
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
		[[NSApp mainMenu] addItem:[[[NSClassFromString(@"FScriptMenuItem") alloc] init] autorelease]];

}
	
@end