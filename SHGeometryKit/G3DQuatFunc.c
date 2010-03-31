/* 
 * G3DQuatFunc.c created by robert on 2001-01-05 15:07:36 +0000
 *
 * Project SHGeometryKit
 *
 * Created with ProjectCenter - http://www.projectcenter.ch
 *
 * $Id: G3DQuatFunc.c,v 1.2 2002/10/27 11:51:42 probert Exp $
 */

#include "G3DQuatFunc.h"
#include "G3DDefs.h"

/*
 * Declarations
 *
 */

void G3DMultiplyQuatf(float dst[4],CFLOAT a[4],CFLOAT b[4]);
void G3DMultiplyQuatd(double dst[4],CDOUBLE a[4],CDOUBLE b[4]);

void G3DQuatFromAngleAxisf(float quat[4], CFLOAT angle, CFLOAT axis[3]);
void G3DQuatFromAngleAxisd(double quat[4], CDOUBLE angle, CDOUBLE axis[3]);

void G3DQuatFromRotationVectorf(float quat[4], CFLOAT axis[3]);
void G3DQuatFromRotationVectord(double quat[4], CDOUBLE axis[3]);

void G3DAngleAxisFromQuatf(float *angle, float axis[3], CFLOAT quat[4]);
void G3DAngleAxisFromQuatd(double *angle, double axis[3], CDOUBLE quat[4]);

void G3DMatrixFromQuatf(float m[16], CFLOAT q[4]);
void G3DMatrixFromQuatd(double m[16], CDOUBLE q[4]);

void G3DQuatFromMatrixf(float q[4], CFLOAT m[16]);
void G3DQuatFromMatrixd(double q[4], CDOUBLE m[16]);

void G3DEulerRepFromQuatf(float res[3], CFLOAT quat[4]);
void G3DEulerRepFromQuatd(double res[3], CDOUBLE quat[4]);

void G3DQuatFromEulerRepf(float q[4],CFLOAT euler[3]);
void G3DQuatFromEulerRepd(double q[4],CDOUBLE euler[3]);

void G3DInterpolateQuatf(float res[4], CFLOAT from[4], CFLOAT to[4], CFLOAT t);
void G3DInterpolateQuatd(double rs[4], CDOUBLE f[4], CDOUBLE to[4], CDOUBLE t);

/******************************************************************************
 *
 * Quaternion Functions 
 *
 *****************************************************************************/

__G3DI__ void G3DMultiplyQuatf(float dst[4],CFLOAT a[4], CFLOAT b[4])
{
  float s1 = (a[2] - a[1]) * (b[1] - b[2]);    
  float s2 = (a[3] + a[0]) * (b[3] + b[0]);
  float s3 = (a[3] - a[0]) * (b[1] + b[2]);
  float s4 = (a[2] + a[1]) * (b[3] - b[0]);
  float s5 = (a[2] - a[0]) * (b[0] - b[1]);
  float s6 = (a[2] + a[0]) * (b[0] + b[1]);
  float s7 = (a[3] + a[1]) * (b[3] - b[2]);
  float s8 = (a[3] - a[1]) * (b[3] + b[2]);
  float s9 = s6 + s7 + s8;
  float t  = (s5 + s9)*0.5f;
  
  dst[0] = s2 + t - s9;
  dst[1] = s3 + t - s8;
  dst[2] = s4 + t - s7;
  dst[3] = s1 + t - s6;
}

__G3DI__ void G3DMultiplyQuatd(double dst[4],CDOUBLE a[4], CDOUBLE b[4])
{
  double s1 = (a[2] - a[1]) * (b[1] - b[2]);    
  double s2 = (a[3] + a[0]) * (b[3] + b[0]);
  double s3 = (a[3] - a[0]) * (b[1] + b[2]);
  double s4 = (a[2] + a[1]) * (b[3] - b[0]);
  double s5 = (a[2] - a[0]) * (b[0] - b[1]);
  double s6 = (a[2] + a[0]) * (b[0] + b[1]);
  double s7 = (a[3] + a[1]) * (b[3] - b[2]);
  double s8 = (a[3] - a[1]) * (b[3] + b[2]);
  double s9 = s6 + s7 + s8;
  double t  = (s5 + s9)*0.5f;
  
  dst[0] = s2 + t - s9;
  dst[1] = s3 + t - s8;
  dst[2] = s4 + t - s7;
  dst[3] = s1 + t - s6;
}

