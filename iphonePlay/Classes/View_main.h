//
//  View_main.h
//  iphonePlay
//
//  Created by steve hooley on 16/01/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "View_Base.h"

@class ViewController_mainScreen, TouchTracker, ScrollController;

@interface View_main : View_Base {

	ViewController_mainScreen	*controller;
	TouchTracker				*touchTracker;
	ScrollController			*_scrollController;
}

@property (assign) IBOutlet ViewController_mainScreen *controller;
@property (assign) ScrollController *scrollController;

- (void)myTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)myTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)myTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)myTouchesCanceled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
