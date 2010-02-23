//
//  iphonePlayAppDelegate.m
//  iphonePlay
//
//  Created by Steven Hooley on 1/15/09.
//  Copyright Bestbefore 2009. All rights reserved.
//

#import "iphonePlayAppDelegate.h"
#import "RootViewController.h"
#import "SinePlayer.h"
#import "TemperedScale.h"
#import "Keyboard_Simplest.h"
#import "LogController.h"

@implementation iphonePlayAppDelegate

@synthesize window;
@synthesize rootViewController;

- (void)dealloc {

	rootViewController.view = nil;
    [rootViewController release];

	[window release];

	[simpleKeyboard release];

	[sinePlayer release];
	[coreAudio tearDownGraph];
	[coreAudio release];

    [super dealloc];
}

//http://www.restoroot.com/Blog/2008/10/18/crash-reporter-for-iphone-applications/
void MyUncaughtExceptionHandler(NSException *exception) {
	
    NSArray *callStackArray = [exception callStackReturnAddresses];
    int frameCount = [callStackArray count];
    void *backtraceFrames[frameCount];
	
    for (int i=0; i<frameCount; i++) {
		NSUInteger res = [[callStackArray objectAtIndex:i] unsignedIntegerValue];
        backtraceFrames[i] = (void *)(res);
    }
	
    // report the exception
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	NSSetUncaughtExceptionHandler(&MyUncaughtExceptionHandler);

	NSAssert( window && rootViewController, @"Fucked Up Nib Stuff");

	coreAudio = [[CoreAudioSineGenerator alloc] init];
	[coreAudio setUpGraph];

	sinePlayer = [[SinePlayer SinePlayerWithInfrastructure:coreAudio] retain];

	simpleKeyboard = [[Keyboard_Simplest alloc] init];
	[simpleKeyboard setNoteLookup:[TemperedScale temperedScale]];
	[simpleKeyboard connectOutputTo:sinePlayer];
	
	[rootViewController showActiveViewController];

	[window addSubview:[rootViewController view]];
	[window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {

	[self release];
}

- (Keyboard_Simplest *)activeKeyboard {
	return simpleKeyboard;
}

- (Float32)cpuUsage {
	return [coreAudio getCPULoad] * 100;
}

@end
