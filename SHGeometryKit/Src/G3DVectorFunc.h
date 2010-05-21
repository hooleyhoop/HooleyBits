//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class              	G3DVectorFunc
// Creator            	Philippe C.D. Robert
// Maintainer         	Philippe C.D. Robert
// Creation Date      	2001-01-05 15:07:17 +0000
//
// Copyright (c) Philippe C.D. Robert
//
// The SHGeometryKit is free software; you can redistribute it and/or modify it 
// under the terms of the GNU LGPL Version 2 as published by the Free 
// Software Foundation
//
// $Id: G3DVectorFunc.h,v 1.3 2002/10/27 12:44:21 probert Exp $
//
//-----------------------------------------------------------------------------

/*!
  @header G3DVectorFunc
  Optimised vector computation C functions.
*/

#ifndef __G3DVectorFunc_h_INCLUDE
#define __G3DVectorFunc_h_INCLUDE

#import "G3DFunctions.h"
#import <Quartz/Quartz.h>

/*! 
  @function G3DAddScaledVector3fv
  @discussion Performs the single-precision floating point addition of p and lambda * q.
  @param res The resulting vector
  @param p The first vector
  @param q The second vector
  @param lambda The scaling factor
*/
__G3DIE__ void G3DAddScaledVector3fv(CGFloat res[3], CFLOAT p[3], CFLOAT q[3], CFLOAT lambda);

/*! 
  @function G3DAddScaledVector3dv
  @discussion Performs the double-precision floating point addition of p and lambda * q.
  @param res The resulting vector
  @param p The first vector
  @param q The second vector
  @param lambda The scaling factor
*/
__G3DIE__ void G3DAddScaledVector3dv(double res[3], CDOUBLE p[3], CDOUBLE q[3], CDOUBLE lambda);

/*! 
  @function G3DAddScaledVectors3fv
  @discussion Performs the single-precision floating point addition of p and lambda1 * q and 
              lambda2 * r.
  @param res The resulting vector
  @param p The first vector
  @param q The second vector
  @param lambda1 The fist scaling factor
  @param lambda2 The second scaling factor
*/
__G3DIE__ void G3DAddScaledVectors3fv(CGFloat res[3], CFLOAT p[3], CFLOAT q[3], CFLOAT lambda1, CFLOAT r[3], CFLOAT lambda2);

/*! 
  @function G3DAddScaledVectors3dv
  @discussion Performs the double-precision floating point addition of p and lambda1 * q and 
              lambda2 * r.
  @param res The resulting vector
  @param p The first vector
  @param q The second vector
  @param lambda1 The fist scaling factor
  @param lambda2 The second scaling factor
*/
__G3DIE__ void G3DAddScaledVectors3dv(double res[3], CDOUBLE p[3], CDOUBLE q[3], CDOUBLE lambda1, CDOUBLE r[3], CDOUBLE lambda2);

/*! 
  @function G3DVector3fFromEulerRep
  @discussion Computes the single-precision vector from Euler Angles.
  @param res The resulting vector
  @param src The Euler angles
*/
__G3DIE__ void G3DVector3fFromEulerRep(CGFloat res[3], CFLOAT src[3]);

/*! 
  @function G3DVector3dFromEulerRep
  @discussion Computes the double-precision vector from Euler Angles.
  @param res The resulting vector
  @param src The Euler angles
*/
__G3DIE__ void G3DVector3dFromEulerRep(double res[3], CDOUBLE src[3]);

/*! 
  @function G3DEulerRepFromVector3f
  @discussion Computes the single-precision Euler Angles from a vector. The 3rd (roll) component
              is thereby set to 0.0
  @param res The resulting vector
  @param src The Euler angles
*/
__G3DIE__ void G3DEulerRepFromVector3f(CGFloat res[3], CFLOAT src[3]);

