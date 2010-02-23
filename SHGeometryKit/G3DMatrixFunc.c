/* 
 * G3DMatrixFunc.c created by robert on 2001-01-05 15:07:26 +0000
 *
 * Project SHGeometryKit
 *
 * Created with ProjectCenter - http://www.projectcenter.ch
 *
 * $Id: G3DMatrixFunc.c,v 1.1 2002/10/12 17:24:32 probert Exp $
 */

#include "G3DMatrixFunc.h"
#include "G3DVectorFunc.h"
#include "G3DQuatFunc.h"
#include "G3DDefs.h"

#include <string.h>

/******************************************************************************
 *
 * Matrix Function Declarations
 *
 *****************************************************************************/

void G3DVector3fXMatrix3f(float res[3],  CFLOAT vec[3], CFLOAT matrix[9]);
void G3DVector3dXMatrix3d(double res[3],  CDOUBLE vec[3], CDOUBLE matrix[9]);

void G3DMatrix3fXVector3f(float res[3],  CFLOAT matrix[9], CFLOAT vector[3]);
void G3DMatrix3dXVector3d(double res[3],  CDOUBLE matrix[9], CDOUBLE vector[3]);

void G3DVector4fXMatrix4f(float res[4],  CFLOAT vec[4], CFLOAT matrix[16]);
void G3DVector4dXMatrix4d(double res[4],  CDOUBLE vec[4], CDOUBLE matrix[16]);

void G3DMatrix4fXVector4f(float res[4],  CFLOAT matrix[16], CFLOAT vec[4]);
void G3DMatrix4dXVector4d(double res[4],  CDOUBLE matrix[16], CDOUBLE vec[4]);

void G3DMatrix4fXVector3f(float res[3],  CFLOAT matrix[16], CFLOAT vec[3]);
void G3DMatrix4dXVector3d(double res[3],  CDOUBLE matrix[16], CDOUBLE vec[3]);

void G3DCopyMatrix3fv(float m1[9], CFLOAT m2[9]);
void G3DCopyMatrix3dv(double m1[9], CDOUBLE m2[9]);

void G3DCopyMatrix4fv(float m1[16], CFLOAT m2[16]);
void G3DCopyMatrix4dv(double m1[16], CDOUBLE m2[16]);

float G3DDeterminante2f(CFLOAT a, CFLOAT b, CFLOAT c, CFLOAT d);
double G3DDeterminante2d(CDOUBLE a, CDOUBLE b, CDOUBLE c, CDOUBLE d);

float G3DDeterminante3fv(CFLOAT a[3],CFLOAT b[3],CFLOAT c[3]);
double G3DDeterminante3dv(CDOUBLE a[3],CDOUBLE b[3],CDOUBLE c[3]);
float G3DDeterminante3f(CFLOAT a1,CFLOAT a2,CFLOAT a3,CFLOAT b1,CFLOAT b2,CFLOAT b3,CFLOAT c1,CFLOAT c2,CFLOAT c3);
double G3DDeterminante3d(CDOUBLE a1,CDOUBLE a2,CDOUBLE a3,CDOUBLE b1,CDOUBLE b2,CDOUBLE b3,CDOUBLE c1,CDOUBLE c2,CDOUBLE c3);

float G3DDeterminante4fv(CFLOAT m[16]);
double G3DDeterminante4dv(CDOUBLE m[16]);

void G3DMakeIdentity3fv(float m[9]);
void G3DMakeIdentity3dv(double m[9]);
void G3DMakeIdentity4fv(float m[16]);
void G3DMakeIdentity4dv(double m[16]);

void G3DAddMatrix3fv(float m[9],CFLOAT a[9],CFLOAT b[9]);
void G3DAddMatrix3dv(double m[9],CDOUBLE a[9],CDOUBLE b[9]);
void G3DAddMatrix4fv(float m[16],CFLOAT a[16],CFLOAT b[16]);
void G3DAddMatrix4dv(double m[16],CDOUBLE a[16],CDOUBLE b[16]);

void G3DSubMatrix3fv(float m[9],CFLOAT a[9],CFLOAT b[9]);
void G3DSubMatrix3dv(double m[9],CDOUBLE a[9],CDOUBLE b[9]);
void G3DSubMatrix4fv(float m[16],CFLOAT a[16],CFLOAT b[16]);
void G3DSubMatrix4dv(double m[16],CDOUBLE a[16],CDOUBLE b[16]);

void G3DMultiplyMatrix3fv(float m[9], CFLOAT a[9], CFLOAT b[9]);
void G3DMultiplyMatrix3dv(double m[9], CDOUBLE a[9], CDOUBLE b[9]);
void G3DMultiplyMatrix4fv(float m[16], CFLOAT a[16], CFLOAT b[16]);
void G3DMultiplyMatrix4dv(double m[16], CDOUBLE a[16], CDOUBLE b[16]);

void G3DSimpleInvertMatrix4fv(float i[16], CFLOAT matrix[16]);
void G3DSimpleInvertMatrix4dv(double i[16], CDOUBLE matrix[16]);

int G3DInvertMatrix4fv(float i[16], CFLOAT matrix[16]);
int G3DInvertMatrix4dv(double i[16], CDOUBLE matrix[16]);

void G3DAdjointMatrix4fv(float adj[16], CFLOAT m[16]);
void G3DAdjointMatrix4dv(double adj[16], CDOUBLE m[16]);

void G3DTransposeMatrix3fv(float t[9], CFLOAT matrix[9]);
void G3DTransposeMatrix3dv(double t[9], CDOUBLE matrix[9]);
void G3DTransposeMatrix4fv(float t[16], CFLOAT matrix[16]);
void G3DTransposeMatrix4dv(double t[16], CDOUBLE matrix[16]);

void G3DMakeXRotation3f(float matrix[9],CFLOAT angle);
void G3DMakeXRotation3d(double matrix[9],CDOUBLE angle);
void G3DMakeYRotation3f(float matrix[9],CFLOAT angle);
void G3DMakeYRotation3d(double matrix[9],CDOUBLE angle);
void G3DMakeZRotation3f(float matrix[9],CFLOAT angle);
void G3DMakeZRotation3d(double matrix[9],CDOUBLE angle);

void G3DMakeXRotation4f(float matrix[16],CFLOAT angle);
void G3DMakeXRotation4d(double matrix[16],CDOUBLE angle);
void G3DMakeYRotation4f(float matrix[16],CFLOAT angle);
void G3DMakeYRotation4d(double matrix[16],CDOUBLE angle);
void G3DMakeZRotation4f(float matrix[16],CFLOAT angle);
void G3DMakeZRotation4d(double matrix[16],CDOUBLE angle);

void G3DMakeInvXRotation4f(float matrix[16],CFLOAT angle);
void G3DMakeInvXRotation4d(double matrix[16],CDOUBLE angle);
void G3DMakeInvYRotation4f(float matrix[16],CFLOAT angle);
void G3DMakeInvYRotation4d(double matrix[16],CDOUBLE angle);
void G3DMakeInvZRotation4f(float matrix[16],CFLOAT angle);
void G3DMakeInvZRotation4d(double matrix[16],CDOUBLE angle);

void G3DMakeRotation3f(float mat[9],CFLOAT angle,CFLOAT axis[3]);
void G3DMakeRotation3d(double mat[9],CDOUBLE angle,CDOUBLE axis[3]);
void G3DMakeRotation4f(float mat[16],CFLOAT angle,CFLOAT axis[3]);
void G3DMakeRotation4d(double mat[16],CDOUBLE angle,CDOUBLE axis[3]);

void G3DMakeTranslation4f(float matrix[16],CFLOAT v[3]);
void G3DMakeTranslation4d(double matrix[16],CDOUBLE v[3]);

void G3DMakeTranslationRotation4f(float res[16],CFLOAT t[3],CFLOAT rot[3]);
void G3DMakeTranslationRotation4d(double res[16],CDOUBLE t[3],CDOUBLE rot[3]);

void G3DMakeTranslationRotationScale4f(float res[16],CFLOAT t[3],CFLOAT rot[16], CFLOAT scale);
void G3DMakeTranslationRotationScale4d(double res[16],CDOUBLE t[3],CDOUBLE rot[16], CDOUBLE scale);

void G3DMakeTranslationQuatScale4f(float res[16],CFLOAT t[3],CFLOAT quat[4], CFLOAT scale);
void G3DMakeTranslationQuatScale4d(double res[16],CDOUBLE t[3],CDOUBLE quat[4], CDOUBLE scale);

void G3DMakeScale3fv(float m[9],CFLOAT scale[3]);
void G3DMakeScale3dv(double m[9],CDOUBLE scale[3]);

void G3DMakeScale4fv(float m[16],CFLOAT scale[3]);
void G3DMakeScale4dv(double m[16],CDOUBLE scale[3]);

void G3DMakeEulerTransform4fv(float euler[16], CFLOAT hpr[3]);
void G3DMakeEulerTransform4dv(double euler[16], CDOUBLE hpr[3]);

void G3DHPRFromEulerTransform4fv(float hpr[3], CFLOAT euler[16]);
void G3DHPRFromEulerTransform4dv(double hpr[3], CDOUBLE euler[16]);

void G3DInvertEulerTransform4fv(float inv[16], CFLOAT euler[16]);
void G3DInvertEulerTransform4dv(double inv[16], CDOUBLE euler[16]);

/******************************************************************************
 *
 * Matrix Function Definition
 *
 *****************************************************************************/

__G3DI__ void G3DVector3fXMatrix3f(float res[3],  CFLOAT vector[3], CFLOAT matrix[9])
{
  res[0] = vector[0]*matrix[0] + vector[1]*matrix[1] + vector[2]*matrix[2];
  res[1] = vector[0]*matrix[3] + vector[1]*matrix[4] + vector[2]*matrix[5];
  res[2] = vector[0]*matrix[6] + vector[1]*matrix[7] + vector[2]*matrix[8];
}

