//
//  AudioQueueFilePlayerAppDelegate.h
//  AudioQueueFilePlayer
//
//  Created by steve hooley on 04/02/2009.
//  Copyright BestBefore Ltd 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHooleyObject.h"

@class AudioQueueFilePlayerViewController, AudioQueuePlay;

@interface AudioQueueFilePlayerAppDelegate : SHooleyObject <UIApplicationDelegate> {

    UIWindow *window;
    AudioQueueFilePlayerViewController *viewController;
	AudioQueuePlay *audioController;
	
	UITabBarController *tabBarController;
	UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AudioQueueFilePlayerViewController *viewController;

- (void)getAudioLevel:(Float32 *)audioLevel peakLevel:(Float32 *)audioPeakLevel;

@end

