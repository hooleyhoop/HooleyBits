//
//  SH2dBezierPt.m
//  SHGeometryKit
//
//  Created by Steven Hooley on 06/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SH2dBezierPt.h"
#import "G3DTuple2d.h"

@implementation SH2dBezierPt


#pragma mark -
#pragma mark class methods
//=========================================================== 
// - bezPtWithBasePt:
//=========================================================== 
+ (SH2dBezierPt*) bezPtWithBasePt:(G3DTuple2d *)aTuple
{
	return [[[SH2dBezierPt alloc] initWithBasePt:aTuple] autorelease];
}


//=========================================================== 
// - bezPtWithBasePt: CntrlPt:
//=========================================================== 
+ (SH2dBezierPt*) bezPtWithBasePt:(G3DTuple2d *)aTuple1 CntrlPt:(G3DTuple2d *)aTuple2
{
	return [[[SH2dBezierPt alloc] initWithBasePt:aTuple1 CntrlPt:aTuple2] autorelease];
}

#pragma mark init methods
//=========================================================== 
// - init:
//=========================================================== 
- (SH2dBezierPt*)init
{
  return [self initWithBpX:0.0 bpY:0.0];
}

//=========================================================== 
// - initWithBasePt:
//=========================================================== 
- (SH2dBezierPt*)initWithBasePt:(G3DTuple2d *)aTuple
{
  return [self initWithBpX:[aTuple x] bpY:[aTuple y]];
}

//=========================================================== 
// - initWithBasePt: CntrlPt:
//=========================================================== 
- (SH2dBezierPt*)initWithBasePt:(G3DTuple2d *)aTuple1 CntrlPt:(G3DTuple2d *)aTuple2
{
  return [self initWithBpX:[aTuple1 x] bpY:[aTuple1 y] cntrlPtX:[aTuple2 x] cntrlPtY:[aTuple2 y] ];
}

//=========================================================== 
// - initWithBpX: bpY:
//=========================================================== 
- (SH2dBezierPt*)initWithBpX:(double)x1 bpY:(double)y1
{
  return [self initWithBpX:x1 bpY:y1 cntrlPtX:MAXFLOAT cntrlPtY:MAXFLOAT];
}

// designated initializer
//=========================================================== 
// - initWithBpX: bpY: cntrlPtX: cntrlPtY:
//=========================================================== 
- (SH2dBezierPt*)initWithBpX:(double)x1 bpY:(double)y1 cntrlPtX:(double)x2 cntrlPtY:(double)y2
{
	if(self=[super init])
	{
		[self setBPoint:[G3DTuple2d tupleWithX:x1 y:y1]];
		[self setCntrlPoint:[G3DTuple2d tupleWithX:x2 y:y2]];
		if(x2!=MAXFLOAT && y2!=MAXFLOAT){
			_curvePoint=YES;
			_linePoint=NO;
		} else {
			_curvePoint=NO;
			_linePoint=YES;			
		}
	}
	return self;
}


#pragma mark action methods
//=========================================================== 
// - isEqualToBezierPt
//=========================================================== 
- (BOOL) isEqualToBezierPt:(SH2dBezierPt*)pt
{
	if([_bPoint isEqualToTuple:[pt bPoint]])
	{
		if(_curvePoint==[pt curvePoint]){
			if([_cntrlPoint isEqualToTuple:[pt cntrlPoint]]) {
				return YES;
			}
		}
	}
	return NO;
}


#pragma mark NSCopying methods
//=========================================================== 
// - copyWithZone
//=========================================================== 
- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] allocWithZone: zone] initWithBasePt:_bPoint CntrlPt:_cntrlPoint ];
    return copy;
}

#pragma mark accessor methods
//=========================================================== 
// - bPoint
//=========================================================== 
- (G3DTuple2d *)bPoint {
    return _bPoint;
}

//=========================================================== 
// - setBPoint
//=========================================================== 
- (void)setBPoint:(G3DTuple2d *)value {
    if (_bPoint != value) {
		[value retain];
        [_bPoint release];
        _bPoint = value;
    }
}

//=========================================================== 
// - cntrlPoint
//=========================================================== 
- (G3DTuple2d *)cntrlPoint {
    return _cntrlPoint;
}

//=========================================================== 
// - setCntrlPoint
//=========================================================== 
- (void)setCntrlPoint:(G3DTuple2d *)value {
    if (_cntrlPoint != value) {
		[value retain];
        [_cntrlPoint release];
        _cntrlPoint = value ;
    }
}

//=========================================================== 
// - linePoint
//=========================================================== 
- (BOOL)linePoint {
    return _linePoint;
}

//=========================================================== 
// - curvePoint
//=========================================================== 
- (BOOL)curvePoint {
    return _curvePoint;
}






		
@end



