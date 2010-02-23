//
//  ScrollController.h
//  iphonePlay
//
//  Created by Steven Hooley on 5/30/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import <Foundation/Foundation.h>

@class View_main, CustomScrollView;

@interface ScrollController : NSObject {

	CustomScrollView *_scrollView;
	View_main *_mainView;
	NSMutableSet *_downTouches;
}

@property (retain) CustomScrollView *scrollView;
@property (retain) View_main *mainView;

- (void)doScrollMagicWithView:(View_main *)contentView;

- (void)didStartTouches:(NSSet *)touches inView:(UIView *)view withEvent:(UIEvent *)event;
- (void)didMoveTouches:(NSSet *)touches inView:(UIView *)view withEvent:(UIEvent *)event;
- (void)didEndTouches:(NSSet *)touches inView:(UIView *)view withEvent:(UIEvent *)event;
- (void)didCancelTouches:(NSSet *)touches inView:(UIView *)view withEvent:(UIEvent *)event;

@end
