//
//  SpectraView.h
//  AudioQueueFilePlayer
//
//  Created by steve hooley on 04/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NUMBER_OF_BARS 9

@interface SpectraView : UIView {

	// An animation timer that, when animation is started, will periodically call -drawView at the given rate.
	NSTimer *animationTimer;
	NSTimeInterval animationInterval;
	
	CALayer *bars[NUMBER_OF_BARS];
}

@property NSTimeInterval animationInterval;


- (void)setupLayers;

- (void)startAnimation;
- (void)stopAnimation;

@end
