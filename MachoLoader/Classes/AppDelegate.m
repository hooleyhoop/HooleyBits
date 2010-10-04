//
//  AppDelegate.m
//  MachoLoader
//
//  Created by steve hooley on 03/04/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "MachoLoader.h"
#import "DisassemblyChecker.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

//	NSString *pathToApp = [[NSBundle mainBundle] executablePath];
NSString *pathToApp = @"/Applications/6-386.app/Contents/MacOS/6-386";
//	NSString *pathToApp = @"/Applications/iTunes.app/Contents/MacOS/iTunes_thin";
//	NSString *pathToApp = @"/Applications/Adobe Lightroom 3.app/Contents/MacOS/Adobe Lightroomx86_64";
//	NSString *pathToApp = @"/Library/Frameworks/Houdini.framework/Versions/11.0.469/Houdini";
	
//	NSString *pathToOtoolOutput = @"/Applications/6-386.app/Contents/MacOS/6-386";
	
//	DisassemblyChecker *dc = [[DisassemblyChecker alloc] initWithPath:pathToOtoolOutput];
	MachoLoader *ml = [[MachoLoader alloc] initWithPath:pathToApp checker:nil];
	
	[ml readFile];

	[ml release];
//	NSString *section = [ml sectionForMemAddress:0];

}

@end
