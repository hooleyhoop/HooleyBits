//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DQuaternionf
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
// $Id: G3DQuaternionf.m,v 1.3 2002/10/20 11:14:27 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DQuaternionf.h"

#import "G3DMatrix3f.h"
#import "G3DMatrix4f.h"
#import "G3DVector3f.h"
#import "G3DTuple4f.h"

#import "G3DDefs.h"
#import "G3DQuatFunc.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

NSString *G3DQuaternionfException = @"G3DQuaternionfException";

@implementation G3DQuaternionf

//-----------------------------------------------------------------------------
// class methods
//-----------------------------------------------------------------------------

static Class G3DTuple4fClass;
static Class G3DMatrix4fClass;
static Class G3DMatrix3fClass;

+ (void)initialize
{
  if (self == [G3DQuaternionf class]) {
    G3DTuple4fClass  = [G3DTuple4f class];
    G3DMatrix4fClass  = [G3DMatrix4f class];
    G3DMatrix3fClass  = [G3DMatrix3f class];
  }
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)init
{
  if ((self = [super initWithX:0.0 y:0.0 z:0.0 w:1.0])) {
  }
  return self;
}

- (id)initWithElements:(const float *)values
{
  if ((self = [self init])) {
    G3DCopyVector4fv(_tuple,values);
  }
  return self;
}

- (id)initWithQuaternion:(G3DQuaternionf *)aTuple
{
  if ((self = [self init])) {
    G3DCopyVector4fv(_tuple,[aTuple elements]);
  }
  return self;
}

- (id)initWithMatrix4f:(G3DMatrix4f *)aMatrix
{
  if ((self = [self init])) {
    G3DQuatFromMatrixf(_tuple,[aMatrix elements]);
  }
  return self;
}

- (id)initWithEulerRep:(float *)ev
{
  if ((self = [self init])) {
    G3DQuatFromEulerRepf(_tuple,ev);
  }
  return self;
}

//-----------------------------------------------------------------------------
// Math
//-----------------------------------------------------------------------------

- (float)norm
{
  return (_tuple[0]*_tuple[0] + 
          _tuple[1]*_tuple[1] + 
          _tuple[2]*_tuple[2] + 
          _tuple[3]*_tuple[3]);
}

- (void)conjugate
{
  _tuple[0] = -_tuple[0];
  _tuple[1] = -_tuple[1];
  _tuple[2] = -_tuple[2];
}

- (G3DQuaternionf *)conjugatedQuaternion
{
  G3DQuaternionf *tmp = [[G3DQuaternionf alloc] initWithQuaternion:self];

  [tmp conjugate];
  
  return [tmp autorelease];
}

- (void)invert
{
  register float sql = _tuple[0]*_tuple[0] + 
                       _tuple[1]*_tuple[1] + 
                       _tuple[2]*_tuple[2] + 
                       _tuple[3]*_tuple[3];

  if (sql != 0.0) {
    sql = 1.0/sql;
  }
  else {
    sql = 1.0;
  }

  _tuple[0] *= -sql;
  _tuple[1] *= -sql;
  _tuple[2] *= -sql;
  _tuple[3] *=  sql;
}

- (G3DQuaternionf *)invertedQuaternion
{
  G3DQuaternionf *tmp = [[G3DQuaternionf alloc] initWithQuaternion:self];

  [tmp invert];
  return [tmp autorelease];
}

- (void)normalise
{
  register float sql = _tuple[0]*_tuple[0] + 
                       _tuple[1]*_tuple[1] + 
                       _tuple[2]*_tuple[2] + 
                       _tuple[3]*_tuple[3];
  
  if (sql > 0.0) {
    sql = (1.0/ sqrt(sql));

    _tuple[0] *= sql;
    _tuple[1] *= sql;
    _tuple[2] *= sql;
    _tuple[3] *= sql;
  }
}

- (G3DQuaternionf *)normalisedQuaternion
{
  G3DQuaternionf *tmp = [[G3DQuaternionf alloc] initWithQuaternion:self];

  [tmp normalise];
  return [tmp autorelease];
}

- (void)interpolate:(G3DQuaternionf *)quat factor:(const float)val
{
  float tmp[4];
  const float *to = [quat elements];

  G3DInterpolateQuatf(tmp,_tuple,to,val);
  G3DCopyVector4fv(_tuple,tmp);
}

