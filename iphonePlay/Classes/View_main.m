//
//  View_main.m
//  iphonePlay
//
//  Created by steve hooley on 16/01/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "View_main.h"
#import <CoreGraphics/CoreGraphics.h>
#import "Widget_Keyboard_Simplest.h"
#import "LogController.h"
#import "TouchTracker.h"
#import "HooleyTouchEvent.h"
#import "TouchMeter.h"
#import "ScrollController.h"

@implementation View_main

@synthesize controller;
@synthesize scrollController = _scrollController;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    if(self) {
		touchTracker = [[TouchTracker alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
    if(self) {
		touchTracker = [[TouchTracker alloc] init];
    }
    return self;
}

- (void)dealloc {

	[touchTracker release];
    [super dealloc];
}

#pragma mark touch events
/* This is where we first receive a touch event */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[_scrollController didStartTouches:touches inView:self withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[_scrollController didMoveTouches:touches inView:self withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[_scrollController didEndTouches:touches inView:self withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[_scrollController didCancelTouches:touches inView:self withEvent:event];
}

- (void)myTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

	for( UITouch *touch in touches ){		
	//		NSUInteger tapCount = touch.tapCount;
	//		if(tapCount>1)
	//			logError(@"TAP TAP Began");
		CGPoint touchPoint = [touch locationInView:self];
	//		//logInfo(@"Touch Began (%f, %f), (%f, %f)", (float)touchPoint.x, (float)previousPt.y, (float)previousPt.x, (float)touchPoint.y );
			/* touchTracker will attempt to keep track of open touches */
		HooleyTouchEvent *newTouch = [touchTracker beganTouch:touch atLoc:touchPoint];

		/* forward the touch event to the view controller */
		[controller touchBegan: newTouch];
	}
	
	[[TouchMeter sharedTouchMeter] touch:1];
}

- (void)myTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	for( UITouch *touch in touches ){
	
		CGPoint previousTouchPoint = [touch previousLocationInView:self];
		CGPoint touchPoint = [touch locationInView:self];
		//logInfo(@"Touch Moved Frm (%f, %f) to (%f, %f)", (float)previousTouchPoint.x, (float)previousTouchPoint.y, (float)touchPoint.x, (float)touchPoint.y);
		HooleyTouchEvent *movedTouch = [touchTracker movedTouch:touch from:previousTouchPoint to:touchPoint];
		[controller touchMoved:movedTouch];
	}
	
	[[TouchMeter sharedTouchMeter] touch:1];
}

- (void)myTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

	for( UITouch *touch in touches ){		
		CGPoint previousPt = [touch previousLocationInView:self];
		CGPoint touchPoint = [touch locationInView:self];
//		NSUInteger tapCount = touch.tapCount; 
//		if(tapCount>1)
//			logError(@"TAP TAP Ended");
		// logInfo(@"Touch Ended (%f, %f), (%f, %f)\n", (float)touchPoint.x, (float)previousPt.y, (float)previousPt.x, (float)touchPoint.y );
		HooleyTouchEvent *endedTouch = [touchTracker endedTouch:touch at:touchPoint prevPt:previousPt];
		[controller touchEnded:endedTouch];
	}
	[[TouchMeter sharedTouchMeter] touch:1];
}

- (void)myTouchesCanceled:(NSSet *)touches withEvent:(UIEvent *)event {
	[[TouchMeter sharedTouchMeter] touch:1];
}

@end
