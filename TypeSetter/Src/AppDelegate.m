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


// check out this guys great c code
http://nothings.org/stb/stb_truetype.h


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	// enable font - 'Free Sans'
	NSString *pathForEmbeddedFont = [[NSBundle mainBundle] pathForResource:@"FREESANS" ofType:@"ttf" inDirectory:nil];
	NSURL *fontURL = [NSURL fileURLWithPath:pathForEmbeddedFont];
	CFErrorRef err;
	bool success = CTFontManagerRegisterFontsForURL( (CFURLRef)fontURL, kCTFontManagerScopeProcess, &err );
	NSAssert(success, @"Failed to load font FREESANS.ttf");

	_controller = [[WindowController alloc] initWithWindowNibName:@"TypeSetWindow"];
	[_controller showWindow:nil];
}

@end
