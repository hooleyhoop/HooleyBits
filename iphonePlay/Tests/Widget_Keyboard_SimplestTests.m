//
//  Widget_Keyboard_SimplestTests.m
//  iphonePlay
//
//  Created by steve hooley on 12/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//
#import "GTMSenTestCase.h"
#if (!GTM_IPHONE_SDK)
#warning - we seem to be compiling tests with the wrong SDK
#endif
#import "Widget_Keyboard_Simplest.h"

@interface Widget_Keyboard_SimplestTests : SenTestCase {
	
	Widget_Keyboard_Simplest	*keyBoardWidget;
}

@end

@implementation Widget_Keyboard_SimplestTests

- (void)setUp {
	
	keyBoardWidget = [[Widget_Keyboard_Simplest alloc] init];
}

- (void)tearDown {
	
	[keyBoardWidget release];
}

- (void)testWidget {
	
}

//- (void)addToView:(UIView *)aView;
//- (void)removeFromView:(UIView *)aView;

//- (void)touchBegan:(HooleyTouchEvent *)hTouchEvent;
// did it hit
// set the touch

//- (void)touchMoved:(HooleyTouchEvent *)hTouchEvent;
//- (void)touchEnded:(HooleyTouchEvent *)hTouchEvent;

//- (void)_pressedKeyLayer:(Layer_key *)lyr;
//- (void)_releasedKeyLayer:(Layer_key *)lyr;

//- (void)setModel:(Keyboard_Simplest *)keybrd;

//- (void)_setupKeys;

@end
