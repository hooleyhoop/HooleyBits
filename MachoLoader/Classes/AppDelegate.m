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

	NSArray *paths = [NSArray arrayWithObjects:
					  [[NSBundle mainBundle] executablePath],
					  @"/Applications/6-386.app/Contents/MacOS/6-386",
					  @"/Applications/iTunes.app/Contents/MacOS/iTunes_thin",
					  @"/Applications/Adobe Lightroom 3.app/Contents/MacOS/Adobe Lightroomx86_64",
					  @"/Applications/Adobe After Effects CS5/Adobe After Effects CS5.app/Contents/MacOS/After Effects",
					  @"/Library/Frameworks/Houdini.framework/Versions/11.0.469/Houdini",
					  nil];

	for( NSString *each in paths ) {
		if([[NSFileManager defaultManager] fileExistsAtPath:each]) {
			MachoLoader *ml = [[MachoLoader alloc] initWithPath:each checker:nil];
			[ml readFile];
			[ml release];
		}
	}

}

@end
