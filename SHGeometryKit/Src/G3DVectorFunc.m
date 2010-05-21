/* 
 * G3DVectorFunc.c created by robert on 2001-01-05 15:07:16 +0000
 *
 * Project SHGeometryKit
 *
 * Created with ProjectCenter - http://www.projectcenter.ch
 *
 * $Id: G3DVectorFunc.c,v 1.1 2002/10/12 17:24:32 probert Exp $
 */

#include "G3DVectorFunc.h"
#include "G3DDefs.h"

/******************************************************************************
 *
 * Vector Function Declarations
 *
 *****************************************************************************/

void G3DAddScaledVector3fv(float res[3], CFLOAT p[3], CFLOAT q[3], CFLOAT lambda);
void G3DAddScaledVector3dv(double res[3], CDOUBLE p[3], CDOUBLE q[3], CDOUBLE lambda);

void G3DAddScaledVectors3fv(float res[3], CFLOAT p[3], CFLOAT q[3], CFLOAT lambda1, CFLOAT r[3], CFLOAT lambda2);
void G3DAddScaledVectors3dv(double res[3], CDOUBLE p[3], CDOUBLE q[3], CDOUBLE lambda1, CDOUBLE r[3], CDOUBLE lambda2);

void G3DVector3fFromEulerRep(float res[3], CFLOAT src[3]);
void G3DVector3dFromEulerRep(double res[3], CDOUBLE src[3]);

void G3DEulerRepFromVector3f(float res[3], CFLOAT src[3]);
void G3DEulerRepFromVector3d(double res[3], CDOUBLE src[3]);

void G3DTransformVector3fv(float res[3],CFLOAT src[3], CFLOAT mat[16]);
void G3DTransformVector3dv(double res[3],CDOUBLE src[3], CDOUBLE mat[16]);

void G3DTransformVector4fv(float res[4],CFLOAT src[4], CFLOAT mat[16]);
void G3DTransformVector4dv(double res[4],CDOUBLE src[4], CDOUBLE mat[16]);

void G3DMultiplyVector3fv(float res[3], CFLOAT a[3], CFLOAT b[3]);
void G3DMultiplyVector3dv(double res[3], CDOUBLE a[3], CDOUBLE b[3]);

void G3DCopyVector2f(float res[2], CFLOAT x, CFLOAT y);
void G3DCopyVector2d(double res[2], CDOUBLE x, CDOUBLE y);

void G3DCopyVector3f(float res[3], CFLOAT x, CFLOAT y, CFLOAT z);
void G3DCopyVector3d(double res[3], CDOUBLE x, CDOUBLE y, CDOUBLE z);

void G3DCopyVector4f(float res[4], CFLOAT x, CFLOAT y, CFLOAT z, CFLOAT h);
void G3DCopyVector4d(double res[4], CDOUBLE x, CDOUBLE y, CDOUBLE z, CDOUBLE h);

void G3DCopyVector2dv(double cpy[2], CDOUBLE orig[2]);
void G3DCopyVector3dv(double cpy[3], CDOUBLE orig[3]);
void G3DCopyVector4dv(double cpy[4], CDOUBLE orig[4]);

void G3DCopyVector2fv(float cpy[2], CFLOAT orig[2]);
void G3DCopyVector3fv(float cpy[3], CFLOAT orig[3]);
void G3DCopyVector4fv(float cpy[4], CFLOAT orig[4]);

void G3DAddVectors2dv(double res[2],CDOUBLE a[2],CDOUBLE b[2]);
void G3DAddVectors3dv(double res[3],CDOUBLE a[3],CDOUBLE b[3]);
void G3DAddVectors4dv(double res[4],CDOUBLE a[4],CDOUBLE b[4]);

void G3DAddVectors2fv(float res[2],CFLOAT a[2],CFLOAT b[2]);
void G3DAddVectors3fv(float res[3],CFLOAT a[3],CFLOAT b[3]);
void G3DAddVectors4fv(float res[4],CFLOAT a[4],CFLOAT b[4]);

void G3DSubVectors2dv(double res[2],CDOUBLE a[2],CDOUBLE b[2]);
void G3DSubVectors3dv(double res[3],CDOUBLE a[3],CDOUBLE b[3]);
void G3DSubVectors4dv(double res[4],CDOUBLE a[4],CDOUBLE b[4]);

