//-----------------------------------------------------------------------------
// Project            	RenderKit
// Class		G3DMatrix4d
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
// $Id: G3DMatrix4d.m,v 1.3 2002/10/20 09:20:11 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DMatrix4d.h"
#import "G3DMatrix3d.h"
#import "G3DVector3d.h"
#import "G3DVector4d.h"
#import "G3DQuaterniond.h"
#import "G3DFunctions.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"
#import "G3DQuatFunc.h"

#import "G3DDefsIntl.h"

NSString *G3DMatrix4dException = @"G3DMatrix4dException";

@implementation G3DMatrix4d

//-----------------------------------------------------------------------------
// class methods
//-----------------------------------------------------------------------------

static Class G3DVector4dClass;

+ (void)initialize
{
  [super initialize];
  
  if (self == [G3DMatrix4d class]) {
    G3DVector4dClass  = [G3DVector4d class];
  }
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)init
{
  return [self initWithElements:G3DIdentityMatrix4d];
}

- (id)initWithMatrix4d:(G3DMatrix4d *)aMatrix
{
  return [self initWithElements:[aMatrix elements]];
}

- (id)initWithElements:(const double *)vals
{
  if ((self = [super init])) {
    G3DCopyMatrix4dv(matrix,vals);

    // This can be used to optimise operations later...
    _mode = G3D_GENERIC;
  }
  return self;
}

- (id)initWithRotation:(G3DMatrix4d *)vals translation:(G3DVector3d *)trans scale:(const double)factor
{
  const double *rot = [vals elements];
  const double *t = [trans elements];

  [self initWithElements:(double*)G3DIdentityMatrix4d];

  G3DMakeTranslationRotationScale4d(matrix,t,rot,factor);

  return self;
}

- (id)initWithQuaternion:(G3DQuaterniond *)quat translation:(G3DVector3d *)trans scale:(const double)scale
{
  const double *q = [quat elements];
  const double *t = [trans elements];

  NSAssert(quat,@"No quaternion provided!");
  NSAssert(trans,@"No translation provided!");

  [self initWithElements:(double*)G3DIdentityMatrix4d];

  G3DMakeTranslationQuatScale4d(matrix,t,q,scale);  
  
  return self;
}

- (void)dealloc
{
	[super dealloc];
}

//-----------------------------------------------------------------------------
// math
//-----------------------------------------------------------------------------

- (void)addMatrix:(G3DMatrix4d *)a
{
  const double *m = [a elements];

  G3DAddMatrix4dv(matrix,matrix,m);
}

- (void)subMatrix:(G3DMatrix4d *)a
{
  const double *m = [a elements];

  G3DSubMatrix4dv(matrix,matrix,m);
}

- (void)multiplyByMatrix:(G3DMatrix4d *)aMatrix
{
  double a[16] __attribute__ ((aligned));
  const double *b = [aMatrix elements];

  // We don't want to calculate overriden values...
  G3DCopyMatrix4dv(a,matrix);
  G3DMultiplyMatrix4dv(matrix,a,b);
}

- (void)multiplyByMatrix:(G3DMatrix4d *)aMatrix and:(G3DMatrix4d *)bMatrix
{
  const double *a = [aMatrix elements];
  const double *b = [bMatrix elements];

  G3DMultiplyMatrix4dv(matrix,a,b);
}

- (void)multiplyByMatrix:(G3DMatrix4d *)aMat andTransposed:(G3DMatrix4d *)bMat
{
  const double *a = [aMat elements];
  double b[16];

  G3DTransposeMatrix4dv(b,[bMat elements]);
  G3DMultiplyMatrix4dv(matrix,a,b);
}

- (void)multiplyByTransposedMatrix:(G3DMatrix4d *)aMat and:(G3DMatrix4d *)bMat
{
  const double *b = [bMat elements];
  double a[16];

  G3DTransposeMatrix4dv(a,[aMat elements]);
  G3DMultiplyMatrix4dv(matrix,a,b);
}

