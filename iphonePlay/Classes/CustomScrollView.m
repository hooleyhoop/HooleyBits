//
//  CustomScrollView.m
//  iphonePlay
//
//  Created by steve hooley on 15/04/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "CustomScrollView.h"
#import "TouchMeter.h"
#import "ScrollController.h"

@implementation CustomScrollView

@synthesize scrollController = _scrollController;
@synthesize orientation = _orientation;
@synthesize scrollbarWidth = _scrollbarWidth;

- (void)dealloc {
	[_downTouches release];
	[super dealloc];
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
	
	NSLog(@"touches should begin?");
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:nil];
	if([self orientatedScreenPtForPt:touchPoint].x<_scrollbarWidth){
		return NO;
	}
	
	
//		self.scrollEnabled = YES;
//		self.delaysContentTouches = YES;
//		view.exclusiveTouch = NO;
//		self.exclusiveTouch = YES;
//		_allowedToDrag = YES;
//		return NO;
//	}

//	self.scrollEnabled = NO;
	self.delaysContentTouches = NO;
//	self.exclusiveTouch = NO;
//	view.exclusiveTouch = YES;
//	_allowedToDrag = NO;
	return YES;
}

//- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
//	NSLog(@"touchesShouldCancelInContentView %@", view);
//	return _allowedToDrag;
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if([_downTouches count]>0)
		NSLog(@"old touches? %i", [_downTouches count]);
	
	NSMutableSet *beganTouches = [NSMutableSet set];

	for(UITouch *eachTouch in touches)
	{
		CGPoint touchPoint = [eachTouch locationInView:nil];
		CGPoint orientatedPt = [self orientatedScreenPtForPt:touchPoint];
		// NSLog(@"x = %f, %f", orientatedPt.x, orientatedPt.y);
		if(orientatedPt.x>=_scrollbarWidth){
			continue;
		} else {
			if(!_downTouches)
				_downTouches = [[NSMutableSet set] retain];
			[_downTouches addObject:eachTouch];
			[beganTouches addObject:eachTouch];
		}
	}
	
	[_scrollController didStartTouches:touches inView:self withEvent:event];

	if([beganTouches count]){
		[super touchesBegan:touches withEvent:event];
		[[TouchMeter sharedTouchMeter] touch:0];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	NSMutableSet *movedTouches = [NSMutableSet set];

	for(UITouch *eachTouch in touches){
		if([_downTouches containsObject:eachTouch])
			[movedTouches addObject:eachTouch];
	}
	
	[_scrollController didMoveTouches:touches inView:self withEvent:event];

	if([movedTouches count]){
		[super touchesMoved:touches withEvent:event];
		[[TouchMeter sharedTouchMeter] touch:0];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	NSMutableSet *endedTouches = [NSMutableSet set];

	for(UITouch *eachTouch in touches){
		if([_downTouches containsObject:eachTouch]==YES){
			[_downTouches removeObject:eachTouch];
			[endedTouches addObject:eachTouch];
		}
	}
	
	[_scrollController didEndTouches:touches inView:self withEvent:event];
	
	if([endedTouches count]){
		[super touchesEnded:touches withEvent:event];
		[[TouchMeter sharedTouchMeter] touch:0];
	}	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

	for(UITouch *eachTouch in touches){
		if([_downTouches containsObject:eachTouch]==YES)
			[_downTouches removeObject:eachTouch];
	}
	[_scrollController didCancelTouches:touches inView:self withEvent:event];

	[super touchesCancelled:touches withEvent:event];
	[[TouchMeter sharedTouchMeter] touch:0];
}

// The delegate typically implements this method to obtain the change in content offset from scrollView and draw the affected portion of the content view.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

// called when scrolling animation finished. may be called immediately if already at top
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {	
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
	NSLog(@"scrollViewWillBeginDragging");
	if(_allowedToDrag){
//		self.scrollEnabled = YES;
//		self.delaysContentTouches = YES;
//		self.exclusiveTouch = YES;
	} else {
//		self.scrollEnabled = NO;
//		self.delaysContentTouches = NO;
//		self.exclusiveTouch = NO;
	}
}

// called on finger up if user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

	//		self.scrollEnabled = YES;
//		self.delaysContentTouches = NO;
//		self.exclusiveTouch = NO;

}

// called on finger up as we are moving
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
}

// called when scroll view grinds to a halt
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
}

// return a view that will be scaled. if delegate returns nil, nothing happens
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return nil;
}

// scale between minimum and maximum. called after any 'bounce' animations
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
}

// return a yes if you want to scroll to the top. if not defined, assumes YES
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
	return NO;
}

- (CGPoint)orientatedScreenPtForPt:(CGPoint)windowPt {

	//NSLog(@"unrotated x = %f, %f", windowPt.x, windowPt.y);
	CGPoint orientatedPt = windowPt;
	CGSize windowFrameSize = [UIScreen mainScreen].applicationFrame.size;

//	if(_orientation==UIDeviceOrientationPortrait || ) 		
//	} else if(_orientation==UIDeviceOrientationPortraitUpsideDown){
		//		orientatedPt.x = windowFrameSize.height-windowPt.x;
		//		orientatedPt.y = ;
	// } else
	if(_orientation==UIDeviceOrientationPortraitUpsideDown){
		orientatedPt.x = windowFrameSize.width-windowPt.x;
		orientatedPt.y = windowFrameSize.height-windowPt.y;		
		
	} else if(_orientation==UIDeviceOrientationLandscapeLeft ) {
		orientatedPt.x = windowPt.y;
		orientatedPt.y = windowFrameSize.width-windowPt.x;

	} else if(_orientation==UIDeviceOrientationLandscapeRight) {
		orientatedPt.x = windowFrameSize.height-windowPt.y;
		orientatedPt.y = windowPt.x;

		//	} else if(orientation==UIDeviceOrientationFaceUp || orientation==UIDeviceOrientationFaceDown){

	} else {
		NSLog(@"Unknown Orientation!");
	}
	return orientatedPt;
}
	
@end