void G3DSubVectors2fv(float res[2],CFLOAT a[2],CFLOAT b[2]);
void G3DSubVectors3fv(float res[3],CFLOAT a[3],CFLOAT b[3]);
void G3DSubVectors4fv(float res[4],CFLOAT a[4],CFLOAT b[4]);

void G3DNegateVector2dv(double res[2],CDOUBLE src[2]);
void G3DNegateVector3dv(double res[3],CDOUBLE src[3]);
void G3DNegateVector4dv(double res[4],CDOUBLE src[4]);

void G3DNegateVector2fv(float res[2],CFLOAT src[2]);
void G3DNegateVector3fv(float res[3],CFLOAT src[3]);
void G3DNegateVector4fv(float res[4],CFLOAT src[4]);

void G3DScaleVector2dv(double res[2],CDOUBLE src[2],CDOUBLE scalar);
void G3DScaleVector3dv(double res[3],CDOUBLE src[3],CDOUBLE scalar);
void G3DScaleVector4dv(double res[4],CDOUBLE src[4],CDOUBLE scalar);

void G3DScaleVector2fv(float res[2],CFLOAT src[2],CFLOAT scalar);
void G3DScaleVector3fv(float res[3],CFLOAT src[3],CFLOAT scalar);
void G3DScaleVector4fv(float res[4],CFLOAT src[4],CFLOAT scalar);

int G3DCompareVector2fv(CFLOAT a[2],CFLOAT b[2],CFLOAT tol);
int G3DCompareVector3fv(CFLOAT a[3],CFLOAT b[3],CFLOAT tol);
int G3DCompareVector4fv(CFLOAT a[4],CFLOAT b[4],CFLOAT tol);

int G3DCompareVector2dv(CDOUBLE a[2],CDOUBLE b[2],CDOUBLE tol);
int G3DCompareVector3dv(CDOUBLE a[3],CDOUBLE b[3],CDOUBLE tol);
int G3DCompareVector4dv(CDOUBLE a[4],CDOUBLE b[4],CDOUBLE tol);

int G3DIsEqualToVector2fv(CFLOAT a[2],CFLOAT b[2]);
int G3DIsEqualToVector3fv(CFLOAT a[3],CFLOAT b[3]);
int G3DIsEqualToVector4fv(CFLOAT a[4],CFLOAT b[4]);

int G3DIsEqualToVector2dv(CDOUBLE a[2],CDOUBLE b[2]);
int G3DIsEqualToVector3dv(CDOUBLE a[3],CDOUBLE b[3]);
int G3DIsEqualToVector4dv(CDOUBLE a[4],CDOUBLE b[4]);

float G3DScalarProduct2fv(CFLOAT a[2],CFLOAT b[2]);
float G3DScalarProduct3fv(CFLOAT a[3],CFLOAT b[3]);
float G3DScalarProduct4fv(CFLOAT a[4],CFLOAT b[4]);

double G3DScalarProduct2dv(CDOUBLE a[2],CDOUBLE b[2]);
double G3DScalarProduct3dv(CDOUBLE a[3],CDOUBLE b[3]);
double G3DScalarProduct4dv(CDOUBLE a[4],CDOUBLE b[4]);

void G3DVectorProduct3fv(float res[3],CFLOAT a[3],CFLOAT b[3]);
void G3DVectorProduct3dv(double res[3],CDOUBLE a[3],CDOUBLE b[3]);

float G3DMixedProduct3fv(CFLOAT a[3], CFLOAT b[3], CFLOAT c[3]);
double G3DMixedProduct3dv(CDOUBLE a[3], CDOUBLE b[3], CDOUBLE c[3]);

float G3DDistance2fv(CFLOAT a[2],CFLOAT b[2]);
float G3DDistance3fv(CFLOAT a[3],CFLOAT b[3]);
float G3DDistance4fv(CFLOAT a[4],CFLOAT b[4]);

double G3DDistance2dv(CDOUBLE a[2],CDOUBLE b[2]);
double G3DDistance3dv(CDOUBLE a[3],CDOUBLE b[3]);
double G3DDistance4dv(CDOUBLE a[4],CDOUBLE b[4]);

float G3DLength2fv(CFLOAT a[2]);
float G3DLength3fv(CFLOAT a[3]);
float G3DLength4fv(CFLOAT a[4]);

