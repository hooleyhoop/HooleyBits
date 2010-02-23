//
//  iPhonePixelEditorAppDelegate.m
//  iPhonePixelEditor
//
//  Created by steve hooley on 23/02/2009.
//  Copyright BestBefore Ltd 2009. All rights reserved.
//

#import "iPhonePixelEditorAppDelegate.h"
#import "EAGLView.h"

@implementation iPhonePixelEditorAppDelegate

@synthesize window;
@synthesize glView;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	glView.animationInterval = 1.0 / 60.0;
	[glView startAnimation];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	glView.animationInterval = 1.0 / 5.0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	glView.animationInterval = 1.0 / 60.0;
}


- (void)dealloc {
	[window release];
	[glView release];
	[super dealloc];
}

@end
