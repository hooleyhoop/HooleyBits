//
//  TouchMeter.h
//  iphonePlay
//
//  Created by steve hooley on 29/05/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHooleyObject.h"

@interface TouchMeter : SHooleyObject {

	UIView *_touchMeterView;
	NSTimer *_pulsTimer;

}

+ (TouchMeter *)sharedTouchMeter;
+ (void)clean;

- (void)addToView:(UIView *)value;
- (void)positionAtBottom;

- (void)touch:(NSUInteger)value;

@end