double G3DLength2dv(CDOUBLE a[2]);
double G3DLength3dv(CDOUBLE a[3]);
double G3DLength4dv(CDOUBLE a[4]);

void G3DNormalise2fv(float res[2],CFLOAT src[2]);
void G3DNormalise3fv(float res[3],CFLOAT src[3]);
void G3DNormalise4fv(float res[4],CFLOAT src[4]);

void G3DNormalise2dv(double res[2],CDOUBLE src[2]);
void G3DNormalise3dv(double res[3],CDOUBLE src[3]);
void G3DNormalise4dv(double res[4],CDOUBLE src[4]);

/******************************************************************************
 *
 * Vector Function Definitions
 *
 *****************************************************************************/

__G3DI__ void G3DAddScaledVector3fv(float res[3], CFLOAT p[3], CFLOAT q[3], CFLOAT lambda)
{
  res[0] = p[0] + lambda * q[0];
  res[1] = p[1] + lambda * q[1];
  res[2] = p[2] + lambda * q[2];
}

__G3DI__ void G3DAddScaledVector3dv(double res[3], CDOUBLE p[3], CDOUBLE q[3], CDOUBLE lambda)
{
  res[0] = p[0] + lambda * q[0];
  res[1] = p[1] + lambda * q[1];
  res[2] = p[2] + lambda * q[2];
}

__G3DI__ void G3DAddScaledVectors3fv(float res[3], CFLOAT p[3], CFLOAT q[3], CFLOAT lambda1, CFLOAT r[3], CFLOAT lambda2)
{
  res[0] = p[0] + lambda1 * q[0] + lambda2 * r[0];
  res[1] = p[1] + lambda1 * q[1] + lambda2 * r[1];
  res[2] = p[2] + lambda1 * q[2] + lambda2 * r[2];
}

__G3DI__ void G3DAddScaledVectors3dv(double res[3], CDOUBLE p[3], CDOUBLE q[3], CDOUBLE lambda1, CDOUBLE r[3], CDOUBLE lambda2)
{
  res[0] = p[0] + lambda1 * q[0] + lambda2 * r[0];
  res[1] = p[1] + lambda1 * q[1] + lambda2 * r[1];
  res[2] = p[2] + lambda1 * q[2] + lambda2 * r[2];
}

__G3DI__ void G3DVector3fFromEulerRep(float res[3], CFLOAT src[3])
{
  // warning G3DVector3fFromEulerRep not yet done!
}

__G3DI__ void G3DVector3dFromEulerRep(double res[3], CDOUBLE src[3])
{
  // warning G3DVector3dFromEulerRep not yet done!
}

__G3DI__ void G3DEulerRepFromVector3f(float res[3], CFLOAT src[3])
{
  float tmp[3];
  float length;
  float scalar;

  tmp[0] = src[0];
  tmp[1] = src[1];
  tmp[2] = src[2];

  /* Normalise */
  length = sqrt(SQR(tmp[0]) + SQR(tmp[1]) + SQR(tmp[2]));
  scalar = 1.0f/length;

  tmp[0] = src[0] * scalar;
  tmp[1] = src[1] * scalar;
  tmp[2] = src[2] * scalar;

  res[0] = -atan2(tmp[0], tmp[1]) * RAD2DEG;
  res[1] = -atan2(tmp[2], sqrt(SQR(tmp[0]) + SQR(tmp[1]))) * RAD2DEG;
  res[2] = 0.0f;
}

__G3DI__ void G3DEulerRepFromVector3d(double res[3], CDOUBLE src[3])
{
  double tmp[3];
  double length;
  double scalar;

  tmp[0] = src[0];
  tmp[1] = src[1];
  tmp[2] = src[2];

  /* Normalise */
  length = sqrt(SQR(tmp[0]) + SQR(tmp[1]) + SQR(tmp[2]));
  scalar = 1.0/length;

  tmp[0] = src[0] * scalar;
  tmp[1] = src[1] * scalar;
  tmp[2] = src[2] * scalar;

  res[0] = -atan2(tmp[0], tmp[1]) * RAD2DEG;
  res[1] = -atan2(tmp[2], sqrt(SQR(tmp[0]) + SQR(tmp[1]))) * RAD2DEG;
  res[2] = 0.0;
}

