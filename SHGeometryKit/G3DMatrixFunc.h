/*-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class              	G3DMatrixFunc
// Creator            	Philippe C.D. Robert
// Maintainer         	Philippe C.D. Robert
// Creation Date      	2001-01-05 15:07:28 +0000
//
// Copyright (c) Philippe C.D. Robert
//
// The SHGeometryKit is free software; you can redistribute it and/or modify it 
// under the terms of the GNU LGPL Version 2 as published by the Free 
// Software Foundation
//
// $Id: G3DMatrixFunc.h,v 1.3 2002/10/20 13:00:21 probert Exp $
//
//---------------------------------------------------------------------------*/

/*!
  @header G3DMatrixFunc
  Optimised matrix computation C functions.
*/

#ifndef __G3DMatrixFunc_h_INCLUDE
#define __G3DMatrixFunc_h_INCLUDE

#include "G3DFunctions.h"

/*! 
  @function G3DVector3fXMatrix3f
  @discussion Multiplies a 3-element vector by a 3 by 3 matrix.
  @param res The result
  @param vec A 3-element vector
  @param matrix A 3 by 3 matrix
*/
__G3DIE__ void G3DVector3fXMatrix3f(float res[3],  CFLOAT vec[3], CFLOAT matrix[9]);

/*! 
  @function G3DVector3dXMatrix3d
  @discussion Multiplies a 3-element vector by a 3 by 3 matrix.
  @param res The result
  @param vec A 3-element vector
  @param matrix A 3 by 3 matrix
*/
__G3DIE__ void G3DVector3dXMatrix3d(double res[3],  CDOUBLE vec[3], CDOUBLE matrix[9]);

/*! 
  @function G3DMatrix3fXVector3f
  @discussion Multiplies a 3 by 3 matrix by a 3-element vector.
  @param res The result
  @param matrix A 3 by 3 matrix
  @param vector A 3-element vector
*/
__G3DIE__ void G3DMatrix3fXVector3f(float res[3],  CFLOAT matrix[9], CFLOAT vector[3]);

/*! 
  @function G3DMatrix3dXVector3d
  @discussion Multiplies a 3 by 3 matrix by a 3-element vector.
  @param res The result
  @param matrix A 3 by 3 matrix
  @param vector A 3-element vector
*/
__G3DIE__ void G3DMatrix3dXVector3d(double res[3],  CDOUBLE matrix[9], CDOUBLE vector[3]);

/*! 
  @function G3DVector4fXMatrix4f
  @discussion Multiplies a 4-element vector by a 4 by 4 matrix.
  @param res The result
  @param vec A 4-element vector
  @param matrix A 4 by 4 matrix
*/
__G3DIE__ void G3DVector4fXMatrix4f(float res[4],  CFLOAT vec[4], CFLOAT matrix[16]);

/*! 
  @function G3DVector4dXMatrix4d
  @discussion Multiplies a 4-element vector by a 4 by 4 matrix.
  @param res The result
  @param vec A 4-element vector
  @param matrix A 4 by 4 matrix
*/
__G3DIE__ void G3DVector4dXMatrix4d(double res[4],  CDOUBLE vec[4], CDOUBLE matrix[16]);

/*! 
  @function G3DMatrix4fXVector4f
  @discussion Multiplies a 4 by 4 matrix by a 4-element vector.
  @param res The result
  @param matrix A 4 by 4 matrix
  @param vector A 4-element vector
*/
__G3DIE__ void G3DMatrix4fXVector4f(float res[4],  CFLOAT matrix[16], CFLOAT vec[4]);

/*! 
  @function G3DMatrix4dXVector4d
  @discussion Multiplies a 4 by 4 matrix by a 4-element vector.
  @param res The result
  @param matrix A 4 by 4 matrix
  @param vector A 4-element vector
*/
__G3DIE__ void G3DMatrix4dXVector4d(double res[4],  CDOUBLE matrix[16], CDOUBLE vec[4]);

/*! 
  @function G3DMatrix4fXVector3f
  @discussion Multiplies the upper left 3 by 3 submatrix of a 4 by 4 matrix by a 3-element vector.
  @param res The result
  @param matrix A 4 by 4 matrix
  @param vector A 4-element vector
*/
__G3DIE__ void G3DMatrix4fXVector3f(float res[3],  CFLOAT matrix[16], CFLOAT vec[3]);

