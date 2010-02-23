//-----------------------------------------------------------------------------
// Project            	RenderKit
// Class		G3DMatrix3d
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
// $Id: G3DMatrix3d.m,v 1.3 2002/10/20 09:20:11 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DMatrix3d.h"
#import "G3DTuple3d.h"
#import "G3DVector3d.h"
#import "G3DQuaterniond.h"
#import "G3DFunctions.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

#import "G3DDefsIntl.h"

NSString *G3DMatrix3dException = @"G3DMatrix3dException";

@implementation G3DMatrix3d

//-----------------------------------------------------------------------------
// class methods
//-----------------------------------------------------------------------------

static Class G3DTuple3dClass;

+ (void)initialize
{
  if (self == [G3DMatrix3d class]) {
    G3DTuple3dClass  = [G3DTuple3d class];
  }
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)init
{
  return [self initWithElements:(double *)G3DIdentityMatrix3d];
}

- (id)initWithMatrix3d:(G3DMatrix3d *)aMatrix
{
  return [self initWithElements:[aMatrix elements]];
}

- (id)initWithElements:(const double *)vals
{
  if ((self = [super init])) {
    G3DCopyMatrix3dv(matrix,vals);

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

- (void)addMatrix:(G3DMatrix3d *)a
{
  const double *m = [a elements];

  G3DAddMatrix3dv(matrix,matrix,m);
}

- (void)subMatrix:(G3DMatrix3d *)a
{
  const double *m = [a elements];

  G3DSubMatrix3dv(matrix,matrix,m);
}

- (void)multiplyByMatrix:(G3DMatrix3d *)aMatrix
{
  double l[9] __attribute__ ((aligned));
  const double *m = [aMatrix elements];

  // We don't want to calculate overriden values...
  G3DCopyMatrix3dv(l,matrix);
  G3DMultiplyMatrix3dv(matrix,l,m);
}

- (void)multiplyByMatrix:(G3DMatrix3d *)a and:(G3DMatrix3d *)b
{
  const double *l = [a elements];
  const double *m = [b elements];

  G3DMultiplyMatrix3dv(matrix,l,m);
}

- (void)multiplyByMatrix:(G3DMatrix3d *)a andTransposed:(G3DMatrix3d *)b
{
  const double *l = [a elements];
  double m[9];

  G3DTransposeMatrix3dv(m,[b elements]);
  G3DMultiplyMatrix3dv(matrix,l,m);
}

- (void)multiplyByTransposedMatrix:(G3DMatrix3d *)a and:(G3DMatrix3d *)b
{
  double l[9];
  const double *m = [b elements];

  G3DTransposeMatrix3dv(l,[a elements]);
  G3DMultiplyMatrix3dv(matrix,l,m);
}

- (void)multiplyByTransposedMatrix:(G3DMatrix3d *)a andTransposed:(G3DMatrix3d *)b
{
  double l[9];
  double m[9];

  G3DTransposeMatrix3dv(l,[a elements]);
  G3DTransposeMatrix3dv(m,[b elements]);

  G3DMultiplyMatrix3dv(matrix,l,m);
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

- (G3DTuple3d *)vectorByPreMultiplying:(G3DTuple3d *)aTuple
{
  double n[3] __attribute__ ((aligned));

  G3DVector3dXMatrix3d(n, [aTuple elements], matrix);
  return [[(G3DTuple3d*)[G3DTuple3dClass alloc] initWithElements:n] autorelease];
}

- (G3DTuple3d *)vectorByPostMultiplying:(G3DTuple3d *)aTuple;
{
  double n[3] __attribute__ ((aligned));

  G3DMatrix3dXVector3d(n, matrix, [aTuple elements]);
  return [[(G3DTuple3d*)[G3DTuple3dClass alloc] initWithElements:n] autorelease];
}

- (BOOL)invert
{
  BOOL ret = NO;

  switch(_mode) {
  case G3D_SCALE:
    if (matrix[0] == 0.0 || matrix[4] == 0.0 || matrix[8] == 0.0) {
      [NSException raise:G3DMatrix3dException format:@"Singular matrix!"];
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
    NSLog(@"generic 3x3 invertion is not yet implemented...");
    ret = YES;
    break;
  }
  return ret;
}

- (G3DMatrix3d *)invertedMatrix
{
  G3DMatrix3d *im = [[G3DMatrix3d alloc] initWithMatrix3d:self];

  return [im invert] ? [im autorelease] : nil;
}

- (void)transpose
{
  G3DTransposeMatrix3dv(_t,matrix);
  G3DCopyMatrix3dv(matrix,_t);
}

- (G3DMatrix3d *)transposedMatrix
{
  double tr[9];

  G3DTransposeMatrix3dv(tr,matrix);

  return [[(G3DMatrix3d*)[G3DMatrix3d alloc] initWithElements:tr] autorelease];
}

- (void)addScalar:(const double)scalar
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

- (void)subScalar:(const double)scalar
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

- (void)multiplyByScalar:(const double)scalar
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

- (void)divideByScalar:(const double)scalar
{
  if (scalar == 0.0) {
    [NSException raise:G3DMatrix3dException format:@"Division by zero!"];
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

- (void)multiplyRow:(const int)pos byValue:(const double)val
{
  matrix[pos] *= val;
  matrix[pos+3] *= val;
  matrix[pos+6] *= val;
}

- (void)multiplyCol:(const int)pos byValue:(const double)val
{
  int p = (pos * 3);

  matrix[p++] *= val;
  matrix[p++] *= val;
  matrix[p] *= val;
}

- (void)addElements:(const double *)vals toRow:(const int)rowPos
{
  matrix[rowPos] += vals[0];
  matrix[rowPos+3] += vals[1];
  matrix[rowPos+6] += vals[2];
}

- (void)addElements:(const double *)vals toColumn:(const int)colPos
{
  int i = (colPos * 3);

  matrix[i++] += vals[0];
  matrix[i++] += vals[1];
  matrix[i] += vals[2];
}

- (void)subElements:(const double *)vals fromRow:(const int)rowPos
{
  matrix[rowPos] -= vals[0];
  matrix[rowPos+3] -= vals[1];
  matrix[rowPos+6] -= vals[2];
}

- (void)subElements:(const double *)vals fromColumn:(const int)colPos
{
  int i = (colPos * 3);

  matrix[i++] -= vals[0];
  matrix[i++] -= vals[1];
  matrix[i] -= vals[2];
}

- (double)determinant
{
  return G3DDeterminante3d(matrix[0], matrix[3], matrix[6],
			  matrix[1], matrix[4], matrix[7],
			  matrix[2], matrix[5], matrix[8]);
}

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

- (void)setMatrix:(G3DMatrix3d *)aMatrix
{
  G3DCopyMatrix3dv(matrix,[aMatrix elements]);
}

- (void)setXRotation:(const double)angle
{
  G3DMakeXRotation3d(matrix,angle);
}

- (void)setYRotation:(const double)angle
{
  G3DMakeYRotation3d(matrix,angle);
}

- (void)setZRotation:(const double)angle
{
  G3DMakeZRotation3d(matrix,angle);
}

- (void)setRotation:(const double)angle axis:(const double *)axis
{
  G3DMakeRotation3d(matrix,angle,axis);
}

- (void)setRotation:(const double)angle axisVector:(G3DVector3d *)vec
{
  G3DMakeRotation3d(matrix,angle,[vec elements]);
}

- (G3DVector3d *)scale
{
  return [[[G3DVector3d alloc] initWithX:matrix[0] y:matrix[4] z:matrix[8]] autorelease];
}

- (void)setScale:(G3DVector3d *)scale
{
  G3DMakeScale3dv(matrix,[scale elements]);
}

- (void)setElements:(const double *)vals
{
  G3DCopyMatrix3dv(matrix,vals);
}

- (const double *)elements
{
  return (const double *)matrix;
}

- (G3DVector3d *)rowVectorAtIndex:(const int)row
{
  G3DVector3d *vec = [[G3DVector3d alloc] init];
  double tmp[3] __attribute__ ((aligned));

  tmp[0] = matrix[row];
  tmp[1] = matrix[row+3];
  tmp[2] = matrix[row+6];

  [vec setElements:tmp];

  return [vec autorelease];
}

- (G3DVector3d *)columnVectorAtIndex:(const int)col
{
  G3DVector3d *vec = [[G3DVector3d alloc] init];
  double tmp[3] __attribute__ ((aligned));
  int r = (col*3);

  tmp[0] = matrix[r++];
  tmp[1] = matrix[r++];
  tmp[2] = matrix[r];

  [vec setElements:tmp];

  return [vec autorelease];
}

- (void)setElement:(const double)val atRow:(const int)row column:(const int)col
{
  matrix[(col*3) + row] = val;
}

- (double)elementAtRow:(const int)row column:(const int)col
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

- (BOOL)isEqualToMatrix:(G3DMatrix3d *)aMatrix
{
  const double *m = [aMatrix elements];

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
  [aCoder encodeArrayOfObjCType:@encode(double) count:9 at:matrix];
  [aCoder encodeValueOfObjCType:@encode(int) at:&_mode];
  [aCoder encodeArrayOfObjCType:@encode(double) count:9 at:_t];
  [aCoder encodeArrayOfObjCType:@encode(double) count:9 at:_i];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
  self = [super init];
  [aCoder decodeArrayOfObjCType:@encode(double) count:9 at:matrix];
  [aCoder decodeValueOfObjCType:@encode(int) at:&_mode];
  [aCoder decodeArrayOfObjCType:@encode(double) count:9 at:_t];
  [aCoder decodeArrayOfObjCType:@encode(double) count:9 at:_i];
  return self;
}

//-----------------------------------------------------------------------------
// NSCopying
//-----------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
  G3DMatrix3d *copy = [[G3DMatrix3d allocWithZone:zone] init];

  G3DCopyMatrix3dv(copy->matrix,matrix);
  G3DCopyMatrix3dv(copy->_t,_t);
  G3DCopyMatrix3dv(copy->_i,_t);
  copy->_mode = _mode;
  
  return copy;
}

@end