__G3DI__ void G3DQuatFromAngleAxisf(float quat[4], CFLOAT angle, CFLOAT axis[3])
{
  float ta = angle * DEG2RAD / 2.0f;
  float sina = -sin(ta);
  float len = axis[0]*axis[0]+axis[1]*axis[1]+axis[2]*axis[2];

  if (len < G3DEPSILON) {
    quat[0] = quat[1] = quat[2] = quat[3] = 0.0f;
    return;
  }

  /* 
   * Normalising the axis if needed
   */

  if (len != 1.0f) {
    float tmp[3];
    float scale;
    
    scale = 1.0f/sqrt(len);

    tmp[0] = axis[0] * scale;
    tmp[1] = axis[1] * scale;
    tmp[2] = axis[2] * scale;    

    /* Imaginary part */
    
    quat[0] = sina * tmp[0]; 
    quat[1] = sina * tmp[1]; 
    quat[2] = sina * tmp[2];
  }
  else {
    /* Imaginary part */
    
    quat[0] = sina * axis[0]; 
    quat[1] = sina * axis[1]; 
    quat[2] = sina * axis[2];
  }
 
  /* Real part */
  quat[3] = cos(ta);
}

__G3DI__ void G3DQuatFromAngleAxisd(double quat[4], CDOUBLE angle, CDOUBLE axis[3])
{
  double ta = angle * DEG2RAD / 2.0;
  double sina = -sin(ta);
  double len = axis[0]*axis[0]+axis[1]*axis[1]+axis[2]*axis[2];

  if (len < G3DEPSILON) {
    quat[0] = quat[1] = quat[2] = quat[3] = 0.0f;
    return;
  }

  /* 
   * Normalising the axis if needed
   */

  if (len != 1.0) {
    double tmp[3];
    double scale;
    
    scale = 1.0/sqrt(len);

    tmp[0] = axis[0] * scale;
    tmp[1] = axis[1] * scale;
    tmp[2] = axis[2] * scale;    

    /* Imaginary part */
    
    quat[0] = sina * tmp[0]; 
    quat[1] = sina * tmp[1]; 
    quat[2] = sina * tmp[2];
  }
  else {
    /* Imaginary part */
    
    quat[0] = sina * axis[0]; 
    quat[1] = sina * axis[1]; 
    quat[2] = sina * axis[2];
  }
 
  /* Real part */
  quat[3] = cos(ta);
}

__G3DI__ void G3DQuatFromRotationVectorf(float quat[4], CFLOAT axis[3])
{
  float len2 = axis[0]*axis[0]+axis[1]*axis[1]+axis[2]*axis[2];
  float ta;
  float sina;
  float scale;
  float len;

  if (len2 < G3DEPSILON) {
    quat[3] = 1.0f;
    quat[0] = quat[1] = quat[2] = 0.0f;
    return;
  }

  len = sqrt(len2);

  ta = 0.5f * len;   // length == angle
  sina = - sin(ta);

  scale = sina / len;

  /* Imaginary part */
  quat[0] = axis[0] * scale;
  quat[1] = axis[1] * scale;
  quat[2] = axis[2] * scale;

  /* Real part */
  quat[3] = cos(ta);
}