__G3DI__ void G3DTransformVector3fv(float res[3],CFLOAT src[3], CFLOAT mat[16])
{
  res[0] = src[0]*mat[0] + src[1]*mat[4] + src[2]*mat[8] + mat[12];
  res[1] = src[0]*mat[1] + src[1]*mat[5] + src[2]*mat[9] + mat[13];
  res[2] = src[0]*mat[2] + src[1]*mat[6] + src[2]*mat[10] + mat[14];
}

__G3DI__ void G3DTransformVector3dv(double res[3],CDOUBLE src[3], CDOUBLE mat[16])
{
  res[0] = src[0]*mat[0] + src[1]*mat[4] + src[2]*mat[8] + mat[12];
  res[1] = src[0]*mat[1] + src[1]*mat[5] + src[2]*mat[9] + mat[13];
  res[2] = src[0]*mat[2] + src[1]*mat[6] + src[2]*mat[10] + mat[14];
}

__G3DI__ void G3DTransformVector4fv(float res[4],CFLOAT src[4], CFLOAT mat[16])
{
  res[0] = src[0]*mat[0] + src[1]*mat[4] + src[2]*mat[8] + src[3]*mat[12];
  res[1] = src[0]*mat[1] + src[1]*mat[5] + src[2]*mat[9] + src[3]*mat[13];
  res[2] = src[0]*mat[2] + src[1]*mat[6] + src[2]*mat[10] + src[3]*mat[14];
  res[3] = src[0]*mat[3] + src[1]*mat[7] + src[2]*mat[11] + src[3]*mat[15];
}

__G3DI__ void G3DTransformVector4dv(double res[4],CDOUBLE src[4], CDOUBLE mat[16])
{
  res[0] = src[0]*mat[0] + src[1]*mat[4] + src[2]*mat[8] + src[3]*mat[12];
  res[1] = src[0]*mat[1] + src[1]*mat[5] + src[2]*mat[9] + src[3]*mat[13];
  res[2] = src[0]*mat[2] + src[1]*mat[6] + src[2]*mat[10] + src[3]*mat[14];
  res[3] = src[0]*mat[3] + src[1]*mat[7] + src[2]*mat[11] + src[3]*mat[15];
}

__G3DI__ void G3DMultiplyVector3dv(double res[3], CDOUBLE a[3], CDOUBLE b[3]) 
{
  res[0] = a[1] * b[2] - a[2] * b[1];
  res[1] = a[2] * b[0] - a[0] * b[2];
  res[2] = a[0] * b[1] - a[1] * b[0];
}

__G3DI__ void G3DMultiplyVector3fv(float res[3], CFLOAT a[3], CFLOAT b[3])
{
  res[0] = a[1] * b[2] - a[2] * b[1];
  res[1] = a[2] * b[0] - a[0] * b[2];
  res[2] = a[0] * b[1] - a[1] * b[0];
}

__G3DI__ void G3DCopyVector2f(float res[2], CFLOAT x, CFLOAT y)
{
  res[0] = x;
  res[1] = y;
}

__G3DI__ void G3DCopyVector2d(double res[2], CDOUBLE x, CDOUBLE y)
{
  res[0] = x;
  res[1] = y;
}

__G3DI__ void G3DCopyVector3f(float res[3], CFLOAT x, CFLOAT y, CFLOAT z)
{
  res[0] = x;
  res[1] = y;
  res[2] = z;
}

__G3DI__ void G3DCopyVector3d(double res[3], CDOUBLE x, CDOUBLE y, CDOUBLE z)
{
  res[0] = x;
  res[1] = y;
  res[2] = z;
}

__G3DI__ void G3DCopyVector4f(float res[4], CFLOAT x, CFLOAT y, CFLOAT z, CFLOAT h)
{
  res[0] = x;
  res[1] = y;
  res[2] = z;
  res[3] = h;
}

__G3DI__ void G3DCopyVector4d(double res[4], CDOUBLE x, CDOUBLE y, CDOUBLE z, CDOUBLE h)
{
  res[0] = x;
  res[1] = y;
  res[2] = z;
  res[3] = h;
}

__G3DI__ void G3DCopyVector2fv(float cpy[2], CFLOAT orig[2])
{
  cpy[0] = orig[0];
  cpy[1] = orig[1];
}

__G3DI__ void G3DCopyVector2dv(double cpy[2], CDOUBLE orig[2])
{
  cpy[0] = orig[0];
  cpy[1] = orig[1];
}