/*! 
  @function G3DEulerRepFromVector3d
  @discussion Computes the double-precision Euler Angles from a vector. The 3rd (roll) component
              is thereby set to 0.0
  @param res The resulting vector
  @param src The Euler angles
*/
__G3DIE__ void G3DEulerRepFromVector3d(double res[3], CDOUBLE src[3]);

/*! 
  @function G3DTransformVector3fv
  @discussion Transforms the 3-element, single-precision vector src by the transformation matrix 
              mat.
  @param res The transformed vector
  @param src The original vector
  @param mat The transformation matrix
*/
__G3DIE__ void G3DTransformVector3fv(CGFloat res[3],CFLOAT src[3], CFLOAT mat[16]);

/*! 
  @function G3DTransformVector3dv
  @discussion Transforms the 3-element, double-precision vector src by the transformation matrix 
              mat.
  @param res The transformed vector
  @param src The original vector
  @param mat The transformation matrix
*/
__G3DIE__ void G3DTransformVector3dv(double res[3],CDOUBLE src[3], CDOUBLE mat[16]);

/*! 
  @function G3DTransformVector4fv
  @discussion Transforms the 4-element, single-precision vector src by the transformation matrix 
              mat.
  @param res The transformed vector
  @param src The original vector
  @param mat The transformation matrix
*/
__G3DIE__ void G3DTransformVector4fv(CGFloat res[4],CFLOAT src[4], CFLOAT mat[16]);

/*! 
  @function G3DTransformVector4dv
  @discussion Transforms the 4-element, double-precision vector src by the transformation matrix 
              mat.
  @param res The transformed vector
  @param src The original vector
  @param mat The transformation matrix
*/
__G3DIE__ void G3DTransformVector4dv(double res[4],CDOUBLE src[4], CDOUBLE mat[16]);

/*! 
  @function G3DMultiplyVector3fv
  @discussion Computes the 3-element, single-precision vector multiplication of a and b.
  @param res The multiplied vector
  @param a The first vector
  @param a The second vector
*/
__G3DIE__ void G3DMultiplyVector3fv(CGFloat res[3], CFLOAT a[3], CFLOAT b[3]);

/*! 
  @function G3DMultiplyVector3dv
  @discussion Computes the 3-element, double-precision vector multiplication of a and b.
  @param res The multiplied vector
  @param a The first vector
  @param a The second vector
*/
__G3DIE__ void G3DMultiplyVector3dv(double res[3], CDOUBLE a[3], CDOUBLE b[3]);

/*! 
  @function G3DCopyVector2f
  @discussion Copies the 2 single-precision vector elements x and y to res.
  @param res The destination
  @param x The first element
  @param y The second element
*/
__G3DIE__ void G3DCopyVector2f(CGFloat res[2], CFLOAT x, CFLOAT y);

/*! 
  @function G3DCopyVector2d
  @discussion Copies the 2 double-precision vector elements x and y to res.
  @param res The destination
  @param x The first element
  @param y The second element
*/
__G3DIE__ void G3DCopyVector2d(double res[2], CDOUBLE x, CDOUBLE y);

/*! 
  @function G3DCopyVector3f
  @discussion Copies the 3 single-precision vector elements x, y and z to res.
  @param res The destination
  @param x The first element
  @param y The second element
  @param z The third element
*/
__G3DIE__ void G3DCopyVector3f(CGFloat res[3], CFLOAT x, CFLOAT y, CFLOAT z);

/*! 
  @function G3DCopyVector3d
  @discussion Copies the 3 double-precision vector elements x, y and z to res.
  @param res The destination
  @param x The first element
  @param y The second element
  @param z The third element
*/
__G3DIE__ void G3DCopyVector3d(double res[3], CDOUBLE x, CDOUBLE y, CDOUBLE z);

/*! 
  @function G3DCopyVector4f
  @discussion Copies the 4 single-precision vector elements x, y, z and h to res.
  @param res The destination
  @param x The first element
  @param y The second element
  @param z The third element
  @param h The forth element
*/
__G3DIE__ void G3DCopyVector4f(CGFloat res[4], CFLOAT x, CFLOAT y, CFLOAT z, CFLOAT h);

