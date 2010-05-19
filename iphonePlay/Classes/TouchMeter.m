//
//  TouchMeter.m
//  iphonePlay
//
//  Created by steve hooley on 29/05/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "TouchMeter.h"
#import <QuartzCore/QuartzCore.h>

static TouchMeter *sharedTouchMeter;

@implementation TouchMeter

+ (TouchMeter *)sharedTouchMeter {
	if(!sharedTouchMeter)
		sharedTouchMeter = [[TouchMeter alloc] init];
	return sharedTouchMeter;
}

+ (void)clean {
	[sharedTouchMeter release];
	sharedTouchMeter = nil;
}

#pragma mark Init
- (id)init {
	
	self=[super init];
    if(self) {
		CGRect touchMeterFrame = CGRectMake(0,0,40,20);
		_touchMeterView = [[UIView alloc] initWithFrame:touchMeterFrame];
	//	_touchMeterView.backgroundColor = [UIColor greenColor];
		
		CALayer *circleLayer1 = [CALayer layer];
		circleLayer1.anchorPoint = CGPointMake(0.0f, 0.0f);
		circleLayer1.bounds = CGRectMake( 0.0f, 0.0f, touchMeterFrame.size.width/2, touchMeterFrame.size.height );

		CALayer *circleLayer2 = [CALayer layer];
		circleLayer2.anchorPoint = CGPointMake(0.0f, 0.0f);
		circleLayer2.bounds = CGRectMake( 0.0f, 0.0f, touchMeterFrame.size.width/2, touchMeterFrame.size.height );
		
		CALayer *rootLayer = _touchMeterView.layer;
		[rootLayer addSublayer:circleLayer1];
		[rootLayer addSublayer:circleLayer2];
		
		circleLayer1.position = CGPointMake( 0, 0 );		
		circleLayer2.position = CGPointMake( touchMeterFrame.size.width/2, 0 );	
		circleLayer1.opacity = 0;		
		circleLayer2.opacity = 0;	

		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		float colVals1[4] = { 0/255.0f, 255/255.0f, 0/255.0f, 1.0f };
		float colVals2[4] = { 255/255.0f, 0/255.0f, 0/255.0f, 1.0f };
		CGColorRef col1 = CGColorCreate(colorSpace, colVals1);
		CGColorRef col2 = CGColorCreate(colorSpace, colVals2);
		circleLayer1.backgroundColor = col1;
		circleLayer2.backgroundColor = col2;
		
		CGColorSpaceRelease(colorSpace);
		CGColorRelease(col1); 
		CGColorRelease(col2);
		

    }
    return self;
}

- (void)dealloc {
	
	[_touchMeterView release];
    [super dealloc];
}

- (void)addToView:(UIView *)value {
	
	[value addSubview: _touchMeterView];
	[self positionAtBottom];
}

- (void)positionAtBottom {

	CGRect parentFrame = _touchMeterView.superview.frame;
	CGRect childFrame = _touchMeterView.frame;
	NSLog(@"ParentFrame is %@", NSStringFromCGRect(parentFrame));

	childFrame.origin.x = 0;
	childFrame.origin.y = 0;
	_touchMeterView.frame = childFrame;
}

- (void)touch:(NSUInteger)value {
	// Disable actions, else the layer will move to the wrong place and then back!

    [CATransaction flush];
    [CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	CALayer *rootLayer = _touchMeterView.layer;
	CALayer *circleLayer = [[rootLayer sublayers] objectAtIndex:value];
	circleLayer.opacity = 1.0f;
    [CATransaction commit];
	circleLayer.opacity = 0.0f;
}



@end
