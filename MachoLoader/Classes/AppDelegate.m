//
//  AppDelegate.m
//  MachoLoader
//
//  Created by steve hooley on 03/04/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "MachoLoader.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

//	NSString *pathToApp = [[NSBundle mainBundle] executablePath];
//	NSString *pathToApp = @"/Applications/6-386.app/Contents/MacOS/6-386";
//	NSString *pathToApp = @"/Applications/CrossOver.app/Contents/MacOS/CrossOver";
	NSString *pathToApp = @"/Applications/SIGMA Photo Pro.app/Contents/MacOS/SIGMA Photo Pro";
	
	MachoLoader *ml = [[MachoLoader alloc] initWithPath:pathToApp];
	[ml readFile];

	[ml release];
//	NSString *section = [ml sectionForMemAddress:0];

}

@end