__G3DI__ void G3DCopyVector3fv(float cpy[3], CFLOAT orig[3])
{
  cpy[0] = orig[0];
  cpy[1] = orig[1];
  cpy[2] = orig[2];
}

__G3DI__ void G3DCopyVector3dv(double cpy[3], CDOUBLE orig[3])
{
  cpy[0] = orig[0];
  cpy[1] = orig[1];
  cpy[2] = orig[2];
}

__G3DI__ void G3DCopyVector4fv(float cpy[4], CFLOAT orig[4])
{
  cpy[0] = orig[0];
  cpy[1] = orig[1];
  cpy[2] = orig[2];
  cpy[3] = orig[3];
}

__G3DI__ void G3DCopyVector4dv(double cpy[4], CDOUBLE orig[4])
{
  cpy[0] = orig[0];
  cpy[1] = orig[1];
  cpy[2] = orig[2];
  cpy[3] = orig[3];
}

__G3DI__ void G3DAddVectors2fv(float res[2], CFLOAT a[2], CFLOAT b[2])
{
  res[0] = a[0] + b[0];
  res[1] = a[1] + b[1];
}

__G3DI__ void G3DAddVectors2dv(double res[2], CDOUBLE a[2], CDOUBLE b[2])
{
  res[0] = a[0] + b[0];
  res[1] = a[1] + b[1];
}

__G3DI__ void G3DAddVectors3fv(float res[3], CFLOAT a[3], CFLOAT b[3])
{
  res[0] = a[0] + b[0];
  res[1] = a[1] + b[1];
  res[2] = a[2] + b[2];
}

__G3DI__ void G3DAddVectors3dv(double res[3], CDOUBLE a[3], CDOUBLE b[3])
{
  res[0] = a[0] + b[0];
  res[1] = a[1] + b[1];
  res[2] = a[2] + b[2];
}

__G3DI__ void G3DAddVectors4fv(float res[4], CFLOAT a[4], CFLOAT b[4])
{
  res[0] = a[0] + b[0];
  res[1] = a[1] + b[1];
  res[2] = a[2] + b[2];
  res[3] = a[3] + b[3];
}

__G3DI__ void G3DAddVectors4dv(double res[4], CDOUBLE a[4], CDOUBLE b[4])
{
  res[0] = a[0] + b[0];
  res[1] = a[1] + b[1];
  res[2] = a[2] + b[2];
  res[3] = a[3] + b[3];
}

__G3DI__ void G3DSubVectors2fv(float res[2], CFLOAT a[2], CFLOAT b[2])
{
  res[0] = a[0] - b[0];
  res[1] = a[1] - b[1];
}

__G3DI__ void G3DSubVectors2dv(double res[2], CDOUBLE a[2], CDOUBLE b[2])
{
  res[0] = a[0] - b[0];
  res[1] = a[1] - b[1];
}

__G3DI__ void G3DSubVectors3fv(float res[3], CFLOAT a[3], CFLOAT b[3])
{
  res[0] = a[0] - b[0];
  res[1] = a[1] - b[1];
  res[2] = a[2] - b[2];
}

__G3DI__ void G3DSubVectors3dv(double res[3], CDOUBLE a[3], CDOUBLE b[3])
{
  res[0] = a[0] - b[0];
  res[1] = a[1] - b[1];
  res[2] = a[2] - b[2];
}

__G3DI__ void G3DSubVectors4fv(float res[4], CFLOAT a[4], CFLOAT b[4])
{
  res[0] = a[0] - b[0];
  res[1] = a[1] - b[1];
  res[2] = a[2] - b[2];
  res[3] = a[3] - b[3];
}

__G3DI__ void G3DSubVectors4dv(double res[4], CDOUBLE a[4], CDOUBLE b[4])
{
  res[0] = a[0] - b[0];
  res[1] = a[1] - b[1];
  res[2] = a[2] - b[2];
  res[3] = a[3] - b[3];
}

__G3DI__ void G3DNegateVector2fv(float res[2], CFLOAT src[2])
{
  res[0] = -src[0];
  res[1] = -src[1];
}

__G3DI__ void G3DNegateVector2dv(double res[2], CDOUBLE src[2])
{
  res[0] = -src[0];
  res[1] = -src[1];
}

