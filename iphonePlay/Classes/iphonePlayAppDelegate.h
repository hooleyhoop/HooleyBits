//
//  iphonePlayAppDelegate.h
//  iphonePlay
//
//  Created by Steven Hooley on 1/15/09.
//  Copyright Bestbefore 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreAudioSineGenerator.h"
#import "SHooleyObject.h"

@class RootViewController, SinePlayer, Keyboard_Simplest;

@interface iphonePlayAppDelegate : SHooleyObject <UIApplicationDelegate> {
	
    UIWindow								*window;
    RootViewController						*rootViewController;
	
	CoreAudioSineGenerator					*coreAudio;
	SinePlayer								*sinePlayer;
	Keyboard_Simplest						*simpleKeyboard;
}

@property (assign) IBOutlet UIWindow *window;
@property (assign) IBOutlet RootViewController *rootViewController;

- (Keyboard_Simplest *)activeKeyboard;
- (Float32)cpuUsage;

@end

