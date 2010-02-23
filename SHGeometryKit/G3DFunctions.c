/*
 * Project            	SHGeometryKit
 * Class              	G3DFunctions
 * Creator            	Philippe C.D. Robert
 * Maintainer         	Philippe C.D. Robert
 * Creation Date      	Thu Sep  9 11:05:08 CEST 1999
 *
 * Copyright (c) Philippe C.D. Robert
 *
 * The SHGeometryKit is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU LGPL Version 2 as published by the Free 
 * Software Foundation
 *
 * A lot of the code found here is based on algorithms and code examples found
 * in the Graphics Gem books and papers from GameDeveloper!
 *
 * $Id: G3DFunctions.c,v 1.1 2002/10/12 17:24:32 probert Exp $
 *
 */

#include "G3DFunctions.h"

/******************************************************************************
 *
 * Some usefuls vectors and matrices
 *
 *****************************************************************************/

const float  G3DIdentityMatrix3f[9] = {1.0f,0.0f,0.0f,
                                       0.0f,1.0f,0.0f,
                                       0.0f,0.0f,1.0f};

const double G3DIdentityMatrix3d[9] = {1.0,0.0,0.0,
                                       0.0,1.0,0.0,
                                       0.0,0.0,1.0};

const float  G3DIdentityMatrix4f[16] = {1.0f,0.0f,0.0f,0.0f,
                                        0.0f,1.0f,0.0f,0.0f,
				        0.0f,0.0f,1.0f,0.0f,
				        0.0f,0.0f,0.0f,1.0f};

const double G3DIdentityMatrix4d[16] = {1.0,0.0,0.0,0.0,
                                        0.0,1.0,0.0,0.0,
				        0.0,0.0,1.0,0.0,
				        0.0,0.0,0.0,1.0};

const float  G3DDefaultPlane4f[4] = {0.0f,0.0f,1.0f,0.0f};
const double G3DDefaultPlane4d[4] = {0.0,0.0,1.0,0.0};

/******************************************************************************
 *
 * Misc Functions Declaration
 *
 *****************************************************************************/

void G3DLinearInterpolateVector3fv(float res[3], CFLOAT a[3], CFLOAT b[3], 
                                   CFLOAT lambda);
void G3DLinearInterpolateVector3dv(double res[3], CDOUBLE a[3], CDOUBLE b[3], 
                                   CDOUBLE lambda);

float  G3DDistanceFromPlanef(CFLOAT point[3],CFLOAT plane[4]);
double G3DDistanceFromPlaned(CDOUBLE point[3],CDOUBLE plane[4]);

int G3DIntersectLinePlanef(float point[3], CFLOAT ldir[3], CFLOAT lpos[3], 
                           CFLOAT plane[4]);

int G3DIntersectLinePlaned(double point[3], CDOUBLE ldir[3], CDOUBLE lpos[3], 
                           CDOUBLE plane[4]);

int G3DCompareFloat(float a, float b, float tol);
int G3DCompareDouble(double a, double b, double tol);

void G3DFloatsFromDoubles(float* dest, CDOUBLE *src, const int size);
void G3DDoublesFromFloats(double* dest, CFLOAT *src, const int size);


/******************************************************************************
 *
 * Misc Functions Definition
 *
 *****************************************************************************/

__G3DI__ void G3DLinearInterpolateVector3fv(float res[3], CFLOAT a[3], 
                                            CFLOAT b[3], CFLOAT lambda)
{
  float d1mlambda = 1.0f - lambda;

  if (d1mlambda == 0.0f) {
    res[0] = a[0];
    res[1] = a[1];
    res[2] = a[2];
  }
  else if (d1mlambda == 1.0f) {
    res[0] = b[0];
    res[1] = b[1];
    res[2] = b[2];
  }
  else {
    res[0] = lambda * a[0] + d1mlambda * b[0];
    res[1] = lambda * a[1] + d1mlambda * b[1];
    res[2] = lambda * a[2] + d1mlambda * b[2];
  }
}


