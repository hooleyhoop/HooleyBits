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
// $Id: G3DMatrix4f.h,v 1.6 2002/10/21 19:32:54 probert Exp $
//-----------------------------------------------------------------------------

#ifndef __G3DMatrix4f_h_INCLUDE
#define __G3DMatrix4f_h_INCLUDE

#import <Foundation/Foundation.h>
#import "G3DDefs.h"

@class G3DMatrix3f;
@class G3DTuple3f;
@class G3DTuple4f;
@class G3DVector3f;
@class G3DVector4f;
@class G3DQuaternionf;

/*!
   @class      G3DMatrix4f
   @abstract   A generic 4 by 4 matrix.
   @discussion A single-precision floating point 4 by 4 matrix. Primarily to support
               generic 3D transformations.
*/

@interface G3DMatrix4f : NSObject <NSCoding, NSCopying>
{
  float matrix[16];

  int _mode;           // G3DMatrixType
  float _t[16];        // Transposed
  float _i[16];        // Inverted
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)init;
- (id)initWithMatrix4f:(G3DMatrix4f *)aMatrix;
- (id)initWithElements:(const float *)vals;

- (id)initWithRotation:(G3DMatrix4f *)vals translation:(G3DVector3f *)t scale:(float)factor;
// self = S * R * T

- (id)initWithQuaternion:(G3DQuaternionf *)q translation:(G3DVector3f *)t scale:(float)s;

- (void)dealloc;

//-----------------------------------------------------------------------------
// math
//-----------------------------------------------------------------------------

- (void)addMatrix:(G3DMatrix4f *)a;
- (void)subMatrix:(G3DMatrix4f *)a;

- (void)multiplyByMatrix:(G3DMatrix4f *)a;
- (void)multiplyByMatrix:(G3DMatrix4f *)a and:(G3DMatrix4f *)b;
- (void)multiplyByMatrix:(G3DMatrix4f *)a andTransposed:(G3DMatrix4f *)b;
- (void)multiplyByTransposedMatrix:(G3DMatrix4f *)a and:(G3DMatrix4f *)b;
- (void)multiplyByTransposedMatrix:(G3DMatrix4f *)a andTransposed:(G3DMatrix4f *)b;

- (void)multiplyByMatrices:(NSArray *)matrices;

- (BOOL)invert;
- (G3DMatrix4f *)invertedMatrix;

- (void)transpose;
- (G3DMatrix4f *)transposedMatrix;

- (void)addScalar:(const float)scalar;
- (void)subScalar:(const float)scalar;

- (void)multiplyByScalar:(const float)scalar;
- (void)divideByScalar:(const float)scalar;

- (void)multiplyRow:(const int)pos byValue:(const float)val;
- (void)multiplyCol:(const int)pos byValue:(const float)val;

- (void)addElements:(const float *)vals toRow:(const int)rowPos;
- (void)addElements:(const float *)vals toColumn:(const int)colPos;

- (void)subElements:(const float *)vals fromRow:(const int)rowPos;
- (void)subElements:(const float *)vals fromColumn:(const int)colPos;

- (float)determinant;

- (G3DVector4f *)vectorByPreMultiplying:(G3DVector4f *)aTuple;
  // Returns aTuple * self;

- (G3DVector4f *)vectorByPostMultiplying:(G3DVector4f *)aTuple;
  // Returns self * aTuple

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

- (G3DVector4f *)translation;
- (void)setTranslation:(G3DVector4f *)t;

- (G3DVector4f *)scale;
- (void)setScale:(G3DVector4f *)scale;

- (G3DQuaternionf *)quaternion;
- (void)setQuaternion:(G3DQuaternionf *)aQuat;

- (void)setMatrix:(G3DMatrix4f *)aMatrix;

- (void)setXRotation:(const float)angle;
- (void)setYRotation:(const float)angle;
- (void)setZRotation:(const float)angle;
- (void)setRotation:(const float)angle axis:(const float *)axis;
- (void)setRotation:(const float)angle axisVector:(G3DVector3f *)vec;

- (void)setRotation:(G3DMatrix4f *)vals translation:(G3DVector3f *)t scale:(const float)factor;
- (void)setQuaternion:(G3DQuaternionf *)q translation:(G3DVector3f *)t scale:(const float)s;

- (void)setElements:(const float *)vals;
- (const float *)elements;

- (G3DVector4f *)rowVectorAtIndex:(const int)row;
- (G3DVector4f *)columnVectorAtIndex:(const int)col;

- (void)setElement:(const float)val atRow:(const int)row column:(const int)col;
- (float)elementAtRow:(const int)row column:(const int)col;

//-----------------------------------------------------------------------------
// misc
//-----------------------------------------------------------------------------

- (BOOL)isEqualToMatrix:(G3DMatrix4f *)aMatrix;

- (NSString *)description;

//-----------------------------------------------------------------------------
// NSCoding
//-----------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aCoder;

//-----------------------------------------------------------------------------
// NSCopying
//-----------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone;

@end

extern NSString *G3DMatrix4fException;

#endif




