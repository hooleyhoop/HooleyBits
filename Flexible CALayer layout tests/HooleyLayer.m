//
//  HooleyLayer.m
//  CALayerLayout
//
//  Created by steve hooley on 26/06/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HooleyLayer.h"


@implementation HooleyLayer

@synthesize unitPos;
@synthesize unitSize;
@synthesize unitRadius;

- (void)turnOn {
	
    CGColorRef bgColor = CGColorCreateGenericRGB( 1, 1, 0, 1.0 );
	_backGrndColour = self.backgroundColor;
	self.backgroundColor  = bgColor;
}

- (void)turnOff {
	
	self.backgroundColor  = _backGrndColour;
}


- (void)updatePositionForFrame:(CGRect)rframe {
	
	if(hasUnitPos){
		CGPoint pos = [self positionForParentFrame:rframe];
	    self.position = pos;
	}
}

- (void)updateSizeForFrame:(CGRect)rframe {
	
	if(hasUnitSize){
		CGSize asize = [self sizeForParentFrame:rframe];
		CGRect bnds = self.bounds;
		bnds.size = asize;
		self.bounds = bnds;
	}
}

- (void)updateRadiusForFrame:(CGRect)rframe {
	
	if(hasUnitRadius){
		CGFloat rad = [self radiusForParentFrame:rframe];
		self.cornerRadius = rad;
	}
}

- (void)positionToUnitPosition:(CGPoint)pos of:(CGRect)rframe {
	
	[self setUnitPos: CGPointMake(pos.x/rframe.size.width, pos.y/rframe.size.height ) ];
    self.position = pos;
}

- (void)sizeToUnitSize:(CGSize)asize of:(CGRect)rframe {

	[self setUnitSize: CGSizeMake(asize.width/rframe.size.width, asize.height/rframe.size.height ) ];
	CGRect bnds = self.bounds;
    bnds.size = asize;
	self.bounds = bnds;
}

- (void)cornerRadiusToUnitRadius:(CGFloat)rad of:(CGRect)rframe {

	[self setUnitRadius: (CGFloat)(rad/rframe.size.width) ];
    self.cornerRadius = rad;
}

- (void)setUnitPos:(CGPoint)uPos {
	
	unitPos = uPos;
	hasUnitPos = YES;
}

- (void)setUnitSize:(CGSize)uSize {

	unitSize = uSize;
	hasUnitSize = YES;
}

- (void)setUnitRadius:(CGFloat)uRad {

	unitRadius = uRad;
	hasUnitRadius = YES;
}

- (CGSize)sizeForParentFrame:(CGRect)rframe {
	
	CGSize asize;
	if(hasUnitSize)
		asize = CGSizeMake( unitSize.width*rframe.size.width, unitSize.height*rframe.size.height );
	else 
		asize = self.bounds.size;
	return asize;
}

- (CGPoint)positionForParentFrame:(CGRect)rframe {

	CGPoint pos;
	if(hasUnitPos)
		pos = CGPointMake( unitPos.x*rframe.size.width, unitPos.y*rframe.size.height );
	else
		pos = self.position;
	return pos;
}

- (CGFloat)radiusForParentFrame:(CGRect)rframe {
	
	CGFloat rad;
	if(hasUnitRadius)
		rad = unitRadius*rframe.size.width;
	else
		rad = 0;
	return rad;
}


@end



