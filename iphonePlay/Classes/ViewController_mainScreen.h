//
//  ViewController_mainScreen.h
//  iphonePlay
//
//  Created by Steven Hooley on 1/15/09.
//  Copyright Bestbefore 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController_Base.h"

@class Widget_Keyboard_Simplest, Keyboard_Simplest, HooleyTouchEvent, TouchMeter, ScrollController;

@interface ViewController_mainScreen : ViewController_Base <UIAccelerometerDelegate> {

	UILabel						*cpuUsage;
    UIButton					*infoButton;

	Widget_Keyboard_Simplest	*keyBoardWidget;
	NSTimer						*animationTimer;
	
	NSArray						*tlo;
	
	TouchMeter					*_touchMeter;
	
	ScrollController			*_scrollController;
}

@property (assign) IBOutlet UILabel					*cpuUsage;
@property (retain, nonatomic) IBOutlet UIButton		*infoButton;

- (void)touchBegan:(HooleyTouchEvent *)hTouchEvent;
- (void)touchMoved:(HooleyTouchEvent *)hTouchEvent;
- (void)touchEnded:(HooleyTouchEvent *)hTouchEvent;

- (IBAction)infoButtonPressed:(id)sender;

- (void)setAnimating:(BOOL)flag;

@end

