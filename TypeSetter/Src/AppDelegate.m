//
//  AppDelegate.m
//  TypeSetter
//
//  Created by steve hooley on 13/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "WindowController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	WindowController *controller = [[WindowController alloc] initWithWindowNibName:@"TypeSetWindow"];
	[controller showWindow:nil];
}

@end
