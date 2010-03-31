//
//  SH2dBezierPt.h
//  SHGeometryKit
//
//  Created by Steven Hooley on 06/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class G3DTuple2d;

@interface SH2dBezierPt : NSObject {

		G3DTuple2d* _bPoint;
		G3DTuple2d* _cntrlPoint;
		BOOL _curvePoint;
		BOOL _linePoint;
}


#pragma mark -
#pragma mark class methods
+ (SH2dBezierPt*) bezPtWithBasePt:(G3DTuple2d *)aTuple;
+ (SH2dBezierPt*) bezPtWithBasePt:(G3DTuple2d *)aTuple1 CntrlPt:(G3DTuple2d *)aTuple2;

#pragma mark init methods
- (SH2dBezierPt*)initWithBasePt:(G3DTuple2d *)aTuple;
- (SH2dBezierPt*)initWithBasePt:(G3DTuple2d *)aTuple CntrlPt:(G3DTuple2d *)aTuple;

- (SH2dBezierPt*)initWithBpX:(double)x1 bpY:(double)y1;
- (SH2dBezierPt*)initWithBpX:(double)x1 bpY:(double)y1 cntrlPtX:(double)x2 cntrlPtY:(double)y2;

#pragma mark accessor methods
- (BOOL) isEqualToBezierPt:(SH2dBezierPt*)pt;

#pragma mark accessor methods
- (G3DTuple2d *)bPoint;
- (void)setBPoint:(G3DTuple2d *)value;

- (G3DTuple2d *)cntrlPoint;
- (void)setCntrlPoint:(G3DTuple2d *)value;

- (BOOL)curvePoint;
- (BOOL)linePoint;


@end