__G3DI__ void G3DQuatFromRotationVectord(double quat[4], CDOUBLE axis[3])
{
  double len2 = axis[0]*axis[0]+axis[1]*axis[1]+axis[2]*axis[2];
  double ta;
  double sina;
  double scale;
  double len;

  if (len2 < G3DEPSILON) {
    quat[3] = 1.0;
    quat[0] = quat[1] = quat[2] = 0.0;
    return;
  }

  len = sqrt(len2);

  ta = 0.5 * len;   // length == angle
  sina = - sin(ta);

  scale = sina / len;

  /* Imaginary part */
  quat[0] = axis[0] * scale;
  quat[1] = axis[1] * scale;
  quat[2] = axis[2] * scale;

  /* Real part */
  quat[3] = cos(ta);
}

__G3DI__ void G3DAngleAxisFromQuatf(float *angle, float axis[3], CFLOAT quat[4])
{
  float a = acos(quat[3]);
  float s = -sin(a);

  *angle = 2.0f * a * RAD2DEG;

  if (s == 0.0) {
    axis[0] = 0.0f;
    axis[1] = 0.0f;
    axis[2] = 1.0f;
  }
  else {
    float scale = 1.0f/s;

    axis[0] = quat[0] * scale;
    axis[1] = quat[1] * scale;
    axis[2] = quat[2] * scale;
  }
}

__G3DI__ void G3DAngleAxisFromQuatd(double *angle, double axis[3], CDOUBLE quat[4])
{
  double a = acos(quat[3]);
  double s = -sin(a);

  *angle = 2.0 * a * RAD2DEG;

  if (s == 0.0) {
    axis[0] = 0.0f;
    axis[1] = 0.0f;
    axis[2] = 1.0f;
  }
  else {
    double scale = 1.0/s;

    axis[0] = quat[0] * scale;
    axis[1] = quat[1] * scale;
    axis[2] = quat[2] * scale;
  }
}

__G3DI__ void G3DMatrixFromQuatf(float m[16], CFLOAT q[4])
{
  float t_sq0 = 2*SQR(q[0]);
  float t_sq1 = 2*SQR(q[1]);
  float t_sq2 = 2*SQR(q[2]);

  float t_q0 = 2 * q[0];
  float t_q1 = 2 * q[1];
  float t_q3 = 2 * q[3];

  float t_q3_q0 = t_q3 * q[0];
  float t_q3_q1 = t_q3 * q[1];
  float t_q3_q2 = t_q3 * q[2];

  float t_q0_q1 = t_q0 * q[1];
  float t_q0_q2 = t_q0 * q[2];

  float t_q1_q2 = t_q1 * q[2];

  m[0] = 1.0f-t_sq1-t_sq2;
  m[1] = t_q0_q1+t_q3_q2;
  m[2] = t_q0_q2-t_q3_q1;
  m[3] = 0.0f;

  m[4] = t_q0_q1-t_q3_q2;
  m[5] = 1.0f-t_sq0-t_sq2;
  m[6] = t_q1_q2+t_q3_q0;
  m[7] = 0.0f;

  m[8] = t_q0_q2+t_q3_q1;
  m[9] = t_q1_q2-t_q3_q0;
  m[10] = 1.0f-t_sq0-t_sq1;
  m[11] = 0.0f;

  m[12] = 0.0f;
  m[13] = 0.0f;
  m[14] = 0.0f;
  m[15] = 1.0f;
}

__G3DI__ void G3DMatrixFromQuatd(double m[16], CDOUBLE q[4])
{
  double t_sq0 = 2*SQR(q[0]);
  double t_sq1 = 2*SQR(q[1]);
  double t_sq2 = 2*SQR(q[2]);

  double t_q0 = 2 * q[0];
  double t_q1 = 2 * q[1];
  double t_q3 = 2 * q[3];

  double t_q3_q0 = t_q3 * q[0];
  double t_q3_q1 = t_q3 * q[1];
  double t_q3_q2 = t_q3 * q[2];

  double t_q0_q1 = t_q0 * q[1];
  double t_q0_q2 = t_q0 * q[2];

  double t_q1_q2 = t_q1 * q[2];

  m[0] = 1.0f-t_sq1-t_sq2;
  m[1] = t_q0_q1+t_q3_q2;
  m[2] = t_q0_q2-t_q3_q1;
  m[3] = 0.0f;

  m[4] = t_q0_q1-t_q3_q2;
  m[5] = 1.0f-t_sq0-t_sq2;
  m[6] = t_q1_q2+t_q3_q0;
  m[7] = 0.0f;

  m[8] = t_q0_q2+t_q3_q1;
  m[9] = t_q1_q2-t_q3_q0;
  m[10] = 1.0f-t_sq0-t_sq1;
  m[11] = 0.0f;

  m[12] = 0.0;
  m[13] = 0.0;
  m[14] = 0.0;
  m[15] = 1.0;
}

