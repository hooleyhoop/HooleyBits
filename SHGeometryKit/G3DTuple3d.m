//-----------------------------------------------------------------------------
// Project            	RenderKit
// Class		G3DTuple3d
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
// $Id: G3DTuple3d.m,v 1.3 2002/10/20 09:20:11 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DTuple3d.h"
#import "G3DFunctions.h"
#import "G3DDefs.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

NSString *G3DTuple3dException = @"G3DTuple3dException";

@implementation G3DTuple3d

//-----------------------------------------------------------------------------
// Class methods
//-----------------------------------------------------------------------------

static Class NSArrayClass;
static Class NSMutableArrayClass;
static Class NSStringClass;

+ (void)initialize
{
  if (self == [G3DTuple3d class]) {
    NSStringClass = [NSString class];
    NSArrayClass  = [NSArray class];
    NSMutableArrayClass  = [NSMutableArray class];
  }
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)init
{
  return [self initWithX:0.0 y:0.0 z:0.0];
}

- (id)initWithElements:(const double *)vals
{
  return [self initWithX:vals[0] y:vals[1] z:vals[2]];
}

- (id)initWithX:(double)x y:(double)y z:(double)z
{
  if ((self = [super init])) {
    _tuple[0] = x;
    _tuple[1] = y;
    _tuple[2] = z;
  }
  return self;
}

- (id)initWithTuple:(G3DTuple3d *)aTuple
{
  return [self initWithX:[aTuple x] y:[aTuple y] z:[aTuple z]];
}

//-----------------------------------------------------------------------------
// Math
//-----------------------------------------------------------------------------

- (void)absolute
{
  _tuple[0] = ABS(_tuple[0]);
  _tuple[1] = ABS(_tuple[1]);
  _tuple[2] = ABS(_tuple[2]);
}

- (void)clamp
{
  _tuple[0] = CLAMP(_tuple[0],0.0,1.0);
  _tuple[1] = CLAMP(_tuple[1],0.0,1.0);
  _tuple[2] = CLAMP(_tuple[2],0.0,1.0);
}

- (void)clampLow:(double)low high:(double)high
{
  if (low > high) {
    double tmp = low;
    low = high;
    high = tmp;
  }
  _tuple[0] = CLAMP(_tuple[0],low,high);
  _tuple[1] = CLAMP(_tuple[1],low,high);
  _tuple[2] = CLAMP(_tuple[2],low,high);
}

- (void)addTuple3d:(G3DTuple3d *)aTuple
{
  const double *tmp = [aTuple elements];

  _tuple[0] += tmp[0];
  _tuple[1] += tmp[1];
  _tuple[2] += tmp[2];
}

- (void)subTuple3d:(G3DTuple3d *)aTuple
{
  const double *tmp = [aTuple elements];

  _tuple[0] -= tmp[0];
  _tuple[1] -= tmp[1];
  _tuple[2] -= tmp[2];
}

- (void)multiplyBy:(double)aScalar
{
  _tuple[0] *= aScalar;
  _tuple[1] *= aScalar;
  _tuple[2] *= aScalar;
}

- (void)divideBy:(double)aScalar
{
  double tmp;

  if (aScalar == 0.0) {
    [NSException raise:G3DTuple3dException format:@"Division by zero!"];
  }

  tmp = 1.0 / aScalar;
    
  _tuple[0] *= tmp;
  _tuple[1] *= tmp;
  _tuple[2] *= tmp;
}

- (void)interpolateBetween:(G3DTuple3d *)first and:(G3DTuple3d *)second factor:(double)factor
{
  double ifac = 1 - factor;
  const double *a = [first elements];
  const double *b = [second elements];

  _tuple[0] = ifac*a[0] + factor*b[0];
  _tuple[1] = ifac*a[0] + factor*b[0];
  _tuple[2] = ifac*a[0] + factor*b[0];
}

- (void)negate
{
  _tuple[0] *= -1.0;
  _tuple[1] *= -1.0;
  _tuple[2] *= -1.0;
}

- (BOOL)isEqualToTuple:(id)aTuple
{
  if ([aTuple isKindOfClass:[G3DTuple3d class]]) 
  {
    if( _tuple[0] == [aTuple x] 
        && _tuple[1] == [aTuple y] 
        && _tuple[2] == [aTuple z]) 
    {
      return YES;
    }
  }
  return NO;
}

//-----------------------------------------------------------------------------
// Accessing
//-----------------------------------------------------------------------------

- (const double *)elements
{
  return (const double *)_tuple;
}

- (void)setElements:(const double *)values
{
  G3DCopyVector3dv(_tuple,values);
}

- (void)getElements:(double *)values
{
  G3DCopyVector3dv(values,_tuple);
}

- (double)x
{
  return _tuple[0];
}

- (void)setX:(double)x
{
  _tuple[0] = x;
}

- (double)y
{
  return _tuple[1];
}

- (void)setY:(double)y
{
  _tuple[1] = y;
}

- (double)z
{
  return _tuple[2];
}

- (void)setZ:(double)z
{
  _tuple[2] = z;
}

- (void)setValuesWithTuple:(G3DTuple3d *)aTuple
{
  const double *tmp = [aTuple elements];
 
  _tuple[0] = tmp[0];
  _tuple[1] = tmp[1];
  _tuple[2] = tmp[2];
}

- (NSString *)description
{
  return [NSStringClass stringWithFormat:@"<%@ %x %x>: x = %f, y = %f, z = %f",[self class],self,[NSThread currentThread],_tuple[0],_tuple[1],_tuple[2]];
}

//-----------------------------------------------------------------------------
// NSCoding
//-----------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeArrayOfObjCType:@encode(double) count:3 at:_tuple];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
  self = [super init];
  [aCoder decodeArrayOfObjCType:@encode(double) count:3 at:_tuple];
  return self;
}

//-----------------------------------------------------------------------------
// NSCopying
//-----------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
  return [[[self class] allocWithZone:zone] initWithTuple:self];
}

@end