- (void)multiplyByQuaternion:(G3DQuaternionf *)aQuat
{
  const float *a = [aQuat elements];

  G3DMultiplyQuatf(_tuple, _tuple, a);
}

- (void)multiplyByQuaternion:(G3DQuaternionf *)quatA and:(G3DQuaternionf *)quatB
{
  const float *a = [quatA elements];
  const float *b = [quatB elements];

  G3DMultiplyQuatf(_tuple, a, b);
}

- (void)multiplyByInvertedQuaternion:(G3DQuaternionf *)aQuat
{
  [self multiplyByQuaternion:[aQuat invertedQuaternion]];
}

- (void)multiplyByQuaternion:(G3DQuaternionf *)a andInverted:(G3DQuaternionf *)b
{
  [self multiplyByQuaternion:a and:[b invertedQuaternion]];
}

- (void)multiplyByScalar:(float)value
{
  _tuple[0] *= value;
  _tuple[1] *= value;
  _tuple[2] *= value;
  _tuple[3] *= value;
}

- (void)addQuaternion:(G3DQuaternionf *)aQuat
{
  const float *t = [aQuat elements];

  _tuple[0] += t[0];
  _tuple[1] += t[1];
  _tuple[2] += t[2];
  _tuple[3] += t[3];
}

- (void)subQuaternion:(G3DQuaternionf *)aQuat
{
  const float *t = [aQuat elements];

  _tuple[0] -= t[0];
  _tuple[1] -= t[1];
  _tuple[2] -= t[2];
  _tuple[3] -= t[3];
}

- (void)rotateByAngle:(const float)angle axis:(G3DVector3f *)aVec
{
  float tmp[4];
  const float *v = [aVec elements];
  float *a = _tuple;
  float *b = tmp;

  G3DCopyVector4f(tmp,v[0],v[1],v[2],angle);
  G3DMultiplyQuatf(_tuple, a, b);

  [self normalise];
}

//-----------------------------------------------------------------------------
// Accessor methods
//-----------------------------------------------------------------------------

- (void)setQuaternionWithMatrix4f:(G3DMatrix4f *)m
{
  const float *mat = [m elements];

  G3DQuatFromMatrixf(_tuple,mat);
}

- (G3DMatrix4f *)rotationMatrix4f
{
  float m[16];

  G3DMatrixFromQuatf(m,_tuple);

  return [[[G3DMatrix4fClass alloc] initWithElements:(const float*)m] autorelease];
}

- (G3DMatrix3f *)rotationMatrix3f
{
  float m[9];

  float x2x = _tuple[0] * (_tuple[0] + _tuple[0]);
  float x2y = _tuple[0] * (_tuple[1] + _tuple[1]);
  float x2z = _tuple[0] * (_tuple[2] + _tuple[2]);

  float w2x = _tuple[3] * (_tuple[0] + _tuple[0]);
  float w2y = _tuple[3] * (_tuple[1] + _tuple[1]);
  float w2z = _tuple[3] * (_tuple[2] + _tuple[2]);

  float y2y = _tuple[1] * (_tuple[1] + _tuple[1]);
  float y2z = _tuple[1] * (_tuple[2] + _tuple[2]);
  float z2z = _tuple[2] * (_tuple[2] + _tuple[2]);

  G3DCopyVector3f(m, 1.0-(y2y+z2z), x2y-w2z, x2z+w2y);
  G3DCopyVector3f(m+3, x2y+w2z, 1.0-(x2x+z2z), y2z-w2x);
  G3DCopyVector3f(m+6, x2z-w2y, y2z+w2x, 1.0-(x2x+y2y));

  return [[[G3DMatrix3fClass alloc] initWithElements:(const float*)m] autorelease];
}

- (void)setQuaternion:(G3DQuaternionf *)q
{
  [super setValuesWithTuple:q];
}

- (void)setVector:(G3DVector3f *)vec angle:(float)val
{
  const float *tmp = [vec elements];

  G3DQuatFromAngleAxisf(_tuple,val,tmp);
}

- (G3DTuple4f *)angleAxisRepresentation
{
  float angleAxis[4];

  G3DAngleAxisFromQuatf(angleAxis,angleAxis,_tuple);

  return [[[G3DTuple4fClass alloc] initWithElements:(const float*)angleAxis] autorelease];
}

@end






