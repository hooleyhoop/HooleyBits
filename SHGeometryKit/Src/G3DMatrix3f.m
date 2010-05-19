//-----------------------------------------------------------------------------
// Project            	RenderKit
// Class		G3DMatrix3f
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
// $Id: G3DMatrix3f.m,v 1.3 2002/10/20 09:20:11 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DMatrix3f.h"
#import "G3DTuple3f.h"
#import "G3DVector3f.h"
#import "G3DQuaternionf.h"
#import "G3DFunctions.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

#import "G3DDefsIntl.h"

NSString *G3DMatrix3fException = @"G3DMatrix3fException";

@implementation G3DMatrix3f

//-----------------------------------------------------------------------------
// class methods
//-----------------------------------------------------------------------------

static Class G3DTuple3fClass;

+ (void)initialize
{
  if (self == [G3DMatrix3f class]) {
    G3DTuple3fClass  = [G3DTuple3f class];
  }
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)init
{
  return [self initWithElements:G3DIdentityMatrix3f];
}

- (id)initWithMatrix3f:(G3DMatrix3f *)aMatrix
{
  return [self initWithElements:[aMatrix elements]];
}

- (id)initWithElements:(const float *)vals
{
  if ((self = [super init])) {
    G3DCopyMatrix3fv(matrix,vals);

    // This can be used to optimise operations later...
    _mode = G3D_GENERIC;
  }
  return self;
}

- (void)dealloc
{
	[super dealloc];
}

//-----------------------------------------------------------------------------
// math
//-----------------------------------------------------------------------------

- (void)addMatrix:(G3DMatrix3f *)a
{
  const float *m = [a elements];

  G3DAddMatrix3fv(matrix,matrix,m);
}

- (void)subMatrix:(G3DMatrix3f *)a
{
  const float *m = [a elements];

  G3DSubMatrix3fv(matrix,matrix,m);
}

- (void)multiplyByMatrix:(G3DMatrix3f *)aMatrix
{
  float l[9] __attribute__ ((aligned));
  const float *m = [aMatrix elements];

  // We don't want to calculate overriden values...
  G3DCopyMatrix3fv(l,matrix);
  G3DMultiplyMatrix3fv(matrix,l,m);
}

- (void)multiplyByMatrix:(G3DMatrix3f *)a and:(G3DMatrix3f *)b
{
  const float *l = [a elements];
  const float *m = [b elements];

  G3DMultiplyMatrix3fv(matrix,l,m);
}

- (void)multiplyByMatrix:(G3DMatrix3f *)a andTransposed:(G3DMatrix3f *)b
{
  const float *l = [a elements];
  float m[9];

  G3DTransposeMatrix3fv(m,[b elements]);
  G3DMultiplyMatrix3fv(matrix,l,m);
}

- (void)multiplyByTransposedMatrix:(G3DMatrix3f *)a and:(G3DMatrix3f *)b
{
  float l[9];
  const float *m = [b elements];

  G3DTransposeMatrix3fv(l,[a elements]);
  G3DMultiplyMatrix3fv(matrix,l,m);
}

- (void)multiplyByTransposedMatrix:(G3DMatrix3f *)a andTransposed:(G3DMatrix3f *)b
{
  float l[9];
  float m[9];

  G3DTransposeMatrix3fv(l,[a elements]);
  G3DTransposeMatrix3fv(m,[b elements]);

  G3DMultiplyMatrix3fv(matrix,l,m);
}

- (void)multiplyByMatrices:(NSArray *)matrices
{
  int c = [matrices count];
  int i;
  register void (*mulu)(id, SEL, id);

  mulu = (void*)[self methodForSelector:@selector(multiplyByMatrix:)];

  for (i=0;i<c;i++) {
    mulu(self,@selector(multiplyByMatrix:),[matrices objectAtIndex:i]);
  }
}

- (G3DTuple3f *)vectorByPreMultiplying:(G3DTuple3f *)aTuple
{
  float n[3] __attribute__ ((aligned));

  G3DVector3fXMatrix3f(n, [aTuple elements], matrix);
  return [[(G3DTuple3f*)[G3DTuple3fClass alloc] initWithElements:n] autorelease];
}

- (G3DTuple3f *)vectorByPostMultiplying:(G3DTuple3f *)aTuple;
{
  float n[3] __attribute__ ((aligned));

  G3DMatrix3fXVector3f(n, matrix, [aTuple elements]);
  return [[(G3DTuple3f*)[G3DTuple3fClass alloc] initWithElements:n] autorelease];
}