/*! 
  @function G3DCopyVector4d
  @discussion Copies the 4 double-precision vector elements x, y, z and h to res.
  @param res The destination
  @param x The first element
  @param y The second element
  @param z The third element
  @param h The forth element
*/
__G3DIE__ void G3DCopyVector4d(double res[4], CDOUBLE x, CDOUBLE y, CDOUBLE z, CDOUBLE h);

/*! 
  @function G3DCopyVector2fv
  @discussion Copies the 2-element, single-precision vector orig to cpy.
  @param cpy The destination
  @param orig The source vector
*/
__G3DIE__ void G3DCopyVector2fv(CGFloat cpy[2], CFLOAT orig[2]);

/*! 
  @function G3DCopyVector2dv
  @discussion Copies the 2-element, double-precision vector orig to cpy.
  @param cpy The destination
  @param orig The source vector
*/
__G3DIE__ void G3DCopyVector2dv(double cpy[2], CDOUBLE orig[2]);

/*! 
  @function G3DCopyVector3fv
  @discussion Copies the 3-element, single-precision vector orig to cpy.
  @param cpy The destination
  @param orig The source vector
*/
__G3DIE__ void G3DCopyVector3fv(CGFloat cpy[3], CFLOAT orig[3]);

/*! 
  @function G3DCopyVector3dv
  @discussion Copies the 3-element, double-precision vector orig to cpy.
  @param cpy The destination
  @param orig The source vector
*/
__G3DIE__ void G3DCopyVector3dv(double cpy[3], CDOUBLE orig[3]);

/*! 
  @function G3DCopyVector4fv
  @discussion Copies the 4-element, single-precision vector orig to cpy.
  @param cpy The destination
  @param orig The source vector
*/
__G3DIE__ void G3DCopyVector4fv(CGFloat cpy[4], CFLOAT orig[4]);

/*! 
  @function G3DCopyVector4dv
  @discussion Copies the 4-element, double-precision vector orig to cpy.
  @param cpy The destination
  @param orig The source vector
*/
__G3DIE__ void G3DCopyVector4dv(double cpy[4], CDOUBLE orig[4]);

/*! 
  @function G3DAddVectors2fv
  @discussion Adds the 2-element, single-precision vectors a and b and stores the result in res.
  @param res The destination
  @param a The first vector
  @param b The second vector
*/
__G3DIE__ void G3DAddVectors2fv(CGFloat res[2],CFLOAT a[2],CFLOAT b[2]);

/*! 
  @function G3DAddVectors3fv
  @discussion Adds the 3-element, single-precision vectors a and b and stores the result in res.
  @param res The destination
  @param a The first vector
  @param b The second vector
*/
__G3DIE__ void G3DAddVectors3fv(CGFloat res[3],CFLOAT a[3],CFLOAT b[3]);

/*! 
  @function G3DAddVectors4fv
  @discussion Adds the 4-element, single-precision vectors a and b and stores the result in res.
  @param res The destination
  @param a The first vector
  @param b The second vector
*/
__G3DIE__ void G3DAddVectors4fv(CGFloat res[4],CFLOAT a[4],CFLOAT b[4]);

/*! 
  @function G3DAddVectors2dv
  @discussion Adds the 2-element, double-precision vectors a and b and stores the result in res.
  @param res The destination
  @param a The first vector
  @param b The second vector
*/
__G3DIE__ void G3DAddVectors2dv(double res[2],CDOUBLE a[2],CDOUBLE b[2]);

/*! 
  @function G3DAddVectors3dv
  @discussion Adds the 3-element, double-precision vectors a and b and stores the result in res.
  @param res The destination
  @param a The first vector
  @param b The second vector
*/
__G3DIE__ void G3DAddVectors3dv(double res[3],CDOUBLE a[3],CDOUBLE b[3]);

