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
// $Id: G3DMatrix3f.h,v 1.6 2002/10/21 19:32:54 probert Exp $
//-----------------------------------------------------------------------------

#ifndef __G3DMatrix3f_h_INCLUDE
#define __G3DMatrix3f_h_INCLUDE

#import <Foundation/Foundation.h>
#import "G3DDefs.h"

@class G3DTuple3f;
@class G3DVector3f;
@class G3DQuaternion;

/*!
   @class      G3DMatrix3f
   @abstract   A generic 3 by 3 matrix.
   @discussion A single-precision floating point 3 by 3 matrix. Primarily to support
               3D rotations.
*/

@interface G3DMatrix3f : NSObject <NSCoding, NSCopying>
{
  float matrix[9];
    
  int _mode;           // G3DMatrixType
  float _t[9];         // the transposed
  float _i[9];         // the inverted
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)init;
- (id)initWithMatrix3f:(G3DMatrix3f *)aMatrix;
- (id)initWithElements:(const float *)vals;

//-----------------------------------------------------------------------------
// math
//-----------------------------------------------------------------------------

- (void)addMatrix:(G3DMatrix3f *)a;
- (void)subMatrix:(G3DMatrix3f *)a;

- (void)multiplyByMatrix:(G3DMatrix3f *)a;
- (void)multiplyByMatrix:(G3DMatrix3f *)a and:(G3DMatrix3f *)b;
- (void)multiplyByMatrix:(G3DMatrix3f *)a andTransposed:(G3DMatrix3f *)b;
- (void)multiplyByTransposedMatrix:(G3DMatrix3f *)a and:(G3DMatrix3f *)b;
- (void)multiplyByTransposedMatrix:(G3DMatrix3f *)a andTransposed:(G3DMatrix3f *)b;

- (void)multiplyByMatrices:(NSArray *)matrices;

- (G3DTuple3f *)vectorByPreMultiplying:(G3DTuple3f *)aTuple;
// Returns aTuple * self;
- (G3DTuple3f *)vectorByPostMultiplying:(G3DTuple3f *)aTuple;
// Returns self * aTuple

- (BOOL)invert;
- (G3DMatrix3f *)invertedMatrix;

- (void)transpose;
- (G3DMatrix3f *)transposedMatrix;

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

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

- (void)setMatrix:(G3DMatrix3f *)aMatrix;

- (void)setXRotation:(const float)angle;
- (void)setYRotation:(const float)angle;
- (void)setZRotation:(const float)angle;
- (void)setRotation:(const float)angle axis:(const float *)axis;
- (void)setRotation:(const float)angle axisVector:(G3DVector3f *)vec;

- (G3DVector3f *)scale;
- (void)setScale:(G3DVector3f *)factor;

- (void)setElements:(const float *)vals;
- (const float *)elements;

- (G3DVector3f *)rowVectorAtIndex:(const int)row;
- (G3DVector3f *)columnVectorAtIndex:(const int)col;

- (void)setElement:(const float)val atRow:(const int)row column:(const int)col;
- (float)elementAtRow:(const int)row column:(const int)col;

//-----------------------------------------------------------------------------
// misc
//-----------------------------------------------------------------------------

- (NSString *)description;

- (BOOL)isEqualToMatrix:(G3DMatrix3f *)aMatrix;

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

extern NSString *G3DMatrix3fException;

#endif