- (void)multiplyByTransposedMatrix:(G3DMatrix4d *)aMatrix andTransposed:(G3DMatrix4d *)bMatrix
{
  double b[16];
  double a[16];

  G3DTransposeMatrix4dv(a,[aMatrix elements]);
  G3DTransposeMatrix4dv(b,[bMatrix elements]);
  G3DMultiplyMatrix4dv(matrix,a,b);
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

- (BOOL)invert
{
  double i[16] __attribute__ ((aligned));

  if (!G3DInvertMatrix4dv(i,matrix)) {
    return NO;
  }
  G3DCopyMatrix4dv(matrix,i);

  return YES;
}

- (G3DMatrix4d *)invertedMatrix
{
  G3DMatrix4d *im = [[G3DMatrix4d alloc] initWithMatrix4d:self];

  return [im invert] ? [im autorelease] : nil;
}

- (void)transpose
{
  G3DTransposeMatrix4dv(_t,matrix);
  G3DCopyMatrix4dv(matrix,_t);
}

- (G3DMatrix4d *)transposedMatrix
{
  double tr[16];

  G3DTransposeMatrix4dv(tr,matrix);

  return [[(G3DMatrix4d*)[G3DMatrix4d alloc] initWithElements:tr] autorelease];
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
  matrix[9] += scalar;
  matrix[10] += scalar;
  matrix[11] += scalar;
  matrix[12] += scalar;
  matrix[13] += scalar;
  matrix[14] += scalar;
  matrix[15] += scalar;
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
  matrix[9] -= scalar;
  matrix[10] -= scalar;
  matrix[11] -= scalar;
  matrix[12] -= scalar;
  matrix[13] -= scalar;
  matrix[14] -= scalar;
  matrix[15] -= scalar;
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
  matrix[9] *= scalar;
  matrix[10] *= scalar;
  matrix[11] *= scalar;
  matrix[12] *= scalar;
  matrix[13] *= scalar;
  matrix[14] *= scalar;
  matrix[15] *= scalar;
}

- (void)divideByScalar:(const double)scalar
{
  if (scalar == 0.0) {
    [NSException raise:G3DMatrix4dException format:@"Division by zero!"];
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
  matrix[9] /= scalar;
  matrix[10] /= scalar;
  matrix[11] /= scalar;
  matrix[12] /= scalar;
  matrix[13] /= scalar;
  matrix[14] /= scalar;
  matrix[15] /= scalar;
}

- (void)multiplyRow:(const int)pos byValue:(const double)val
{
  matrix[pos] *= val;
  matrix[pos+4] *= val;
  matrix[pos+8] *= val;
  matrix[pos+12] *= val;
}

- (void)multiplyCol:(const int)pos byValue:(const double)val
{
  int p = (pos * 4);

  matrix[p++] *= val;
  matrix[p++] *= val;
  matrix[p++] *= val;
  matrix[p] *= val;
}

- (void)addElements:(const double *)vals toRow:(const int)rowPos
{
  matrix[rowPos] += vals[0];
  matrix[rowPos+4] += vals[1];
  matrix[rowPos+8] += vals[2];
  matrix[rowPos+12] += vals[3];
}

- (void)addElements:(const double *)vals toColumn:(const int)colPos
{
  int i = (colPos * 4);

  matrix[i++] += vals[0];
  matrix[i++] += vals[1];
  matrix[i++] += vals[2];
  matrix[i] += vals[3];
}

- (void)subElements:(const double *)vals fromRow:(const int)rowPos
{
  matrix[rowPos] -= vals[0];
  matrix[rowPos+4] -= vals[1];
  matrix[rowPos+8] -= vals[2];
  matrix[rowPos+12] -= vals[3];
}

- (void)subElements:(const double *)vals fromColumn:(const int)colPos
{
  int i = (colPos * 4);

  matrix[i++] -= vals[0];
  matrix[i++] -= vals[1];
  matrix[i++] -= vals[2];
  matrix[i] -= vals[3];
}

- (double)determinant
{
  return G3DDeterminante4dv(matrix);
}

- (G3DVector4d *)vectorByPreMultiplying:(G3DVector4d *)aTuple
{
  double n[4] __attribute__ ((aligned));

  G3DVector4dXMatrix4d(n, [aTuple elements], matrix);
  return [[[G3DVector4dClass alloc] initWithElements:(const double*)n] autorelease];
}

- (G3DVector4d *)vectorByPostMultiplying:(G3DVector4d *)aTuple
{
  double n[4] __attribute__ ((aligned));

  G3DMatrix4dXVector4d(n, matrix, [aTuple elements]);
  return [[[G3DVector4dClass alloc] initWithElements:(const double*)n] autorelease];
}

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

- (G3DVector4d *)translation
{
  return [[[G3DVector4dClass alloc] initWithElements:(const double*)&matrix[12]] autorelease];
}

- (void)setTranslation:(G3DVector4d *)t
{
  G3DCopyVector4dv(&matrix[12],[t elements]);
}

- (G3DVector4d *)scale
{
  return [[[G3DVector4dClass alloc] initWithX:matrix[0] y:matrix[5] z:matrix[10] w:matrix[15]] autorelease];
}

- (void)setScale:(G3DVector4d *)scale
{
  G3DMakeScale4dv(matrix,[scale elements]);
}

- (G3DQuaterniond *)quaternion
{
  G3DQuaterniond *quat;
  double q[4];
    
  G3DQuatFromMatrixd(q, matrix);
  
  quat = [(G3DQuaterniond*)[G3DQuaterniond alloc] initWithElements:q];
  return [quat autorelease];
}

- (void)setQuaternion:(G3DQuaterniond *)aQuat
{
  G3DMatrixFromQuatd(matrix, (double*)[aQuat elements]);
}

- (void)setMatrix:(G3DMatrix4d *)aMatrix
{
  G3DCopyMatrix4dv(matrix,[aMatrix elements]);
}

- (void)setXRotation:(const double)angle
{
  G3DMakeXRotation4d(matrix,angle);
}

- (void)setYRotation:(const double)angle
{
  G3DMakeYRotation4d(matrix,angle);
}

- (void)setZRotation:(const double)angle
{
  G3DMakeZRotation4d(matrix,angle);
}

- (void)setRotation:(const double)angle axis:(const double *)axis;
{
  G3DMakeRotation4d(matrix,angle,axis);
}

- (void)setRotation:(const double)angle axisVector:(G3DVector3d *)vec
{
  G3DMakeRotation4d(matrix,angle,[vec elements]);
}

- (void)setRotation:(G3DMatrix4d *)vals translation:(G3DVector3d *)trans scale:(const double)factor
{
  const double *rot = [vals elements];
  const double *t = [trans elements];

  G3DMakeTranslationRotationScale4d(matrix,t,rot,factor);
}

- (void)setQuaternion:(G3DQuaterniond *)q translation:(G3DVector3d *)t scale:(const double)s
{
  const double *quat = [q elements];
  const double *trans = [t elements];

  G3DMakeTranslationQuatScale4d(matrix,trans,quat,s);  
}

- (void)setElements:(const double *)vals
{
  G3DCopyMatrix4dv(matrix,vals);
}

- (const double *)elements
{
  return matrix;
}

- (G3DVector4d *)rowVectorAtIndex:(const int)row
{
  G3DVector4d *vec = [[G3DVector4d alloc] init];
  double tmp[4] __attribute__ ((aligned));

  tmp[0] = matrix[row];
  tmp[1] = matrix[row+4];
  tmp[2] = matrix[row+8];
  tmp[3] = matrix[row+12];

  [vec setElements:tmp];

  return [vec autorelease];
}

- (G3DVector4d *)columnVectorAtIndex:(const int)col
{
  G3DVector4d *vec = [[G3DVector4d alloc] init];
  double tmp[4] __attribute__ ((aligned));
  int r = (col*4);

  tmp[0] = matrix[r++];
  tmp[1] = matrix[r++];
  tmp[2] = matrix[r++];
  tmp[3] = matrix[r];

  [vec setElements:tmp];

  return [vec autorelease];
}

- (void)setElement:(const double)val atRow:(const int)row column:(const int)col
{
  matrix[(col*4) + row] = val;
}

- (double)elementAtRow:(const int)row column:(const int)col
{
  return matrix[(col*4) + row];
}

//-----------------------------------------------------------------------------
// misc
//-----------------------------------------------------------------------------

- (BOOL)isEqualToMatrix:(G3DMatrix4d *)aMatrix
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
      matrix[8] == m[8] &&
      matrix[9] == m[9] &&
      matrix[10] == m[10] &&
      matrix[11] == m[11] &&
      matrix[12] == m[12] &&
      matrix[13] == m[13] &&
      matrix[14] == m[14] &&
      matrix[15] == m[15]) {
    return YES;
  }
  return NO;
}

