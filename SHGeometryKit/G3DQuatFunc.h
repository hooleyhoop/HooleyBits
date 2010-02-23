/*-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class              	G3DQuatFunc
// Creator            	Philippe C.D. Robert
// Maintainer         	Philippe C.D. Robert
// Creation Date      	2001-01-05 15:07:37 +0000
//
// Copyright (c) Philippe C.D. Robert
//
// The SHGeometryKit is free software; you can redistribute it and/or modify it 
// under the terms of the GNU LGPL Version 2 as published by the Free 
// Software Foundation
//
// $Id: G3DQuatFunc.h,v 1.5 2002/10/27 11:57:08 probert Exp $
//
//---------------------------------------------------------------------------*/

/*!
  @header G3DQuatFunc
  Optimised quaternion computation C functions. 
  
  The quaternions are stored as 4-element tuples where the elements 0, 1 and 2 are 
  interpreted as the imaginary part and element 3 as the real part. 
*/

#ifndef __G3DQuatFunc_h_INCLUDE
#define __G3DQuatFunc_h_INCLUDE

#include "G3DFunctions.h"

/*! 
  @function G3DMultiplyQuatf
  @discussion Multiplies the 2 quaternions a and b such as [ ww' - v.v', vxv' + wv' + v'w ]
  @param dst The result
  @param a The first quaternion
  @param b The second quaternion
*/
__G3DIE__ void G3DMultiplyQuatf(float dst[4],CFLOAT a[4],CFLOAT b[4]);

/*! 
  @function G3DMultiplyQuatd
  @discussion Multiplies the 2 quaternions a and b such as [ ww' - v.v', vxv' + wv' + v'w ]
  @param dst The result
  @param a The first quaternion
  @param b The second quaternion
*/
__G3DIE__ void G3DMultiplyQuatd(double dst[4],CDOUBLE a[4],CDOUBLE b[4]);

/*! 
  @function G3DQuatFromAngleAxisf
  @discussion Creates a single-precision quaternion from a rotation angle and rotation axis. 
  @param dst The new quaternion
  @param angle The rotation angle
  @param axis The rotation axis
*/
__G3DIE__ void G3DQuatFromAngleAxisf(float quat[4], CFLOAT angle, CFLOAT axis[3]);

/*! 
  @function G3DQuatFromAngleAxisd
  @discussion Creates a double-precision quaternion from a rotation angle and rotation axis. 
  @param dst The new quaternion
  @param angle The rotation angle
  @param axis The rotation axis
*/
__G3DIE__ void G3DQuatFromAngleAxisd(double quat[4], CDOUBLE angle, CDOUBLE axis[3]);

/*! 
  @function G3DQuatFromRotationVectorf
  @discussion Creates a single-precision quaternion from a rotation vector. If the length of the
              vector is lesser than G3DEpsilon a unity quaternion is returned.
  @param quat The new quaternion
  @param axis The rotation vector
*/
__G3DIE__ void G3DQuatFromRotationVectorf(float quat[4], CFLOAT axis[3]);

/*! 
  @function G3DQuatFromRotationVectord
  @discussion Creates a double-precision quaternion from a rotation vector. If the length of the
              vector is lesser than G3DEpsilon a unity quaternion is returned.
  @param quat The new quaternion
  @param axis The rotation vector
*/
__G3DIE__ void G3DQuatFromRotationVectord(double quat[4], CDOUBLE axis[3]);

/*! 
  @function G3DAngleAxisFromQuatf
  @discussion Creates a single-precision angle-axis representation from quat.
  @param angle The rotation angle
  @param axis The rotation vector
  @param quat The quaternion
*/
__G3DIE__ void G3DAngleAxisFromQuatf(float *angle, float axis[3], CFLOAT quat[4]);

/*! 
  @function G3DAngleAxisFromQuatd
  @discussion Creates a double-precision angle-axis representation from quat.
  @param angle The rotation angle
  @param axis The rotation vector
  @param quat The quaternion
*/
__G3DIE__ void G3DAngleAxisFromQuatd(double *angle, double axis[3], CDOUBLE quat[4]);

/*! 
  @function G3DMatrixFromQuatf
  @discussion Creates a single-precision rotation matrix from quat.
  @param m The rotation matrix
  @param quat The quaternion
*/
__G3DIE__ void G3DMatrixFromQuatf(float m[16], CFLOAT quat[4]);

/*! 
  @function G3DMatrixFromQuatd
  @discussion Creates a double-precision rotation matrix from quat.
  @param m The rotation matrix
  @param quat The quaternion
*/
__G3DIE__ void G3DMatrixFromQuatd(double m[16], CDOUBLE quat[4]);

/*! 
  @function G3DQuatFromMatrixf
  @discussion Creates a single-precision quaternion from the rotation matrix m.
  @param quat The quaternion
  @param m The rotation matrix
*/
__G3DIE__ void G3DQuatFromMatrixf(float quat[4], CFLOAT m[16]);

/*! 
  @function G3DQuatFromMatrixd
  @discussion Creates a double-precision quaternion from the rotation matrix m.
  @param quat The quaternion
  @param m The rotation matrix
*/
__G3DIE__ void G3DQuatFromMatrixd(double quat[4], CDOUBLE m[16]);

/*! 
  @function G3DEulerRepFromQuatf
  @discussion Creates single-precision Euler angles from quat. NOT YET IMPLEMENTED!
  @param res The Euler angles
  @param quat The quaternion
*/
__G3DIE__ void G3DEulerRepFromQuatf(float res[3], CFLOAT quat[4]);

/*! 
  @function G3DEulerRepFromQuatd
  @discussion Creates double-precision Euler angles from quat. NOT YET IMPLEMENTED!
  @param res The Euler angles
  @param quat The quaternion
*/
__G3DIE__ void G3DEulerRepFromQuatd(double res[3], CDOUBLE quat[4]);

/*! 
  @function G3DQuatFromEulerRepf
  @discussion Creates single-precision quaternion from Euler angles.
  @param quat The quaternion
  @param euler The Euler angles
*/
__G3DIE__ void G3DQuatFromEulerRepf(float quat[4],CFLOAT euler[3]);

/*! 
  @function G3DQuatFromEulerRepd
  @discussion Creates double-precision quaternion from Euler angles.
  @param quat The quaternion
  @param euler The Euler angles
*/
__G3DIE__ void G3DQuatFromEulerRepd(double quat[4],CDOUBLE euler[3]);

/*! 
  @function G3DInterpolateQuatf
  @discussion Performs a spherical linear interpolation (SLERP) between the single-precision
              quaternions from and to. If the 2 quaternions are close enough a linear interpolation 
              is calculated.
  @param res The interpolated quaternion
  @param from The first quaternion
  @param to The second quaternion
  @param t The interpolation factor
*/
__G3DIE__ void G3DInterpolateQuatf(float res[4], CFLOAT from[4], CFLOAT to[4], CFLOAT t);

/*! 
  @function G3DInterpolateQuatf
  @discussion Performs a spherical linear interpolation (SLERP) between the double-precision
              quaternions from and to. If the 2 quaternions are close enough a linear interpolation
              is calculated.
  @param res The interpolated quaternion
  @param from The first quaternion
  @param to The second quaternion
  @param t The interpolation factor
*/
__G3DIE__ void G3DInterpolateQuatd(double res[4], CDOUBLE from[4], CDOUBLE to[4], CDOUBLE t);

#endif
