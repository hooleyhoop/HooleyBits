//
//  ActorKitTestAppDelegate.h
//  ActorKitTest
//
//  Created by steve hooley on 13/02/2009.
//  Copyright BestBefore Ltd 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActorKitTestViewController, 	HooAudioStreamer;

@interface ActorKitTestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ActorKitTestViewController *viewController;
	
	// mp3 test
	HooAudioStreamer *_player;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ActorKitTestViewController *viewController;

- (void)receiveEcho:(NSString *)text;
- (void)echo;
- (void)helloActor;

@end