__G3DI__ void G3DQuatFromMatrixf(float quat[4], CFLOAT m[16])
{
  float tr;
  float q[4];

  /*
   * m[15] == 1.0f if it is a rotation matrix - and I assume it is!
   */

  tr = m[0] + m[5] + m[10];
  tr++;

  if (tr > 0.0f) {
    float s = 0.5f /sqrt(tr);

    quat[3] = 0.25f / s;
    quat[0] = s * (m[9]-m[6]);
    quat[1] = s * (m[2]-m[8]);
    quat[2] = s * (m[4]-m[1]);
  }
  else {
    float s;
    int i = 0;
    int j;
    int k;
    int nxt[3] = {1,2,0};

    if (m[5] > m[0]) {
      i = 1;
    }
    if (m[10] > (*(m+i)+i)) {
      i = 2;
    }
    j = nxt[i];
    k = nxt[j];

    s = sqrt(1.0f + ((*(m+i)+i) - ((*(m+j)+j) - (*(m+k)+k)))) * 2.0f;

    /*
     * s cannot be 0.0
     */

    q[i] = 0.5f / s;

    q[3] = ((*(m+k)+j) + (*(m+j)+k)) / s;
    q[j] = ((*(m+j)+i) + (*(m+i)+j)) / s;
    q[k] = ((*(m+k)+i) + (*(m+i)+k)) / s;

    quat[0] = q[0];
    quat[1] = q[1];
    quat[2] = q[2];
    quat[3] = q[3];
  }
}

__G3DI__ void G3DQuatFromMatrixd(double quat[4], CDOUBLE m[16])
{
  float tr;
  float q[4];

  /*
   * m[15] == 1.0 if it is a rotation matrix - and I assume it is!
   */

  tr = m[0] + m[5] + m[10];
  tr++;

  if (tr > 0.0) {
    float s = 0.5 /sqrt(tr);

    quat[3] = 0.25 / s;
    quat[0] = s * (m[9]-m[6]);
    quat[1] = s * (m[2]-m[8]);
    quat[2] = s * (m[4]-m[1]);
  }
  else {
    float s;
    int i = 0;
    int j;
    int k;
    int nxt[3] = {1,2,0};

    if (m[5] > m[0]) {
      i = 1;
    }
    if (m[10] > (*(m+i)+i)) {
      i = 2;
    }
    j = nxt[i];
    k = nxt[j];

    s = sqrt(1.0 + ((*(m+i)+i) - ((*(m+j)+j) - (*(m+k)+k)))) * 2.0;

    /*
     * s cannot be 0.0
     */

    q[i] = 0.5 / s;

    q[3] = ((*(m+k)+j) + (*(m+j)+k)) / s;
    q[j] = ((*(m+j)+i) + (*(m+i)+j)) / s;
    q[k] = ((*(m+k)+i) + (*(m+i)+k)) / s;

    quat[0] = q[0];
    quat[1] = q[1];
    quat[2] = q[2];
    quat[3] = q[3];
  }
}

/* from jeffl@darwin3d.com */