- (BOOL)invert
{
  BOOL ret = NO;

  switch(_mode) {
  case G3D_SCALE:
    if (matrix[0] == 0.0 || matrix[4] == 0.0 || matrix[8] == 0.0) {
      [NSException raise:G3DMatrix3fException format:@"Singular matrix!"];
      return NO;
    }
    matrix[0] = (1.0/matrix[0]);
    matrix[1] = (1.0/matrix[1]);
    matrix[2] = (1.0/matrix[2]);
    ret = YES;
    break;
  case G3D_ROTATION:
    [self transpose];
    ret = YES;
    break;
  case G3D_ID:
    ret = YES;
    break;
  case G3D_GENERIC:
  default:
    // Invert the matrix using the well known Gauss algorithm
    NSLog(@"generic 3x3 inversion is not yet implemented");
    ret = YES;
    break;
  }
  return ret;
}

- (G3DMatrix3f *)invertedMatrix
{
  G3DMatrix3f *im = [[G3DMatrix3f alloc] initWithMatrix3f:self];

  return [im invert] ? [im autorelease] : nil;
}

- (void)transpose
{
  G3DTransposeMatrix3fv(_t,matrix);
  G3DCopyMatrix3fv(matrix,_t);
}

- (G3DMatrix3f *)transposedMatrix
{
  float tr[9];

  G3DTransposeMatrix3fv(tr,matrix);

  return [[[G3DMatrix3f alloc] initWithElements:tr] autorelease];
}

- (void)addScalar:(const float)scalar
{
  matrix[0] += scalar;
  matrix[1] += scalar;
  matrix[2] += scalar;
  matrix[3] += scalar;
  matrix[4] += scalar;
  matrix[5] += scalar;
  matrix[6] += scalar;
  matrix[7] += scalar;
  matrix[8] += scalar;
}

- (void)subScalar:(const float)scalar
{
  matrix[0] -= scalar;
  matrix[1] -= scalar;
  matrix[2] -= scalar;
  matrix[3] -= scalar;
  matrix[4] -= scalar;
  matrix[5] -= scalar;
  matrix[6] -= scalar;
  matrix[7] -= scalar;
  matrix[8] -= scalar;
}

- (void)multiplyByScalar:(const float)scalar
{
  matrix[0] *= scalar;
  matrix[1] *= scalar;
  matrix[2] *= scalar;
  matrix[3] *= scalar;
  matrix[4] *= scalar;
  matrix[5] *= scalar;
  matrix[6] *= scalar;
  matrix[7] *= scalar;
  matrix[8] *= scalar;
}

- (void)divideByScalar:(const float)scalar
{
  if (scalar == 0.0) {
    [NSException raise:G3DMatrix3fException format:@"Division by zero!"];
    return;
  }

  matrix[0] /= scalar;
  matrix[1] /= scalar;
  matrix[2] /= scalar;
  matrix[3] /= scalar;
  matrix[4] /= scalar;
  matrix[5] /= scalar;
  matrix[6] /= scalar;
  matrix[7] /= scalar;
  matrix[8] /= scalar;
}

- (void)multiplyRow:(const int)pos byValue:(const float)val
{
  matrix[pos] *= val;
  matrix[pos+3] *= val;
  matrix[pos+6] *= val;
}

- (void)multiplyCol:(const int)pos byValue:(const float)val
{
  int p = (pos * 3);

  matrix[p++] *= val;
  matrix[p++] *= val;
  matrix[p] *= val;
}

- (void)addElements:(const float *)vals toRow:(const int)rowPos
{
  matrix[rowPos] += vals[0];
  matrix[rowPos+3] += vals[1];
  matrix[rowPos+6] += vals[2];
}

- (void)addElements:(const float *)vals toColumn:(const int)colPos
{
  int i = (colPos * 3);

  matrix[i++] += vals[0];
  matrix[i++] += vals[1];
  matrix[i] += vals[2];
}

- (void)subElements:(const float *)vals fromRow:(const int)rowPos
{
  matrix[rowPos] -= vals[0];
  matrix[rowPos+3] -= vals[1];
  matrix[rowPos+6] -= vals[2];
}

- (void)subElements:(const float *)vals fromColumn:(const int)colPos
{
  int i = (colPos * 3);

  matrix[i++] -= vals[0];
  matrix[i++] -= vals[1];
  matrix[i] -= vals[2];
}

- (float)determinant
{
  return G3DDeterminante3f(matrix[0], matrix[3], matrix[6],
			  matrix[1], matrix[4], matrix[7],
			  matrix[2], matrix[5], matrix[8]);
}

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