__G3DI__ void G3DVector3dXMatrix3d(double res[3],  CDOUBLE vector[3], CDOUBLE matrix[9])
{
  res[0] = vector[0]*matrix[0] + vector[1]*matrix[1] + vector[2]*matrix[2];
  res[1] = vector[0]*matrix[3] + vector[1]*matrix[4] + vector[2]*matrix[5];
  res[2] = vector[0]*matrix[6] + vector[1]*matrix[7] + vector[2]*matrix[8];
}

__G3DI__ void G3DMatrix3fXVector3f(float res[3],  CFLOAT matrix[9], CFLOAT vector[3])
{
  res[0] = vector[0]*matrix[0] + vector[1]*matrix[3] + vector[2]*matrix[6];
  res[1] = vector[0]*matrix[1] + vector[1]*matrix[4] + vector[2]*matrix[7];
  res[2] = vector[0]*matrix[2] + vector[1]*matrix[5] + vector[2]*matrix[8];
}

__G3DI__ void G3DMatrix3dXVector3d(double res[3],  CDOUBLE matrix[9], CDOUBLE vector[3])
{
  res[0] = vector[0]*matrix[0] + vector[1]*matrix[3] + vector[2]*matrix[6];
  res[1] = vector[0]*matrix[1] + vector[1]*matrix[4] + vector[2]*matrix[7];
  res[2] = vector[0]*matrix[2] + vector[1]*matrix[5] + vector[2]*matrix[8];
}

__G3DI__ void G3DVector4fXMatrix4f(float n[4],  CFLOAT t[4], CFLOAT matrix[16])
{
  n[0] = t[0]*matrix[0] + t[1]*matrix[1] + t[2]*matrix[2] + t[3]*matrix[3]; 
  n[1] = t[0]*matrix[4] + t[1]*matrix[5] + t[2]*matrix[6] + t[3]*matrix[7];
  n[2] = t[0]*matrix[8] + t[1]*matrix[9] + t[2]*matrix[10] + t[3]*matrix[11]; 
  n[3] = t[0]*matrix[12] + t[1]*matrix[13] + t[2]*matrix[14] + t[3]*matrix[15];
}

__G3DI__ void G3DVector4dXMatrix4d(double n[4],  CDOUBLE t[4], CDOUBLE matrix[16])
{
  n[0] = t[0]*matrix[0] + t[1]*matrix[1] + t[2]*matrix[2] + t[3]*matrix[3]; 
  n[1] = t[0]*matrix[4] + t[1]*matrix[5] + t[2]*matrix[6] + t[3]*matrix[7];
  n[2] = t[0]*matrix[8] + t[1]*matrix[9] + t[2]*matrix[10] + t[3]*matrix[11]; 
  n[3] = t[0]*matrix[12] + t[1]*matrix[13] + t[2]*matrix[14] + t[3]*matrix[15];
}

__G3DI__ void G3DMatrix4fXVector4f(float n[4],  CFLOAT matrix[16], CFLOAT t[4])
{
  n[0] = t[0]*matrix[0] + t[1]*matrix[4] + t[2]*matrix[8] + t[3]*matrix[12]; 
  n[1] = t[0]*matrix[1] + t[1]*matrix[5] + t[2]*matrix[9] + t[3]*matrix[13]; 
  n[2] = t[0]*matrix[2] + t[1]*matrix[6] + t[2]*matrix[10] + t[3]*matrix[14]; 
  n[3] = t[0]*matrix[3] + t[1]*matrix[7] + t[2]*matrix[11] + t[3]*matrix[15];
}

__G3DI__ void G3DMatrix4dXVector4d(double n[4],  CDOUBLE matrix[16], CDOUBLE t[4])
{
  n[0] = t[0]*matrix[0] + t[1]*matrix[4] + t[2]*matrix[8] + t[3]*matrix[12]; 
  n[1] = t[0]*matrix[1] + t[1]*matrix[5] + t[2]*matrix[9] + t[3]*matrix[13]; 
  n[2] = t[0]*matrix[2] + t[1]*matrix[6] + t[2]*matrix[10] + t[3]*matrix[14]; 
  n[3] = t[0]*matrix[3] + t[1]*matrix[7] + t[2]*matrix[11] + t[3]*matrix[15];
}

__G3DI__ void G3DMatrix4fXVector3f(float n[3],  CFLOAT matrix[16], CFLOAT t[3])
{
  n[0] = t[0]*matrix[0] + t[1]*matrix[4] + t[2]*matrix[8]; 
  n[1] = t[0]*matrix[1] + t[1]*matrix[5] + t[2]*matrix[9]; 
  n[2] = t[0]*matrix[2] + t[1]*matrix[6] + t[2]*matrix[10]; 
}

__G3DI__ void G3DMatrix4dXVector3d(double n[3],  CDOUBLE matrix[16], CDOUBLE t[3])
{
  n[0] = t[0]*matrix[0] + t[1]*matrix[4] + t[2]*matrix[8]; 
  n[1] = t[0]*matrix[1] + t[1]*matrix[5] + t[2]*matrix[9]; 
  n[2] = t[0]*matrix[2] + t[1]*matrix[6] + t[2]*matrix[10]; 
}

__G3DI__ void G3DCopyMatrix3fv(float m1[9], CFLOAT m2[9])
{
  memcpy(m1,m2,sizeof(float)*9);
}

__G3DI__ void G3DCopyMatrix3dv(double m1[9], CDOUBLE m2[9])
{
  memcpy(m1,m2,sizeof(double)*9);
}

__G3DI__ void G3DCopyMatrix4fv(float m1[16], CFLOAT m2[16])
{
  memcpy(m1,m2,sizeof(float)*16);
}

__G3DI__ void G3DCopyMatrix4dv(double m1[16], CDOUBLE m2[16])
{
  memcpy(m1,m2,sizeof(double)*16);
}

__G3DI__ float G3DDeterminante2f(CFLOAT a, CFLOAT b, CFLOAT c, CFLOAT d)
{
  return (a * d - b * c);
}

__G3DI__ double G3DDeterminante2d(CDOUBLE a, CDOUBLE b, CDOUBLE c, CDOUBLE d)
{
  return (a * d - b * c);
}

__G3DI__ float G3DDeterminante3fv(CFLOAT a[3],CFLOAT b[3],CFLOAT c[3])
{
  return ( a[0] * G3DDeterminante2f(b[1], b[2], c[1], c[2])
	   - b[0] * G3DDeterminante2f(a[1], a[2], c[1], c[2])
	   + c[0] * G3DDeterminante2f(a[1], a[2], b[1], b[2]));
}

__G3DI__ double G3DDeterminante3dv(CDOUBLE a[3],CDOUBLE b[3],CDOUBLE c[3])
{
  return ( a[0] * G3DDeterminante2d(b[1], b[2], c[1], c[2])
	   - b[0] * G3DDeterminante2d(a[1], a[2], c[1], c[2])
	   + c[0] * G3DDeterminante2d(a[1], a[2], b[1], b[2]));
}

__G3DI__ float G3DDeterminante3f(CFLOAT a1,CFLOAT a2,CFLOAT a3,CFLOAT b1,CFLOAT b2,CFLOAT b3,CFLOAT c1,CFLOAT c2,CFLOAT c3)
{
  return ( a1 * G3DDeterminante2f(b2, b3, c2, c3)
	   - b1 * G3DDeterminante2f(a2, a3, c2, c3)
	   + c1 * G3DDeterminante2f(a2, a3, b2, b3));
}

__G3DI__ double G3DDeterminante3d(CDOUBLE a1,CDOUBLE a2,CDOUBLE a3,CDOUBLE b1,CDOUBLE b2,CDOUBLE b3,CDOUBLE c1,CDOUBLE c2,CDOUBLE c3)
{
  return ( a1 * G3DDeterminante2d(b2, b3, c2, c3)
	   - b1 * G3DDeterminante2d(a2, a3, c2, c3)
	   + c1 * G3DDeterminante2d(a2, a3, b2, b3));
}

__G3DI__ float G3DDeterminante4fv(CFLOAT m[16])
{
  register float a1, a2, a3, a4, b1, b2, b3, b4, c1, c2, c3, c4, d1, d2, d3, d4;

  a1 = m[0]; b1 = m[4]; c1 = m[8]; d1 = m[12];
  a2 = m[1]; b2 = m[5]; c2 = m[9]; d2 = m[13];
  a3 = m[2]; b3 = m[6]; c3 = m[10]; d3 = m[14];
  a4 = m[3]; b4 = m[7]; c4 = m[11]; d4 = m[15];
  
  return (a1 * G3DDeterminante3f(b2, b3, b4, c2, c3, c4, d2, d3, d4)
	     - b1 * G3DDeterminante3f(a2, a3, a4, c2, c3, c4, d2, d3, d4)
	     + c1 * G3DDeterminante3f(a2, a3, a4, b2, b3, b4, d2, d3, d4)
	     - d1 * G3DDeterminante3f(a2, a3, a4, b2, b3, b4, c2, c3, c4));
}

__G3DI__ double G3DDeterminante4dv(CDOUBLE m[16])
{
  register double a1, a2, a3, a4, b1, b2, b3, b4, c1, c2, c3, c4, d1, d2, d3, d4;

  a1 = m[0]; b1 = m[4]; c1 = m[8]; d1 = m[12];
  a2 = m[1]; b2 = m[5]; c2 = m[9]; d2 = m[13];
  a3 = m[2]; b3 = m[6]; c3 = m[10]; d3 = m[14];
  a4 = m[3]; b4 = m[7]; c4 = m[11]; d4 = m[15];
  
  return (a1 * G3DDeterminante3d(b2, b3, b4, c2, c3, c4, d2, d3, d4)
	     - b1 * G3DDeterminante3d(a2, a3, a4, c2, c3, c4, d2, d3, d4)
	     + c1 * G3DDeterminante3d(a2, a3, a4, b2, b3, b4, d2, d3, d4)
	     - d1 * G3DDeterminante3d(a2, a3, a4, b2, b3, b4, c2, c3, c4));
}