/*! 
  @function G3DAddVectors4dv
  @discussion Adds the 4-element, double-precision vectors a and b and stores the result in res.
  @param res The destination
  @param a The first vector
  @param b The second vector
*/
__G3DIE__ void G3DAddVectors4dv(double res[4],CDOUBLE a[4],CDOUBLE b[4]);

/*! 
  @function G3DSubVectors2fv
  @discussion Subtracts the 2-element, single-precision vector b from a and stores the result in 
              res.
  @param res The destination
  @param a The first vector
  @param b The second vector
*/
__G3DIE__ void G3DSubVectors2fv(CGFloat res[2],CFLOAT a[2],CFLOAT b[2]);

/*! 
  @function G3DSubVectors3fv
  @discussion Subtracts the 3-element, single-precision vector b from a and stores the result in 
              res.
  @param res The destination
  @param a The first vector
  @param b The second vector
*/
__G3DIE__ void G3DSubVectors3fv(CGFloat res[3],CFLOAT a[3],CFLOAT b[3]);

/*! 
  @function G3DSubVectors4fv
  @discussion Subtracts the 4-element, single-precision vector b from a and stores the result in 
              res.
  @param res The destination
  @param a The first vector
  @param b The second vector
*/
__G3DIE__ void G3DSubVectors4fv(CGFloat res[4],CFLOAT a[4],CFLOAT b[4]);

/*! 
  @function G3DSubVectors2dv
  @discussion Subtracts the 2-element, double-precision vector b from a and stores the result in 
              res.
  @param res The destination
  @param a The first vector
  @param b The second vector
*/
__G3DIE__ void G3DSubVectors2dv(double res[2],CDOUBLE a[2],CDOUBLE b[2]);

/*! 
  @function G3DSubVectors3dv
  @discussion Subtracts the 3-element, double-precision vector b from a and stores the result in 
              res.
  @param res The destination
  @param a The first vector
  @param b The second vector
*/
__G3DIE__ void G3DSubVectors3dv(double res[3],CDOUBLE a[3],CDOUBLE b[3]);

/*! 
  @function G3DSubVectors4dv
  @discussion Subtracts the 4-element, double-precision vector b from a and stores the result in 
              res.
  @param res The destination
  @param a The first vector
  @param b The second vector
*/
__G3DIE__ void G3DSubVectors4dv(double res[4],CDOUBLE a[4],CDOUBLE b[4]);

/*! 
  @function G3DNegateVector2fv
  @discussion Negates the 2-element, single-precision vector src and stores the result in res.
  @param res The destination
  @param src The source vector
*/
__G3DIE__ void G3DNegateVector2fv(CGFloat res[2],CFLOAT src[2]);

/*! 
  @function G3DNegateVector3fv
  @discussion Negates the 3-element, single-precision vector src and stores the result in res.
  @param res The destination
  @param src The source vector
*/
__G3DIE__ void G3DNegateVector3fv(CGFloat res[3],CFLOAT src[3]);

/*! 
  @function G3DNegateVector4fv
  @discussion Negates the 4-element, single-precision vector src and stores the result in res.
  @param res The destination
  @param src The source vector
*/
__G3DIE__ void G3DNegateVector4fv(CGFloat res[4],CFLOAT src[4]);

/*! 
  @function G3DNegateVector2dv
  @discussion Negates the 2-element, double-precision vector src and stores the result in res.
  @param res The destination
  @param src The source vector
*/
__G3DIE__ void G3DNegateVector2dv(double res[2],CDOUBLE src[2]);

/*! 
  @function G3DNegateVector3dv
  @discussion Negates the 3-element, double-precision vector src and stores the result in res.
  @param res The destination
  @param src The source vector
*/
__G3DIE__ void G3DNegateVector3dv(double res[3],CDOUBLE src[3]);

