//
//  ActorKitTestAppDelegate.m
//  ActorKitTest
//
//  Created by steve hooley on 13/02/2009.
//  Copyright BestBefore Ltd 2009. All rights reserved.
//

#import "ActorKitTestAppDelegate.h"
#import "ActorKitTestViewController.h"

@implementation ActorKitTestAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	NSThread *thisThread = [NSThread currentThread];
	NSLog(@"Main Thread %@", thisThread);
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

@end
