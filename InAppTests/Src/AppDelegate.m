//
//  AppDelegate.m
//  InAppTests
//
//  Created by steve hooley on 01/02/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "FScript/FScript.h"

@implementation AppDelegate

- (void)awakeFromNib {
	[[NSApp mainMenu] addItem:[[[FScriptMenuItem alloc] init] autorelease]];	
}

- (void)applicationDidFinishLaunching:(NSNotification *)sender {
	NSLog(@"eh");
}

@end