/*! 
  @function G3DNegateVector4dv
  @discussion Negates the 4-element, double-precision vector src and stores the result in res.
  @param res The destination
  @param src The source vector
*/
__G3DIE__ void G3DNegateVector4dv(double res[4],CDOUBLE src[4]);

/*! 
  @function G3DScaleVector2fv
  @discussion Scales the 2-element, single-precision vector src by scalar and stores the result 
              in res.
  @param res The destination
  @param src The source vector
  @param scalar The scaling factor
*/
__G3DIE__ void G3DScaleVector2fv(CGFloat res[2],CFLOAT src[2],CFLOAT scalar);

/*! 
  @function G3DScaleVector3fv
  @discussion Scales the 3-element, single-precision vector src by scalar and stores the result 
              in res.
  @param res The destination
  @param src The source vector
  @param scalar The scaling factor
*/
__G3DIE__ void G3DScaleVector3fv(CGFloat res[3],CFLOAT src[3],CFLOAT scalar);

/*! 
  @function G3DScaleVector4fv
  @discussion Scales the 4-element, single-precision vector src by scalar and stores the result 
              in res.
  @param res The destination
  @param src The source vector
  @param scalar The scaling factor
*/
__G3DIE__ void G3DScaleVector4fv(CGFloat res[4],CFLOAT src[4],CFLOAT scalar);

/*! 
  @function G3DScaleVector2dv
  @discussion Scales the 2-element, double-precision vector src by scalar and stores the result 
              in res.
  @param res The destination
  @param src The source vector
  @param scalar The scaling factor
*/
__G3DIE__ void G3DScaleVector2dv(double res[2],CDOUBLE src[2],CDOUBLE scalar);

/*! 
  @function G3DScaleVector3dv
  @discussion Scales the 3-element, double-precision vector src by scalar and stores the result 
              in res.
  @param res The destination
  @param src The source vector
  @param scalar The scaling factor
*/
__G3DIE__ void G3DScaleVector3dv(double res[3],CDOUBLE src[3],CDOUBLE scalar);

/*! 
  @function G3DScaleVector4dv
  @discussion Scales the 4-element, double-precision vector src by scalar and stores the result 
              in res.
  @param res The destination
  @param src The source vector
  @param scalar The scaling factor
*/
__G3DIE__ void G3DScaleVector4dv(double res[4],CDOUBLE src[4],CDOUBLE scalar);

/*! 
  @function G3DCompareVector2fv
  @discussion Compares the 2-element, single-precision vectors a and b using the factor tol.
  @param a The first vector
  @param b The second vector
  @param tol The factor
  @result Returns -1, 0 or 1 according to the result of G3DCompareFloat().
*/
__G3DIE__ NSInteger G3DCompareVector2fv(CFLOAT a[2],CFLOAT b[2],CFLOAT tol);

/*! 
  @function G3DCompareVector3fv
  @discussion Compares the 3-element, single-precision vectors a and b using the factor tol.
  @param a The first vector
  @param b The second vector
  @param tol The factor
  @result Returns -1, 0 or 1 according to the result of G3DCompareFloat().
*/
__G3DIE__ NSInteger G3DCompareVector3fv(CFLOAT a[3],CFLOAT b[3],CFLOAT tol);

/*! 
  @function G3DCompareVector4fv
  @discussion Compares the 4-element, single-precision vectors a and b using the factor tol.
  @param a The first vector
  @param b The second vector
  @param tol The factor
  @result Returns -1, 0 or 1 according to the result of G3DCompareFloat().
*/
__G3DIE__ NSInteger G3DCompareVector4fv(CFLOAT a[4],CFLOAT b[4],CFLOAT tol);

/*! 
  @function G3DCompareVector2dv
  @discussion Compares the 2-element, double-precision vectors a and b using the factor tol.
  @param a The first vector
  @param b The second vector
  @param tol The factor
  @result Returns -1, 0 or 1 according to the result of G3DCompareFloat().
*/
__G3DIE__ NSInteger G3DCompareVector2dv(CDOUBLE a[2],CDOUBLE b[2],CDOUBLE tol);