/*! 
  @function G3DMatrix4dXVector3d
  @discussion Multiplies the upper left 3 by 3 submatrix of a 4 by 4 matrix by a 3-element vector.
  @param res The result
  @param matrix A 4 by 4 matrix
  @param vector A 4-element vector
*/
__G3DIE__ void G3DMatrix4dXVector3d(double res[3],  CDOUBLE matrix[16], CDOUBLE vec[3]);

/*
 *
 */

/*! 
  @function G3DCopyMatrix3fv
  @discussion Copies the 3 by 3 matrix m2 to m1.
  @param m1 The destination matrix
  @param m2 The source matrix
*/
__G3DIE__ void G3DCopyMatrix3fv(float m1[9], CFLOAT m2[9]);

/*! 
  @function G3DCopyMatrix3dv
  @discussion Copies the 3 by 3 matrix m2 to m1.
  @param m1 The destination matrix
  @param m2 The source matrix
*/
__G3DIE__ void G3DCopyMatrix3dv(double m1[9], CDOUBLE m2[9]);

/*! 
  @function G3DCopyMatrix4fv
  @discussion Copies the 4 by 4 matrix m2 to m1.
  @param m1 The destination matrix
  @param m2 The source matrix
*/
__G3DIE__ void G3DCopyMatrix4fv(float m1[16], CFLOAT m2[16]);

/*! 
  @function G3DCopyMatrix4dv
  @discussion Copies the 4 by 4 matrix m2 to m1.
  @param m1 The destination matrix
  @param m2 The source matrix
*/
__G3DIE__ void G3DCopyMatrix4dv(double m1[16], CDOUBLE m2[16]);

/*
 *
 */

/*! 
  @function G3DDeterminante2f
  @discussion Computes the determinante of a 2 by 2 matrix.
  @param a Matrix element at row 0, col 0
  @param b Matrix element at row 1, col 0
  @param c Matrix element at row 0, col 1
  @param d Matrix element at row 1, col 1
  @result Returns the single-precision determinante of the passed matrix. 
*/
__G3DIE__ float G3DDeterminante2f(CFLOAT a, CFLOAT b, CFLOAT c, CFLOAT d);

/*! 
  @function G3DDeterminante2d
  @discussion Computes the determinante of a 2 by 2 matrix.
  @param a Matrix element at row 0, col 0
  @param b Matrix element at row 1, col 0
  @param c Matrix element at row 0, col 1
  @param d Matrix element at row 1, col 1
  @result Returns the double-precision determinante of the passed matrix. 
*/
__G3DIE__ double G3DDeterminante2d(CDOUBLE a, CDOUBLE b, CDOUBLE c, CDOUBLE d);

/*! 
  @function G3DDeterminante3fv
  @discussion Computes the determinante of a 3 by 3 matrix.
  @param a Matrix column 0
  @param b Matrix column 1
  @param c Matrix column 2
  @result Returns the single-precision determinante of the passed matrix. 
*/
__G3DIE__ float G3DDeterminante3fv(CFLOAT a[3],CFLOAT b[3],CFLOAT c[3]);

/*! 
  @function G3DDeterminante3dv
  @discussion Computes the determinante of a 3 by 3 matrix.
  @param a Matrix column 0
  @param b Matrix column 1
  @param c Matrix column 2
  @result Returns the double-precision determinante of the passed matrix. 
*/
__G3DIE__ double G3DDeterminante3dv(CDOUBLE a[3],CDOUBLE b[3],CDOUBLE c[3]);

/*! 
  @function G3DDeterminante3f
  @discussion Computes the determinante of a 3 by 3 matrix.
  @param a1 Matrix element at row 0, col 0
  @param a2 Matrix element at row 1, col 0
  @param a3 Matrix element at row 2, col 0
  @param b1 Matrix element at row 0, col 1
  @param b2 Matrix element at row 1, col 1
  @param b3 Matrix element at row 2, col 1
  @param c1 Matrix element at row 0, col 2
  @param c2 Matrix element at row 1, col 2
  @param c3 Matrix element at row 2, col 2
  @result Returns the single-precision determinante of the passed matrix. 
*/
__G3DIE__ float G3DDeterminante3f(CFLOAT a1,CFLOAT a2,CFLOAT a3,CFLOAT b1,
                                  CFLOAT b2,CFLOAT b3,CFLOAT c1,CFLOAT c2,
				  CFLOAT c3);

