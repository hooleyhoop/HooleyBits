//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DVector4d
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
// $Id: G3DVector4d.m,v 1.2 2002/10/20 09:20:11 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DVector4d.h"

#import "G3DFunctions.h"
#import "G3DDefs.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

@implementation G3DVector4d

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)initWithVector:(G3DVector4d *)vec
{
  if ((self = [super initWithX:[vec x] y:[vec y] z:[vec z] w:[vec w]])) {
  }
  return self;
}

//-----------------------------------------------------------------------------
// Math
//-----------------------------------------------------------------------------

- (G3DVector4d *)vectorByAdding:(G3DVector4d *)aVector
{
  G3DVector4d *newVector = [[G3DVector4d alloc] initWithVector:self];
  [newVector addTuple4d:aVector];
  return [newVector autorelease];
}

- (G3DVector4d *)vectorBySubtracting:(G3DVector4d *)aVector
{
  G3DVector4d *newVector = [[G3DVector4d alloc] initWithVector:self];
  [newVector subTuple4d:aVector];
  return [newVector autorelease];
}

- (G3DVector4d *)vectorByMultiplyingBy:(double)aScalar
{
  G3DVector4d *newVector = [[G3DVector4d alloc] initWithVector:self];
  [newVector multiplyBy:aScalar];
  return [newVector autorelease];
}

- (G3DVector4d *)vectorByDividingBy:(double)aScalar
{
  G3DVector4d *newVector = [[G3DVector4d alloc] initWithVector:self];
  [newVector divideBy:aScalar];
  return [newVector autorelease];
}

- (double)dotProduct:(G3DVector4d *)aVec
{
  const double *b = [aVec elements];

  return (_tuple[0] * b[0] + _tuple[1] * b[1] + _tuple[2] * b[2] + _tuple[3] * b[3]); 
}

- (double)length
{
  return G3DLength4dv(_tuple);
}

- (double)squaredLength
{
  return (_tuple[0] * _tuple[0] + _tuple[1] * _tuple[1] + _tuple[2] * _tuple[2] + _tuple[3] * _tuple[3]);
}

- (void)normalise
{
  G3DNormalise4dv(_tuple,_tuple);
}

- (G3DVector4d *)normalisedVector
{
  double t[4];

  G3DNormalise4dv(t,_tuple);

  return [[[G3DVector4d alloc] initWithElements:t] autorelease];
}

@end