/*! 
  @function G3DCompareVector3dv
  @discussion Compares the 3-element, double-precision vectors a and b using the factor tol.
  @param a The first vector
  @param b The second vector
  @param tol The factor
  @result Returns -1, 0 or 1 according to the result of G3DCompareFloat().
*/
__G3DIE__ NSInteger G3DCompareVector3dv(CDOUBLE a[3],CDOUBLE b[3],CDOUBLE tol);

/*! 
  @function G3DCompareVector4dv
  @discussion Compares the 4-element, double-precision vectors a and b using the factor tol.
  @param a The first vector
  @param b The second vector
  @param tol The factor
  @result Returns -1, 0 or 1 according to the result of G3DCompareFloat().
*/
__G3DIE__ NSInteger G3DCompareVector4dv(CDOUBLE a[4],CDOUBLE b[4],CDOUBLE tol);

/*! 
  @function G3DIsEqualToVector2fv
  @discussion Performs an equality test on the 2-element, single-precision vectors a and b.
  @param a The first vector
  @param b The second vector
  @result Returns 1 if the vectors are equal, 0 otherwise.
*/
__G3DIE__ int G3DIsEqualToVector2fv(CFLOAT a[2],CFLOAT b[2]);

/*! 
  @function G3DIsEqualToVector3fv
  @discussion Performs an equality test on the 3-element, single-precision vectors a and b.
  @param a The first vector
  @param b The second vector
  @result Returns 1 if the vectors are equal, 0 otherwise.
*/
__G3DIE__ int G3DIsEqualToVector3fv(CFLOAT a[3],CFLOAT b[3]);

/*! 
  @function G3DIsEqualToVector4fv
  @discussion Performs an equality test on the 4-element, single-precision vectors a and b.
  @param a The first vector
  @param b The second vector
  @result Returns 1 if the vectors are equal, 0 otherwise.
*/
__G3DIE__ int G3DIsEqualToVector4fv(CFLOAT a[4],CFLOAT b[4]);

/*! 
  @function G3DIsEqualToVector2dv
  @discussion Performs an equality test on the 2-element, double-precision vectors a and b.
  @param a The first vector
  @param b The second vector
  @result Returns 1 if the vectors are equal, 0 otherwise.
*/
__G3DIE__ int G3DIsEqualToVector2dv(CDOUBLE a[2],CDOUBLE b[2]);

/*! 
  @function G3DIsEqualToVector3dv
  @discussion Performs an equality test on the 3-element, double-precision vectors a and b.
  @param a The first vector
  @param b The second vector
  @result Returns 1 if the vectors are equal, 0 otherwise.
*/
__G3DIE__ int G3DIsEqualToVector3dv(CDOUBLE a[3],CDOUBLE b[3]);

/*! 
  @function G3DIsEqualToVector4dv
  @discussion Performs an equality test on the 4-element, double-precision vectors a and b.
  @param a The first vector
  @param b The second vector
  @result Returns 1 if the vectors are equal, 0 otherwise.
*/
__G3DIE__ int G3DIsEqualToVector4dv(CDOUBLE a[4],CDOUBLE b[4]);

/*! 
  @function G3DScalarProduct2fv
  @discussion Calculates the scalar product of the 2-element, single-precision vectors a and b.
  @param a The first vector
  @param b The second vector
  @result Returns the single-precision scalar product.
*/
__G3DIE__ CGFloat G3DScalarProduct2fv(CFLOAT a[2],CFLOAT b[2]);

/*! 
  @function G3DScalarProduct3fv
  @discussion Calculates the scalar product of the 3-element, single-precision vectors a and b.
  @param a The first vector
  @param b The second vector
  @result Returns the single-precision scalar product.
*/
__G3DIE__ CGFloat G3DScalarProduct3fv(CFLOAT a[3],CFLOAT b[3]);

