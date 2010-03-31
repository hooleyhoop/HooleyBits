//
//  HooleyLayer.h
//  CALayerLayout
//
//  Created by steve hooley on 26/06/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface HooleyLayer : CALayer {

	CGPoint unitPos;
	CGSize unitSize;
	CGFloat unitRadius;
	
	BOOL hasUnitPos, hasUnitSize, hasUnitRadius;
	
	CGColorRef _backGrndColour;
}

@property CGPoint unitPos;
@property CGSize unitSize;
@property CGFloat unitRadius;

- (void)turnOn;
- (void)turnOff;

- (void)updatePositionForFrame:(CGRect)rframe;
- (void)updateSizeForFrame:(CGRect)rframe;
- (void)updateRadiusForFrame:(CGRect)rframe;

- (void)sizeToUnitSize:(CGSize)size of:(CGRect)rframe;
- (void)positionToUnitPosition:(CGPoint)pos of:(CGRect)rframe;
- (void)cornerRadiusToUnitRadius:(CGFloat)rad of:(CGRect)rframe;

- (void)setUnitPos:(CGPoint)uPos;
- (void)setUnitSize:(CGSize)uSize;
- (void)setUnitRadius:(CGFloat)uRad;

- (CGSize)sizeForParentFrame:(CGRect)rframe;
- (CGPoint)positionForParentFrame:(CGRect)rframe;
- (CGFloat)radiusForParentFrame:(CGRect)rframe;

@end
