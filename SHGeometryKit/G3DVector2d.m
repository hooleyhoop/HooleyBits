//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DVector2d
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
// $Id: G3DVector2d.m,v 1.2 2002/10/20 09:20:11 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DVector2d.h"

#import "G3DFunctions.h"
#import "G3DDefs.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

@implementation G3DVector2d

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)initWithVector:(G3DVector2d *)vec
{
  if ((self = [super initWithX:[vec x] y:[vec y]])) {
  }
  return self;
}

//-----------------------------------------------------------------------------
// Math
//-----------------------------------------------------------------------------

- (G3DVector2d *)vectorByAdding:(G3DVector2d *)aVector
{
  G3DVector2d *newVector = [[G3DVector2d alloc] initWithVector:self];
  [newVector addTuple2d:aVector];
  return [newVector autorelease];
}

- (G3DVector2d *)vectorBySubtracting:(G3DVector2d *)aVector
{
  G3DVector2d *newVector = [[G3DVector2d alloc] initWithVector:self];
  [newVector subTuple2d:aVector];
  return [newVector autorelease];
}

- (G3DVector2d *)vectorByMultiplyingBy:(double)aScalar
{
  G3DVector2d *newVector = [[G3DVector2d alloc] initWithVector:self];
  [newVector multiplyBy:aScalar];
  return [newVector autorelease];
}

- (G3DVector2d *)vectorByDividingBy:(double)aScalar
{
  G3DVector2d *newVector = [[G3DVector2d alloc] initWithVector:self];
  [newVector divideBy:aScalar];
  return [newVector autorelease];
}

- (double)dotProduct:(G3DVector2d *)aVec
{
  const double *b = [aVec elements];

  return (_tuple[0] * b[0] + _tuple[1] * b[1]); 
}

- (double)length
{
  return G3DLength2dv(_tuple);
}

- (double)squaredLength
{
  return (_tuple[0] * _tuple[0] + _tuple[1] * _tuple[1]);
}

- (void)normalise
{
  G3DNormalise2dv(_tuple,_tuple);
}

- (G3DVector2d *)normalisedVector
{
  double t[2];

  G3DNormalise2dv(t,_tuple);

  return [[[G3DVector2d alloc] initWithElements:t] autorelease];
}

@end






