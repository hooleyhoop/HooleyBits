//
//  RadialView.h
//  SpokeDiagram
//
//  Created by steve hooley on 20/10/2008.
//  Copyright 2008 BestBefore Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RadialView : NSView {

	float numberOfColums;
	float driveSideTensions[18], nonDriveSideTension[18];
	int driveSideAdjustments[18], nonDriveSideAdjustments[18];
    float minValue, maxValue;

}

@end