- (void)setMatrix:(G3DMatrix3f *)aMatrix
{
  G3DCopyMatrix3fv(matrix,[aMatrix elements]);
}

- (void)setXRotation:(const float)angle
{
  G3DMakeXRotation3f(matrix,angle);
}

- (void)setYRotation:(const float)angle
{
  G3DMakeYRotation3f(matrix,angle);
}

- (void)setZRotation:(const float)angle
{
  G3DMakeZRotation3f(matrix,angle);
}

- (void)setRotation:(const float)angle axis:(const float *)axis
{
  G3DMakeRotation3f(matrix,angle,axis);
}

- (void)setRotation:(const float)angle axisVector:(G3DVector3f *)vec
{
  G3DMakeRotation3f(matrix,angle,[vec elements]);
}

- (G3DVector3f *)scale
{
  return [[[G3DVector3f alloc] initWithX:matrix[0] y:matrix[4] z:matrix[8]] autorelease];
}

- (void)setScale:(G3DVector3f *)factor
{
  G3DMakeScale3fv(matrix,[factor elements]);
}

- (void)setElements:(const float *)vals
{
  G3DCopyMatrix3fv(matrix,vals);
}

- (const float *)elements
{
  return (const float*)matrix;
}

- (G3DVector3f *)rowVectorAtIndex:(const int)row
{
  G3DVector3f *vec = [[G3DVector3f alloc] init];
  float tmp[3] __attribute__ ((aligned));

  tmp[0] = matrix[row];
  tmp[1] = matrix[row+3];
  tmp[2] = matrix[row+6];

  [vec setElements:tmp];

  return [vec autorelease];
}

- (G3DVector3f *)columnVectorAtIndex:(const int)col
{
  G3DVector3f *vec = [[G3DVector3f alloc] init];
  float tmp[3] __attribute__ ((aligned));
  int r = (col*3);

  tmp[0] = matrix[r++];
  tmp[1] = matrix[r++];
  tmp[2] = matrix[r];

  [vec setElements:tmp];

  return [vec autorelease];
}

- (void)setElement:(const float)val atRow:(const int)row column:(const int)col
{
  matrix[(col*3) + row] = val;
}

- (float)elementAtRow:(const int)row column:(const int)col
{
  return matrix[(col*3) + row];
}

//-----------------------------------------------------------------------------
// misc
//-----------------------------------------------------------------------------

- (NSString *)description
{
  NSString *str;

  str = [NSString stringWithFormat:@"%@:\n%f %f %f\n%f %f %f\n%f %f %f",[super description],matrix[0],matrix[3],matrix[6],matrix[1],matrix[4],matrix[7],matrix[2],matrix[5],matrix[8]];

  return str;
}

- (BOOL)isEqualToMatrix:(G3DMatrix3f *)aMatrix
{
  const float *m = [aMatrix elements];

  if (matrix[0] == m[0] &&
      matrix[1] == m[1] &&
      matrix[2] == m[2] &&
      matrix[3] == m[3] &&
      matrix[4] == m[4] &&
      matrix[5] == m[5] &&
      matrix[6] == m[6] &&
      matrix[7] == m[7] &&
      matrix[8] == m[8]) {
    return YES;
  }
  return NO;
}

//-----------------------------------------------------------------------------
// NSCoding
//-----------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeArrayOfObjCType:@encode(float) count:9 at:matrix];
  [aCoder encodeValueOfObjCType:@encode(int) at:&_mode];
  [aCoder encodeArrayOfObjCType:@encode(float) count:9 at:_t];
  [aCoder encodeArrayOfObjCType:@encode(float) count:9 at:_i];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
  self = [super init];
  [aCoder decodeArrayOfObjCType:@encode(float) count:9 at:matrix];
  [aCoder decodeValueOfObjCType:@encode(int) at:&_mode];
  [aCoder decodeArrayOfObjCType:@encode(float) count:9 at:_t];
  [aCoder decodeArrayOfObjCType:@encode(float) count:9 at:_i];
  return self;
}

//-----------------------------------------------------------------------------
// NSCopying
//-----------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
  G3DMatrix3f *copy = [[G3DMatrix3f allocWithZone:zone] init];

  G3DCopyMatrix3fv(copy->matrix,matrix);
  G3DCopyMatrix3fv(copy->_t,_t);
  G3DCopyMatrix3fv(copy->_i,_t);
  copy->_mode = _mode;

  return copy;
}

@end






