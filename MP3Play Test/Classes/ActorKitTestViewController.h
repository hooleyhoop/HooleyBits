//
//  ActorKitTestViewController.h
//  ActorKitTest
//
//  Created by steve hooley on 13/02/2009.
//  Copyright BestBefore Ltd 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HooAudioStreamer;

@interface ActorKitTestViewController : UIViewController {

	IBOutlet UIButton *stopButton, *playButton;
	IBOutlet UIActivityIndicatorView *busySpinner;
	
	// mp3 test
	HooAudioStreamer *_player;
	
	BOOL _isPlaying;
	BOOL _isBuffering;	
}

@property (assign) UIButton *stopButton, *playButton;
@property (assign) UIActivityIndicatorView *busySpinner;
@property (readwrite) BOOL isPlaying;	// Set true as soon as playAudio is called - ie, doesn't represent whether audio is actually being played.
@property (readwrite) BOOL isBuffering;

- (IBAction)play:(id)sender;
- (IBAction)stop:(id)sender;

- (void)playAudio;
- (void)stopAudio;
- (void)audioIsReady;

@end