__G3DI__ void G3DMakeIdentity3fv(float m[9])
{
  m[0] = m[4] = m[8] = 1.0f;
  m[1] = m[2] = m[3] = m[5] = m[6] = m[7] = 0.0f;
}

__G3DI__ void G3DMakeIdentity3dv(double m[9])
{
  m[0] = m[4] = m[8] = 1.0;
  m[1] = m[2] = m[3] = m[5] = m[6] = m[7] = 0.0;
}

__G3DI__ void G3DMakeIdentity4fv(float m[16])
{
  m[0] = m[5] = m[10] = m[15] = 1.0f;
  m[1] = m[2] = m[3] = m[4] = m[6] = m[7] = m[8] = m[9] = m[11] = m[12] = m[13] = m[14] = 0.0f;
}

__G3DI__ void G3DMakeIdentity4dv(double m[16])
{
  m[0] = m[5] = m[10] = m[15] = 1.0;
  m[1] = m[2] = m[3] = m[4] = m[6] = m[7] = m[8] = m[9] = m[11] = m[12] = m[13] = m[14] = 0.0;
}

__G3DI__ void G3DAddMatrix3fv(float m[9],CFLOAT a[9],CFLOAT b[9])
{
  m[0] = a[0] + b[0];
  m[1] = a[1] + b[1];
  m[2] = a[2] + b[2];
  m[3] = a[3] + b[3];
  m[4] = a[4] + b[4];
  m[5] = a[5] + b[5];
  m[6] = a[6] + b[6];
  m[7] = a[7] + b[7];
  m[8] = a[8] + b[8];
}

__G3DI__ void G3DAddMatrix3dv(double m[9],CDOUBLE a[9],CDOUBLE b[9])
{
  m[0] = a[0] + b[0];
  m[1] = a[1] + b[1];
  m[2] = a[2] + b[2];
  m[3] = a[3] + b[3];
  m[4] = a[4] + b[4];
  m[5] = a[5] + b[5];
  m[6] = a[6] + b[6];
  m[7] = a[7] + b[7];
  m[8] = a[8] + b[8];
}

__G3DI__ void G3DAddMatrix4fv(float m[16],CFLOAT a[16],CFLOAT b[16])
{
  m[0] = a[0] + b[0];
  m[1] = a[1] + b[1];
  m[2] = a[2] + b[2];
  m[3] = a[3] + b[3];
  m[4] = a[4] + b[4];
  m[5] = a[5] + b[5];
  m[6] = a[6] + b[6];
  m[7] = a[7] + b[7];
  m[8] = a[8] + b[8];
  m[9] = a[9] + b[9];
  m[10] = a[10] + b[10];
  m[11] = a[11] + b[11];
  m[12] = a[12] + b[12];
  m[13] = a[13] + b[13];
  m[14] = a[14] + b[14];
  m[15] = a[15] + b[15];
}

__G3DI__ void G3DAddMatrix4dv(double m[16],CDOUBLE a[16],CDOUBLE b[16])
{
  m[0] = a[0] + b[0];
  m[1] = a[1] + b[1];
  m[2] = a[2] + b[2];
  m[3] = a[3] + b[3];
  m[4] = a[4] + b[4];
  m[5] = a[5] + b[5];
  m[6] = a[6] + b[6];
  m[7] = a[7] + b[7];
  m[8] = a[8] + b[8];
  m[9] = a[9] + b[9];
  m[10] = a[10] + b[10];
  m[11] = a[11] + b[11];
  m[12] = a[12] + b[12];
  m[13] = a[13] + b[13];
  m[14] = a[14] + b[14];
  m[15] = a[15] + b[15];
}

__G3DI__ void G3DSubMatrix3fv(float m[9],CFLOAT a[9],CFLOAT b[9])
{
  m[0] = a[0] - b[0];
  m[1] = a[1] - b[1];
  m[2] = a[2] - b[2];
  m[3] = a[3] - b[3];
  m[4] = a[4] - b[4];
  m[5] = a[5] - b[5];
  m[6] = a[6] - b[6];
  m[7] = a[7] - b[7];
  m[8] = a[8] - b[8];
}

__G3DI__ void G3DSubMatrix3dv(double m[9],CDOUBLE a[9],CDOUBLE b[9])
{
  m[0] = a[0] - b[0];
  m[1] = a[1] - b[1];
  m[2] = a[2] - b[2];
  m[3] = a[3] - b[3];
  m[4] = a[4] - b[4];
  m[5] = a[5] - b[5];
  m[6] = a[6] - b[6];
  m[7] = a[7] - b[7];
  m[8] = a[8] - b[8];
}

__G3DI__ void G3DSubMatrix4fv(float m[16],CFLOAT a[16],CFLOAT b[16])
{
  m[0] = a[0] - b[0];
  m[1] = a[1] - b[1];
  m[2] = a[2] - b[2];
  m[3] = a[3] - b[3];
  m[4] = a[4] - b[4];
  m[5] = a[5] - b[5];
  m[6] = a[6] - b[6];
  m[7] = a[7] - b[7];
  m[8] = a[8] - b[8];
  m[9] = a[9] - b[9];
  m[10] = a[10] - b[10];
  m[11] = a[11] - b[11];
  m[12] = a[12] - b[12];
  m[13] = a[13] - b[13];
  m[14] = a[14] - b[14];
  m[15] = a[15] - b[15];
}

__G3DI__ void G3DSubMatrix4dv(double m[16],CDOUBLE a[16],CDOUBLE b[16])
{
  m[0] = a[0] - b[0];
  m[1] = a[1] - b[1];
  m[2] = a[2] - b[2];
  m[3] = a[3] - b[3];
  m[4] = a[4] - b[4];
  m[5] = a[5] - b[5];
  m[6] = a[6] - b[6];
  m[7] = a[7] - b[7];
  m[8] = a[8] - b[8];
  m[9] = a[9] - b[9];
  m[10] = a[10] - b[10];
  m[11] = a[11] - b[11];
  m[12] = a[12] - b[12];
  m[13] = a[13] - b[13];
  m[14] = a[14] - b[14];
  m[15] = a[15] - b[15];
}

__G3DI__ void G3DMultiplyMatrix3fv(float m[9], CFLOAT a[9], CFLOAT b[9])
{
  m[0] = a[0]*b[0]+a[3]*b[1]+a[6]*b[2];
  m[1] = a[1]*b[0]+a[4]*b[1]+a[7]*b[2];
  m[2] = a[2]*b[0]+a[5]*b[1]+a[8]*b[2];

  m[3] = a[0]*b[3]+a[3]*b[4]+a[6]*b[5];
  m[4] = a[1]*b[3]+a[4]*b[4]+a[7]*b[5];
  m[5] = a[2]*b[3]+a[5]*b[4]+a[8]*b[5];

  m[6] = a[0]*b[6]+a[3]*b[7]+a[6]*b[8];
  m[7] = a[1]*b[6]+a[4]*b[7]+a[7]*b[8];
  m[8] = a[2]*b[6]+a[5]*b[7]+a[8]*b[8];
}

__G3DI__ void G3DMultiplyMatrix3dv(double m[9], CDOUBLE a[9], CDOUBLE b[9])
{
  m[0] = a[0]*b[0]+a[3]*b[1]+a[6]*b[2];
  m[1] = a[1]*b[0]+a[4]*b[1]+a[7]*b[2];
  m[2] = a[2]*b[0]+a[5]*b[1]+a[8]*b[2];

  m[3] = a[0]*b[3]+a[3]*b[4]+a[6]*b[5];
  m[4] = a[1]*b[3]+a[4]*b[4]+a[7]*b[5];
  m[5] = a[2]*b[3]+a[5]*b[4]+a[8]*b[5];

  m[6] = a[0]*b[6]+a[3]*b[7]+a[6]*b[8];
  m[7] = a[1]*b[6]+a[4]*b[7]+a[7]*b[8];
  m[8] = a[2]*b[6]+a[5]*b[7]+a[8]*b[8];
}

