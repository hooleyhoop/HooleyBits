//
//  Widget_Keyboard_Simplest.h
//  iphonePlay
//
//  Created by steve hooley on 12/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//
#import "SHooleyObject.h"
#import "KeyboardProtocol.h"
#import <Foundation/Foundation.h>

@class Layer_key, HooleyTouchEvent, GridLayout, Layer_Base;

@interface Widget_Keyboard_Simplest : SHooleyObject {

	UIView							*view;
	SHooleyObject<KeyboardProtocol> *keyboard;
	Layer_Base						*widgetLayer;
	
	CGColorRef						onColour, offColour, errColour, backgroundColour, borderColour;
	
	GridLayout						*layoutManager;
}

@property (retain) GridLayout *layoutManager;

- (void)addToView:(UIView *)aView;
- (void)removeFromView:(UIView *)aView;

- (void)touchBegan:(HooleyTouchEvent *)hTouchEvent;
- (void)touchMoved:(HooleyTouchEvent *)hTouchEvent;
- (void)touchEnded:(HooleyTouchEvent *)hTouchEvent;

- (void)_pressedKeyLayer:(Layer_key *)lyr withTouch:(HooleyTouchEvent *)hTouchEvent;
- (void)_releasedKeyLayer:(Layer_key *)lyr;

- (Layer_key *)keyPressedByTouch:(HooleyTouchEvent *)hTouchEvent;

- (void)setModel:(SHooleyObject<KeyboardProtocol> *)keybrd;

- (void)_setupKeys;
- (void)relayout;

- (CGSize)neededSizeForScrollFrame:(CGRect)frame;


@end