/*! 
  @function G3DDeterminante3d
  @discussion Computes the determinante of a 3 by 3 matrix.
  @param a1 Matrix element at row 0, col 0
  @param a2 Matrix element at row 1, col 0
  @param a3 Matrix element at row 2, col 0
  @param b1 Matrix element at row 0, col 1
  @param b2 Matrix element at row 1, col 1
  @param b3 Matrix element at row 2, col 1
  @param c1 Matrix element at row 0, col 2
  @param c2 Matrix element at row 1, col 2
  @param c3 Matrix element at row 2, col 2
  @result Returns the double-precision determinante of the passed matrix. 
*/
__G3DIE__ double G3DDeterminante3d(CDOUBLE a1,CDOUBLE a2,CDOUBLE a3,CDOUBLE b1,
                                   CDOUBLE b2,CDOUBLE b3,CDOUBLE c1,CDOUBLE c2,
				   CDOUBLE c3);

/*! 
  @function G3DDeterminante4fv
  @discussion Computes the determinante of a 4 by 4 matrix.
  @param m A 4 by 4 single-precision matrix
  @result Returns the single-precision determinante of the passed matrix. 
*/
__G3DIE__ float G3DDeterminante4fv(CFLOAT m[16]);

/*! 
  @function G3DDeterminante4dv
  @discussion Computes the determinante of a 4 by 4 matrix.
  @param m A 4 by 4 double-precision matrix
  @result Returns the double-precision determinante of the passed matrix. 
*/
__G3DIE__ double G3DDeterminante4dv(CDOUBLE m[16]);

/*
 *
 */

/*! 
  @function G3DMakeIdentity3fv
  @discussion Initialises the 3 by 3 matrix m as a unity matrix.
  @param m A 3 by 3 single-precision matrix
*/
__G3DIE__ void G3DMakeIdentity3fv(float m[9]);

/*! 
  @function G3DMakeIdentity3dv
  @discussion Initialises the 3 by 3 matrix m as a unity matrix.
  @param m A 3 by 3 double-precision matrix
*/
__G3DIE__ void G3DMakeIdentity3dv(double m[9]);

/*! 
  @function G3DMakeIdentity4fv
  @discussion Initialises the 4 by 4 matrix m as a unity matrix.
  @param m A 4 by 4 single-precision matrix
*/
__G3DIE__ void G3DMakeIdentity4fv(float m[16]);

/*! 
  @function G3DMakeIdentity4dv
  @discussion Initialises the 4 by 4 matrix m as a unity matrix.
  @param m A 4 by 4 double-precision matrix
*/
__G3DIE__ void G3DMakeIdentity4dv(double m[16]);

/*
 *
 */

/*! 
  @function G3DAddMatrix3fv
  @discussion Computes the matrix addition of a and b and stores the result in m.
  @param m The resulting matrix
  @param a The first matrix
  @param b The second matrix
*/
__G3DIE__ void G3DAddMatrix3fv(float m[9],CFLOAT a[9],CFLOAT b[9]);

/*! 
  @function G3DAddMatrix3dv
  @discussion Computes the matrix addition of a and b and stores the result in m.
  @param m The resulting matrix
  @param a The first matrix
  @param b The second matrix
*/
__G3DIE__ void G3DAddMatrix3dv(double m[9],CDOUBLE a[9],CDOUBLE b[9]);

/*! 
  @function G3DAddMatrix4fv
  @discussion Computes the matrix addition of a and b and stores the result in m.
  @param m The resulting matrix
  @param a The first matrix
  @param b The second matrix
*/
__G3DIE__ void G3DAddMatrix4fv(float m[16],CFLOAT a[16],CFLOAT b[16]);

/*! 
  @function G3DAddMatrix4dv
  @discussion Computes the matrix addition of a and b and stores the result in m.
  @param m The resulting matrix
  @param a The first matrix
  @param b The second matrix
*/
__G3DIE__ void G3DAddMatrix4dv(double m[16],CDOUBLE a[16],CDOUBLE b[16]);

/*
 *
 */

/*! 
  @function G3DSubMatrix3fv
  @discussion Computes the matrix subtraction of a and b and stores the result in m.
  @param m The resulting matrix
  @param a The first matrix
  @param b The second matrix
*/
__G3DIE__ void G3DSubMatrix3fv(float m[9],CFLOAT a[9],CFLOAT b[9]);

