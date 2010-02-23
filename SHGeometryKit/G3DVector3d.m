//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DVector3d
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
// $Id: G3DVector3d.m,v 1.2 2002/10/20 09:20:11 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DVector3d.h"

#import "G3DFunctions.h"
#import "G3DDefs.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

@implementation G3DVector3d

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)initWithVector:(G3DVector3d *)vec
{
  if ((self = [super initWithX:[vec x] y:[vec y] z:[vec z]])) {
  }
  return self;
}

//-----------------------------------------------------------------------------
// Math
//-----------------------------------------------------------------------------

- (G3DVector3d *)vectorByAdding:(G3DVector3d *)aVector
{
  G3DVector3d* newVector = [[G3DVector3d alloc] initWithVector:self];
  [newVector addTuple3d:aVector];
  return [newVector autorelease];
}

- (G3DVector3d *)vectorBySubtracting:(G3DVector3d *)aVector
{
  G3DVector3d* newVector = [[G3DVector3d alloc] initWithVector:self];
  [newVector subTuple3d:aVector];
  return [newVector autorelease];
}

- (G3DVector3d *)vectorByMultiplyingBy:(double)aScalar
{
  G3DVector3d* newVector = [[G3DVector3d alloc] initWithVector:self];
  [newVector multiplyBy:aScalar];
  return [newVector autorelease];
}

- (G3DVector3d *)vectorByDividingBy:(double)aScalar
{
  G3DVector3d* newVector = [[G3DVector3d alloc] initWithVector:self];
  [newVector divideBy:aScalar];
  return [newVector autorelease];
}

- (double)dotProduct:(G3DVector3d *)aVec
{
  const double *b = [aVec elements];

  return (_tuple[0] * b[0] + _tuple[1] * b[1] + _tuple[2] * b[2]); 
}

- (void)crossProductWith:(G3DVector3d *)aVec and:(G3DVector3d *)bVec
{
  const double *a = [aVec elements];
  const double *b = [bVec elements];

  _tuple[0] = a[1] * b[2] - a[2] * b[1];
  _tuple[1] = a[2] * b[0] - a[0] * b[2];
  _tuple[2] = a[0] * b[1] - a[1] * b[0];
}

- (double)length
{
  return G3DLength3dv(_tuple);
}

- (double)squaredLength
{
  return (_tuple[0] * _tuple[0] + _tuple[1] * _tuple[1] + _tuple[2] * _tuple[2]);
}

- (void)normalise
{
  G3DNormalise3dv(_tuple,_tuple);
}

- (G3DVector3d *)normalisedVector
{
  double t[3];

  G3DNormalise3dv(t,_tuple);

  return [[[G3DVector3d alloc] initWithElements:t] autorelease];
}

@end






