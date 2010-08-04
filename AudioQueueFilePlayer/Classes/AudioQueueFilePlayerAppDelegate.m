//
//  AudioQueueFilePlayerAppDelegate.m
//  AudioQueueFilePlayer
//
//  Created by steve hooley on 04/02/2009.
//  Copyright BestBefore Ltd 2009. All rights reserved.
//

#import "AudioQueueFilePlayerAppDelegate.h"
#import "AudioQueueFilePlayerViewController.h"
#import "AudioQueuePlay.h"
#import "SpectraView.h"

#import "BBLogger.h"

@implementation AudioQueueFilePlayerAppDelegate

@synthesize window;
@synthesize viewController;

use mach-0 loader to get the address of the _cstring section.  replace addressess in the disassembly with the relevant string literals
- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	logInfo(@"Running..");
	
    // Override point for customization after app launch
	UIView *spectraView = viewController.view;
	NSAssert(spectraView, @"oops what are we doing?");
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
	[window addSubview:tabBarController.view];
	
	UIViewController *groupsController = [[[UIViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	navigationController = [[UINavigationController alloc] initWithRootViewController:groupsController];
	navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[window addSubview:[navigationController view]];
	
	// Initialize the audioQueue and send it a file to play
	audioController = [[AudioQueuePlay alloc] init];
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *pathToAudioFile = [mainBundle pathForResource:@"audioboo_recording" ofType:@"aif"];
	[audioController playFile:pathToAudioFile];
	
	// start the animation
	[(SpectraView *)viewController.view setupLayers];
	[(SpectraView *)viewController.view startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	
	logInfo(@"Quiting..");
}

- (void)dealloc {

    [viewController release];
    [window release];
	
	[audioController release];

    [super dealloc];
}

- (void)getAudioLevel:(Float32 *)audioLevel peakLevel:(Float32 *)audioPeakLevel {

	Float32 levels[2];
	Float32 peakLevels[2];
	[audioController getAudioLevels:levels peakLevels:peakLevels];
	*audioLevel = levels[0];
	*audioPeakLevel = peakLevels[0];
}

@end