/*! 
  @function G3DSubMatrix3dv
  @discussion Computes the matrix subtraction of a and b and stores the result in m.
  @param m The resulting matrix
  @param a The first matrix
  @param b The second matrix
*/
__G3DIE__ void G3DSubMatrix3dv(double m[9],CDOUBLE a[9],CDOUBLE b[9]);

/*! 
  @function G3DSubMatrix4fv
  @discussion Computes the matrix subtraction of a and b and stores the result in m.
  @param m The resulting matrix
  @param a The first matrix
  @param b The second matrix
*/
__G3DIE__ void G3DSubMatrix4fv(float m[16],CFLOAT a[16],CFLOAT b[16]);

/*! 
  @function G3DSubMatrix4dv
  @discussion Computes the matrix subtraction of a and b and stores the result in m.
  @param m The resulting matrix
  @param a The first matrix
  @param b The second matrix
*/
__G3DIE__ void G3DSubMatrix4dv(double m[16],CDOUBLE a[16],CDOUBLE b[16]);

/*
 *
 */

/*! 
  @function G3DMultiplyMatrix3fv
  @discussion Computes the matrix multiplication of a and b and stores the result in m.
  @param m The resulting matrix
  @param a The first matrix
  @param b The second matrix
*/
__G3DIE__ void G3DMultiplyMatrix3fv(float m[9], CFLOAT a[9], CFLOAT b[9]);

/*! 
  @function G3DMultiplyMatrix3dv
  @discussion Computes the matrix multiplication of a and b and stores the result in m.
  @param m The resulting matrix
  @param a The first matrix
  @param b The second matrix
*/
__G3DIE__ void G3DMultiplyMatrix3dv(double m[9], CDOUBLE a[9], CDOUBLE b[9]);

/*! 
  @function G3DMultiplyMatrix4fv
  @discussion Computes the matrix multiplication of a and b and stores the result in m.
  @param m The resulting matrix
  @param a The first matrix
  @param b The second matrix
*/
__G3DIE__ void G3DMultiplyMatrix4fv(float m[16], CFLOAT a[16], CFLOAT b[16]);

/*! 
  @function G3DMultiplyMatrix4dv
  @discussion Computes the matrix multiplication of a and b and stores the result in m.
  @param m The resulting matrix
  @param a The first matrix
  @param b The second matrix
*/
__G3DIE__ void G3DMultiplyMatrix4dv(double m[16], CDOUBLE a[16],CDOUBLE b[16]);

/*
 *
 */

/*! 
  @function G3DSimpleInvertMatrix4fv
  @discussion Computes the inverse of matrix and stores the result in m. Matrix must be an 
              orthogonal matrix!
  @param i The inverted matrix
  @param matrix The orthogonal source matrix
*/
__G3DIE__ void G3DSimpleInvertMatrix4fv(float i[16], CFLOAT matrix[16]);

/*! 
  @function G3DSimpleInvertMatrix4dv
  @discussion Computes the inverse of matrix and stores the result in m. Matrix must be an 
              orthogonal matrix!
  @param i The inverted matrix
  @param matrix The orthogonal source matrix
*/
__G3DIE__ void G3DSimpleInvertMatrix4dv(double i[16], CDOUBLE matrix[16]);

/*
 *
 */

/*! 
  @function G3DInvertMatrix4fv
  @discussion Computes the inverse of matrix and stores the result in m. 
  @param i The inverted matrix
  @param matrix The source matrix
*/
__G3DIE__ int G3DInvertMatrix4fv(float i[16], CFLOAT matrix[16]);

/*! 
  @function G3DInvertMatrix4dv
  @discussion Computes the inverse of matrix and stores the result in m. 
  @param i The inverted matrix
  @param matrix The source matrix
*/
__G3DIE__ int G3DInvertMatrix4dv(double i[16], CDOUBLE matrix[16]);

/*
 *
 */

/*! 
  @function G3DAdjointMatrix4fv
  @discussion Computes the adjoint of matrix m and stores the result in adj. 
  @param adj The adjoint matrix
  @param m The source matrix
*/
extern void G3DAdjointMatrix4fv(float adj[16], CFLOAT m[16]);

/*! 
  @function G3DAdjointMatrix4dv
  @discussion Computes the adjoint of matrix m and stores the result in adj. 
  @param adj The adjoint matrix
  @param m The source matrix
*/
extern void G3DAdjointMatrix4dv(double adj[16], CDOUBLE m[16]);

/*
 *
 */