__G3DI__ void G3DLinearInterpolateVector3dv(double res[3], CDOUBLE a[3], 
                                            CDOUBLE b[3], CDOUBLE lambda)
{
  double d1mlambda = 1.0 - lambda;

  if (d1mlambda == 0.0) {
    res[0] = a[0];
    res[1] = a[1];
    res[2] = a[2];
  }
  else if (d1mlambda == 1.0) {
    res[0] = b[0];
    res[1] = b[1];
    res[2] = b[2];
  }
  else {
    res[0] = lambda * a[0] + d1mlambda * b[0];
    res[1] = lambda * a[1] + d1mlambda * b[1];
    res[2] = lambda * a[2] + d1mlambda * b[2];
  }
}

__G3DI__ float G3DDistanceFromPlanef(CFLOAT point[3],CFLOAT plane[4])
{
  return plane[3] + (point[0]*plane[0]+point[1]*plane[1]+point[2]*plane[2]);
}

__G3DI__ double G3DDistanceFromPlaned(CDOUBLE point[3],CDOUBLE plane[4])
{
  return plane[3] + (point[0]*plane[0]+point[1]*plane[1]+point[2]*plane[2]);
}

__G3DI__ int G3DIntersectLinePlanef(float isect[3], CFLOAT ldir[3], 
                                    CFLOAT lpos[3], CFLOAT plane[4])
{
    float tmp;
    float _sp_val_pos;
    float _sp_val_dir;

    // Parallel to plane?!
    if(fabs( (plane[0] * ldir[0] + 
              plane[1] * ldir[1] + 
	      plane[2] * ldir[2]) ) < 0.0001f) {
        return 0;
    }

    _sp_val_pos = plane[0] * lpos[0] + plane[1] * lpos[1] + plane[2] * lpos[2];
    _sp_val_dir = plane[0] * ldir[0] + plane[1] * ldir[1] + plane[2] * ldir[2];

    tmp = (plane[3]+_sp_val_pos)/_sp_val_dir;

    isect[0] = lpos[0] + tmp*ldir[0];
    isect[1] = lpos[1] + tmp*ldir[1];
    isect[2] = lpos[2] + tmp*ldir[2];

    return 1;
}

__G3DI__ int G3DIntersectLinePlaned(double isect[3], CDOUBLE ldir[3], 
                                    CDOUBLE lpos[3], CDOUBLE plane[4])
{
    double tmp;
    double _sp_val_pos;
    double _sp_val_dir;

    // Parallel to plane?!
    if(fabs( (plane[0] * ldir[0] + 
              plane[1] * ldir[1] + 
	      plane[2] * ldir[2]) ) < 0.0001) {
        return 0;
    }

    _sp_val_pos = plane[0] * lpos[0] + plane[1] * lpos[1] + plane[2] * lpos[2];
    _sp_val_dir = plane[0] * ldir[0] + plane[1] * ldir[1] + plane[2] * ldir[2];

    tmp = (plane[3]+_sp_val_pos)/_sp_val_dir;

    isect[0] = lpos[0] + tmp*ldir[0];
    isect[1] = lpos[1] + tmp*ldir[1];
    isect[2] = lpos[2] + tmp*ldir[2];

    return 1;
}

__G3DI__ int G3DCompareFloat(float a, float b, float tol) 
{
  if ((a+tol) < b) return -1;
  if ((b+tol) < a) return 1;
  return 0;
}

__G3DI__ int G3DCompareDouble(double a, double b, double tol) 
{
  if ((a+tol) < b) return -1;
  if ((b+tol) < a) return 1;
  return 0;
}

__G3DI__ void G3DFloatsFromDoubles(float* dest, CDOUBLE *src, int size)
{
  while(size--) {
    *dest++ = (float)*src++;
  }
}

__G3DI__ void G3DDoublesFromFloats(double* dest, CFLOAT *src, int size)
{
  while(size--) {
    *dest++ = (double)*src++;
  }
}

