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
// $Id: G3DMatrix4d.h,v 1.6 2002/10/21 19:32:54 probert Exp $
//-----------------------------------------------------------------------------

#ifndef __G3DMatrix4d_h_INCLUDE
#define __G3DMatrix4d_h_INCLUDE

#import <Foundation/Foundation.h>
#import "G3DDefs.h"

@class G3DMatrix3d;
@class G3DTuple3d;
@class G3DTuple4d;
@class G3DVector3d;
@class G3DVector4d;
@class G3DQuaterniond;

/*!
   @class      G3DMatrix4d
   @abstract   A generic 4 by 4 matrix.
   @discussion A double-precision floating point 4 by 4 matrix. Primarily to support
               generic 3D transformations.
*/

@interface G3DMatrix4d : NSObject <NSCoding, NSCopying>
{
  double matrix[16];

  int _mode;           // G3DMatrixType
  double _t[16];       // Transposed
  double _i[16];       // Inverted
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)init;
- (id)initWithMatrix4d:(G3DMatrix4d *)aMatrix;
- (id)initWithElements:(const double *)vals;

- (id)initWithRotation:(G3DMatrix4d *)vals translation:(G3DVector3d *)t scale:(const double)factor;
// self = S * R * T

- (id)initWithQuaternion:(G3DQuaterniond *)q translation:(G3DVector3d *)t scale:(const double)s;

//-----------------------------------------------------------------------------
// math
//-----------------------------------------------------------------------------

- (void)addMatrix:(G3DMatrix4d *)a;
- (void)subMatrix:(G3DMatrix4d *)a;

- (void)multiplyByMatrix:(G3DMatrix4d *)a;
- (void)multiplyByMatrix:(G3DMatrix4d *)a and:(G3DMatrix4d *)b;
- (void)multiplyByMatrix:(G3DMatrix4d *)a andTransposed:(G3DMatrix4d *)b;
- (void)multiplyByTransposedMatrix:(G3DMatrix4d *)a and:(G3DMatrix4d *)b;
- (void)multiplyByTransposedMatrix:(G3DMatrix4d *)a andTransposed:(G3DMatrix4d *)b;

- (void)multiplyByMatrices:(NSArray *)matrices;

- (BOOL)invert;
- (G3DMatrix4d *)invertedMatrix;

- (void)transpose;
- (G3DMatrix4d *)transposedMatrix;

- (void)addScalar:(const double)scalar;
- (void)subScalar:(const double)scalar;

- (void)multiplyByScalar:(const double)scalar;
- (void)divideByScalar:(const double)scalar;

- (void)multiplyRow:(const int)pos byValue:(const double)val;
- (void)multiplyCol:(const int)pos byValue:(const double)val;

- (void)addElements:(const double *)vals toRow:(const int)rowPos;
- (void)addElements:(const double *)vals toColumn:(const int)colPos;

- (void)subElements:(const double *)vals fromRow:(const int)rowPos;
- (void)subElements:(const double *)vals fromColumn:(const int)colPos;

- (double)determinant;

- (G3DVector4d *)vectorByPreMultiplying:(G3DVector4d *)aTuple;
  // Returns aTuple * self;

- (G3DVector4d *)vectorByPostMultiplying:(G3DVector4d *)aTuple;
  // Returns self * aTuple

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

- (G3DVector4d *)translation;
- (void)setTranslation:(G3DVector4d *)t;

- (G3DVector4d *)scale;
- (void)setScale:(G3DVector4d *)scale;

- (G3DQuaterniond *)quaternion;
- (void)setQuaternion:(G3DQuaterniond *)aQuat;

- (void)setMatrix:(G3DMatrix4d *)aMatrix;

- (void)setXRotation:(const double)angle;
- (void)setYRotation:(const double)angle;
- (void)setZRotation:(const double)angle;
- (void)setRotation:(const double)angle axis:(const double *)axis;
- (void)setRotation:(const double)angle axisVector:(G3DVector3d *)vec;

- (void)setRotation:(G3DMatrix4d *)vals translation:(G3DVector3d *)t scale:(const double)factor;
- (void)setQuaternion:(G3DQuaterniond *)q translation:(G3DVector3d *)t scale:(const double)s;

- (void)setElements:(const double *)vals;
- (const double *)elements;

- (G3DVector4d *)rowVectorAtIndex:(const int)row;
- (G3DVector4d *)columnVectorAtIndex:(const int)col;

- (void)setElement:(const double)val atRow:(const int)row column:(const int)col;
- (double)elementAtRow:(const int)row column:(const int)col;

//-----------------------------------------------------------------------------
// misc
//-----------------------------------------------------------------------------

- (BOOL)isEqualToMatrix:(G3DMatrix4d *)aMatrix;

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

extern NSString *G3DMatrix4dException;

#endif