__G3DI__ void G3DMultiplyMatrix4fv(float m[16], CFLOAT a[16], CFLOAT b[16])
{
  /* 
   * If the 2 matrices are 'transposed affin', we can save us a lot of mulus!
   */

  if (a[3] == 0.0f && a[7] == 0.0f && a[11] == 0.0f &&
      b[3] == 0.0f && b[7] == 0.0f && b[11] == 0.0f &&
      a[15] == 1.0f && b[15] == 1.0f) {

    /* First row */
    m[0] = a[0]*b[0] + a[4]*b[1] + a[8]*b[2];
    m[4] = a[0]*b[4] + a[4]*b[5] + a[8]*b[6];
    m[8] = a[0]*b[8] + a[4]*b[9] + a[8]*b[10];
    m[12] = a[0]*b[12] + a[4]*b[13] + a[8]*b[14] + a[12];
    
    /* Second row */
    m[1] = a[1]*b[0] + a[5]*b[1] + a[9]*b[2];
    m[5] = a[1]*b[4] + a[5]*b[5] + a[9]*b[6];
    m[9] = a[1]*b[8] + a[5]*b[9] + a[9]*b[10];
    m[13] = a[1]*b[12] + a[5]*b[13] + a[9]*b[14] + a[13];
    
    /* Third row */
    m[2] = a[2]*b[0] + a[6]*b[1] + a[10]*b[2];
    m[6] = a[2]*b[4] + a[6]*b[5] + a[10]*b[6];
    m[10] = a[2]*b[8] + a[6]*b[9] + a[10]*b[10];
    m[14] = a[2]*b[12] + a[6]*b[13] + a[10]*b[14] + a[14];
    
    /* Forth row */
    m[3]  = 0.0f;
    m[7]  = 0.0f;
    m[11] = 0.0f;
    m[15] = 1.0f;
  }
  else {
    /* First row */
    m[0] = a[0]*b[0] + a[4]*b[1] + a[8]*b[2] + a[12]*b[3];
    m[4] = a[0]*b[4] + a[4]*b[5] + a[8]*b[6] + a[12]*b[7];
    m[8] = a[0]*b[8] + a[4]*b[9] + a[8]*b[10] + a[12]*b[11];
    m[12] = a[0]*b[12] + a[4]*b[13] + a[8]*b[14] + a[12]*b[15];
    
    /* Second row */
    m[1] = a[1]*b[0] + a[5]*b[1] + a[9]*b[2] + a[13]*b[3];
    m[5] = a[1]*b[4] + a[5]*b[5] + a[9]*b[6] + a[13]*b[7];
    m[9] = a[1]*b[8] + a[5]*b[9] + a[9]*b[10] + a[13]*b[11];
    m[13] = a[1]*b[12] + a[5]*b[13] + a[9]*b[14] + a[13] *b[15];
    
    /* Third row */
    m[2] = a[2]*b[0] + a[6]*b[1] + a[10]*b[2] + a[14]*b[3];
    m[6] = a[2]*b[4] + a[6]*b[5] + a[10]*b[6] + a[14]*b[7];
    m[10] = a[2]*b[8] + a[6]*b[9] + a[10]*b[10] + a[14]*b[11];
    m[14] = a[2]*b[12] + a[6]*b[13] + a[10]*b[14] + a[14]*b[15];
    
    /* Forth row */
    m[3] = a[3]*b[0] + a[7]*b[1] + a[11]*b[2] + a[15]*b[3];
    m[7] = a[3]*b[4] + a[7]*b[5] + a[11]*b[6] + a[15]*b[7];
    m[11] = a[3]*b[8] + a[7]*b[9] + a[11]*b[10] + a[15]*b[11];
    m[15] = a[3]*b[12] + a[7]*b[13] + a[11]*b[14] + a[15]*b[15];
  }
}

__G3DI__ void G3DMultiplyMatrix4dv(double m[16], CDOUBLE a[16], CDOUBLE b[16])
{
  /*
   * If the 2 matrices are 'transposed affin', we can save us a lot of mulus!
   */
  if (a[3] == 0.0 && a[7] == 0.0 && a[11] == 0.0 &&
      b[3] == 0.0 && b[7] == 0.0 && b[11] == 0.0 &&
      a[15] == 1.0 && b[15] == 1.0) {

    /* First row */
    m[0] = a[0]*b[0] + a[4]*b[1] + a[8]*b[2];
    m[4] = a[0]*b[4] + a[4]*b[5] + a[8]*b[6];
    m[8] = a[0]*b[8] + a[4]*b[9] + a[8]*b[10];
    m[12] = a[0]*b[12] + a[4]*b[13] + a[8]*b[14] + a[12];
    
    /* Second row */
    m[1] = a[1]*b[0] + a[5]*b[1] + a[9]*b[2];
    m[5] = a[1]*b[4] + a[5]*b[5] + a[9]*b[6];
    m[9] = a[1]*b[8] + a[5]*b[9] + a[9]*b[10];
    m[13] = a[1]*b[12] + a[5]*b[13] + a[9]*b[14] + a[13];
    
    /* Third row */
    m[2] = a[2]*b[0] + a[6]*b[1] + a[10]*b[2];
    m[6] = a[2]*b[4] + a[6]*b[5] + a[10]*b[6];
    m[10] = a[2]*b[8] + a[6]*b[9] + a[10]*b[10];
    m[14] = a[2]*b[12] + a[6]*b[13] + a[10]*b[14] + a[14];
    
    /* Forth row */
    m[3]  = 0.0;
    m[7]  = 0.0;
    m[11] = 0.0;
    m[15] = 1.0;
  }
  else {
    /* First row */
    m[0] = a[0]*b[0] + a[4]*b[1] + a[8]*b[2] + a[12]*b[3];
    m[4] = a[0]*b[4] + a[4]*b[5] + a[8]*b[6] + a[12]*b[7];
    m[8] = a[0]*b[8] + a[4]*b[9] + a[8]*b[10] + a[12]*b[11];
    m[12] = a[0]*b[12] + a[4]*b[13] + a[8]*b[14] + a[12]*b[15];
    
    /* Second row */
    m[1] = a[1]*b[0] + a[5]*b[1] + a[9]*b[2] + a[13]*b[3];
    m[5] = a[1]*b[4] + a[5]*b[5] + a[9]*b[6] + a[13]*b[7];
    m[9] = a[1]*b[8] + a[5]*b[9] + a[9]*b[10] + a[13]*b[11];
    m[13] = a[1]*b[12] + a[5]*b[13] + a[9]*b[14] + a[13] *b[15];
    
    /* Third row */
    m[2] = a[2]*b[0] + a[6]*b[1] + a[10]*b[2] + a[14]*b[3];
    m[6] = a[2]*b[4] + a[6]*b[5] + a[10]*b[6] + a[14]*b[7];
    m[10] = a[2]*b[8] + a[6]*b[9] + a[10]*b[10] + a[14]*b[11];
    m[14] = a[2]*b[12] + a[6]*b[13] + a[10]*b[14] + a[14]*b[15];
    
    /* Forth row */
    m[3] = a[3]*b[0] + a[7]*b[1] + a[11]*b[2] + a[15]*b[3];
    m[7] = a[3]*b[4] + a[7]*b[5] + a[11]*b[6] + a[15]*b[7];
    m[11] = a[3]*b[8] + a[7]*b[9] + a[11]*b[10] + a[15]*b[11];
    m[15] = a[3]*b[12] + a[7]*b[13] + a[11]*b[14] + a[15]*b[15];
  }
}

__G3DI__ void G3DSimpleInvertMatrix4fv(float i[16], CFLOAT matrix[16])
{
  /* First col */
  i[0]  = matrix[0];
  i[1]  = matrix[4];
  i[2]  = matrix[8];
  i[3] = -  (matrix[3]  * matrix[0] +
             matrix[7]  * matrix[4] +
             matrix[11] * matrix[8]);
  
  /* Second col */
  i[4]  = matrix[1];
  i[5]  = matrix[5];
  i[6]  = matrix[9];
  i[7] = - (matrix[3]   * matrix[1] +
             matrix[7]  * matrix[5] +
             matrix[11] * matrix[9]);

  /* Third col */
  i[8]  = matrix[2];
  i[9]  = matrix[6];
  i[10] = matrix[10];
  i[11] = - (matrix[3]  * matrix[2] +
             matrix[7]  * matrix[6] +
             matrix[11] * matrix[10]);

  /* Forth col */
  i[12]  = i[13]  = i[14] = 0.0f;
  i[15] =  1.0f;
}

__G3DI__ void G3DSimpleInvertMatrix4dv(double i[16], CDOUBLE matrix[16])
{
  i[0]  = matrix[0];
  i[1]  = matrix[4];
  i[2]  = matrix[8];
  i[3] = -  (matrix[3]  * matrix[0] +
             matrix[7]  * matrix[4] +
             matrix[11] * matrix[8]);
  
  /* Second col */
  i[4]  = matrix[1];
  i[5]  = matrix[5];
  i[6]  = matrix[9];
  i[7] = - (matrix[3]   * matrix[1] +
             matrix[7]  * matrix[5] +
             matrix[11] * matrix[9]);

  /* Third col */
  i[8]  = matrix[2];
  i[9]  = matrix[6];
  i[10] = matrix[10];
  i[11] = - (matrix[3]  * matrix[2] +
             matrix[7]  * matrix[6] +
             matrix[11] * matrix[10]);

  /* Forth col */
  i[12]  = i[13]  = i[14] = 0.0;
  i[15] =  1.0;
}

#define	ACCUMULATE if(temp >= 0.0) pos += temp; else neg += temp;
#define	PRECISION_LIMIT	(1.0e-15)

