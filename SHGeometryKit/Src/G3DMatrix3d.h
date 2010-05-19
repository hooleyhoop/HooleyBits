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
// $Id: G3DMatrix3d.h,v 1.7 2002/10/27 20:17:02 probert Exp $
//-----------------------------------------------------------------------------

#ifndef __G3DMatrix3d_h_INCLUDE
#define __G3DMatrix3d_h_INCLUDE

#import <Foundation/Foundation.h>
#import "G3DDefs.h"

@class G3DTuple3d;
@class G3DVector3d;
@class G3DQuaternion;

/*!
   @class      G3DMatrix3d
   @abstract   A generic 3 by 3 matrix.
   @discussion A double-precision floating point 3 by 3 matrix. Primarily to support
               3D rotations.
*/

@interface G3DMatrix3d : NSObject <NSCoding, NSCopying>
{
  double matrix[9];
  
  int _mode;           // G3DMatrixType
  double _t[9];        // the transposed
  double _i[9];        // the inverted
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

/*! 
   @method init   
   @abstract Creates a 3 by 3 unit matrix. 
   @result Returns the newly initialised matrix object or nil on error.
*/
- (id)init;

/*! 
   @method initWithMatrix3d:   
   @abstract Creates a 3 by 3 matrix initialised with another matrix by invoking 
             initWithElements:. 
   @param aMatrix Another 3 by 3 matrix object
   @result  Returns the newly initialised matrix object or nil on error.
*/
- (id)initWithMatrix3d:(G3DMatrix3d *)aMatrix;

/*! 
   @method initWithElements:   
   @abstract Creates a 3 by 3 matrix initialised with the elements 
             specified in the C array. This is the designated initialiser!
   @param vals A C array specifying the tuple
   @result  Returns the newly initialised matrix object or nil on error.
*/
- (id)initWithElements:(const double *)vals;

//-----------------------------------------------------------------------------
// math
//-----------------------------------------------------------------------------

/*! 
   @method addMatrix:   
   @abstract Adds a 3 by 3 matrix to the receiver. 
   @param a Another matrix object
*/
- (void)addMatrix:(G3DMatrix3d *)a;

/*! 
   @method subMatrix:   
   @abstract Subtracts a 3 by 3 matrix from the receiver. 
   @param a Another matrix object
*/
- (void)subMatrix:(G3DMatrix3d *)a;

/*! 
   @method multiplyByMatrix:   
   @abstract Multiplies the receiver by the 3 by 3 matrix a. 
   @param a Another matrix object
*/
- (void)multiplyByMatrix:(G3DMatrix3d *)a;

/*! 
   @method multiplyByMatrix:and:
   @abstract Multiplies the 3 by 3 matrices a and b and stores the result in the receiver. 
   @param a The first matrix object
   @param b The second matrix object
*/
- (void)multiplyByMatrix:(G3DMatrix3d *)a and:(G3DMatrix3d *)b;

/*! 
   @method multiplyByMatrix:andTransposed:
   @abstract Multiplies the 3 by 3 matrix a by the transposed of the 3 by 3 matrix b and stores 
             the result in the receiver. 
   @param a The first matrix object
   @param b The second matrix object
*/
- (void)multiplyByMatrix:(G3DMatrix3d *)a andTransposed:(G3DMatrix3d *)b;

/*! 
   @method multiplyByTransposedMatrix:and:   
   @abstract Multiplies the transposed of the 3 by 3 matrix a by the 3 by 3 matrix b and stores 
             the result in the receiver. 
   @param a The first matrix object
   @param b The second matrix object
*/
- (void)multiplyByTransposedMatrix:(G3DMatrix3d *)a and:(G3DMatrix3d *)b;

/*! 
   @method multiplyByTransposedMatrix:andTransposed:   
   @abstract Multiplies the transposed of the 3 by 3 matrix a by the transposed of the 3 by 3 
             matrix b and stores the result in the receiver. 
   @param a The first matrix object
   @param b The second matrix object
*/
- (void)multiplyByTransposedMatrix:(G3DMatrix3d *)a andTransposed:(G3DMatrix3d *)b;

/*! 
   @method multiplyByMatrices:   
   @abstract Multiplies the receiver by all 3 by 3 matrices. 
   @param matrices An array of 3 by 3 matrix object
*/
- (void)multiplyByMatrices:(NSArray *)matrices;

/*! 
   @method vectorByPreMultiplying:   
   @abstract Premultiplies the receiver by aTuple. 
   @param aTuple A 3-element tuple object
*/
- (G3DTuple3d *)vectorByPreMultiplying:(G3DTuple3d *)aTuple;

/*! 
   @method vectorByPostMultiplying:   
   @abstract Postmultiplies the receiver by aTuple. 
   @param aTuple A 3-element tuple object
*/
- (G3DTuple3d *)vectorByPostMultiplying:(G3DTuple3d *)aTuple;

/*! 
   @method invert:   
   @abstract Performs the matrix inversion of the receiver. 
*/
- (BOOL)invert;

/*! 
   @method invertedMatrix:   
   @abstract Returns the inverse of the receiver.
   @result Returns an autoreleased 3 by 3 matrix object. 
*/
- (G3DMatrix3d *)invertedMatrix;

/*! 
   @method transpose:   
   @abstract Performs the matrix transposition of the receiver. 
*/
- (void)transpose;

/*! 
   @method transposedMatrix:   
   @abstract Returns the transpose of the receiver.
   @result Returns an autoreleased 3 by 3 matrix object. 
*/
- (G3DMatrix3d *)transposedMatrix;

/*! 
   @method addScalar:   
   @abstract Adds a double-precision scalar value to all elements of the receiver.
   @param scalar A scalar value 
*/
- (void)addScalar:(const double)scalar;

/*! 
   @method subScalar:   
   @abstract Subtracts a double-precision scalar value from all elements of the receiver.
   @param scalar A scalar value 
*/
- (void)subScalar:(const double)scalar;

/*! 
   @method multiplyByScalar:   
   @abstract Multiplies the receiver by a double-precision scalar value.
   @param scalar A scalar value 
*/
- (void)multiplyByScalar:(const double)scalar;

/*! 
   @method divideByScalar:   
   @abstract Divides the receiver by a double-precision scalar value. Raises a G3DMatrix3dException
             exception if scalar is equal to 0.0.
   @param scalar A scalar value 
*/
- (void)divideByScalar:(const double)scalar;

/*! 
   @method multiplyRow:byValue:   
   @abstract Multiplies the row pos of the receiver by a double-precision scalar value.
   @param pos The row position
   @param val A scalar value 
*/
- (void)multiplyRow:(const int)pos byValue:(const double)val;

/*! 
   @method multiplyCol:byValue:   
   @abstract Multiplies the column pos of the receiver by a double-precision scalar value.
   @param pos The column position
   @param val A scalar value 
*/
- (void)multiplyCol:(const int)pos byValue:(const double)val;

/*! 
   @method addElements:toRow:   
   @abstract Adds the double-precision row elements vals to the row rowPos of the receiver.
   @param vals The row elements
   @param rowPos The row position 
*/
- (void)addElements:(const double *)vals toRow:(const int)rowPos;

/*! 
   @method addElements:toColumn:   
   @abstract Adds the double-precision column elements vals to the column colPos of the receiver.
   @param vals The column elements
   @param colPos The column position 
*/
- (void)addElements:(const double *)vals toColumn:(const int)colPos;

/*! 
   @method subElements:fromRow:   
   @abstract Subtracts the double-precision row elements vals from the row rowPos of the receiver.
   @param vals The row elements
   @param rowPos The row position 
*/
- (void)subElements:(const double *)vals fromRow:(const int)rowPos;

/*! 
   @method subElements:fromColumn:   
   @abstract Subtracts the double-precision column elements vals from the column colPos of the 
             receiver.
   @param vals The column elements
   @param colPos The column position 
*/
- (void)subElements:(const double *)vals fromColumn:(const int)colPos;

/*! 
   @method determinant   
   @abstract Calculates the determinant of the receiver.
   @result Returns the double-precision determinant of the receiver. 
*/
- (double)determinant;

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

/*! 
   @method setMatrix:   
   @abstract Copies the elements of aMatrix to the receiver.
   @param aMatrix A 3 by 3 matrix object. 
*/
- (void)setMatrix:(G3DMatrix3d *)aMatrix;

/*! 
   @method setXRotation:   
   @abstract Configures the reciever as a rotation matrix which rotates by angle degrees around 
             the X axis.
   @param angle A double-precision rotation angle. 
*/
- (void)setXRotation:(const double)angle;

/*! 
   @method setYRotation:   
   @abstract Configures the reciever as a rotation matrix which rotates by angle degrees around 
             the Y axis.
   @param angle A double-precision rotation angle. 
*/
- (void)setYRotation:(const double)angle;

/*! 
   @method setZRotation:   
   @abstract Configures the reciever as a rotation matrix which rotates by angle degrees around 
             the Z axis.
   @param angle A double-precision rotation angle. 
*/
- (void)setZRotation:(const double)angle;

/*! 
   @method setRotation:axis: 
   @abstract Configures the reciever as a rotation matrix which rotates by angle degrees around 
             the passed axis.
   @param angle A double-precision rotation angle. 
   @param axis The 3 rotation axis vector elements. 
*/
- (void)setRotation:(const double)angle axis:(const double *)axis;

/*! 
   @method setRotation:axisVector: 
   @abstract Configures the reciever as a rotation matrix which rotates by angle degrees around 
             the passed axis.
   @param angle A double-precision rotation angle. 
   @param vec The rotation axis vector object. 
*/
- (void)setRotation:(const double)angle axisVector:(G3DVector3d *)vec;

/*! 
   @method scale 
   @abstract Creates a 3-element vector from the scaling elements of the receiver.
   @result Returns an autoreleased 3-element, double-precision vector. 
*/
- (G3DVector3d *)scale;

/*! 
   @method setScale: 
   @abstract Set the scaling values of the receiver to factor.
   @param factor A 3-element, double-precision scaling vector. 
*/
- (void)setScale:(G3DVector3d *)factor;

/*! 
   @method setElements: 
   @abstract Set the elements of the receiver to vals.
   @param vals 9 double-precision matrix elements. 
*/
- (void)setElements:(const double *)vals;

/*! 
   @method elements 
   @abstract Returns a pointer to the matrix elements.
*/
- (const double *)elements;

/*! 
   @method rowVectorAtIndex: 
   @abstract Creates a row vector from the row elements at row row.
   @param row A row index.
   @result Returns an autoreleased 3-element, double-precision row vector.
*/
- (G3DVector3d *)rowVectorAtIndex:(const int)row;

/*! 
   @method columnVectorAtIndex: 
   @abstract Creates a column vector from the column elements at column col.
   @param col A column index.
   @result Returns an autoreleased 3-element, double-precision row vector.
*/
- (G3DVector3d *)columnVectorAtIndex:(const int)col;

/*! 
   @method setElement:atRow:column: 
   @abstract Sets the element at row row and column col to val.
   @param val A double-precision matrix element.
   @param row A row index.
   @param col A column index.
*/
- (void)setElement:(const double)val atRow:(const int)row column:(const int)col;

/*! 
   @method elementAtRow:column: 
   @abstract Returns the element at row row and column col.
   @param row A row index.
   @param col A column index.
   @result Returns a double-precision floating point matrix element.
*/
- (double)elementAtRow:(const int)row column:(const int)col;

//-----------------------------------------------------------------------------
// misc
//-----------------------------------------------------------------------------

/*! 
   @method description
   @abstract Returns a description of the matrix.
   @result Returns a NSString object describing the receiver's elements.
*/
- (NSString *)description;

/*! 
   @method isEqualToMatrix:   
   @abstract Checks if the passed object is equal to the receiver.
   @param aMatrix Another 3 by 3 double-precision matrix.
   @result Returns YES if anObj is equivalent to the receiver, NO otherwise.
*/
- (BOOL)isEqualToMatrix:(G3DMatrix3d *)aMatrix;

//-----------------------------------------------------------------------------
// NSCoding
//-----------------------------------------------------------------------------

/*! 
   @method encodeWithCoder:
   @abstract Encodes the receiver using encoder.
*/
- (void)encodeWithCoder:(NSCoder *)aCoder;

/*! 
   @method initWithCoder:
   @abstract Initializes a newly allocated instance from data in aCoder.
   @result Returns self.
*/
- (id)initWithCoder:(NSCoder *)aCoder;

//-----------------------------------------------------------------------------
// NSCopying
//-----------------------------------------------------------------------------

/*! 
   @method copyWithZone:
   @abstract Returns a new instance that's a copy of the receiver. Memory for the new 
             instance is allocated from zone, which may be nil. If zone is nil, the new 
             instance is allocated from the default zone, which is returned from the 
             function NSDefaultMallocZone. The returned object is implicitly retained 
             by the sender, who is responsible for releasing.
   @result Returns a new instance that's a copy of the receiver.
*/
- (id)copyWithZone:(NSZone *)zone;

@end

extern NSString *G3DMatrix3dException;

#endif




