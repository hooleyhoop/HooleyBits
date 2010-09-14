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
//	NSString *pathToApp = @"/Applications/modo.app/Contents/MacOS/modo";
//	NSString *pathToApp = @"/Applications/Adobe After Effects CS3/Adobe After Effects CS3.app/Contents/MacOS/After Effects";
	NSString *pathToApp = @"/Applications/6-386.app/Contents/MacOS/6-386";
	
	MachoLoader *ml = [[MachoLoader alloc] initWithPath:pathToApp];
	[ml readFile];

//	NSString *section = [ml sectionForMemAddress:0];

}

@end