__G3DI__ void G3DEulerRepFromQuatf(float res[3], CFLOAT quat[4])
{
  // UPDATE DOCUMENTATION!
  /*
  float matrix[9];
  dobule cx,sx;
  float cy,sy,yr;
  float cz,sz;

  // CONVERT QUATERNION TO MATRIX - I DON'T REALLY NEED ALL OF IT

  matrix[0][0] = SG_ONE - (SG_TWO * quat[SG_Y] * quat[SG_Y])
                        - (SG_TWO * quat[SG_Z] * quat[SG_Z]);
//matrix[0][1] = (SG_TWO * quat->x * quat->y) - (SG_TWO * quat->w * quat->z);
//matrix[0][2] = (SG_TWO * quat->x * quat->z) + (SG_TWO * quat->w * quat->y);

  matrix[1][0] = (SG_TWO * quat[SG_X] * quat[SG_Y]) +
                          (SG_TWO * quat[SG_W] * quat[SG_Z]);
//matrix[1][1] = SG_ONE - (SG_TWO * quat->x * quat->x)
//                      - (SG_TWO * quat->z * quat->z);
//matrix[1][2] = (SG_TWO * quat->y * quat->z) - (SG_TWO * quat->w * quat->x);

  matrix[2][0] = (SG_TWO * quat[SG_X] * quat[SG_Z]) -
                 (SG_TWO * quat[SG_W] * quat[SG_Y]);
  matrix[2][1] = (SG_TWO * quat[SG_Y] * quat[SG_Z]) +
                 (SG_TWO * quat[SG_W] * quat[SG_X]);
  matrix[2][2] = SG_ONE - (SG_TWO * quat[SG_X] * quat[SG_X])
                        - (SG_TWO * quat[SG_Y] * quat[SG_Y]);

  sy = -matrix[2][0];
  cy = sqrt(SG_ONE - (sy * sy));
  yr = atan2(sy,cy);
  euler[1] = yr * SG_RADIANS_TO_DEGREES ;

  // AVOID DIVIDE BY ZERO ERROR ONLY WHERE Y= +-90 or +-270 
  // NOT CHECKING cy BECAUSE OF PRECISION ERRORS
  if (sy != SG_ONE && sy != -SG_ONE)	
  {
    cx = matrix[2][2] / cy;
    sx = matrix[2][1] / cy;
    euler[0] = ((float)atan2(sx,cx)) * SG_RADIANS_TO_DEGREES ;

    cz = matrix[0][0] / cy;
    sz = matrix[1][0] / cy;
    euler[2] = (atan2(sz,cz)) * SG_RADIANS_TO_DEGREES ;
  }
  else
  {
    // SINCE Cos(Y) IS 0, I AM SCREWED.  ADOPT THE STANDARD Z = 0
    // I THINK THERE IS A WAY TO FIX THIS BUT I AM NOT SURE.  EULERS SUCK
    // NEED SOME MORE OF THE MATRIX TERMS NOW

    matrix[1][1] = SG_ONE - (SG_TWO * quat[SG_X] * quat[SG_X])
                          - (SG_TWO * quat[SG_Z] * quat[SG_Z]);
    matrix[1][2] = (SG_TWO * quat[SG_Y] * quat[SG_Z]) -
                   (SG_TWO * quat[SG_W] * quat[SG_X]);

    cx =  matrix[1][1];
    sx = -matrix[1][2];
    euler[0] = (atan2(sx,cx)) * SG_RADIANS_TO_DEGREES ;

    cz = SG_ONE ;
    sz = SG_ZERO ;
    euler[2] = (atan2(sz,cz)) * SG_RADIANS_TO_DEGREES ;
  }
  */
}

__G3DI__ void G3DEulerRepFromQuatd(double res[3], CDOUBLE quat[4])
{
  // UPDATE DOCUMENTATION!
}

__G3DI__ void G3DQuatFromEulerRepf(float q[4],CFLOAT euler[3])
{
  float cr, cp, cy;
  float sr, sp, sy;
  float cpcy, spsy;

  float rh = euler[0]/2.0f;
  float ph = euler[1]/2.0f;
  float yh = euler[2]/2.0f;

  cr = (float)cos(rh);
  cp = (float)cos(ph);
  cy = (float)cos(yh);

  sr = (float)sin(rh);
  sp = (float)sin(ph);
  sy = (float)sin(yh);

  cpcy = cp*cy;
  spsy = sp*sy;

  q[0] = sr * cpcy - cr * spsy;
  q[1] = cr * sp * cy + sr * cp * sy;
  q[2] = cr * cp * sy - sr * sp * cy;

  q[3] = cr * cpcy + sr * spsy;
}

