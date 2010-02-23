//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DVector2f
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
// $Id: G3DVector2f.m,v 1.2 2002/10/20 09:20:11 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DVector2f.h"

#import "G3DFunctions.h"
#import "G3DDefs.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

@implementation G3DVector2f

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)initWithVector:(G3DVector2f *)vec
{
  if ((self = [super initWithX:[vec x] y:[vec y]])) {
  }
  return self;
}

//-----------------------------------------------------------------------------
// Math
//-----------------------------------------------------------------------------

- (G3DVector2f *)vectorByAdding:(G3DVector2f *)aVector
{
  G3DVector2f *newVector = [[G3DVector2f alloc] initWithVector:self];
  [newVector addTuple2f:aVector];
  return [newVector autorelease];
}

- (G3DVector2f *)vectorBySubtracting:(G3DVector2f *)aVector
{
  G3DVector2f *newVector = [[G3DVector2f alloc] initWithVector:self];
  [newVector subTuple2f:aVector];
  return [newVector autorelease];
}

- (G3DVector2f *)vectorByMultiplyingBy:(float)aScalar
{
  G3DVector2f *newVector = [[G3DVector2f alloc] initWithVector:self];
  [newVector multiplyBy:aScalar];
  return [newVector autorelease];
}

- (G3DVector2f *)vectorByDividingBy:(float)aScalar
{
  G3DVector2f *newVector = [[G3DVector2f alloc] initWithVector:self];
  [newVector divideBy:aScalar];
  return [newVector autorelease];
}

- (float)dotProduct:(G3DVector2f *)aVec
{
  const float *b = [aVec elements];

  return (_tuple[0] * b[0] + _tuple[1] * b[1]); 
}

- (float)length
{
  return G3DLength2fv(_tuple);
}

- (float)squaredLength
{
  return (_tuple[0] * _tuple[0] + _tuple[1] * _tuple[1]);
}

- (void)normalise
{
  G3DNormalise2fv(_tuple,_tuple);
}

- (G3DVector2f *)normalisedVector
{
  float t[2];

  G3DNormalise2fv(t,_tuple);

  return [[[G3DVector2f alloc] initWithElements:t] autorelease];
}

@end