/*! 
  @function G3DTransposeMatrix3fv
  @discussion Computes the transpose of matrix and stores the result in t. 
  @param t The adjoint matrix
  @param matrix The source matrix
*/
__G3DIE__ void G3DTransposeMatrix3fv(float t[9], CFLOAT matrix[9]);

/*! 
  @function G3DTransposeMatrix3dv
  @discussion Computes the transpose of matrix and stores the result in t. 
  @param t The adjoint matrix
  @param matrix The source matrix
*/
__G3DIE__ void G3DTransposeMatrix3dv(double t[9], CDOUBLE matrix[9]);

/*! 
  @function G3DTransposeMatrix4fv
  @discussion Computes the transpose of matrix and stores the result in t. 
  @param t The adjoint matrix
  @param matrix The source matrix
*/
__G3DIE__ void G3DTransposeMatrix4fv(float t[16], CFLOAT matrix[16]);

/*! 
  @function G3DTransposeMatrix4dv
  @discussion Computes the transpose of matrix and stores the result in t. 
  @param t The adjoint matrix
  @param matrix The source matrix
*/
__G3DIE__ void G3DTransposeMatrix4dv(double t[16], CDOUBLE matrix[16]);

/*
 *
 */

/*! 
  @function G3DMakeXRotation3f
  @discussion Creates a 3 by 3 rotation matrix which rotates angle degrees around X. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeXRotation3f(float matrix[9],CFLOAT angle);

/*! 
  @function G3DMakeXRotation3d
  @discussion Creates a 3 by 3 rotation matrix which rotates angle degrees around X. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeXRotation3d(double matrix[9],CDOUBLE angle);

/*! 
  @function G3DMakeYRotation3f
  @discussion Creates a 3 by 3 rotation matrix which rotates angle degrees around Y. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeYRotation3f(float matrix[9],CFLOAT angle);

/*! 
  @function G3DMakeYRotation3d
  @discussion Creates a 3 by 3 rotation matrix which rotates angle degrees around Y. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeYRotation3d(double matrix[9],CDOUBLE angle);

/*! 
  @function G3DMakeZRotation3f
  @discussion Creates a 3 by 3 rotation matrix which rotates angle degrees around Z. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeZRotation3f(float matrix[9],CFLOAT angle);

/*! 
  @function G3DMakeZRotation3d
  @discussion Creates a 3 by 3 rotation matrix which rotates angle degrees around Z. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeZRotation3d(double matrix[9],CDOUBLE angle);

/*! 
  @function G3DMakeXRotation4f
  @discussion Creates a 4 by 4 rotation matrix which rotates angle degrees around X. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeXRotation4f(float matrix[16],CFLOAT angle);

/*! 
  @function G3DMakeXRotation4d
  @discussion Creates a 4 by 4 rotation matrix which rotates angle degrees around X. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeXRotation4d(double matrix[16],CDOUBLE angle);

/*! 
  @function G3DMakeYRotation4f
  @discussion Creates a 4 by 4 rotation matrix which rotates angle degrees around Y. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeYRotation4f(float matrix[16],CFLOAT angle);

/*! 
  @function G3DMakeYRotation4d
  @discussion Creates a 4 by 4 rotation matrix which rotates angle degrees around Y. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeYRotation4d(double matrix[16],CDOUBLE angle);

/*! 
  @function G3DMakeZRotation4f
  @discussion Creates a 4 by 4 rotation matrix which rotates angle degrees around Z. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeZRotation4f(float matrix[16],CFLOAT angle);

/*! 
  @function G3DMakeZRotation4d
  @discussion Creates a 4 by 4 rotation matrix which rotates angle degrees around Z. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeZRotation4d(double matrix[16],CDOUBLE angle);

/*
 *
 */

