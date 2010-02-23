//-----------------------------------------------------------------------------
// Project            	RenderKit
// Class		G3DTuple2f
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
// $Id: G3DTuple2f.m,v 1.3 2002/10/20 09:20:11 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DTuple2f.h"
#import "G3DFunctions.h"
#import "G3DDefs.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

NSString *G3DTuple2fException = @"G3DTuple2fException";

@implementation G3DTuple2f

//-----------------------------------------------------------------------------
// Class methods
//-----------------------------------------------------------------------------

static Class NSArrayClass;
static Class NSMutableArrayClass;
static Class NSStringClass;

+ (void)initialize
{
  if (self == [G3DTuple2f class]) {
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
  return [self initWithX:0.0 y:0.0];
}

- (id)initWithElements:(const float *)vals
{
  return [self initWithX:vals[0] y:vals[1]];
}

- (id)initWithX:(float)x y:(float)y
{
  if ((self = [super init])) {
    _tuple[0] = x;
    _tuple[1] = y;
  }
  return self;
}

- (id)initWithTuple:(G3DTuple2f *)aTuple
{
  return [self initWithX:[aTuple x] y:[aTuple y]];
}

//-----------------------------------------------------------------------------
// Math
//-----------------------------------------------------------------------------

- (void)absolute
{
  _tuple[0] = ABS(_tuple[0]);
  _tuple[1] = ABS(_tuple[1]);
}

- (void)clamp
{
  _tuple[0] = CLAMP(_tuple[0],0.0,1.0);
  _tuple[1] = CLAMP(_tuple[1],0.0,1.0);
}

- (void)clampLow:(float)low high:(float)high
{
  if (low > high) {
    float tmp = low;
    low = high;
    high = tmp;
  }
  _tuple[0] = CLAMP(_tuple[0],low,high);
  _tuple[1] = CLAMP(_tuple[1],low,high);
}

- (void)addTuple2f:(G3DTuple2f *)aTuple
{
  const float *tmp = [aTuple elements];

  _tuple[0] += tmp[0];
  _tuple[1] += tmp[1];
}

- (void)subTuple2f:(G3DTuple2f *)aTuple
{
  const float *tmp = [aTuple elements];

  _tuple[0] -= tmp[0];
  _tuple[1] -= tmp[1];
}

- (void)multiplyBy:(float)aScalar
{
  _tuple[0] *= aScalar;
  _tuple[1] *= aScalar;
}

- (void)divideBy:(float)aScalar
{
  float tmp;

  if (aScalar == 0.0) {
    [NSException raise:G3DTuple2fException format:@"Division by zero!"];
  }

  tmp = 1.0 / aScalar;
    
  _tuple[0] *= tmp;
  _tuple[1] *= tmp;
}

- (void)interpolateBetween:(G3DTuple2f *)first and:(G3DTuple2f *)second factor:(float)factor
{
  float ifac = 1 - factor;
  const float *a = [first elements];
  const float *b = [second elements];

  _tuple[0] = ifac*a[0] + factor*b[0];
  _tuple[1] = ifac*a[0] + factor*b[0];
}

- (void)negate
{
  _tuple[0] *= -1.0;
  _tuple[1] *= -1.0;
}

- (BOOL)isEqualToTuple:(id)aTuple
{
  if ([aTuple isKindOfClass:[G3DTuple2f class]]) {
    if (_tuple[0] == [aTuple x] && _tuple[1] == [aTuple y]) {
      return YES;
    }
  }
  return NO;
}

//-----------------------------------------------------------------------------
// Accessing
//-----------------------------------------------------------------------------

- (const float *)elements
{
  return (const float *)_tuple;
}

- (void)setElements:(const float *)values
{
  G3DCopyVector2fv(_tuple,values);
}

- (void)getElements:(float *)values
{
  G3DCopyVector2fv(values,_tuple);
}

- (float)x
{
  return _tuple[0];
}

- (void)setX:(float)x
{
  _tuple[0] = x;
}

- (float)y
{
  return _tuple[1];
}

- (void)setY:(float)y
{
  _tuple[1] = y;
}

- (void)setValuesWithTuple:(G3DTuple2f *)aTuple
{
  const float *tmp = [aTuple elements];
 
  _tuple[0] = tmp[0];
  _tuple[1] = tmp[1];
}

- (NSString *)description
{
  return [NSStringClass stringWithFormat:@"<%@ %x %x>: x = %f, y = %f",[self class],self,[NSThread currentThread],_tuple[0],_tuple[1]];
}

//-----------------------------------------------------------------------------
// NSCoding
//-----------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeArrayOfObjCType:@encode(float) count:2 at:_tuple];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
  self = [super init];
  [aCoder decodeArrayOfObjCType:@encode(float) count:2 at:_tuple];
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