__G3DI__ void G3DNegateVector3fv(float res[3], CFLOAT src[3])
{
  res[0] = -src[0];
  res[1] = -src[1];
  res[2] = -src[2];
}

__G3DI__ void G3DNegateVector3dv(double res[3], CDOUBLE src[3])
{
  res[0] = -src[0];
  res[1] = -src[1];
  res[2] = -src[2];
}

__G3DI__ void G3DNegateVector4fv(float res[4], CFLOAT src[4])
{
  res[0] = -src[0];
  res[1] = -src[1];
  res[2] = -src[2];
  res[3] = -src[3];
}

__G3DI__ void G3DNegateVector4dv(double res[4], CDOUBLE src[4])
{
  res[0] = -src[0];
  res[1] = -src[1];
  res[2] = -src[2];
  res[3] = -src[3];
}

__G3DI__ void G3DScaleVector2fv(float res[2], CFLOAT src[2], CFLOAT scalar)
{
  res[0] = src[0] * scalar;
  res[1] = src[1] * scalar;
}

__G3DI__ void G3DScaleVector2dv(double res[2], CDOUBLE src[2], CDOUBLE scalar)
{
  res[0] = src[0] * scalar;
  res[1] = src[1] * scalar;
}

__G3DI__ void G3DScaleVector3fv(float res[3], CFLOAT src[3], CFLOAT scalar)
{
  res[0] = src[0] * scalar;
  res[1] = src[1] * scalar;
  res[2] = src[2] * scalar;
}

__G3DI__ void G3DScaleVector3dv(double res[3], CDOUBLE src[3], CDOUBLE scalar)
{
  res[0] = src[0] * scalar;
  res[1] = src[1] * scalar;
  res[2] = src[2] * scalar;
}

__G3DI__ void G3DScaleVector4fv(float res[4], CFLOAT src[4], CFLOAT scalar)
{
  res[0] = src[0] * scalar;
  res[1] = src[1] * scalar;
  res[2] = src[2] * scalar;
  res[3] = src[3] * scalar;
}

__G3DI__ void G3DScaleVector4dv(double res[4], CDOUBLE src[4], CDOUBLE scalar)
{
  res[0] = src[0] * scalar;
  res[1] = src[1] * scalar;
  res[2] = src[2] * scalar;
  res[3] = src[3] * scalar;
}

__G3DI__ int G3DCompareVector2fv(CFLOAT a[2], CFLOAT b[2], CFLOAT tol)
{
  int ret = 0;

  if ((ret = G3DCompareFloat(a[0], b[0], tol)) != 0.0f) return ret;
  if ((ret = G3DCompareFloat(a[1], b[1], tol)) != 0.0f) return ret;

  return ret;
}

__G3DI__ int G3DCompareVector2dv(CDOUBLE a[2], CDOUBLE b[2], CDOUBLE tol)
{
  int ret = 0;

  if ((ret = G3DCompareDouble(a[0], b[0], tol)) != 0) return ret;
  if ((ret = G3DCompareDouble(a[1], b[1], tol)) != 0) return ret;

  return ret;
}

__G3DI__ int G3DCompareVector3fv(CFLOAT a[3], CFLOAT b[3], CFLOAT tol)
{
  int ret = 0;

  if ((ret = G3DCompareFloat(a[0], b[0], tol)) != 0.0f) return ret;
  if ((ret = G3DCompareFloat(a[1], b[1], tol)) != 0.0f) return ret;
  if ((ret = G3DCompareFloat(a[2], b[2], tol)) != 0.0f) return ret;

  return ret;
}

__G3DI__ int G3DCompareVector3dv(CDOUBLE a[3], CDOUBLE b[3], CDOUBLE tol)
{
  int ret = 0;

  if ((ret = G3DCompareDouble(a[0], b[0], tol)) != 0) return ret;
  if ((ret = G3DCompareDouble(a[1], b[1], tol)) != 0) return ret;
  if ((ret = G3DCompareDouble(a[2], b[2], tol)) != 0) return ret;

  return ret;
}

