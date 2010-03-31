//-----------------------------------------------------------------------------
// Project            	RenderKit
// Class		G3DMatrix4f
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
// $Id: G3DMatrix4f.m,v 1.3 2002/10/20 09:20:11 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DMatrix4f.h"
#import "G3DMatrix3f.h"
#import "G3DVector3f.h"
#import "G3DVector4f.h"
#import "G3DQuaternionf.h"
#import "G3DFunctions.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"
#import "G3DQuatFunc.h"

#import "G3DDefsIntl.h"

NSString *G3DMatrix4fException = @"G3DMatrix4fException";

@implementation G3DMatrix4f

//-----------------------------------------------------------------------------
// class methods
//-----------------------------------------------------------------------------

static Class G3DVector4fClass;

+ (void)initialize
{
  [super initialize];
  
  if (self == [G3DMatrix4f class]) {
    G3DVector4fClass  = [G3DVector4f class];
  }
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)init
{
  return [self initWithElements:G3DIdentityMatrix4f];
}

- (id)initWithMatrix4f:(G3DMatrix4f *)aMatrix
{
  return [self initWithElements:[aMatrix elements]];
}

- (id)initWithElements:(const float *)vals
{
  if ((self = [super init])) {
    G3DCopyMatrix4fv(matrix,vals);

    // This can be used to optimise operations later...
    _mode = G3D_GENERIC;
  }
  return self;
}

- (id)initWithRotation:(G3DMatrix4f *)vals translation:(G3DVector3f *)trans scale:(const float)factor
{
  const float *rot = [vals elements];
  const float *t = [trans elements];

  [self initWithElements:(float *)G3DIdentityMatrix4f];

  G3DMakeTranslationRotationScale4f(matrix,t,rot,factor);

  return self;
}

- (id)initWithQuaternion:(G3DQuaternionf *)quat translation:(G3DVector3f *)trans scale:(const float)scale
{
  const float *q = [quat elements];
  const float *t = [trans elements];

  NSAssert(quat,@"No quaternion provided!");
  NSAssert(trans,@"No translation provided!");

  [self initWithElements:(float *)G3DIdentityMatrix4f];

  G3DMakeTranslationQuatScale4f(matrix,t,q,scale);  

  return self;
}

- (void)dealloc
{
	[super dealloc];
}

//-----------------------------------------------------------------------------
// math
//-----------------------------------------------------------------------------

- (void)addMatrix:(G3DMatrix4f *)a
{
  const float *m = [a elements];

  G3DAddMatrix4fv(matrix,matrix,m);
}

- (void)subMatrix:(G3DMatrix4f *)a
{
  const float *m = [a elements];

  G3DSubMatrix4fv(matrix,matrix,m);
}

- (void)multiplyByMatrix:(G3DMatrix4f *)aMatrix
{
  float a[16] __attribute__ ((aligned));
  const float *b = [aMatrix elements];

  // We don't want to calculate overriden values...
  G3DCopyMatrix4fv(a,matrix);
  G3DMultiplyMatrix4fv(matrix,a,b);
}

- (void)multiplyByMatrix:(G3DMatrix4f *)aMatrix and:(G3DMatrix4f *)bMatrix
{
  const float *a = [aMatrix elements];
  const float *b = [bMatrix elements];

  G3DMultiplyMatrix4fv(matrix,a,b);
}

- (void)multiplyByMatrix:(G3DMatrix4f *)aMat andTransposed:(G3DMatrix4f *)bMat
{
  const float *a = [aMat elements];
  float b[16];

  G3DTransposeMatrix4fv(b,[bMat elements]);
  G3DMultiplyMatrix4fv(matrix,a,b);
}

- (void)multiplyByTransposedMatrix:(G3DMatrix4f *)aMat and:(G3DMatrix4f *)bMat
{
  const float *b = [bMat elements];
  float a[16];

  G3DTransposeMatrix4fv(a,[aMat elements]);
  G3DMultiplyMatrix4fv(matrix,a,b);
}

- (void)multiplyByTransposedMatrix:(G3DMatrix4f *)aMatrix andTransposed:(G3DMatrix4f *)bMatrix
{
  float b[16];
  float a[16];

  G3DTransposeMatrix4fv(a,[aMatrix elements]);
  G3DTransposeMatrix4fv(b,[bMatrix elements]);
  G3DMultiplyMatrix4fv(matrix,a,b);
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
  float i[16] __attribute__ ((aligned));

  if (!G3DInvertMatrix4fv(i,matrix)) {
    return NO;
  }
  G3DCopyMatrix4fv(matrix,i);

  return YES;
}

