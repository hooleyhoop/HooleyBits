//
//  CustomScrollView.h
//  iphonePlay
//
//  Created by steve hooley on 15/04/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@class View_main, ScrollController;

@interface CustomScrollView : UIScrollView <UIScrollViewDelegate> {

	BOOL _allowedToDrag;
	ScrollController *_scrollController;
	
	NSMutableSet *_downTouches;
	UIDeviceOrientation _orientation;
	
	CGFloat _scrollbarWidth;
}

@property (assign) ScrollController *scrollController;
@property(nonatomic, readwrite) UIDeviceOrientation orientation;
@property(nonatomic, readwrite) CGFloat scrollbarWidth;

- (CGPoint)orientatedScreenPtForPt:(CGPoint)windowPt;

@end