__G3DI__ int G3DCompareVector4fv(CFLOAT a[4], CFLOAT b[4], CFLOAT tol)
{
  int ret = 0;

  if ((ret = G3DCompareFloat(a[0], b[0], tol)) != 0.0f) return ret;
  if ((ret = G3DCompareFloat(a[1], b[1], tol)) != 0.0f) return ret;
  if ((ret = G3DCompareFloat(a[2], b[2], tol)) != 0.0f) return ret;
  if ((ret = G3DCompareFloat(a[3], b[3], tol)) != 0.0f) return ret;

  return ret;
}

__G3DI__ int G3DCompareVector4dv(CDOUBLE a[4], CDOUBLE b[4], CDOUBLE tol)
{
  int ret = 0;

  if ((ret = G3DCompareDouble(a[0], b[0], tol)) != 0) return ret;
  if ((ret = G3DCompareDouble(a[1], b[1], tol)) != 0) return ret;
  if ((ret = G3DCompareDouble(a[2], b[2], tol)) != 0) return ret;
  if ((ret = G3DCompareDouble(a[3], b[3], tol)) != 0) return ret;

  return ret;
}

__G3DI__ int G3DIsEqualToVector2fv(CFLOAT a[2], CFLOAT b[2])
{
  return (a[0] == b[0] && a[1] == b[1]);
}

__G3DI__ int G3DIsEqualToVector2dv(CDOUBLE a[2], CDOUBLE b[2])
{
  return (a[0] == b[0] && a[1] == b[1]);
}

__G3DI__ int G3DIsEqualToVector3fv(CFLOAT a[3], CFLOAT b[3])
{
  return (a[0] == b[0] && a[1] == b[1] && a[2] == b[2]);
}

__G3DI__ int G3DIsEqualToVector3dv(CDOUBLE a[3], CDOUBLE b[3])
{
  return (a[0] == b[0] && a[1] == b[1] && a[2] == b[2]);
}

__G3DI__ int G3DIsEqualToVector4fv(CFLOAT a[4], CFLOAT b[4])
{
  return (a[0] == b[0] && a[1] == b[1] && a[2] == b[2] && a[3] == b[3]);
}

__G3DI__ int G3DIsEqualToVector4dv(CDOUBLE a[4], CDOUBLE b[4])
{
  return (a[0] == b[0] && a[1] == b[1] && a[2] == b[2] && a[3] == b[3]);
}

__G3DI__ float G3DScalarProduct2fv(CFLOAT a[2], CFLOAT b[2])
{
  return (a[0] * b[0] + a[1] * b[1]);
}

__G3DI__ double G3DScalarProduct2dv(CDOUBLE a[2], CDOUBLE b[2])
{
  return (a[0] * b[0] + a[1] * b[1]);
}

__G3DI__ float G3DScalarProduct3fv(CFLOAT a[3], CFLOAT b[3])
{
  return (a[0] * b[0] + a[1] * b[1] + a[2] * b[2]);
}

__G3DI__ double G3DScalarProduct3dv(CDOUBLE a[3], CDOUBLE b[3])
{
  return (a[0] * b[0] + a[1] * b[1] + a[2] * b[2]);
}

__G3DI__ float G3DScalarProduct4fv(CFLOAT a[4], CFLOAT b[4])
{
  return (a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3]);
}

__G3DI__ double G3DScalarProduct4dv(CDOUBLE a[4], CDOUBLE b[4])
{
  return (a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3]);
}

__G3DI__ void G3DVectorProduct3fv(float res[3], CFLOAT a[3], CFLOAT b[3])
{
  res[0] = a[1] * b[2] - a[2] * b[1] ;
  res[1] = a[2] * b[0] - a[0] * b[2] ;
  res[2] = a[0] * b[1] - a[1] * b[0] ;
}

__G3DI__ void G3DVectorProduct3dv(double res[3], CDOUBLE a[3], CDOUBLE b[3])
{
  res[0] = a[1] * b[2] - a[2] * b[1] ;
  res[1] = a[2] * b[0] - a[0] * b[2] ;
  res[2] = a[0] * b[1] - a[1] * b[0] ;
}

/*
 * Calculates (A x B) * C
 *
 */

__G3DI__ float G3DMixedProduct3fv(CFLOAT a[3], CFLOAT b[3], CFLOAT c[3])
{
  return ((a[0]*b[1]*c[2]) 
	  + (a[1]*b[2]*c[0]) 
	  + (a[2]*b[0]*c[1]) 
	  - (a[2]*b[1]*c[0]) 
	  - (a[0]*b[2]*c[1]) 
	  - (a[1]*b[0]*c[2]));
}