- (G3DMatrix4f *)invertedMatrix
{
  G3DMatrix4f *im = [[G3DMatrix4f alloc] initWithMatrix4f:self];

  return [im invert] ? [im autorelease] : nil;
}

- (void)transpose
{
  G3DTransposeMatrix4fv(_t,matrix);
  G3DCopyMatrix4fv(matrix,_t);
}

- (G3DMatrix4f *)transposedMatrix
{
  float tr[16];

  G3DTransposeMatrix4fv(tr,matrix);

  return [[[G3DMatrix4f alloc] initWithElements:(const float*)tr] autorelease];
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
  matrix[9] += scalar;
  matrix[10] += scalar;
  matrix[11] += scalar;
  matrix[12] += scalar;
  matrix[13] += scalar;
  matrix[14] += scalar;
  matrix[15] += scalar;
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
  matrix[9] -= scalar;
  matrix[10] -= scalar;
  matrix[11] -= scalar;
  matrix[12] -= scalar;
  matrix[13] -= scalar;
  matrix[14] -= scalar;
  matrix[15] -= scalar;
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
  matrix[9] *= scalar;
  matrix[10] *= scalar;
  matrix[11] *= scalar;
  matrix[12] *= scalar;
  matrix[13] *= scalar;
  matrix[14] *= scalar;
  matrix[15] *= scalar;
}

