//
//  ScrollController.m
//  iphonePlay
//
//  Created by Steven Hooley on 5/30/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import "ScrollController.h"
#import "CustomScrollView.h"
#import <QuartzCore/QuartzCore.h>
#import "View_main.h"

@implementation ScrollController

@synthesize scrollView = _scrollView;
@synthesize mainView = _mainView;

- (void)dealloc {
	
	[_scrollView release];
	[_mainView release];
	[_downTouches release];
    [super dealloc];
}

- (void)doScrollMagicWithView:(View_main *)contentView {

	[[contentView retain] autorelease];
	contentView.backgroundColor = [UIColor yellowColor];
	
	CGRect normalSizeFrame = contentView.frame;
	CGRect windowFrame = [UIScreen mainScreen].applicationFrame;
	
	CGFloat scrollbarWidth = 14.0f;
	
	// fill the window with the scrollview
	CustomScrollView *testScrollView = [[[CustomScrollView alloc] initWithFrame:windowFrame] autorelease];
	testScrollView.delaysContentTouches = NO;
	testScrollView.delegate = testScrollView;
	testScrollView.showsHorizontalScrollIndicator = NO;
	testScrollView.showsVerticalScrollIndicator = NO;
	testScrollView.directionalLockEnabled = YES;
	testScrollView.alwaysBounceHorizontal = NO;
	testScrollView.alwaysBounceVertical = NO;
	testScrollView.scrollbarWidth = scrollbarWidth;
	testScrollView.bounces = NO;
	
	CGRect smallerFrameSize = CGRectMake(scrollbarWidth, 0, windowFrame.size.width-scrollbarWidth-5, 1024);
	[contentView setFrame:smallerFrameSize];
	
	CALayer *dragBarLayer = [CALayer layer];
	UIView *dragBarView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollbarWidth, CGRectGetHeight(testScrollView.frame))] autorelease];
	dragBarLayer.frame = CGRectMake(0, 0, CGRectGetWidth(dragBarView.frame), CGRectGetHeight(dragBarView.frame));

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	float onColVals[4] = { 0/255.0f, 255/255.0f, 0/255.0f, 0.67f };
	CGColorRef onColour = CGColorCreate( colorSpace, onColVals );
	dragBarLayer.backgroundColor = onColour;
	dragBarView.backgroundColor = [UIColor clearColor];
	CGColorSpaceRelease(colorSpace);

	[dragBarLayer setNeedsDisplay];
	[dragBarView setNeedsDisplay];

	UIView *contentViewParent = [contentView superview];
	[contentView removeFromSuperview];
	[testScrollView addSubview:contentView];

	[contentViewParent addSubview:testScrollView];

	testScrollView.contentSize = contentView.frame.size;

	CALayer *scrollviewsLayer = contentViewParent.layer;
	// NSArray *subLayers = scrollviewsLayer.sublayers;
	//	CALayer *scrollviewSubLayer = [subLayers objectAtIndex:0];
	//	NSArray *subSubLayers = scrollviewSubLayer.sublayers;
	//	CALayer *scrollviewSubSubLayer1 = [subSubLayers objectAtIndex:0];
	//	CALayer *scrollviewSubSubLayer2 = [subSubLayers objectAtIndex:1];
	//	CGRect scrollviewSubSubLayer1Frame = scrollviewSubSubLayer1.frame;
	//	CGRect scrollviewSubSubLayer2Frame = scrollviewSubSubLayer2.frame;
	//	scrollviewSubSubLayer1.backgroundColor = onColour;
	//	scrollviewSubSubLayer2.backgroundColor = onColour;
	[scrollviewsLayer addSublayer:dragBarLayer];
	
	testScrollView.scrollController = self;
	contentView.scrollController = self;

	CGColorRelease(onColour); 

	self.mainView = contentView;
	self.scrollView = testScrollView;
}

#pragma mark Home rolled touch events
- (void)didStartTouches:(NSSet *)touches inView:(UIView *)view withEvent:(UIEvent *)event {
	
	// we receive this call from both scroll view and content view with the same touches (just to be sure)
	// discard one of the calls
	static NSSet *_previousStartTouches;
	if(_previousStartTouches==touches)
		return;

	NSMutableSet *beganTouches = [NSMutableSet set];
	for(UITouch *eachTouch in touches)
	{
		CGPoint touchPoint = [eachTouch locationInView:nil];
		CGPoint orientatedPt = [_scrollView orientatedScreenPtForPt:touchPoint];
		if(orientatedPt.x>=_scrollView.scrollbarWidth){
			if(!_downTouches)
				_downTouches = [[NSMutableSet set] retain];
			[_downTouches addObject:eachTouch];
			[beganTouches addObject:eachTouch];
		}	
	}
	
	if([beganTouches count])
		[_mainView myTouchesBegan:beganTouches withEvent:event];

	[_previousStartTouches release];
	_previousStartTouches = [touches retain];
}

- (void)didMoveTouches:(NSSet *)touches inView:(UIView *)view withEvent:(UIEvent *)event {
	
	static NSSet *_previousMoveTouches;
	if(_previousMoveTouches==touches)
		return;

	NSMutableSet *moveTouches = [NSMutableSet set];
	for(UITouch *eachTouch in touches)
	{
		if([_downTouches containsObject:eachTouch])
			[moveTouches addObject:eachTouch];
	}
	if([moveTouches count])
		[_mainView myTouchesMoved:moveTouches withEvent:event];

	[_previousMoveTouches release];
	_previousMoveTouches = [touches retain];
}

- (void)didEndTouches:(NSSet *)touches inView:(UIView *)view withEvent:(UIEvent *)event {

	static NSSet *_previousEndTouches;
	if(_previousEndTouches==touches)
		return;

	NSMutableSet *endedTouches = [NSMutableSet set];
	for(UITouch *eachTouch in touches){
		if([_downTouches containsObject:eachTouch]==YES){
			[_downTouches removeObject:eachTouch];
			[endedTouches addObject:eachTouch];
		}
	}

	if([endedTouches count])
		[_mainView myTouchesEnded:endedTouches withEvent:event];
	
	[_previousEndTouches release];
	_previousEndTouches = [touches retain];
}

- (void)didCancelTouches:(NSSet *)touches inView:(UIView *)view withEvent:(UIEvent *)event {

	static NSSet *_previousCancelTouches;
	if(_previousCancelTouches==touches)
		return;

	NSMutableSet *canceledTouches = [NSMutableSet set];
	for(UITouch *eachTouch in touches){
		if([_downTouches containsObject:eachTouch]==YES){
			[_downTouches removeObject:eachTouch];
			[canceledTouches addObject:eachTouch];
		}
	}

	if([canceledTouches count])
		[_mainView myTouchesCanceled:canceledTouches withEvent:event];

	[_previousCancelTouches release];
	_previousCancelTouches = [touches retain];
}


@end