__G3DI__ int G3DInvertMatrix4fv(float i[16],CFLOAT matrix[16])
{
  /*
   * Test if we have an affin matrix, if yes, we can save us a lot of cpu time
   * (Graphics Gem, Bd II, p.348 Based on code by Kevin Wu)
   * Otherwise we use the plain ordinary algorithm... 
   * If m cannot be inverted, i is NOT defined!
   */

  if(matrix[3]==0.0f && matrix[7]==0.0f && matrix[11]==0.0f && matrix[15]==1.0f) {
    register float det_1;
    float pos = 0.0f;
    float neg = 0.0f;
    float temp;
    
    temp =  matrix[0] * matrix[5] * matrix[10]; 
    ACCUMULATE
    temp =  matrix[1] * matrix[6] * matrix[8];
    ACCUMULATE
    temp =  matrix[2] * matrix[4] * matrix[9];
    ACCUMULATE
    temp = -matrix[2] * matrix[5] * matrix[8];
    ACCUMULATE
    temp = -matrix[1] * matrix[4] * matrix[10];
    ACCUMULATE
    temp = -matrix[0] * matrix[6] * matrix[9];
    ACCUMULATE

    det_1 = pos + neg;

    /* Is the submatrix singular? */
    temp = det_1 / (pos - neg);
    
    /* Calculate i = adj(A)/Det(A), A the upper left sumatrix of m */
    if(ABS(temp) >= PRECISION_LIMIT) {
      det_1 = 1.0f/det_1;
 
      i[0] =  (matrix[5] * matrix[10] - matrix[6] * matrix[9]) * det_1;
      i[4] = -(matrix[4] * matrix[10] - matrix[6] * matrix[8]) * det_1;
      i[8] =  (matrix[4] * matrix[9] - matrix[5] * matrix[8]) * det_1;
      
      i[1] = -(matrix[1] * matrix[10] - matrix[2] * matrix[9]) * det_1;
      i[5] =  (matrix[0] * matrix[10] - matrix[2] * matrix[9]) * det_1;
      i[9] = -(matrix[0] * matrix[9] - matrix[1] * matrix[8]) * det_1;
      
      i[2] =  (matrix[1] * matrix[6] - matrix[2] * matrix[5]) * det_1;
      i[6] = -(matrix[0] * matrix[6] - matrix[2] * matrix[4]) * det_1;
      i[10] =  (matrix[0] * matrix[5] - matrix[1] * matrix[4]) * det_1;
     
      /* Calculate -C * Inverse(A) */
      i[12] = -(matrix[12] * i[0] + matrix[13] * i[4] + matrix[14] * i[8]);
      i[13] = -(matrix[12] * i[1] + matrix[13] * i[5] + matrix[14] * i[9]);
      i[14] = -(matrix[12] * i[2] + matrix[13] * i[6] + matrix[14] * i[10]);

      /* Last column... */
      i[3] = 0.0f;
      i[7] = 0.0f;
      i[11] = 0.0f;
      i[15] = 1.0f;
      
      return 1;
    }
    else {
      return 0;
    }
  }
  else {      
    register float det;
    
    G3DAdjointMatrix4fv(i,matrix);
    det = G3DDeterminante4fv(i);
    
    if(det >= G3DEPSILON) {
      register float idet = 1.0f / det;
      
      i[0] *= idet;
      i[1] *= idet;
      i[2] *= idet;
      i[3] *= idet;
          
      i[4] *= idet;
      i[5] *= idet;
      i[6] *= idet;
      i[7] *= idet;
      
      i[8] *= idet;
      i[9] *= idet;
      i[10] *= idet;
      i[11] *= idet;
      
      i[12] *= idet;
      i[13] *= idet;
      i[14] *= idet;
      i[15] *= idet;
      
      return 1;
    }
  }
  return 0;
}

__G3DI__ int G3DInvertMatrix4dv(double i[16],CDOUBLE matrix[16])
{
  /*
   * Test if we have an affin matrix, if yes, we can save us a lot of cpu time
   * (Graphics Gem, Bd II, p.348 Based on code by Kevin Wu)
   * Otherwise we use the plain ordinary algorithm... 
   * If m cannot be inverted, i is NOT defined!
   */

  if(matrix[3]==0.0 && matrix[7]==0.0 && matrix[11]==0.0 && matrix[15]==1.0) {
    register double det_1;
    double pos = 0;
    double neg = 0;
    double temp;
    
    temp =  matrix[0] * matrix[5] * matrix[10]; 
    ACCUMULATE
    temp =  matrix[1] * matrix[6] * matrix[8];
    ACCUMULATE
    temp =  matrix[2] * matrix[4] * matrix[9];
    ACCUMULATE
    temp = -matrix[2] * matrix[5] * matrix[8];
    ACCUMULATE
    temp = -matrix[1] * matrix[4] * matrix[10];
    ACCUMULATE
    temp = -matrix[0] * matrix[6] * matrix[9];
    ACCUMULATE

    det_1 = pos + neg;

    /* Is the submatrix singular? */
    temp = det_1 / (pos - neg);
    
    /* Calculate i = adj(A)/Det(A), A the upper left sumatrix of m */
    if(ABS(temp) >= PRECISION_LIMIT) {
      det_1 = 1.0/det_1;
 
      i[0] =  (matrix[5] * matrix[10] - matrix[6] * matrix[9]) * det_1;
      i[4] = -(matrix[4] * matrix[10] - matrix[6] * matrix[8]) * det_1;
      i[8] =  (matrix[4] * matrix[9] - matrix[5] * matrix[8]) * det_1;
      
      i[1] = -(matrix[1] * matrix[10] - matrix[2] * matrix[9]) * det_1;
      i[5] =  (matrix[0] * matrix[10] - matrix[2] * matrix[9]) * det_1;
      i[9] = -(matrix[0] * matrix[9] - matrix[1] * matrix[8]) * det_1;
      
      i[2] =  (matrix[1] * matrix[6] - matrix[2] * matrix[5]) * det_1;
      i[6] = -(matrix[0] * matrix[6] - matrix[2] * matrix[4]) * det_1;
      i[10] =  (matrix[0] * matrix[5] - matrix[1] * matrix[4]) * det_1;
     
      /* Calculate -C * Inverse(A) */
      i[12] = -(matrix[12] * i[0] + matrix[13] * i[4] + matrix[14] * i[8]);
      i[13] = -(matrix[12] * i[1] + matrix[13] * i[5] + matrix[14] * i[9]);
      i[14] = -(matrix[12] * i[2] + matrix[13] * i[6] + matrix[14] * i[10]);


      /* Last column... */
      i[3] = 0.0;
      i[7] = 0.0;
      i[11] = 0.0;
      i[15] = 1.0;
      
      return 1;
    }
    else {
      return 0;
    }
  }
  else {      
    register double det;
    
    G3DAdjointMatrix4dv(i,matrix);
    det = G3DDeterminante4dv(i);
    
    if(det >= G3DEPSILON) {
      register double idet = 1.0 / det;
      
      i[0] *= idet;
      i[1] *= idet;
      i[2] *= idet;
      i[3] *= idet;
          
      i[4] *= idet;
      i[5] *= idet;
      i[6] *= idet;
      i[7] *= idet;
      
      i[8] *= idet;
      i[9] *= idet;
      i[10] *= idet;
      i[11] *= idet;
      
      i[12] *= idet;
      i[13] *= idet;
      i[14] *= idet;
      i[15] *= idet;
      
      return 1;
    }
  }
  return 0;
}

void G3DAdjointMatrix4fv(float adj[16],CFLOAT m[16])
{
  register float a1, a2, a3, a4, b1, b2, b3, b4;
  register float c1, c2, c3, c4, d1, d2, d3, d4;
 
  a1 = m[0]; b1 = m[4]; c1 = m[8]; d1 = m[12];
  a2 = m[1]; b2 = m[5]; c2 = m[9]; d2 = m[13];
  a3 = m[2]; b3 = m[6]; c3 = m[10]; d3 = m[14];
  a4 = m[3]; b4 = m[7]; c4 = m[11]; d4 = m[15];
 
  adj[0] =  G3DDeterminante3f(b2, b3, b4, c2, c3, c4, d2, d3, d4);
  adj[4] = -G3DDeterminante3f(a2, a3, a4, c2, c3, c4, d2, d3, d4);
  adj[8] =  G3DDeterminante3f(a2, a3, a4, b2, b3, b4, d2, d3, d4);
  adj[12] = -G3DDeterminante3f(a2, a3, a4, b2, b3, b4, c2, c3, c4);
  
  adj[1] = -G3DDeterminante3f(b1, b3, b4, c1, c3, c4, d1, d3, d4);
  adj[5] =  G3DDeterminante3f(a1, a3, a4, c1, c3, c4, d1, d3, d4);
  adj[9] = -G3DDeterminante3f(a1, a3, a4, b1, b3, b4, d1, d3, d4);
  adj[13] =  G3DDeterminante3f(a1, a3, a4, b1, b3, b4, c1, c3, c4);
  
  adj[2] =  G3DDeterminante3f(b1, b2, b4, c1, c2, c4, d1, d2, d4);
  adj[6] = -G3DDeterminante3f(a1, a2, a4, c1, c2, c4, d1, d2, d4);
  adj[10] =  G3DDeterminante3f(a1, a2, a4, b1, b2, b4, d1, d2, d4);
  adj[14] = -G3DDeterminante3f(a1, a2, a4, b1, b2, b4, c1, c2, c4);
  
  adj[3] = -G3DDeterminante3f(b1, b2, b3, c1, c2, c3, d1, d2, d3);
  adj[7] =  G3DDeterminante3f(a1, a2, a3, c1, c2, c3, d1, d2, d3);
  adj[11] = -G3DDeterminante3f(a1, a2, a3, b1, b2, b3, d1, d2, d3);
  adj[15] =  G3DDeterminante3f(a1, a2, a3, b1, b2, b3, c1, c2, c3);
}

void G3DAdjointMatrix4dv(double adj[16],CDOUBLE m[16])
{
  register double a1, a2, a3, a4, b1, b2, b3, b4;
  register double c1, c2, c3, c4, d1, d2, d3, d4;
 
  a1 = m[0]; b1 = m[4]; c1 = m[8]; d1 = m[12];
  a2 = m[1]; b2 = m[5]; c2 = m[9]; d2 = m[13];
  a3 = m[2]; b3 = m[6]; c3 = m[10]; d3 = m[14];
  a4 = m[3]; b4 = m[7]; c4 = m[11]; d4 = m[15];
 
  adj[0] =  G3DDeterminante3d(b2, b3, b4, c2, c3, c4, d2, d3, d4);
  adj[4] = -G3DDeterminante3d(a2, a3, a4, c2, c3, c4, d2, d3, d4);
  adj[8] =  G3DDeterminante3d(a2, a3, a4, b2, b3, b4, d2, d3, d4);
  adj[12] = -G3DDeterminante3d(a2, a3, a4, b2, b3, b4, c2, c3, c4);
  
  adj[1] = -G3DDeterminante3d(b1, b3, b4, c1, c3, c4, d1, d3, d4);
  adj[5] =  G3DDeterminante3d(a1, a3, a4, c1, c3, c4, d1, d3, d4);
  adj[9] = -G3DDeterminante3d(a1, a3, a4, b1, b3, b4, d1, d3, d4);
  adj[13] =  G3DDeterminante3d(a1, a3, a4, b1, b3, b4, c1, c3, c4);
  
  adj[2] =  G3DDeterminante3d(b1, b2, b4, c1, c2, c4, d1, d2, d4);
  adj[6] = -G3DDeterminante3d(a1, a2, a4, c1, c2, c4, d1, d2, d4);
  adj[10] =  G3DDeterminante3d(a1, a2, a4, b1, b2, b4, d1, d2, d4);
  adj[14] = -G3DDeterminante3d(a1, a2, a4, b1, b2, b4, c1, c2, c4);
  
  adj[3] = -G3DDeterminante3d(b1, b2, b3, c1, c2, c3, d1, d2, d3);
  adj[7] =  G3DDeterminante3d(a1, a2, a3, c1, c2, c3, d1, d2, d3);
  adj[11] = -G3DDeterminante3d(a1, a2, a3, b1, b2, b3, d1, d2, d3);
  adj[15] =  G3DDeterminante3d(a1, a2, a3, b1, b2, b3, c1, c2, c3);
}