/*! 
  @function G3DMakeInvXRotation4f
  @discussion Creates an inverted 4 by 4 rotation matrix which rotates angle degrees around X. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeInvXRotation4f(float matrix[16],CFLOAT angle);

/*! 
  @function G3DMakeInvXRotation4d
  @discussion Creates an inverted 4 by 4 rotation matrix which rotates angle degrees around X. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeInvXRotation4d(double matrix[16],CDOUBLE angle);

/*! 
  @function G3DMakeInvYRotation4f
  @discussion Creates an inverted 4 by 4 rotation matrix which rotates angle degrees around Y. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeInvYRotation4f(float matrix[16],CFLOAT angle);

/*! 
  @function G3DMakeInvYRotation4d
  @discussion Creates an inverted 4 by 4 rotation matrix which rotates angle degrees around Y. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeInvYRotation4d(double matrix[16],CDOUBLE angle);

/*! 
  @function G3DMakeInvZRotation4f
  @discussion Creates an inverted 4 by 4 rotation matrix which rotates angle degrees around Z. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeInvZRotation4f(float matrix[16],CFLOAT angle);

/*! 
  @function G3DMakeInvZRotation4d
  @discussion Creates an inverted 4 by 4 rotation matrix which rotates angle degrees around Z. 
  @param matrix The rotation matrix
  @param angle The angle
*/
__G3DIE__ void G3DMakeInvZRotation4d(double matrix[16],CDOUBLE angle);

/*
 *
 */

/*! 
  @function G3DMakeRotation3f
  @discussion Creates a 3 by 3 rotation matrix which rotates angle degrees around axis. 
  @param matrix The rotation matrix
  @param angle The angle
  @param axis The rotation axis
*/
__G3DIE__ void G3DMakeRotation3f(float mat[9],CFLOAT angle,CFLOAT axis[3]);

/*! 
  @function G3DMakeRotation3d
  @discussion Creates a 3 by 3 rotation matrix which rotates angle degrees around axis. 
  @param matrix The rotation matrix
  @param angle The angle
  @param axis The rotation axis
*/
__G3DIE__ void G3DMakeRotation3d(double mat[9],CDOUBLE angle,CDOUBLE axis[3]);

/*! 
  @function G3DMakeRotation4f
  @discussion Creates a 4 by 4 rotation matrix which rotates angle degrees around axis. 
  @param matrix The rotation matrix
  @param angle The angle
  @param axis The rotation axis
*/
__G3DIE__ void G3DMakeRotation4f(float mat[16],CFLOAT angle,CFLOAT axis[3]);

/*! 
  @function G3DMakeRotation4d
  @discussion Creates a 4 by 4 rotation matrix which rotates angle degrees around axis. 
  @param matrix The rotation matrix
  @param angle The angle
  @param axis The rotation axis
*/
__G3DIE__ void G3DMakeRotation4d(double mat[16],CDOUBLE angle,CDOUBLE axis[3]);

/*
 *
 */

/*! 
  @function G3DMakeTranslation4f
  @discussion Creates a 4 by 4 translation matrix. 
  @param matrix The translation matrix
  @param v The translation vector
*/
__G3DIE__ void G3DMakeTranslation4f(float matrix[16],CFLOAT v[3]);

/*! 
  @function G3DMakeTranslation4d
  @discussion Creates a 4 by 4 translation matrix. 
  @param matrix The translation matrix
  @param v The translation vector
*/
__G3DIE__ void G3DMakeTranslation4d(double matrix[16],CDOUBLE v[3]);

/*
 *
 */

/*! 
  @function G3DMakeTranslationRotation4f
  @discussion Creates a 4 by 4 rotation/translation matrix. 
  @param res The resulting transformation matrix
  @param t The translation vector
  @param rot The rotation angles
*/
__G3DIE__ void G3DMakeTranslationRotation4f(float res[16],CFLOAT t[3],
                                            CFLOAT rot[3]);

/*! 
  @function G3DMakeTranslationRotation4d
  @discussion Creates a 4 by 4 rotation/translation matrix. 
  @param res The resulting transformation matrix
  @param t The translation vector
  @param rot The rotation angles
*/
__G3DIE__ void G3DMakeTranslationRotation4d(double res[16],CDOUBLE t[3],
                                            CDOUBLE rot[3]);

/*
 *
 */

/*! 
  @function G3DMakeTranslationRotationScale4f
  @discussion Creates a 4 by 4 rotation/translation/scale matrix. 
  @param res The resulting transformation matrix
  @param t The translation vector
  @param rot The rotation angles
  @param scale The scaling factors
*/
__G3DIE__ void G3DMakeTranslationRotationScale4f(float res[16],CFLOAT t[3],
                                                 CFLOAT rot[16], CFLOAT scale);

/*! 
  @function G3DMakeTranslationRotationScale4d
  @discussion Creates a 4 by 4 rotation/translation/scale matrix. 
  @param res The resulting transformation matrix
  @param t The translation vector
  @param rot The rotation angles
  @param scale The scaling factors
*/
__G3DIE__ void G3DMakeTranslationRotationScale4d(double res[16],CDOUBLE t[3],
                                                 CDOUBLE rot[16],CDOUBLE scale);