/*! 
  @function G3DScalarProduct4fv
  @discussion Calculates the scalar product of the 4-element, single-precision vectors a and b.
  @param a The first vector
  @param b The second vector
  @result Returns the single-precision scalar product.
*/
__G3DIE__ CGFloat G3DScalarProduct4fv(CFLOAT a[4],CFLOAT b[4]);

/*! 
  @function G3DScalarProduct2dv
  @discussion Calculates the scalar product of the 2-element, double-precision vectors a and b.
  @param a The first vector
  @param b The second vector
  @result Returns the double-precision scalar product.
*/
__G3DIE__ double G3DScalarProduct2dv(CDOUBLE a[2],CDOUBLE b[2]);

/*! 
  @function G3DScalarProduct3dv
  @discussion Calculates the scalar product of the 3-element, double-precision vectors a and b.
  @param a The first vector
  @param b The second vector
  @result Returns the double-precision scalar product.
*/
__G3DIE__ double G3DScalarProduct3dv(CDOUBLE a[3],CDOUBLE b[3]);

/*! 
  @function G3DScalarProduct4dv
  @discussion Calculates the scalar product of the 4-element, double-precision vectors a and b.
  @param a The first vector
  @param b The second vector
  @result Returns the double-precision scalar product.
*/
__G3DIE__ double G3DScalarProduct4dv(CDOUBLE a[4],CDOUBLE b[4]);

/*! 
  @function G3DVectorProduct3fv
  @discussion Calculates the vector product of the 3-element, single-precision vectors a and b
              and stores the result in res.
  @param res The resulting vector
  @param a The first vector
  @param b The second vector
*/
__G3DIE__ void G3DVectorProduct3fv(CGFloat res[3],CFLOAT a[3],CFLOAT b[3]);

/*! 
  @function G3DVectorProduct3dv
  @discussion Calculates the vector product of the 3-element, double-precision vectors a and b
              and stores the result in res.
  @param res The resulting vector
  @param a The first vector
  @param b The second vector
*/
__G3DIE__ void G3DVectorProduct3dv(double res[3],CDOUBLE a[3],CDOUBLE b[3]);

/*! 
  @function G3DMixedProduct3fv
  @discussion Calculates the single-precision mixed product (a x b) * c.
  @param a The first vector
  @param b The second vector
  @param b The third vector
  @result Returns a single-precision value.
*/
__G3DIE__ CGFloat G3DMixedProduct3fv(CFLOAT a[3], CFLOAT b[3], CFLOAT c[3]);

/*! 
  @function G3DMixedProduct3dv
  @discussion Calculates the double-precision mixed product (a x b) * c.
  @param a The first vector
  @param b The second vector
  @param b The third vector
  @result Returns a double-precision value.
*/
__G3DIE__ double G3DMixedProduct3dv(CDOUBLE a[3], CDOUBLE b[3], CDOUBLE c[3]);

/*! 
  @function G3DDistance2fv
  @discussion Calculates the single-precision distance from a to b.
  @param a The first vector
  @param b The second vector
  @result Returns the single-precision distance.
*/
__G3DIE__ CGFloat G3DDistance2fv(CFLOAT a[2],CFLOAT b[2]);

/*! 
  @function G3DDistance3fv
  @discussion Calculates the single-precision distance from a to b.
  @param a The first vector
  @param b The second vector
  @result Returns the single-precision distance.
*/
__G3DIE__ CGFloat G3DDistance3fv(CFLOAT a[3],CFLOAT b[3]);

/*! 
  @function G3DDistance4fv
  @discussion Calculates the single-precision distance from a to b.
  @param a The first vector
  @param b The second vector
  @result Returns the single-precision distance.
*/
__G3DIE__ CGFloat G3DDistance4fv(CFLOAT a[4],CFLOAT b[4]);

/*! 
  @function G3DDistance2dv
  @discussion Calculates the double-precision distance from a to b.
  @param a The first vector
  @param b The second vector
  @result Returns the double-precision distance.
*/
__G3DIE__ double G3DDistance2dv(CDOUBLE a[2],CDOUBLE b[2]);