__G3DI__ void G3DTransposeMatrix3fv(float t[9],CFLOAT matrix[9])
{
  t[0] = matrix[0];
  t[1] = matrix[3];
  t[2] = matrix[6];
  t[3] = matrix[1];
  t[4] = matrix[4];
  t[5] = matrix[7];
  t[6] = matrix[2];
  t[7] = matrix[5];
  t[8] = matrix[8];
}

__G3DI__ void G3DTransposeMatrix3dv(double t[9],CDOUBLE matrix[9])
{
  t[0] = matrix[0];
  t[1] = matrix[3];
  t[2] = matrix[6];
  t[3] = matrix[1];
  t[4] = matrix[4];
  t[5] = matrix[7];
  t[6] = matrix[2];
  t[7] = matrix[5];
  t[8] = matrix[8];
}

__G3DI__ void G3DTransposeMatrix4fv(float t[16],CFLOAT matrix[16])
{
  t[0] = matrix[0];
  t[1] = matrix[4];
  t[2] = matrix[8];
  t[3] = matrix[12];
  t[4] = matrix[1];
  t[5] = matrix[5];
  t[6] = matrix[9];
  t[7] = matrix[13];
  t[8] = matrix[2];
  t[9] = matrix[6];
  t[10] = matrix[10];
  t[11] = matrix[14];
  t[12] = matrix[3];
  t[13] = matrix[7];
  t[14] = matrix[11];
  t[15] = matrix[15];
}

__G3DI__ void G3DTransposeMatrix4dv(double t[16],CDOUBLE matrix[16])
{
  t[0] = matrix[0];
  t[1] = matrix[4];
  t[2] = matrix[8];
  t[3] = matrix[12];
  t[4] = matrix[1];
  t[5] = matrix[5];
  t[6] = matrix[9];
  t[7] = matrix[13];
  t[8] = matrix[2];
  t[9] = matrix[6];
  t[10] = matrix[10];
  t[11] = matrix[14];
  t[12] = matrix[3];
  t[13] = matrix[7];
  t[14] = matrix[11];
  t[15] = matrix[15];
}

__G3DI__ void G3DMakeXRotation3f(float matrix[9],CFLOAT angle)
{
  float cosinus = (float)cos(angle);
  float sinus = (float)sin(angle);

  matrix[1] = matrix[2] = matrix[3] = matrix[6] = 0.0f;

  matrix[0] = 1.0f;

  matrix[4] = matrix[8] = cosinus;
  matrix[5] = sinus;
  matrix[7] = -sinus;
}

__G3DI__ void G3DMakeXRotation3d(double matrix[9],CDOUBLE angle)
{
  double cosinus = cos(angle);
  double sinus = sin(angle);

  matrix[1] = matrix[2] = matrix[3] = matrix[6] = 0.0;

  matrix[0] = 1.0;

  matrix[4] = matrix[8] = cosinus;
  matrix[5] = sinus;
  matrix[7] = -sinus;
}

__G3DI__ void G3DMakeYRotation3f(float matrix[9],CFLOAT angle)
{
  float cosinus = (float)cos(angle);
  float sinus = (float)sin(angle);

  matrix[1] = matrix[3] = matrix[5] = matrix[7] = 0.0f;

  matrix[4] = 1.0f;

  matrix[0] = matrix[8] = cosinus;
  matrix[2] = -sinus;
  matrix[6] = sinus;
}

__G3DI__ void G3DMakeYRotation3d(double matrix[9],CDOUBLE angle)
{
  double cosinus = cos(angle);
  double sinus = sin(angle);

  matrix[1] = matrix[3] = matrix[5] = matrix[7] = 0.0;

  matrix[4] = 1.0;

  matrix[0] = matrix[8] = cosinus;
  matrix[2] = -sinus;
  matrix[6] = sinus;
}

__G3DI__ void G3DMakeZRotation3f(float matrix[9],CFLOAT angle)
{
  float cosinus = (float)cos(angle);
  float sinus = (float)sin(angle);

  matrix[2] = matrix[5] = matrix[6] = matrix[7] = 0.0f;

  matrix[8] = 1.0f;

  matrix[0] = matrix[4] = cosinus;
  matrix[1] = sinus;
  matrix[3] = -sinus;
}

__G3DI__ void G3DMakeZRotation3d(double matrix[9],CDOUBLE angle)
{
  double cosinus = cos(angle);
  double sinus = sin(angle);

  matrix[2] = matrix[5] = matrix[6] = matrix[7] = 0.0;

  matrix[8] = 1.0;

  matrix[0] = matrix[4] = cosinus;
  matrix[1] = sinus;
  matrix[3] = -sinus;
}

__G3DI__ void G3DMakeXRotation4f(float matrix[16],CFLOAT angle)
{
  float cosinus = (float)cos(angle);
  float sinus = (float)sin(angle);

  matrix[1] = matrix[2] = matrix[3] = matrix[4] = matrix[7] = matrix[8] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0f;

  matrix[0]  = 1.0f;
  matrix[15] = 1.0f;

  matrix[5] = matrix[10] = cosinus;
  matrix[6] = sinus;
  matrix[9] = -sinus;
}

__G3DI__ void G3DMakeXRotation4d(double matrix[16],CDOUBLE angle)
{
  double cosinus = (double)cos(angle);
  double sinus = (double)sin(angle);

  matrix[1] = matrix[2] = matrix[3] = matrix[4] = matrix[7] = matrix[8] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;

  matrix[0]  = 1.0;
  matrix[15] = 1.0;

  matrix[5] = matrix[10] = cosinus;
  matrix[6] = sinus;
  matrix[9] = -sinus;
}

__G3DI__ void G3DMakeYRotation4f(float matrix[16],CFLOAT angle)
{
  float cosinus = (float)cos(angle);
  float sinus = (float)sin(angle);

  matrix[1] = matrix[3] = matrix[4] = matrix[9] = matrix[6] = matrix[7] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0f;

  matrix[5]  = 1.0f;
  matrix[15] = 1.0f;

  matrix[0] = matrix[10] = cosinus;
  matrix[2] = -sinus;
  matrix[8] = sinus;
}

__G3DI__ void G3DMakeYRotation4d(double matrix[16],CDOUBLE angle)
{
  double cosinus = cos(angle);
  double sinus = sin(angle);

  matrix[1] = matrix[3] = matrix[4] = matrix[9] = matrix[6] = matrix[7] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;

  matrix[5]  = 1.0;
  matrix[15] = 1.0;

  matrix[0] = matrix[10] = cosinus;
  matrix[2] = -sinus;
  matrix[8] = sinus;
}

__G3DI__ void G3DMakeZRotation4f(float matrix[16],CFLOAT angle)
{
  float cosinus = (float)cos(angle);
  float sinus = (float)sin(angle);

  matrix[2] = matrix[3] = matrix[6] = matrix[7] = matrix[8] = matrix[9] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0f;

  matrix[10] = 1.0f;
  matrix[15] = 1.0f;

  matrix[0] = matrix[5] = cosinus;
  matrix[1] = sinus;
  matrix[4] = -sinus;
}

__G3DI__ void G3DMakeZRotation4d(double matrix[16],CDOUBLE angle)
{
  double cosinus = cos(angle);
  double sinus = sin(angle);

  matrix[2] = matrix[3] = matrix[6] = matrix[7] = matrix[8] = matrix[9] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;

  matrix[10] = 1.0;
  matrix[15] = 1.0;

  matrix[0] = matrix[5] = cosinus;
  matrix[1] = sinus;
  matrix[4] = -sinus;
}

__G3DI__ void G3DMakeInvXRotation4f(float matrix[16],CFLOAT angle)
{
  float cosinus = (float)cos(angle);
  float sinus = (float)sin(angle);

  matrix[1] = matrix[2] = matrix[3] = matrix[4] = matrix[7] = matrix[8] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0f;

  matrix[0]  = 1.0f;
  matrix[15] = 1.0f;

  matrix[5] = matrix[10] = cosinus;
  matrix[6] = -sinus;
  matrix[9] = sinus;
}

__G3DI__ void G3DMakeInvXRotation4d(double matrix[16],CDOUBLE angle)
{
  double cosinus = cos(angle);
  double sinus = sin(angle);

  matrix[1] = matrix[2] = matrix[3] = matrix[4] = matrix[7] = matrix[8] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;

  matrix[0]  = 1.0;
  matrix[15] = 1.0;

  matrix[5] = matrix[10] = cosinus;
  matrix[6] = -sinus;
  matrix[9] = sinus;
}

__G3DI__ void G3DMakeInvYRotation4f(float matrix[16],CFLOAT angle)
{
  float cosinus = (float)cos(angle);
  float sinus = (float)sin(angle);

  matrix[1] = matrix[3] = matrix[4] = matrix[9] = matrix[6] = matrix[7] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0f;

  matrix[5]  = 1.0f;
  matrix[15] = 1.0f;

  matrix[0] = matrix[10] = cosinus;
  matrix[2] = sinus;
  matrix[8] = -sinus;
}

