//
//  iPhoneFFTAppDelegate.m
//  iPhoneFFT
//
//  Created by Steven Hooley on 27/05/2010.
//  Copyright Tinsal Parks 2010. All rights reserved.
//

#import "iPhoneFFTAppDelegate.h"
#import "iPhoneFFTViewController.h"
#import "IPhoneFFT.h";
#import "AudioSessionStuff.h";


@implementation iPhoneFFTAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	CALayer *a;

	// Turn off the idle timer, since this app doesn't rely on constant touch input
	// application.idleTimerDisabled = YES;

	_audioSessionManager = [[AudioSessionStuff alloc] init];
	[_audioSessionManager setup];
		
	_iPhoneFFT = [[IPhoneFFT alloc] init]; 
	[_iPhoneFFT beginRecording];

	return YES;
}


- (void)dealloc {

    [viewController release];
    [window release];
    [super dealloc];
}

have a timer that gets myFFT.spectrumData

and draw It

@end