__G3DI__ double G3DMixedProduct3dv(CDOUBLE a[3], CDOUBLE b[3], CDOUBLE c[3])
{
  return ((a[0]*b[1]*c[2]) 
	  + (a[1]*b[2]*c[0]) 
	  + (a[2]*b[0]*c[1]) 
	  - (a[2]*b[1]*c[0]) 
	  - (a[0]*b[2]*c[1]) 
	  - (a[1]*b[0]*c[2]));
}

__G3DI__ float G3DDistance2fv(CFLOAT a[2], CFLOAT b[2])
{
  return sqrt(SQR(a[0]-b[0]) + SQR(a[1]-b[1]));
}

__G3DI__ double G3DDistance2dv(CDOUBLE a[2], CDOUBLE b[2])
{
  return sqrt(SQR(a[0]-b[0]) + SQR(a[1]-b[1]));
}

__G3DI__ float G3DDistance3fv(CFLOAT a[3], CFLOAT b[3])
{
  return sqrt(SQR(a[0]-b[0])+SQR(a[1]-b[1])+SQR(a[2]-b[2]));
}

__G3DI__ double G3DDistance3dv(CDOUBLE a[3], CDOUBLE b[3])
{
  return sqrt(SQR(a[0]-b[0])+SQR(a[1]-b[1])+SQR(a[2]-b[2]));
}

__G3DI__ float G3DDistance4fv(CFLOAT a[4], CFLOAT b[4])
{
  return sqrt(SQR(a[0]-b[0])+SQR(a[1]-b[1])+SQR(a[2]-b[2])+SQR(a[3]-b[3]));
}

__G3DI__ double G3DDistance4dv(CDOUBLE a[4], CDOUBLE b[4])
{
  return sqrt(SQR(a[0]-b[0])+SQR(a[1]-b[1])+SQR(a[2]-b[2])+SQR(a[3]-b[3]));
}

__G3DI__ float G3DLength2fv(CFLOAT a[2])
{
  return sqrt(G3DScalarProduct2fv(a,a));
}

__G3DI__ double G3DLength2dv(CDOUBLE a[2])
{
  return sqrt(G3DScalarProduct2dv(a,a));
}

__G3DI__ float G3DLength3fv(CFLOAT a[3])
{
  return sqrt(G3DScalarProduct3fv(a,a));
}

__G3DI__ double G3DLength3dv(CDOUBLE a[3])
{
  return sqrt(G3DScalarProduct3dv(a,a));
}

__G3DI__ float G3DLength4fv(CFLOAT a[4])
{
  return sqrt(G3DScalarProduct4fv(a,a));
}

__G3DI__ double G3DLength4dv(CDOUBLE a[4])
{
  return sqrt(G3DScalarProduct4dv(a,a));
}

__G3DI__ void G3DNormalise2fv(float res[2], CFLOAT src[2])
{
  register float l;

  if ((l = G3DLength2fv(src)) != 0.0f) {
    G3DScaleVector2fv(res, src,(1.0f/l));
  }
}

__G3DI__ void G3DNormalise2dv(double res[2], CDOUBLE src[2])
{
  register double l;

  if ((l = G3DLength2dv(src)) != 0.0) {
    G3DScaleVector2dv(res, src,(1.0/l));
  }
}

__G3DI__ void G3DNormalise3fv(float res[3], CFLOAT src[3])
{
  register float l;

  if ((l = G3DLength3fv(src)) != 0.0f) {
    G3DScaleVector3fv(res, src,(1.0f/l));
  }
}

__G3DI__ void G3DNormalise3dv(double res[3], CDOUBLE src[3])
{
  register double l;

  if ((l = G3DLength3dv(src)) != 0.0) {
    G3DScaleVector3dv(res, src,(1.0/l));
  }
}

__G3DI__ void G3DNormalise4fv(float res[4], CFLOAT src[4])
{
  register float l;

  if ((l = G3DLength4fv(src)) != 0.0f) {
    G3DScaleVector4fv(res, src,(1.0f/l));
  }
}

__G3DI__ void G3DNormalise4dv(double res[4], CDOUBLE src[4])
{
  register double l;

  if ((l = G3DLength4dv(src)) != 0.0) {
    G3DScaleVector4dv(res, src,(1.0/l));
  }
}
