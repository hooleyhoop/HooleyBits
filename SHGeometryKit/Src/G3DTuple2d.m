//-----------------------------------------------------------------------------
// Project            	RenderKit
// Class				G3DTuple2d
// Creator            	Philippe C.D. Robert
// Maintainer         	Philippe C.D. Robert
// Creation Date      	Thu Sep  9 11:05:08 CEST 1999
//
// Copyright (c) Philippe C.D. Robert
//
// The SHGeometryKit is free software; you can redistribute it and/or modify it 
// under the terms of the GNU LGPL Version 2 as published by the Free 
// Software Foundation
//
// $Id: G3DTuple2d.m,v 1.3 2002/10/20 09:20:11 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DTuple2d.h"

#import "G3DFunctions.h"
#import "G3DDefs.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

NSString *G3DTuple2dException = @"G3DTuple2dException";

@implementation G3DTuple2d


+ (id)tupleWithX:(CGFloat)x y:(CGFloat)y {
	return [[[G3DTuple2d alloc] initWithX:x y:y] autorelease];
}

- (id)init {
  return [self initWithX:0.0 y:0.0];
}

- (id)initWithElements:(const double *)vals {
  return [self initWithX:vals[0] y:vals[1]];
}

- (id)initWithX:(CGFloat)x y:(CGFloat)y {
  if ((self = [super init])) {
    _tuple[0] = x;
    _tuple[1] = y;
  }
  return self;
}

- (id)initWithTuple:(G3DTuple2d *)aTuple {
  return [self initWithX:[aTuple x] y:[aTuple y]];
}

- (void)absolute {
  _tuple[0] = ABS(_tuple[0]);
  _tuple[1] = ABS(_tuple[1]);
}

- (void)clamp {
  _tuple[0] = CLAMP(_tuple[0],0.0,1.0);
  _tuple[1] = CLAMP(_tuple[1],0.0,1.0);
}

- (void)clampLow:(CGFloat)low high:(CGFloat)high {
  if (low > high) {
    double tmp = low;
    low = high;
    high = tmp;
  }
  _tuple[0] = CLAMP(_tuple[0],low,high);
  _tuple[1] = CLAMP(_tuple[1],low,high);
}

- (void)addTuple2d:(G3DTuple2d *)aTuple {
  const double *tmp = [aTuple elements];

  _tuple[0] += tmp[0];
  _tuple[1] += tmp[1];
}

- (void)translateByX:(CGFloat)x byY:(CGFloat)y {
  _tuple[0] += x;
  _tuple[1] += y;
}


- (void)subTuple2d:(G3DTuple2d *)aTuple {
  const double *tmp = [aTuple elements];

  _tuple[0] -= tmp[0];
  _tuple[1] -= tmp[1];
}

- (void)multiplyBy:(CGFloat)aScalar {
  _tuple[0] *= aScalar;
  _tuple[1] *= aScalar;
}

- (void)divideBy:(CGFloat)aScalar {
  double tmp;
  
  if (aScalar == 0.0) {
    [NSException raise:G3DTuple2dException format:@"Division by zero!"];
  }
  
  tmp = 1.0 / aScalar;
  
  _tuple[0] *= tmp;
  _tuple[1] *= tmp;
}


- (void)interpolateBetween:(G3DTuple2d *)first and:(G3DTuple2d *)second factor:(CGFloat)factor {
  double ifac = 1 - factor;
  const double *a = [first elements];
  const double *b = [second elements];

  _tuple[0] = ifac*a[0] + factor*b[0];
  _tuple[1] = ifac*a[0] + factor*b[0];
}

- (BOOL)ispointX:(CGFloat)x py:(CGFloat)y withDistX:(CGFloat)mx distX:(CGFloat)my {
	//NSLog(@"point is [%f, %f], we are [%f, %f]", x, y, _tuple[0], _tuple[1]);
	NSPoint p  = NSMakePoint(x, y);
	NSRect r = NSMakeRect( _tuple[0]-mx, _tuple[1]-my, mx*2, my*2);
	return NSPointInRect(p,r);
}

- (void)negate {
  _tuple[0] *= -1.0;
  _tuple[1] *= -1.0;
}

- (BOOL)isEqualToTuple:(id)aTuple {
  if ([aTuple isKindOfClass:[G3DTuple2d class]]) 
  {
	  BOOL equalX = G3DCompareFloat( _tuple[0], [aTuple x], 0.001f)==0;
	  BOOL equalY = G3DCompareFloat( _tuple[1], [aTuple y], 0.001f)==0;
	  
    if( equalX && equalY ) {
      return YES;
    }
  }
  return NO;
}

- (const double *)elements {
  return (const double*)_tuple;
}

- (void)setElements:(const double *)values {
  G3DCopyVector2dv(_tuple,values);
}

- (void)getElements:(double *)values {
  G3DCopyVector2dv(values,_tuple);
}

- (CGFloat)x {
  return _tuple[0];
}

- (void)setX:(CGFloat)x {
  _tuple[0] = x;
}

- (CGFloat)y {
  return _tuple[1];
}

- (void)setY:(CGFloat)y {
  _tuple[1] = y;
}

- (void)setValuesWithTuple:(G3DTuple2d *)aTuple {
  const double *tmp = [aTuple elements];
 
  _tuple[0] = tmp[0];
  _tuple[1] = tmp[1];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ %x %x>: x = %f, y = %f",[self class],self,[NSThread currentThread],_tuple[0],_tuple[1]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeArrayOfObjCType:@encode(CGFloat) count:2 at:_tuple];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  self = [super init];
  [aCoder decodeArrayOfObjCType:@encode(CGFloat) count:2 at:_tuple];
  return self;
}


- (id)copyWithZone:(NSZone *)zone {
  return [[[self class] allocWithZone:zone] initWithTuple:self];
}

@end