/*! 
  @function G3DDistance3dv
  @discussion Calculates the double-precision distance from a to b.
  @param a The first vector
  @param b The second vector
  @result Returns the double-precision distance.
*/
__G3DIE__ double G3DDistance3dv(CDOUBLE a[3],CDOUBLE b[3]);

/*! 
  @function G3DDistance4dv
  @discussion Calculates the double-precision distance from a to b.
  @param a The first vector
  @param b The second vector
  @result Returns the double-precision distance.
*/
__G3DIE__ double G3DDistance4dv(CDOUBLE a[4],CDOUBLE b[4]);

/*! 
  @function G3DLength2fv
  @discussion Calculates the single-precision length of a.
  @param a The 2-element vector
  @result Returns the single-precision length.
*/
__G3DIE__ CGFloat G3DLength2fv(CFLOAT a[2]);

/*! 
  @function G3DLength3fv
  @discussion Calculates the single-precision length of a.
  @param a The 3-element vector
  @result Returns the single-precision length.
*/
__G3DIE__ CGFloat G3DLength3fv(CFLOAT a[3]);

/*! 
  @function G3DLength4fv
  @discussion Calculates the single-precision length of a.
  @param a The 4-element vector
  @result Returns the single-precision length.
*/
__G3DIE__ CGFloat G3DLength4fv(CFLOAT a[4]);

/*! 
  @function G3DLength2dv
  @discussion Calculates the double-precision length of a.
  @param a The 2-element vector
  @result Returns the double-precision length.
*/
__G3DIE__ double G3DLength2dv(CDOUBLE a[2]);

/*! 
  @function G3DLength3dv
  @discussion Calculates the double-precision length of a.
  @param a The 3-element vector
  @result Returns the double-precision length.
*/
__G3DIE__ double G3DLength3dv(CDOUBLE a[3]);

/*! 
  @function G3DLength4dv
  @discussion Calculates the double-precision length of a.
  @param a The 4-element vector
  @result Returns the double-precision length.
*/
__G3DIE__ double G3DLength4dv(CDOUBLE a[4]);

/*! 
  @function G3DNormalise2fv
  @discussion Normalises the 2-element, single-precision vector src and stores the result in res. 
  @param res The normalised vector
  @param src The original vector
*/
__G3DIE__ void G3DNormalise2fv(CGFloat res[2],CFLOAT src[2]);

/*! 
  @function G3DNormalise3fv
  @discussion Normalises the 3-element, single-precision vector src and stores the result in res. 
  @param res The normalised vector
  @param src The original vector
*/
__G3DIE__ void G3DNormalise3fv(CGFloat res[3],CFLOAT src[3]);

/*! 
  @function G3DNormalise4fv
  @discussion Normalises the 4-element, single-precision vector src and stores the result in res. 
  @param res The normalised vector
  @param src The original vector
*/
__G3DIE__ void G3DNormalise4fv(CGFloat res[4],CFLOAT src[4]);

/*! 
  @function G3DNormalise2dv
  @discussion Normalises the 2-element, double-precision vector src and stores the result in res. 
  @param res The normalised vector
  @param src The original vector
*/
__G3DIE__ void G3DNormalise2dv(double res[2],CDOUBLE src[2]);

/*! 
  @function G3DNormalise3dv
  @discussion Normalises the 2-element, double-precision vector src and stores the result in res. 
  @param res The normalised vector
  @param src The original vector
*/
__G3DIE__ void G3DNormalise3dv(double res[3],CDOUBLE src[3]);

/*! 
  @function G3DNormalise4dv
  @discussion Normalises the 4-element, double-precision vector src and stores the result in res. 
  @param res The normalised vector
  @param src The original vector
*/
__G3DIE__ void G3DNormalise4dv(double res[4],CDOUBLE src[4]);

#endif