- (void)divideByScalar:(const float)scalar
{
  if (scalar == 0.0) {
    [NSException raise:G3DMatrix4fException format:@"Division by zero!"];
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

- (void)multiplyRow:(const int)pos byValue:(const float)val
{
  matrix[pos] *= val;
  matrix[pos+4] *= val;
  matrix[pos+8] *= val;
  matrix[pos+12] *= val;
}

- (void)multiplyCol:(const int)pos byValue:(const float)val
{
  int p = (pos * 4);

  matrix[p++] *= val;
  matrix[p++] *= val;
  matrix[p++] *= val;
  matrix[p] *= val;
}

- (void)addElements:(const float *)vals toRow:(const int)rowPos
{
  matrix[rowPos] += vals[0];
  matrix[rowPos+4] += vals[1];
  matrix[rowPos+8] += vals[2];
  matrix[rowPos+12] += vals[3];
}

- (void)addElements:(const float *)vals toColumn:(const int)colPos
{
  int i = (colPos * 4);

  matrix[i++] += vals[0];
  matrix[i++] += vals[1];
  matrix[i++] += vals[2];
  matrix[i] += vals[3];
}

- (void)subElements:(const float *)vals fromRow:(const int)rowPos
{
  matrix[rowPos] -= vals[0];
  matrix[rowPos+4] -= vals[1];
  matrix[rowPos+8] -= vals[2];
  matrix[rowPos+12] -= vals[3];
}

- (void)subElements:(const float *)vals fromColumn:(const int)colPos
{
  int i = (colPos * 4);

  matrix[i++] -= vals[0];
  matrix[i++] -= vals[1];
  matrix[i++] -= vals[2];
  matrix[i] -= vals[3];
}

- (float)determinant
{
  return G3DDeterminante4fv(matrix);
}

- (G3DVector4f *)vectorByPreMultiplying:(G3DVector4f *)aTuple
{
  float n[4] __attribute__ ((aligned));

  G3DVector4fXMatrix4f(n, [aTuple elements], matrix);
  return [[[G3DVector4fClass alloc] initWithElements:(const float*)n] autorelease];
}

- (G3DVector4f *)vectorByPostMultiplying:(G3DVector4f *)aTuple
{
  float n[4] __attribute__ ((aligned));

  G3DMatrix4fXVector4f(n, matrix, [aTuple elements]);
  return [[[G3DVector4fClass alloc] initWithElements:(const float*)n] autorelease];
}

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

- (G3DVector4f *)translation
{
  return [[[G3DVector4fClass alloc] initWithElements:(const float*)&matrix[12]] autorelease];
}

- (void)setTranslation:(G3DVector4f *)t
{
  G3DCopyVector4fv(&matrix[12],[t elements]);
}

- (G3DVector4f *)scale
{
  return [[[G3DVector4fClass alloc] initWithX:matrix[0] y:matrix[5] z:matrix[10] w:matrix[15]] autorelease];
}

- (void)setScale:(G3DVector4f *)scale
{
  G3DMakeScale4fv(matrix,[scale elements]);
}

- (G3DQuaternionf *)quaternion
{
  G3DQuaternionf *quat;
  float q[4];
    
  G3DQuatFromMatrixf(q, matrix);
  
  quat = [[G3DQuaternionf alloc] initWithElements:(const float*)q];
  return [quat autorelease];
}

- (void)setQuaternion:(G3DQuaternionf *)aQuat
{
  G3DMatrixFromQuatf(matrix, [aQuat elements]);
}

- (void)setMatrix:(G3DMatrix4f *)aMatrix
{
  G3DCopyMatrix4fv(matrix,[aMatrix elements]);
}

- (void)setXRotation:(const float)angle
{
  G3DMakeXRotation4f(matrix,angle);
}

- (void)setYRotation:(const float)angle
{
  G3DMakeYRotation4f(matrix,angle);
}

- (void)setZRotation:(const float)angle
{
  G3DMakeZRotation4f(matrix,angle);
}

- (void)setRotation:(const float)angle axis:(const float *)axis;
{
  G3DMakeRotation4f(matrix,angle,axis);
}

- (void)setRotation:(const float)angle axisVector:(G3DVector3f *)vec
{
  G3DMakeRotation4f(matrix,angle,[vec elements]);
}

- (void)setRotation:(G3DMatrix4f *)vals translation:(G3DVector3f *)trans scale:(const float)factor
{
  const float *rot = [vals elements];
  const float *t = [trans elements];

  G3DMakeTranslationRotationScale4f(matrix,t,rot,factor);
}

- (void)setQuaternion:(G3DQuaternionf *)q translation:(G3DVector3f *)t scale:(const float)s
{
  const float *quat = [q elements];
  const float *trans = [t elements];

  G3DMakeTranslationQuatScale4f(matrix,trans,quat,s);  
}

- (void)setElements:(const float *)vals
{
  G3DCopyMatrix4fv(matrix,vals);
}

- (const float *)elements
{
  return (const float*)matrix;
}

- (G3DVector4f *)rowVectorAtIndex:(const int)row
{
  G3DVector4f *vec = [[G3DVector4f alloc] init];
  float tmp[4] __attribute__ ((aligned));

  tmp[0] = matrix[row];
  tmp[1] = matrix[row+4];
  tmp[2] = matrix[row+8];
  tmp[3] = matrix[row+12];

  [vec setElements:tmp];

  return [vec autorelease];
}

- (G3DVector4f *)columnVectorAtIndex:(const int)col
{
  G3DVector4f *vec = [[G3DVector4f alloc] init];
  float tmp[4] __attribute__ ((aligned));
  int r = (col*4);

  tmp[0] = matrix[r++];
  tmp[1] = matrix[r++];
  tmp[2] = matrix[r++];
  tmp[3] = matrix[r];

  [vec setElements:tmp];

  return [vec autorelease];
}

- (void)setElement:(const float)val atRow:(const int)row column:(const int)col
{
  matrix[(col*4) + row] = val;
}

- (float)elementAtRow:(const int)row column:(const int)col
{
  return matrix[(col*4) + row];
}

//-----------------------------------------------------------------------------
// misc
//-----------------------------------------------------------------------------

- (BOOL)isEqualToMatrix:(G3DMatrix4f *)aMatrix
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
  [aCoder encodeArrayOfObjCType:@encode(float) count:16 at:matrix];
  [aCoder encodeValueOfObjCType:@encode(int) at:&_mode];
  [aCoder encodeArrayOfObjCType:@encode(float) count:16 at:_t];
  [aCoder encodeArrayOfObjCType:@encode(float) count:16 at:_i];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
  self = [super init];
  [aCoder decodeArrayOfObjCType:@encode(float) count:16 at:matrix];
  [aCoder decodeValueOfObjCType:@encode(int) at:&_mode];
  [aCoder decodeArrayOfObjCType:@encode(float) count:16 at:_t];
  [aCoder decodeArrayOfObjCType:@encode(float) count:16 at:_i];
  return self;
}

//-----------------------------------------------------------------------------
// NSCopying
//-----------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
  G3DMatrix4f *copy = [[G3DMatrix4f allocWithZone:zone] init];

  G3DCopyMatrix4fv(copy->matrix,matrix);
  G3DCopyMatrix4fv(copy->_t,_t);
  G3DCopyMatrix4fv(copy->_i,_t);
  copy->_mode = _mode;

  return copy;
}

@end