- (NSString *)description
{
  NSString *str;

  str = [NSString stringWithFormat:@"%@:\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f",[super description],matrix[0],matrix[4],matrix[8],matrix[12],matrix[1],matrix[5],matrix[9],matrix[13],matrix[2],matrix[6],matrix[10],matrix[14],matrix[3],matrix[7],matrix[11],matrix[15]];

  return str;
}

//-----------------------------------------------------------------------------
// NSCoding
//-----------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeArrayOfObjCType:@encode(double) count:16 at:matrix];
  [aCoder encodeValueOfObjCType:@encode(int) at:&_mode];
  [aCoder encodeArrayOfObjCType:@encode(double) count:16 at:_t];
  [aCoder encodeArrayOfObjCType:@encode(double) count:16 at:_i];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
  self = [super init];
  [aCoder decodeArrayOfObjCType:@encode(double) count:16 at:matrix];
  [aCoder decodeValueOfObjCType:@encode(int) at:&_mode];
  [aCoder decodeArrayOfObjCType:@encode(double) count:16 at:_t];
  [aCoder decodeArrayOfObjCType:@encode(double) count:16 at:_i];
  return self;
}

//-----------------------------------------------------------------------------
// NSCopying
//-----------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
  G3DMatrix4d *copy = [[G3DMatrix4d allocWithZone:zone] init];

  G3DCopyMatrix4dv(copy->matrix,matrix);
  G3DCopyMatrix4dv(copy->_t,_t);
  G3DCopyMatrix4dv(copy->_i,_t);
  copy->_mode = _mode;

  return copy;
}

@end






