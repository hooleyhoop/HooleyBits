/*-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class              	G3DFunctions
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
// $Id: G3DFunctions.h,v 1.3 2002/10/19 16:03:08 probert Exp $
//
//---------------------------------------------------------------------------*/

/*!
  @header G3DFunctions
  Some assorted C functions and constants.
*/

#ifndef __G3DFunctions_h_INCLUDE
#define __G3DFunctions_h_INCLUDE

#include "G3DDefs.h"

/******************************************************************************
 *
 * Some usefuls vectors and matrices
 *
 *****************************************************************************/

/*!
   @const G3DIdentityMatrix3f
   @discussion 3 by 3 single-precision identity matrix
*/
extern const float  G3DIdentityMatrix3f[9];

/*!
   @const G3DIdentityMatrix3d
   @discussion 3 by 3 double-precision identity matrix
*/
extern const double G3DIdentityMatrix3d[9];

/*!
   @const G3DIdentityMatrix4f
   @discussion 4 by 4 single-precision identity matrix
*/
extern const float  G3DIdentityMatrix4f[16];

/*!
   @const G3DIdentityMatrix4d
   @discussion 4 by 4 double-precision identity matrix
*/
extern const double G3DIdentityMatrix4d[16];

/*!
   @const G3DDefaultPlane4f
   @discussion Single-precision default plane
*/
extern const float  G3DDefaultPlane4f[4];

/*!
   @const G3DDefaultPlane4d
   @discussion Double-precision default plane
*/
extern const double G3DDefaultPlane4d[4];

/******************************************************************************
 *
 * Misc Functions 
 *
 *****************************************************************************/

/*! 
  @function G3DLinearInterpolateVector3fv
  @discussion Single-precision linear interpolation between vector a and b.
  @param res The interpolated result
  @param a First vector
  @param b Second vector
  @param lambda The scalar interpolation factor
  @result Returns a 3-element vector lambda * a + (1 - lambda) * b.
*/
__G3DIE__ void G3DLinearInterpolateVector3fv(float res[3], CFLOAT a[3], 
                                             CFLOAT b[3], CFLOAT lambda);

/*! 
  @function G3DLinearInterpolateVector3dv
  @discussion Double-precision linear interpolation between vector a and b.
  @param res The interpolated result
  @param a First vector
  @param b Second vector
  @param lambda The scalar interpolation factor
  @result Returns a 3-element vector lambda * a + (1 - lambda) * b.
*/
__G3DIE__ void G3DLinearInterpolateVector3dv(double res[3], CDOUBLE a[3], 
                                             CDOUBLE b[3], CDOUBLE lambda);

/*
 *
 */

/*! 
  @function G3DDistanceFromPlanef
  @discussion Single-precision distance from a plane.
  @param point The point to compute the distance
  @param plane The plane to compute the distance
  @result Returns a single-precision distance value.
*/
__G3DIE__ float  G3DDistanceFromPlanef(CFLOAT point[3],CFLOAT plane[4]);

/*! 
  @function G3DDistanceFromPlaned
  @discussion Double-precision distance from a plane.
  @param point The point to compute the distance
  @param plane The plane to compute the distance
  @result Returns a double-precision distance value.
*/
__G3DIE__ double G3DDistanceFromPlaned(CDOUBLE point[3],CDOUBLE plane[4]);

/*! 
  @function G3DIntersectLinePlanef
  @discussion Single-precision intersection of a line with a plane.
  @param isect The intersection point
  @param ldir The direction of the line
  @param lpos The origin of the line
  @param plane The plane
  @result Returns 1 if an intersection occurs, 0 otherwise. The intersection is stored
          in isect.
*/
__G3DIE__ int G3DIntersectLinePlanef(float isect[3], CFLOAT ldir[3], 
                                     CFLOAT lpos[3], CFLOAT plane[4]);

/*! 
  @function G3DIntersectLinePlaned
  @discussion Double-precision intersection of a line with a plane.
  @param isect The intersection point
  @param ldir The direction of the line
  @param lpos The origin of the line
  @param plane The plane
  @result Returns 1 if an intersection occurs, 0 otherwise. The intersection is stored
          in isect.
*/
__G3DIE__ int G3DIntersectLinePlaned(double isect[3], CDOUBLE ldir[3], 
                                     CDOUBLE lpos[3], CDOUBLE plane[4]);

/*
 *
 */

/*! 
  @function G3DCompareFloat
  @discussion Compares 2 single-precision float values.
  @param a The first scalar value
  @param b The second scalar value
  @param tol The tolerance value
  @result Returns -1 if a+tol < b, 1 if b+tol < a, 0 otherwise.
*/
__G3DIE__ int G3DCompareFloat(float a, float b, float tol);

/*! 
  @function G3DCompareDouble
  @discussion Compares 2 double-precision float values.
  @param a The first scalar value
  @param b The second scalar value
  @param tol The tolerance value
  @result Returns -1 if a+tol < b, 1 if b+tol < a, 0 otherwise.
*/
__G3DIE__ int G3DCompareDouble(double a, double b, double tol);

/*
 *
 */

__G3DIE__ void G3DFloatsFromDoubles(float* dest, CDOUBLE *src, const int size);
__G3DIE__ void G3DDoublesFromFloats(double* dest, CFLOAT *src, const int size);


#endif









