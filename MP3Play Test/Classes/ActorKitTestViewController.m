//
//  ActorKitTestViewController.m
//  ActorKitTest
//
//  Created by steve hooley on 13/02/2009.
//  Copyright BestBefore Ltd 2009. All rights reserved.
//

#import "ActorKitTestViewController.h"
#import "ActorKitTestAppDelegate.h"
#import "HooAudioStreamer.h"

@implementation ActorKitTestViewController

@synthesize stopButton, playButton;
@synthesize busySpinner;
@synthesize isPlaying=_isPlaying, isBuffering=_isBuffering;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	stopButton.enabled = NO;
	stopButton.alpha = 0.5;
	playButton.enabled = YES;
	playButton.alpha = 1.0;
}

- (void)playAudio {
	
	// The audiostreamer behaves much better if we just try to create one instance per attempt to play the file:
	[self stopAudio];
	
	/* Try to play an mp3 */
//	_player = [[HooAudioStreamer alloc] initWithURL:[NSURL URLWithString:@"http://boos.audioboo.fm/attachments/151234/Recording.mp3"]]; // short
//	_player = [[HooAudioStreamer alloc] initWithURL:[NSURL URLWithString:@"http://boos.audioboo.fm/attachments/144145/Recording.mp3"]]; // long
	_player = [[HooAudioStreamer alloc] initWithURL:[NSURL URLWithString:@"http://boos.audioboo.fm/attachments/96814/Recording.mp3"]];	// longest
	
	[_player addObserver:self forKeyPath:@"started" options:NSKeyValueObservingOptionNew context:@"BooClip"];
	[_player addObserver:self forKeyPath:@"stopped" options:NSKeyValueObservingOptionNew context:@"BooClip"];
	[_player startPlayingAudio];
	
	self.isPlaying = YES;
	self.isBuffering = YES;
	
	//steve	[playButtonView setState:kPlaybackStateBuffering];
	stopButton.enabled = YES;
	stopButton.alpha = 1.0f;
	playButton.enabled = NO;
	playButton.alpha = 0.5;
	[busySpinner startAnimating];
}

- (void)audioIsReady {
	self.isBuffering = NO;
	
	//steve	[playButtonView setState:kPlaybackStatePlaying];
	[busySpinner stopAnimating];
}

- (void)stopAudio {
	
	if( self.isPlaying ) {
		
		// Hmm ive had some difficulty getting to stop
		// we call this on the main thread
		self.isPlaying = NO;
		self.isBuffering = NO;
		
		[_player stopPlayingAudio];
		[_player removeObserver:self forKeyPath:@"started"];
		[_player removeObserver:self forKeyPath:@"stopped"];
		[_player release];
		_player = nil;
	
		//steve		[playButtonView setState:kPlaybackStateStopped];
		stopButton.enabled = NO;
		stopButton.alpha = 0.5;
		playButton.enabled = YES;
		playButton.alpha = 1.0;
		
		// audio is ready may not have been called
		self.isBuffering = NO;
		[busySpinner stopAnimating];
	}
}

/* Notification will be received on the player thread */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
	if( [(NSString *)context isEqualToString:@"BooClip"] )
	{
		// We get triggered on AudioStreamer's playback thread, be careful to bounce back to the main thread
		if ([keyPath isEqualToString:@"started"]) {
			id newValue = [change objectForKey:NSKeyValueChangeNewKey];
			if([newValue boolValue])
			// If isPlaying got set, the AudioStreamer has downloaded & started playing the audio.  Let our delegate know about it
				[self performSelectorOnMainThread:@selector(audioIsReady) withObject:nil waitUntilDone:NO];

		} else if ([keyPath isEqualToString:@"stopped"]) {
			// If isPlaying got unset, the audio has been played, and finished normally.
			id newValue = [change objectForKey:NSKeyValueChangeNewKey];
			if([newValue boolValue])
				[self performSelectorOnMainThread:@selector(stopAudio) withObject:nil waitUntilDone:NO];
		} else {
			[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];   
		}
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];   
	}
}

- (IBAction)play:(id)sender {
	[self playAudio];
}

- (IBAction)stop:(id)sender {
	[self stopAudio];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

@end
