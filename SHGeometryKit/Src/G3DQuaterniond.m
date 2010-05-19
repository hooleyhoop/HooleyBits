//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DQuaterniond
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
// $Id: G3DQuaterniond.m,v 1.3 2002/10/20 11:14:27 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DQuaterniond.h"

#import "G3DMatrix3d.h"
#import "G3DMatrix4d.h"
#import "G3DVector3d.h"
#import "G3DTuple4d.h"

#import "G3DDefs.h"
#import "G3DQuatFunc.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

NSString *G3DQuaterniondException = @"G3DQuaterniondException";

@implementation G3DQuaterniond

//-----------------------------------------------------------------------------
// class methods
//-----------------------------------------------------------------------------

static Class G3DTuple4dClass;
static Class G3DMatrix4dClass;
static Class G3DMatrix3dClass;

+ (void)initialize
{
  if (self == [G3DQuaterniond class]) {
    G3DTuple4dClass  = [G3DTuple4d class];
    G3DMatrix4dClass  = [G3DMatrix4d class];
    G3DMatrix3dClass  = [G3DMatrix3d class];
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

- (id)initWithElements:(const double *)values
{
  if ((self = [self init])) {
    G3DCopyVector4dv(_tuple,values);
  }
  return self;
}

- (id)initWithQuaternion:(G3DQuaterniond *)aTuple
{
  if ((self = [self init])) {
    G3DCopyVector4dv(_tuple,[aTuple elements]);
  }
  return self;
}

- (id)initWithMatrix4d:(G3DMatrix4d *)aMatrix
{
  if ((self = [self init])) {
    G3DQuatFromMatrixd(_tuple,[aMatrix elements]);
  }
  return self;
}

- (id)initWithEulerRep:(double *)ev
{
  if ((self = [self init])) {
    G3DQuatFromEulerRepd(_tuple,ev);
  }
  return self;
}

//-----------------------------------------------------------------------------
// Math
//-----------------------------------------------------------------------------

- (double)norm
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

- (G3DQuaterniond *)conjugatedQuaternion
{
  G3DQuaterniond *tmp = [[G3DQuaterniond alloc] initWithQuaternion:self];

  [tmp conjugate];
  
  return [tmp autorelease];
}

- (void)invert
{
  register double sql = _tuple[0]*_tuple[0] + 
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

- (G3DQuaterniond *)invertedQuaternion
{
  G3DQuaterniond *tmp = [[G3DQuaterniond alloc] initWithQuaternion:self];

  [tmp invert];
  return [tmp autorelease];
}

- (void)normalise
{
  register double sql = _tuple[0]*_tuple[0] + 
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

- (G3DQuaterniond *)normalisedQuaternion
{
  G3DQuaterniond *tmp = [[G3DQuaterniond alloc] initWithQuaternion:self];

  [tmp normalise];
  return [tmp autorelease];
}

- (void)interpolate:(G3DQuaterniond *)quat factor:(const double)val
{
  double tmp[4];
  const double *to = [quat elements];

  G3DInterpolateQuatd(tmp,_tuple,to,val);
  G3DCopyVector4dv(_tuple,tmp);
}

- (void)multiplyByQuaternion:(G3DQuaterniond *)aQuat
{
  const double *a = [aQuat elements];

  G3DMultiplyQuatd(_tuple, _tuple, a);
}

- (void)multiplyByQuaternion:(G3DQuaterniond *)quatA and:(G3DQuaterniond *)quatB
{
  const double *a = [quatA elements];
  const double *b = [quatB elements];

  G3DMultiplyQuatd(_tuple, a, b);
}

- (void)multiplyByInvertedQuaternion:(G3DQuaterniond *)aQuat
{
  [self multiplyByQuaternion:[aQuat invertedQuaternion]];
}

- (void)multiplyByQuaternion:(G3DQuaterniond *)a andInverted:(G3DQuaterniond *)b
{
  [self multiplyByQuaternion:a and:[b invertedQuaternion]];
}

- (void)multiplyByScalar:(double)value
{
  _tuple[0] *= value;
  _tuple[1] *= value;
  _tuple[2] *= value;
  _tuple[3] *= value;
}

- (void)addQuaternion:(G3DQuaterniond *)aQuat
{
  const double *t = [aQuat elements];

  _tuple[0] += t[0];
  _tuple[1] += t[1];
  _tuple[2] += t[2];
  _tuple[3] += t[3];
}

- (void)subQuaternion:(G3DQuaterniond *)aQuat
{
  const double *t = [aQuat elements];

  _tuple[0] -= t[0];
  _tuple[1] -= t[1];
  _tuple[2] -= t[2];
  _tuple[3] -= t[3];
}

- (void)rotateByAngle:(const double)angle axis:(G3DVector3d *)aVec
{
  double tmp[4];
  const double *v = [aVec elements];
  double *a = _tuple;
  double *b = tmp;

  G3DCopyVector4d(tmp,v[0],v[1],v[2],angle);
  G3DMultiplyQuatd(_tuple, a, b);

  [self normalise];
}

//-----------------------------------------------------------------------------
// Accessor methods
//-----------------------------------------------------------------------------

- (void)setQuaternionWithMatrix4d:(G3DMatrix4d *)m
{
  const double *mat = [m elements];

  G3DQuatFromMatrixd(_tuple,mat);
}

- (G3DMatrix4d *)rotationMatrix4d
{
  double m[16];

  G3DMatrixFromQuatd(m,_tuple);

  return [[[G3DMatrix4dClass alloc] initWithElements:(const double*)m] autorelease];
}

- (G3DMatrix3d *)rotationMatrix3d
{
  double m[9];

  double x2x = _tuple[0] * (_tuple[0] + _tuple[0]);
  double x2y = _tuple[0] * (_tuple[1] + _tuple[1]);
  double x2z = _tuple[0] * (_tuple[2] + _tuple[2]);

  double w2x = _tuple[3] * (_tuple[0] + _tuple[0]);
  double w2y = _tuple[3] * (_tuple[1] + _tuple[1]);
  double w2z = _tuple[3] * (_tuple[2] + _tuple[2]);

  double y2y = _tuple[1] * (_tuple[1] + _tuple[1]);
  double y2z = _tuple[1] * (_tuple[2] + _tuple[2]);
  double z2z = _tuple[2] * (_tuple[2] + _tuple[2]);

  G3DCopyVector3d(m, 1.0-(y2y+z2z), x2y-w2z, x2z+w2y);
  G3DCopyVector3d(m+3, x2y+w2z, 1.0-(x2x+z2z), y2z-w2x);
  G3DCopyVector3d(m+6, x2z-w2y, y2z+w2x, 1.0-(x2x+y2y));

  return [[[G3DMatrix3dClass alloc] initWithElements:(const double*)m] autorelease];
}

- (void)setQuaternion:(G3DQuaterniond *)q
{
  [super setValuesWithTuple:q];
}

- (void)setVector:(G3DVector3d *)vec angle:(double)val
{
  const double *tmp = [vec elements];

  G3DQuatFromAngleAxisd(_tuple,val,tmp);
}

- (G3DTuple4d *)angleAxisRepresentation
{
  double angleAxis[4];

  G3DAngleAxisFromQuatd(angleAxis,angleAxis,_tuple);

  return [[[G3DTuple4dClass alloc] initWithElements:(const double*)angleAxis] autorelease];
}

@end