/*
 *
 */

/*! 
  @function G3DMakeTranslationQuatScale4f
  @discussion Creates a 4 by 4 rotation/translation/scale matrix. 
  @param res The resulting transformation matrix
  @param t The translation vector
  @param quat The rotation quaternion
  @param scale The scaling factor
*/
__G3DIE__ void G3DMakeTranslationQuatScale4f(float res[16],CFLOAT t[3],
                                             CFLOAT quat[4], CFLOAT scale);

/*! 
  @function G3DMakeTranslationQuatScale4d
  @discussion Creates a 4 by 4 rotation/translation/scale matrix. 
  @param res The resulting transformation matrix
  @param t The translation vector
  @param quat The rotation quaternion
  @param scale The scaling factor
*/
__G3DIE__ void G3DMakeTranslationQuatScale4d(double res[16],CDOUBLE t[3],
                                             CDOUBLE quat[4], CDOUBLE scale);

/*
 *
 */

/*! 
  @function G3DMakeScale3fv
  @discussion Creates a 3 by 3 scaling matrix. 
  @param m The resulting scaling matrix
  @param scale The scaling factors
*/
__G3DIE__ void G3DMakeScale3fv(float m[9],CFLOAT scale[3]);

/*! 
  @function G3DMakeScale3dv
  @discussion Creates a 3 by 3 scaling matrix. 
  @param m The resulting scaling matrix
  @param scale The scaling factors
*/
__G3DIE__ void G3DMakeScale3dv(double m[9],CDOUBLE scale[3]);

/*! 
  @function G3DMakeScale4fv
  @discussion Creates a 4 by 4 scaling matrix. 
  @param m The resulting scaling matrix
  @param scale The scaling factors
*/
__G3DIE__ void G3DMakeScale4fv(float m[16],CFLOAT scale[3]);

/*! 
  @function G3DMakeScale4dv
  @discussion Creates a 4 by 4 scaling matrix. 
  @param m The resulting scaling matrix
  @param scale The scaling factors
*/
__G3DIE__ void G3DMakeScale4dv(double m[16],CDOUBLE scale[3]);

/*
 *
 */

/*! 
  @function G3DMakeEulerTransform4fv
  @discussion Creates a 4 by 4 rotation matrix from HPR Euler angles. 
  @param euler The resulting rotation matrix
  @param hpr The Euler angles
*/
__G3DIE__ void G3DMakeEulerTransform4fv(float euler[16], CFLOAT hpr[3]);

/*! 
  @function G3DMakeEulerTransform4dv
  @discussion Creates a 4 by 4 rotation matrix from HPR Euler angles. 
  @param euler The resulting rotation matrix
  @param hpr The Euler angles
*/
__G3DIE__ void G3DMakeEulerTransform4dv(double euler[16], CDOUBLE hpr[3]);

/*
 *
 */

/*! 
  @function G3DHPRFromEulerTransform4fv
  @discussion Extracts the Euler angles from a 4 by 4 rotation matrix and stores them in hpr. 
  @param hpr The extracted Euler angles
  @param euler The rotation matrix
*/
__G3DIE__ void G3DHPRFromEulerTransform4fv(float hpr[3], CFLOAT euler[16]);

/*! 
  @function G3DHPRFromEulerTransform4dv
  @discussion Extracts the Euler angles from a 4 by 4 rotation matrix and stores them in hpr. 
  @param hpr The extracted Euler angles
  @param euler The rotation matrix
*/
__G3DIE__ void G3DHPRFromEulerTransform4dv(double hpr[3],CDOUBLE euler[16]);

/*
 *
 */

/*! 
  @function G3DInvertEulerTransform4fv
  @discussion Computes the inverse of a 4 by 4 Euler rotation matrix. 
  @param inv The inverted rotation matrix
  @param euler The rotation matrix
*/
__G3DIE__ void G3DInvertEulerTransform4fv(float inv[16], CFLOAT euler[16]);

/*! 
  @function G3DInvertEulerTransform4dv
  @discussion Computes the inverse of a 4 by 4 Euler rotation matrix. 
  @param inv The inverted rotation matrix
  @param euler The rotation matrix
*/
__G3DIE__ void G3DInvertEulerTransform4dv(double inv[16],CDOUBLE euler[16]);

#endif
