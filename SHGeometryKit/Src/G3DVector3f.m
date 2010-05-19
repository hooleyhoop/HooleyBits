//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DVector3f
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
// $Id: G3DVector3f.m,v 1.2 2002/10/20 09:20:11 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DVector3f.h"

#import "G3DFunctions.h"
#import "G3DDefs.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

@implementation G3DVector3f

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)initWithVector:(G3DVector3f *)vec
{
  if ((self = [super initWithX:[vec x] y:[vec y] z:[vec z]])) {
  }
  return self;
}

//-----------------------------------------------------------------------------
// Math
//-----------------------------------------------------------------------------

- (G3DVector3f *)vectorByAdding:(G3DVector3f *)aVector
{
  G3DVector3f* newVector = [[G3DVector3f alloc] initWithVector:self];
  [newVector addTuple3f:aVector];
  return [newVector autorelease];
}

- (G3DVector3f *)vectorBySubtracting:(G3DVector3f *)aVector
{
  G3DVector3f* newVector = [[G3DVector3f alloc] initWithVector:self];
  [newVector subTuple3f:aVector];
  return [newVector autorelease];
}

- (G3DVector3f *)vectorByMultiplyingBy:(float)aScalar
{
  G3DVector3f* newVector = [[G3DVector3f alloc] initWithVector:self];
  [newVector multiplyBy:aScalar];
  return [newVector autorelease];
}

- (G3DVector3f *)vectorByDividingBy:(float)aScalar
{
  G3DVector3f* newVector = [[G3DVector3f alloc] initWithVector:self];
  [newVector divideBy:aScalar];
  return [newVector autorelease];
}

- (float)dotProduct:(G3DVector3f *)aVec
{
  const float *b = [aVec elements];

  return (_tuple[0] * b[0] + _tuple[1] * b[1] + _tuple[2] * b[2]); 
}

- (void)crossProductWith:(G3DVector3f *)aVec and:(G3DVector3f *)bVec
{
  const float *a = [aVec elements];
  const float *b = [bVec elements];

  _tuple[0] = a[1] * b[2] - a[2] * b[1];
  _tuple[1] = a[2] * b[0] - a[0] * b[2];
  _tuple[2] = a[0] * b[1] - a[1] * b[0];
}

- (float)length
{
  return G3DLength3fv(_tuple);
}

- (float)squaredLength
{
  return (_tuple[0] * _tuple[0] + _tuple[1] * _tuple[1] + _tuple[2] * _tuple[2]);
}

- (void)normalise
{
  G3DNormalise3fv(_tuple,_tuple);
}

- (G3DVector3f *)normalisedVector
{
  float t[3];

  G3DNormalise3fv(t,_tuple);

  return [[[G3DVector3f alloc] initWithElements:t] autorelease];
}

@end