__G3DI__ void G3DMakeInvYRotation4d(double matrix[16],CDOUBLE angle)
{
  double cosinus = cos(angle);
  double sinus = sin(angle);

  matrix[1] = matrix[3] = matrix[4] = matrix[9] = matrix[6] = matrix[7] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;

  matrix[5]  = 1.0;
  matrix[15] = 1.0;

  matrix[0] = matrix[10] = cosinus;
  matrix[2] = sinus;
  matrix[8] = -sinus;
}

__G3DI__ void G3DMakeInvZRotation4f(float matrix[16],CFLOAT angle)
{
  float cosinus = (float)cos(angle);
  float sinus = (float)sin(angle);

  matrix[2] = matrix[3] = matrix[6] = matrix[7] = matrix[8] = matrix[9] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0f;

  matrix[10] = 1.0f;
  matrix[15] = 1.0f;

  matrix[0] = matrix[5] = cosinus;
  matrix[1] = -sinus;
  matrix[4] = sinus;
}

__G3DI__ void G3DMakeInvZRotation4d(double matrix[16],CDOUBLE angle)
{
  double cosinus = cos(angle);
  double sinus = sin(angle);

  matrix[2] = matrix[3] = matrix[6] = matrix[7] = matrix[8] = matrix[9] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;

  matrix[10] = 1.0;
  matrix[15] = 1.0;

  matrix[0] = matrix[5] = cosinus;
  matrix[1] = -sinus;
  matrix[4] = sinus;
}

__G3DI__ void G3DMakeRotation3f(float mat[9],CFLOAT a,CFLOAT axis[3])
{
  float ax[3];
  float xy;
  float xz;
  float yz;
  float xs;
  float ys;
  float zs;
  register float s;
  register float c;
  register float t;
  register float angle = a * DEG2RAD;

  if (G3DScalarProduct3fv(axis,axis) == 0.0f) {
    G3DMakeIdentity3fv(mat);
    return;
  }

  G3DNormalise3fv(ax, axis); 

  /*
   * Later I will implement lookups for sin and cos...
   */
  s = (float)sin(angle);
  c = (float)cos(angle);
  t = 1.0f - c;

  xy = ax[0] * ax[1];
  xz = ax[0] * ax[2];
  yz = ax[1] * ax[2];
  xs = s     * ax[0];
  ys = s     * ax[1];
  zs = s     * ax[2];

  mat[0] = t * ax[0] * ax[0] + c;
  mat[1] = t * xy            + zs;
  mat[2] = t * xz            - ys;

  mat[3] = t * xy            - zs;
  mat[4] = t * ax[1] * ax[1] + c ;
  mat[5] = t * yz            + xs;

  mat[6] = t * xz            + ys;
  mat[7] = t * yz            - xs;
  mat[8] = t * ax[2] * ax[2] + c ;
}

__G3DI__ void G3DMakeRotation3d(double mat[9],CDOUBLE a,CDOUBLE axis[3])
{
  double ax[3];
  double xy;
  double xz;
  double yz;
  double xs;
  double ys;
  double zs;
  register double s;
  register double c;
  register double t;
  register double angle = a * DEG2RAD;

  if (G3DScalarProduct3dv(axis,axis) == 0.0) {
    G3DMakeIdentity3dv(mat);
    return;
  }
  
  G3DNormalise3dv(ax, axis); 

  /*
   * Later I will implement lookups for sin and cos...
   */

  s = sin(angle);
  c = cos(angle);
  t = 1.0 - c;

  xy = ax[0] * ax[1];
  xz = ax[0] * ax[2];
  yz = ax[1] * ax[2];
  xs = s     * ax[0];
  ys = s     * ax[1];
  zs = s     * ax[2];

  mat[0] = t * ax[0] * ax[0] + c;
  mat[1] = t * xy            + zs;
  mat[2] = t * xz            - ys;

  mat[3] = t * xy            - zs;
  mat[4] = t * ax[1] * ax[1] + c ;
  mat[5] = t * yz            + xs;

  mat[6] = t * xz            + ys;
  mat[7] = t * yz            - xs;
  mat[8] = t * ax[2] * ax[2] + c ;
}

__G3DI__ void G3DMakeRotation4f(float matrix[16],CFLOAT ang,CFLOAT axis[3])
{
  float ax[3];
  float xy;
  float xz;
  float yz;
  float xs;
  float ys;
  float zs;
  register float s;
  register float c;
  register float t;
  register float angle = ang;

  if (G3DScalarProduct3fv(axis,axis) == 0.0f) {
    G3DMakeIdentity4fv(matrix);
    return;
  }

  G3DNormalise3fv(ax, axis); 

  angle *= DEG2RAD;

  /*
   * Later I will implement lookups for sin and cos...
   */
  s = (float)sin(angle);
  c = (float)cos(angle);
  t = 1.0f - c;

  xy = ax[0] * ax[1];
  xz = ax[0] * ax[2];
  yz = ax[1] * ax[2];
  xs = s     * ax[0];
  ys = s     * ax[1];
  zs = s     * ax[2];

  matrix[0] = t * ax[0] * ax[0]  + c;
  matrix[1] = t * xy             + zs;
  matrix[2] = t * xz             - ys;

  matrix[4] = t * xy             - zs;
  matrix[5] = t * ax[1] * ax[1]  + c ;
  matrix[6] = t * yz             + xs;

  matrix[8] = t * xz             + ys;
  matrix[9] = t * yz             - xs;
  matrix[10] = t * ax[2] * ax[2] + c ;

  matrix[3]  = matrix[7]  = matrix[11] = 0.0f;
  matrix[12] = matrix[13] = matrix[14] = 0.0f;
  matrix[15] = 1.0f;
}

__G3DI__ void G3DMakeRotation4d(double matrix[16],CDOUBLE ang,CDOUBLE axis[3])
{
  double ax[3];
  double xy;
  double xz;
  double yz;
  double xs;
  double ys;
  double zs;
  register double s;
  register double c;
  register double t;
  register double angle = ang;

  if (G3DScalarProduct3dv(axis,axis) == 0.0) {
    G3DMakeIdentity4dv(matrix);
    return;
  }

  G3DNormalise3dv(ax, axis); 

  angle *= DEG2RAD;

  /*
   * Later I will implement lookups for sin and cos...
   */

  s = sin(angle);
  c = cos(angle);
  t = 1.0 - c;

  xy = ax[0] * ax[1];
  xz = ax[0] * ax[2];
  yz = ax[1] * ax[2];
  xs = s     * ax[0];
  ys = s     * ax[1];
  zs = s     * ax[2];

  matrix[0] = t * ax[0] * ax[0]  + c;
  matrix[1] = t * xy             + zs;
  matrix[2] = t * xz             - ys;

  matrix[4] = t * xy             - zs;
  matrix[5] = t * ax[1] * ax[1]  + c ;
  matrix[6] = t * yz             + xs;

  matrix[8] = t * xz             + ys;
  matrix[9] = t * yz             - xs;
  matrix[10] = t * ax[2] * ax[2] + c ;

  matrix[3] = matrix[7] = matrix[11] = 0.0;
  matrix[12] = matrix[13] = matrix[14] = 0.0;
  matrix[15] = 1.0;
}

__G3DI__ void G3DMakeTranslation4f(float matrix[16],CFLOAT v[3])
{
  matrix[1] = matrix[2] = matrix[3] = matrix[4] = matrix[6] = matrix[7] = matrix[8] = matrix[9] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0f;
  
  matrix[12] = v[0];
  matrix[13] = v[1];
  matrix[14] = v[2];
  matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0f;
}

__G3DI__ void G3DMakeTranslation4d(double matrix[16],CDOUBLE v[3])
{
  matrix [1] = matrix[2] = matrix[3] = matrix[4] = matrix[6] = matrix[7] = matrix[8] = matrix[9] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;
  
  matrix[12] = v[0];
  matrix[13] = v[1];
  matrix[14] = v[2];
  matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0;
}

__G3DI__ void G3DMakeTranslationRotation4f(float res[16],CFLOAT t[3],CFLOAT rot[3])
{
  res [1] = res[2] = res[3] = res[4] = res[6] = res[7] = res[8] = res[9] = res[11] = res[12] = res[13] = res[14] = 0.0f;
  
  res[12] = t[0];
  res[13] = t[1];
  res[14] = t[2];
  res[0] = res[5] = res[10] = res[15] = 1.0f;

  // warning Rotation is not yet set!
}

__G3DI__ void G3DMakeTranslationRotation4d(double res[16],CDOUBLE t[3],CDOUBLE rot[3])
{
  res [1] = res[2] = res[3] = res[4] = res[6] = res[7] = res[8] = res[9] = res[11] = res[12] = res[13] = res[14] = 0.0;
  
  res[12] = t[0];
  res[13] = t[1];
  res[14] = t[2];
  res[0] = res[5] = res[10] = res[15] = 1.0;

  // warning Rotation is not yet set!
}

__G3DI__ void G3DMakeTranslationRotationScale4f(float res[16],CFLOAT t[3],CFLOAT rot[16], CFLOAT scale)
{
  /*
   * S * R ... 
   */

  res[0]=scale * rot[0];
  res[1]=scale * rot[1];
  res[2]=scale * rot[2];

  res[4]=scale * rot[4];
  res[5]=scale * rot[5];
  res[6]=scale * rot[6];

  res[8]=scale * rot[8];
  res[9]=scale * rot[9];
  res[10]=scale * rot[10];

  /* 
   * ... * T 
   */

  res[12] = t[0];
  res[13] = t[1];
  res[14] = t[2];

  res[3] = res[7] = res[11] = 0.0f;
  res[15] = 1.0f;
}