__G3DI__ void G3DQuatFromEulerRepd(double q[4],CDOUBLE euler[3])
{
  double cr, cp, cy;
  double sr, sp, sy;
  double cpcy, spsy;

  double rh = euler[0]/2.0f;
  double ph = euler[1]/2.0f;
  double yh = euler[2]/2.0f;

  cr = (double)cos(rh);
  cp = (double)cos(ph);
  cy = (double)cos(yh);

  sr = (double)sin(rh);
  sp = (double)sin(ph);
  sy = (double)sin(yh);

  cpcy = cp*cy;
  spsy = sp*sy;

  q[0] = sr * cpcy - cr * spsy;
  q[1] = cr * sp * cy + sr * cp * sy;
  q[2] = cr * cp * sy - sr * sp * cy;

  q[3] = cr * cpcy + sr * spsy;
}

__G3DI__ void G3DInterpolateQuatf(float res[4], CFLOAT from[4], CFLOAT to[4], CFLOAT t)
{
  float fixedTo[4];
  float omega, v, sinom, scale0, scale1;
  
  v = from[0]*to[0] + from[1]*to[1] + from[2]*to[2] + from[3]*to[3];
  
  if (v < 0.0f) { 
    v = -v; 

    fixedTo[0] = - to[0];
    fixedTo[1] = - to[1];
    fixedTo[2] = - to[2];
    fixedTo[3] = - to[3];
  } 
  else  {
    fixedTo[0] = to[0];
    fixedTo[1] = to[1];
    fixedTo[2] = to[2];
    fixedTo[3] = to[3];
  }
  
  /* calculate SLERP coefficients (linear if from and to are close enough) */
  if ((1.0f - v) > 0.0f) {
    omega = acos(v);
    sinom = sin(omega);
    
    scale0 = sin((1.0f - t) * omega) / sinom;
    scale1 = sin(t * omega) / sinom;
  } 
  else {
    scale0 = 1.0f - t;
    scale1 = t;
  }

  res[0] = scale0 * from[0] + scale1 * fixedTo[0];
  res[1] = scale0 * from[1] + scale1 * fixedTo[1];
  res[2] = scale0 * from[2] + scale1 * fixedTo[2];
  res[3] = scale0 * from[3] + scale1 * fixedTo[3];
}

__G3DI__ void G3DInterpolateQuatd(double res[4], CDOUBLE from[4], CDOUBLE to[4], CDOUBLE t)
{
  double fixedTo[4];
  double omega, v, sinom, scale0, scale1;
  
  v = from[0]*to[0] + from[1]*to[1] + from[2]*to[2] + from[3]*to[3];
  
  if (v < 0.0) { 
    v = -v; 

    fixedTo[0] = - to[0];
    fixedTo[1] = - to[1];
    fixedTo[2] = - to[2];
    fixedTo[3] = - to[3];
  } 
  else  {
    fixedTo[0] = to[0];
    fixedTo[1] = to[1];
    fixedTo[2] = to[2];
    fixedTo[3] = to[3];
  }
  
  /* calculate SLERP coefficients (linear if from and to are close enough) */
  if ((1.0 - v) > 0.0) {
    omega = acos(v);
    sinom = sin(omega);
    
    scale0 = sin((1.0 - t) * omega) / sinom;
    scale1 = sin(t * omega) / sinom;
  } 
  else {
    scale0 = 1.0 - t;
    scale1 = t;
  }

  res[0] = scale0 * from[0] + scale1 * fixedTo[0];
  res[1] = scale0 * from[1] + scale1 * fixedTo[1];
  res[2] = scale0 * from[2] + scale1 * fixedTo[2];
  res[3] = scale0 * from[3] + scale1 * fixedTo[3];
}