__G3DI__ void G3DMakeTranslationRotationScale4d(double res[16],CDOUBLE t[3],CDOUBLE rot[16], CDOUBLE scale)
{
  /*
   * S * R ... 
   */

  res[0]=scale * rot[0];
  res[1]=scale * rot[1];
  res[2]=scale * rot[2];

  res[4]=scale * rot[4];
  res[5]=scale * rot[5];
  res[6]=scale * rot[6];

  res[8]=scale * rot[8];
  res[9]=scale * rot[9];
  res[10]=scale * rot[10];

  /* 
   * ... * T 
   */

  res[12] = t[0];
  res[13] = t[1];
  res[14] = t[2];

  res[3] = res[7] = res[11] = 0.0;
  res[15] = 1.0;
}

__G3DI__ void G3DMakeTranslationQuatScale4f(float res[16],CFLOAT t[3],CFLOAT quat[4], CFLOAT scale)
{
  /*
   * 1st column
   */

  res[0] = 1.0f - 2.0f * (quat[1] * quat[1] + quat[2] * quat[2]);
  res[1] = 2.0f * (quat[0] * quat[1] - quat[2] * quat[3]);
  res[2] = 2.0f * (quat[2] * quat[0] + quat[1] * quat[3]);
  res[3] = 0.0f;

  /*
   * 2nd column
   */

  res[4] = 2.0f * (quat[0] * quat[1] + quat[2] * quat[3]);
  res[5] = 1.0f - 2.0f * (quat[2] * quat[2] + quat[0] * quat[0]);
  res[6] = 2.0f * (quat[1] * quat[2] - quat[0] * quat[3]);
  res[7] = 0.0f;

  /*
   * 3rd column
   */

  res[8] = 2.0f * (quat[2] * quat[0] - quat[1] * quat[3]);
  res[9] = 2.0f * (quat[1] * quat[2] + quat[0] * quat[3]);
  res[10] = 1.0f - 2.0f * (quat[1] * quat[1] + quat[0] * quat[0]);
  res[11] = 0.0f;

  /*
   * 4th column
   */

  res[12] = t[0];
  res[13] = t[1];
  res[14] = t[2];
  res[15] = 1.0f;
  
  /*
   * Scale the whole 3x3 part
   */

  res[0] *= scale;
  res[1] *= scale;
  res[2] *= scale;
  res[4] *= scale;
  res[5] *= scale;
  res[6] *= scale;
  res[8] *= scale;
  res[9] *= scale;
  res[10] *= scale;
}

__G3DI__ void G3DMakeTranslationQuatScale4d(double res[16],CDOUBLE t[3],CDOUBLE quat[4], CDOUBLE scale)
{
  /*
   * 1st column
   */

  res[0] = 1.0 - 2.0 * (quat[1] * quat[1] + quat[2] * quat[2]);
  res[1] = 2.0 * (quat[0] * quat[1] - quat[2] * quat[3]);
  res[2] = 2.0 * (quat[2] * quat[0] + quat[1] * quat[3]);
  res[3] = 0.0;

  /*
   * 2nd column
   */

  res[4] = 2.0 * (quat[0] * quat[1] + quat[2] * quat[3]);
  res[5] = 1.0 - 2.0 * (quat[2] * quat[2] + quat[0] * quat[0]);
  res[6] = 2.0 * (quat[1] * quat[2] - quat[0] * quat[3]);
  res[7] = 0.0;

  /*
   * 3rd column
   */

  res[8] = 2.0 * (quat[2] * quat[0] - quat[1] * quat[3]);
  res[9] = 2.0 * (quat[1] * quat[2] + quat[0] * quat[3]);
  res[10] = 1.0 - 2.0 * (quat[1] * quat[1] + quat[0] * quat[0]);
  res[11] = 0.0;

  /*
   * 4th column
   */

  res[12] = t[0];
  res[13] = t[1];
  res[14] = t[2];
  res[15] = 1.0;
  
  /*
   * Scale the whole 3x3 part
   */

  res[0] *= scale;
  res[1] *= scale;
  res[2] *= scale;
  res[4] *= scale;
  res[5] *= scale;
  res[6] *= scale;
  res[8] *= scale;
  res[9] *= scale;
  res[10] *= scale;
}

__G3DI__ void G3DMakeScale3fv(float m[9],CFLOAT scale[3])
{
  G3DMakeIdentity3fv(m);

  /* The scaling values... */
  m[0] = scale[0];
  m[4] = scale[1];
  m[8] = scale[2];
}

__G3DI__ void G3DMakeScale3dv(double m[9],CDOUBLE scale[3])
{
  G3DMakeIdentity3dv(m);

  /* The scaling values... */
  m[0] = scale[0];
  m[4] = scale[1];
  m[8] = scale[2];
}

__G3DI__ void G3DMakeScale4fv(float m[16],CFLOAT scale[3])
{
  G3DMakeIdentity4fv(m);

  /* The scaling values... */
  m[0] = scale[0];
  m[5] = scale[1];
  m[10] = scale[2];
}

__G3DI__ void G3DMakeScale4dv(double m[16],CDOUBLE scale[3])
{
  G3DMakeIdentity4dv(m);

  /* The scaling values... */
  m[0] = scale[0];
  m[5] = scale[1];
  m[10] = scale[2];
}

__G3DI__ void G3DMakeEulerTransform4fv(float euler[16], CFLOAT hpr[3])
{
  float _m[16];
  float _tmp[16];
  int mod = 0;

  /*
   * Euler(h,p,r) := Rz(r) * Rx(p) * Ry(h)
   *
   */
  
  /*
   * Roll -> Z axis
   */
  
  if (hpr[2]) {
    G3DMakeZRotation4f(euler,hpr[2]);
    mod = 1;
  }
  
  /*
   * Pitch -> X axis
   */
  
  if (hpr[0]) {
    if (mod == 1) {
      G3DMakeXRotation4f(_tmp,hpr[0]);
      G3DMultiplyMatrix4fv(_m,euler,_tmp);
      G3DCopyMatrix4fv(euler,_m);
    }
    else {
      G3DMakeXRotation4f(euler,hpr[0]);
      mod = 1;
    }
  }
  
  /*
   * Head -> Y axis
   */
  
  if (hpr[1]) {
    if (mod == 1) {
      G3DMakeYRotation4f(_tmp,hpr[1]);
      G3DMultiplyMatrix4fv(_m,euler,_tmp);
      G3DCopyMatrix4fv(euler,_m);
    }
    else {
      G3DMakeYRotation4f(euler,hpr[1]);
      mod = 1;
    }
  }  

  /*
   * This shouldn't happen...
   */

  if (mod == 0) {
    G3DMakeIdentity4fv(euler);
  }
}

__G3DI__ void G3DMakeEulerTransform4dv(double euler[16], CDOUBLE hpr[3])
{
  double _m[16];
  double _tmp[16];
  int mod = 0;

  /*
   * Euler(h,p,r) := Rz(r) * Rx(p) * Ry(h)
   *
   */
  
  /*
   * Roll -> Z axis
   */
  
  if (hpr[2]) {
    G3DMakeZRotation4d(euler,hpr[2]);
    mod = 1;
  }
  
  /*
   * Pitch -> X axis
   */
  
  if (hpr[0]) {
    if (mod == 1) {
      G3DMakeXRotation4d(_tmp,hpr[0]);
      G3DMultiplyMatrix4dv(_m,euler,_tmp);
      G3DCopyMatrix4dv(euler,_m);
    }
    else {
      G3DMakeXRotation4d(euler,hpr[0]);
      mod = 1;
    }
  }
  
  /*
   * Head -> Y axis
   */
  
  if (hpr[1]) {
    if (mod == 1) {
      G3DMakeYRotation4d(_tmp,hpr[1]);
      G3DMultiplyMatrix4dv(_m,euler,_tmp);
      G3DCopyMatrix4dv(euler,_m);
    }
    else {
      G3DMakeYRotation4d(euler,hpr[1]);
      mod = 1;
    }
  }  

  /*
   * This shouldn't happen...
   */

  if (mod == 0) {
    G3DMakeIdentity4dv(euler);
  }
}

__G3DI__ void G3DHPRFromEulerTransform4fv(float hpr[3], CFLOAT euler[16])
{
  /*
   * h = atan2(-m[2],m[10])
   * p = arcsin(m[6])
   * r = atan2(-m[4],m[5])
   *
   * If cos(p) == 0 => p == +-1, for more info see Shoemake's paper
   */

  hpr[1] = (float)asin(euler[6]);

  if ((float)cos(hpr[1]) != 0.0f) {
    hpr[0] = (float)atan2(-euler[2],euler[10]);
    hpr[2] = (float)atan2(-euler[4],euler[5]);
  }
  else {
    hpr[0] = 0.0f;
    hpr[2] = (float)atan2(euler[1],euler[0]);
  }
}

__G3DI__ void G3DHPRFromEulerTransform4dv(double hpr[3], CDOUBLE euler[16])
{
  /*
   * h = atan2(-m[2],m[10])
   * p = arcsin(m[6])
   * r = atan2(-m[4],m[5])
   *
   * If cos(p) == 0 => p == +-1, for more info see Shoemake's paper
   */

  hpr[1] = asin(euler[6]);

  if (cos(hpr[1]) != 0.0) {
    hpr[0] = atan2(-euler[2],euler[10]);
    hpr[2] = atan2(-euler[4],euler[5]);
  }
  else {
    hpr[0] = 0.0;
    hpr[2] = atan2(euler[1],euler[0]);
  }
}

__G3DI__ void G3DInvertEulerTransform4fv(float inv[16], CFLOAT euler[16])
{
  /*
   * Inversion means transposing, since E(h,p,r) is orthogonal!
   */

  G3DTransposeMatrix4fv(inv,euler);
}

__G3DI__ void G3DInvertEulerTransform4dv(double inv[16], CDOUBLE euler[16])
{
  /*
   * Inversion means transposing, since E(h,p,r) is orthogonal!
   */

  G3DTransposeMatrix4dv(inv,euler);
}
