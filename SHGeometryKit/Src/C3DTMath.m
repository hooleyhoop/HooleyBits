/*
 *  C3DTMath.c
 *  Cocoa3DTutorial
 *
 *  Created by Paolo Manna on Sat May 17 2003.
 *  Copyright (c) 2003. All rights reserved.
 *
 *  Terms of use:
 *  - Short: OPEN SOURCE under Artistic License -- credit fairly, use freely, alter carefully.
 *  -  Full: <http://www.opensource.org/licenses/artistic-license.html>
 *
 * $Id: C3DTMath.c,v 1.1.1.1 2004/11/29 11:35:56 shooley Exp $
 *
 * $Log: C3DTMath.c,v $
 * Revision 1.1.1.1  2004/11/29 11:35:56  shooley
 * Initial Import
 *
 * Revision 1.1.1.1  2004/11/25 15:33:05  shooley
 * Initial import
 *
 * Revision 1.1.1.1  2004/11/21 11:41:57  shooley
 * Initial Import
 *
 * Revision 1.5  2003/07/08 11:23:02  pmanna
 * Added check for procedural texture tiling
 * Corrected 3D texture generation
 *
 * Revision 1.4  2003/06/24 22:32:27  pmanna
 * Added matrixTranspose and corrected some transformation equations: simplified matrixInverse
 *
 * Revision 1.3  2003/06/17 19:24:33  pmanna
 * Added code for 3D Perlin noise
 *
 * Revision 1.2  2003/06/17 07:05:23  pmanna
 * Added interpolation code for Perlin noise
 *
 * Revision 1.1.1.1  2003/06/10 18:09:30  pmanna
 * Initial import
 *
 *
 */

#import "C3DTMath.h"
#import <Accelerate/Accelerate.h>


/*************************************
* V E C T O R   O P E R A T I O N S
*************************************/

// adds 2 vectors
C3DTVector vectorAdd(const C3DTVector a, const C3DTVector b) {

    C3DTVector	r;

    r.cartesian.x = a.cartesian.x + b.cartesian.x;
    r.cartesian.y = a.cartesian.y + b.cartesian.y;
    r.cartesian.z = a.cartesian.z + b.cartesian.z;
    
    return r;
}

// subtracts 2 vectors
C3DTVector vectorSubtract(const C3DTVector a, const C3DTVector b)
{
    C3DTVector	r;

    r.cartesian.x = a.cartesian.x - b.cartesian.x;
    r.cartesian.y = a.cartesian.y - b.cartesian.y;
    r.cartesian.z = a.cartesian.z - b.cartesian.z;
    
    return r;
}

// Dot product of 2 vectors
inline float vectorDotProduct(const C3DTVector a, const C3DTVector b)
{
    return (a.cartesian.x*b.cartesian.x + a.cartesian.y*b.cartesian.y + a.cartesian.z*b.cartesian.z);
}

// Returns vector product a x b
inline C3DTVector vectorCrossProduct(const C3DTVector a, const C3DTVector b)
{
    C3DTVector	r;

    r.cartesian.x = a.cartesian.y*b.cartesian.z - b.cartesian.y*a.cartesian.z;
    r.cartesian.y = a.cartesian.z*b.cartesian.x - b.cartesian.z*a.cartesian.x;
    r.cartesian.z = a.cartesian.x*b.cartesian.y - b.cartesian.x*a.cartesian.y;

    return r;
}

// Returns (b-a) x (c-a)
inline C3DTVector vectorCrossProductTri(const C3DTVector a, const C3DTVector b, const C3DTVector c) {

	return vectorCrossProduct(vectorSubtract(b,a), vectorSubtract(c,a));
}

float vectorLength( const C3DTVector v ) {
    return sqrtf(v.flts[0]*v.flts[0] + v.flts[1]*v.flts[1] + v.flts[2]*v.flts[2] );
}

C3DTVector vectorNormalize(C3DTVector v) {

    float dist = vectorLength(v);
    C3DTVector r;

    if (dist == 0.0f) {
        return v;
    }

    r.cartesian.x = v.cartesian.x / dist;
    r.cartesian.y = v.cartesian.y / dist;
    r.cartesian.z = v.cartesian.z / dist;

    return r;
}

// Normal of 2 vectors (0 centered)
inline C3DTVector vectorNormal(const C3DTVector a, const C3DTVector b)
{
    return vectorNormalize(vectorCrossProduct(a, b));
}

// Normal of 2 vectors (centered on a 3rd point)
inline C3DTVector vectorNormalTri(const C3DTVector a, const C3DTVector b, const C3DTVector c)
{
    return vectorNormalize(vectorCrossProductTri(a, b, c));
}

// Multiplies a vector by a scalar
inline C3DTVector vectorScale(const float s, const C3DTVector a)
{
    C3DTVector	r;
    
    r.cartesian.x = a.cartesian.x * s;
    r.cartesian.y = a.cartesian.y * s;
    r.cartesian.z = a.cartesian.z * s;

    return r;
}

// Returns the cos() of the angle between 2 vectors
inline float vectorAngleCos(const C3DTVector a, const C3DTVector b)
{
    return vectorDotProduct(vectorNormalize(a), vectorNormalize(b));
}

// Transforms the vector by matrix m
C3DTVector vectorTransform(const C3DTVector v, const C3DTMatrix m)
{
    C3DTVector				r;
    
    r.cartesian.x = v.cartesian.x*m.flts[0] + v.cartesian.y*m.flts[4] + v.cartesian.z*m.flts[8] + m.flts[12];
    r.cartesian.y = v.cartesian.x*m.flts[1] + v.cartesian.y*m.flts[5] + v.cartesian.z*m.flts[9] + m.flts[13];
    r.cartesian.z = v.cartesian.x*m.flts[2] + v.cartesian.y*m.flts[6] + v.cartesian.z*m.flts[10] + m.flts[14];

    return r;
}

/******************************************
* C O N V E R S I O N   O P E R A T I O N S
*******************************************/

C3DTVector cartesianToSpherical(C3DTVector v)
{
    C3DTVector	r;

    r.radial.theta	= atan2f(v.cartesian.z, v.cartesian.x);
    r.radial.phi	= atan2f(v.cartesian.y, sqrtf(v.cartesian.x*v.cartesian.x + v.cartesian.z*v.cartesian.z));
    r.radial.r		= sqrtf(v.cartesian.x*v.cartesian.x + v.cartesian.y*v.cartesian.y + v.cartesian.z*v.cartesian.z);
    r.radial.w		= 0.0f;
    
    return r;
}

C3DTVector sphericalToCartesian(C3DTVector v) {

    C3DTVector r;

    r.cartesian.x	= v.radial.r * cosf(v.radial.phi) * cosf(v.radial.theta);
    r.cartesian.y	= v.radial.r * sinf(v.radial.phi);
    r.cartesian.z	= v.radial.r * cosf(v.radial.phi) * sinf(v.radial.theta);
    r.cartesian.w	= 0.0f;
    
    return r;
}


/*************************************
* M A T R I X   O P E R A T I O N S
*************************************/

// Returns the identity (i.e. standard) matrix
C3DTMatrix matrixIdentity(void)
{
    C3DTMatrix m = {
    {
        1.0f, 0.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 1.0f,
    }
    };
    
    return m;
}

// Return a matrix multiplication from right (mostly for transformation)
C3DTMatrix matrixMultiply(const C3DTMatrix m1, const C3DTMatrix m2)
{
    C3DTMatrix	m;

    m.flts[0]	= m1.flts[0]*m2.flts[0] + m1.flts[4]*m2.flts[1] + m1.flts[8]*m2.flts[2] + m1.flts[12]*m2.flts[3];
    m.flts[1]	= m1.flts[1]*m2.flts[0] + m1.flts[5]*m2.flts[1] + m1.flts[9]*m2.flts[2] + m1.flts[13]*m2.flts[3];
    m.flts[2]	= m1.flts[2]*m2.flts[0] + m1.flts[6]*m2.flts[1] + m1.flts[10]*m2.flts[2] + m1.flts[14]*m2.flts[3];
    m.flts[3]	= m1.flts[3]*m2.flts[0] + m1.flts[7]*m2.flts[1] + m1.flts[11]*m2.flts[2] + m1.flts[15]*m2.flts[3];
    m.flts[4]	= m1.flts[0]*m2.flts[4] + m1.flts[4]*m2.flts[5] + m1.flts[8]*m2.flts[6] + m1.flts[12]*m2.flts[7];
    m.flts[5]	= m1.flts[1]*m2.flts[4] + m1.flts[5]*m2.flts[5] + m1.flts[9]*m2.flts[6] + m1.flts[13]*m2.flts[7];
    m.flts[6]	= m1.flts[2]*m2.flts[4] + m1.flts[6]*m2.flts[5] + m1.flts[10]*m2.flts[6] + m1.flts[14]*m2.flts[7];
    m.flts[7]	= m1.flts[3]*m2.flts[4] + m1.flts[7]*m2.flts[5] + m1.flts[11]*m2.flts[6] + m1.flts[15]*m2.flts[7];
    m.flts[8]	= m1.flts[0]*m2.flts[8] + m1.flts[4]*m2.flts[9] + m1.flts[8]*m2.flts[10] + m1.flts[12]*m2.flts[11];
    m.flts[9]	= m1.flts[1]*m2.flts[8] + m1.flts[5]*m2.flts[9] + m1.flts[9]*m2.flts[10] + m1.flts[13]*m2.flts[11];
    m.flts[10]	= m1.flts[2]*m2.flts[8] + m1.flts[6]*m2.flts[9] + m1.flts[10]*m2.flts[10] + m1.flts[14]*m2.flts[11];
    m.flts[11]	= m1.flts[3]*m2.flts[8] + m1.flts[7]*m2.flts[9] + m1.flts[11]*m2.flts[10] + m1.flts[15]*m2.flts[11];
    m.flts[12]	= m1.flts[0]*m2.flts[12] + m1.flts[4]*m2.flts[13] + m1.flts[8]*m2.flts[14] + m1.flts[12]*m2.flts[15];
    m.flts[13]	= m1.flts[1]*m2.flts[12] + m1.flts[5]*m2.flts[13] + m1.flts[9]*m2.flts[14] + m1.flts[13]*m2.flts[15];
    m.flts[14]	= m1.flts[2]*m2.flts[12] + m1.flts[6]*m2.flts[13] + m1.flts[10]*m2.flts[14] + m1.flts[14]*m2.flts[15];
    m.flts[15]	= m1.flts[3]*m2.flts[12] + m1.flts[7]*m2.flts[13] + m1.flts[11]*m2.flts[14] + m1.flts[15]*m2.flts[15];
    
    return m;
}

// Operates a generic transform on a given matrix (m = n x m)
void matrixTransform(C3DTMatrix *m, const C3DTMatrix n)
{
    *m = matrixMultiply(*m, n);
}

// Return the transpose of a matrix
C3DTMatrix matrixTranspose(const C3DTMatrix m)
{
    C3DTMatrix	t;

    t.flts[0]	= m.flts[0];
    t.flts[1]	= m.flts[4];
    t.flts[2]	= m.flts[8];
    t.flts[3]	= m.flts[12];
    t.flts[4]	= m.flts[1];
    t.flts[5]	= m.flts[5];
    t.flts[6]	= m.flts[9];
    t.flts[7]	= m.flts[13];
    t.flts[8]	= m.flts[2];
    t.flts[9]	= m.flts[6];
    t.flts[10]	= m.flts[10];
    t.flts[11]	= m.flts[14];
    t.flts[12]	= m.flts[3];
    t.flts[13]	= m.flts[7];
    t.flts[14]	= m.flts[11];
    t.flts[15]	= m.flts[15];

    return t;
}

// Returns the inverse of a matrix: we only support matrix whose last row is (0, 0, 0, 1)
C3DTMatrix matrixInverse(const C3DTMatrix m)
{
    C3DTMatrix		r;

    register float	det;
    float			pos = 0.0f;
    float			neg = 0.0f;
    float			temp;

    temp =  m.flts[0] * m.flts[5] * m.flts[10];
    if(temp >= 0.0) pos += temp;
    else neg += temp;
    
    temp =  m.flts[1] * m.flts[6] * m.flts[8];
    if(temp >= 0.0) pos += temp;
    else neg += temp;
    
    temp =  m.flts[2] * m.flts[4] * m.flts[9];
    if(temp >= 0.0) pos += temp;
    else neg += temp;
    
    temp = -m.flts[2] * m.flts[5] * m.flts[8];
    if(temp >= 0.0) pos += temp;
    else neg += temp;
    
    temp = -m.flts[1] * m.flts[4] * m.flts[10];
    if(temp >= 0.0) pos += temp;
    else neg += temp;
    
    temp = -m.flts[0] * m.flts[6] * m.flts[9];
    if(temp >= 0.0) pos += temp;
    else neg += temp;
    
    det = pos + neg;
    
    temp = det / (pos - neg);
    
    if(fabs(temp) >= EPSILON) {
        det = 1.0f/det;
        r.flts[0]	=  (m.flts[5] * m.flts[10]	- m.flts[6] * m.flts[9]) * det;
        r.flts[4]	= -(m.flts[4] * m.flts[10]	- m.flts[6] * m.flts[8]) * det;
        r.flts[8]	=  (m.flts[4] * m.flts[9]	- m.flts[5] * m.flts[8]) * det;
        r.flts[1]	= -(m.flts[1] * m.flts[10]	- m.flts[2] * m.flts[9]) * det;
        r.flts[5]	=  (m.flts[0] * m.flts[10]	- m.flts[2] * m.flts[9]) * det;
        r.flts[9]	= -(m.flts[0] * m.flts[9]	- m.flts[1] * m.flts[8]) * det;
        r.flts[2]	=  (m.flts[1] * m.flts[6]	- m.flts[2] * m.flts[5]) * det;
        r.flts[6]	= -(m.flts[0] * m.flts[6]	- m.flts[2] * m.flts[4]) * det;
        r.flts[10]	=  (m.flts[0] * m.flts[5]	- m.flts[1] * m.flts[4]) * det;
        
        r.flts[12]	= -(m.flts[12] * r.flts[0]	+ m.flts[13] * r.flts[4]	+ m.flts[14] * r.flts[8]);
        r.flts[13]	= -(m.flts[12] * r.flts[1]	+ m.flts[13] * r.flts[5]	+ m.flts[14] * r.flts[9]);
        r.flts[14]	= -(m.flts[12] * r.flts[2]	+ m.flts[13] * r.flts[6]	+ m.flts[14] * r.flts[10]);
        
        r.flts[3]	= 0.0f;
        r.flts[7]	= 0.0f;
        r.flts[11]	= 0.0f;
        r.flts[15]	= 1.0f;
        
        return r;
    }
    else {
        return m;
    }
}


// Returns a matrix to operate translations
static C3DTMatrix matrixForTranslation(const float dx, const float dy, const float dz)
{
    C3DTMatrix	m = matrixIdentity();

    m.flts[3] = dx;
    m.flts[7] = dy;
    m.flts[11] = dz;

    return m;
}

// Returns a matrix to operate non-uniform scaling
static C3DTMatrix matrixForScaling(const float sx, const float sy, const float sz)
{
    C3DTMatrix	m = matrixIdentity();

    m.flts[3] = sx;
    m.flts[5] = sy;
    m.flts[10] = sz;

    return m;
}

// Returns a matrix to operate uniform scaling
static C3DTMatrix matrixForUniformScaling(const float s)
{
    return matrixForScaling(s, s, s);
}

// Returns a matrix to operate rotation
static C3DTMatrix matrixForRotation(const float ax, const float ay, const float az)
{
    C3DTMatrix	r = matrixIdentity();
    float		s;
    float		c;

    if (fabs(ax) > EPSILON)
    {
        C3DTMatrix m = matrixIdentity();

        s = sinf(ax);
        c = cosf(ax);

        m.flts[5] = c;
        m.flts[6] = s;
        m.flts[9] = -s;
        m.flts[10] = c;

        matrixTransform(&r, m);
    }

    if (fabs(ay) > EPSILON)
    {
        C3DTMatrix	m = matrixIdentity();

        s = sinf(ay);
        c = cosf(ay);

        m.flts[0] = c;
        m.flts[2] = s;
        m.flts[8] = -s;
        m.flts[10] = c;

        matrixTransform(&r, m);
    }

    if (fabs(az) > EPSILON)
    {
        C3DTMatrix	m = matrixIdentity();

        s = sinf(az);
        c = cosf(az);

        m.flts[0] = c;
        m.flts[1] = s;
        m.flts[4] = -s;
        m.flts[5] = c;

        matrixTransform(&r, m);
    }

    return r;
}

// Operates a translation on a matrix
void matrixTranslate(C3DTMatrix *m, const float dx, const float dy, const float dz)
{
    matrixTransform(m, matrixForTranslation(dx,dy,dz));
}

// Operates a scaling on a matrix non-uniformly
void matrixScale(C3DTMatrix *m, const float sx, const float sy, const float sz)
{
    matrixTransform(m, matrixForScaling(sx, sy, sz));
}

// Operates a scaling on a matrix uniformly
void matrixUniformScale(C3DTMatrix *m, const float s)
{
    matrixTransform(m, matrixForUniformScaling(s));
}

// Operates a rotation on a matrix
void matrixRotate(C3DTMatrix *m, const float ax, const float ay, const float az)
{
    matrixTransform(m, matrixForRotation(ax,ay,az));
}

/*******************************************
*  Q U A T E R N I O N   O P E R A T I O N S
********************************************/

inline _C3DTQuaternion quaternionIdentity(void)
{
    _C3DTQuaternion q = {
    {
        1.0f, 0.0f, 0.0f, 0.0f
    }
    };

    return q;
}

inline _C3DTQuaternion quaternionInverse(_C3DTQuaternion q)
{
    _C3DTQuaternion	r;

    r.cartesian.x = -q.cartesian.x;
    r.cartesian.y = -q.cartesian.y;
    r.cartesian.z = -q.cartesian.z;
    r.cartesian.w = q.cartesian.w;

    return r;
}

float quaternionLength(_C3DTQuaternion q)
{
    return sqrtf( q.cartesian.x*q.cartesian.x + q.cartesian.y*q.cartesian.y + q.cartesian.z*q.cartesian.z + q.cartesian.w*q.cartesian.w );
}

// Normalizing of a quaternion
_C3DTQuaternion quaternionNormalize(_C3DTQuaternion q)
{
    float dist = quaternionLength(q);
    _C3DTQuaternion	r;

    if (dist == 0.0f) {
        return q;
    }

    r.cartesian.x = q.cartesian.x / dist;
    r.cartesian.y = q.cartesian.y / dist;
    r.cartesian.z = q.cartesian.z / dist;
    r.cartesian.w = q.cartesian.w / dist;

    return r;
}

inline _C3DTQuaternion quaternionMultiply(_C3DTQuaternion a, _C3DTQuaternion b) {
    _C3DTQuaternion	q;

    q.cartesian.x = a.cartesian.w*b.cartesian.x + a.cartesian.x*b.cartesian.w + a.cartesian.y*b.cartesian.z - a.cartesian.z*b.cartesian.y;
    q.cartesian.y = a.cartesian.w*b.cartesian.y + a.cartesian.y*b.cartesian.w + a.cartesian.z*b.cartesian.x - a.cartesian.x*b.cartesian.z;
    q.cartesian.z = a.cartesian.w*b.cartesian.z + a.cartesian.z*b.cartesian.w + a.cartesian.x*b.cartesian.y - a.cartesian.y*b.cartesian.x;
    q.cartesian.w = a.cartesian.w*b.cartesian.w - a.cartesian.x*b.cartesian.x - a.cartesian.y*b.cartesian.y - a.cartesian.z*b.cartesian.z;

    return q;
}

_C3DTQuaternion quaternionFromAxisAngle(C3DTVector v) {

    v = vectorNormalize(v);

    _C3DTQuaternion	q;
    float sinHalfAngle = sinf(v.cartesian.w / 2.0f);

    q.cartesian.x = v.cartesian.x * sinHalfAngle;
    q.cartesian.y = v.cartesian.y * sinHalfAngle;
    q.cartesian.z = v.cartesian.z * sinHalfAngle;
    q.cartesian.w = cosf(v.cartesian.w / 2.0f);

    return q;
}

C3DTVector quaternionToAxisAngle(_C3DTQuaternion q)
{
    float lenOfVector = vectorLength(q);
    C3DTVector r;

    if(lenOfVector < EPSILON)
    {
        // Arbitrary vector, no rotation
        r.cartesian.x = 1.0f;
        r.cartesian.y = 0.0f;
        r.cartesian.z = 0.0f;
        r.cartesian.w = 0.0f;
    }
    else
    {
        float invLen = 1.0f / lenOfVector;

        r.cartesian.x = q.cartesian.x * invLen;
        r.cartesian.y = q.cartesian.y * invLen;
        r.cartesian.z = q.cartesian.z * invLen;
        r.cartesian.w = 2.0f * acosf(q.cartesian.w);
    }

    return r;
}

C3DTVector quaternionToDirectionVector(_C3DTQuaternion q)
{
    C3DTVector	v;
    
    q = quaternionNormalize(q);

    v.cartesian.x = 2.0f * (q.cartesian.x*q.cartesian.z - q.cartesian.w*q.cartesian.y);
    v.cartesian.y = 2.0f * (q.cartesian.y*q.cartesian.z + q.cartesian.w*q.cartesian.x);
    v.cartesian.z = 1.0f - 2.0f * (q.cartesian.x*q.cartesian.x + q.cartesian.y*q.cartesian.y);
    v.cartesian.w = 0.0f;
    
    return v;
}

C3DTMatrix quaternionToMatrix(_C3DTQuaternion q)
{
    C3DTMatrix	m;
    
    q = quaternionNormalize(q);
    
    float		xx	= q.cartesian.x * q.cartesian.x;
    float		yy	= q.cartesian.y * q.cartesian.y;
    float		zz	= q.cartesian.z * q.cartesian.z;

    m.flts[0]	= 1.0f - 2.0f * (yy + zz);
    m.flts[1]	= 2.0f * (q.cartesian.x*q.cartesian.y + q.cartesian.w*q.cartesian.z);
    m.flts[2]	= 2.0f * (q.cartesian.x*q.cartesian.z - q.cartesian.w*q.cartesian.y);
    m.flts[3]	= 0.0f;

    m.flts[4]	= 2.0f * (q.cartesian.x*q.cartesian.y - q.cartesian.w*q.cartesian.z);
    m.flts[5]	= 1.0f - 2.0f * (xx + zz);
    m.flts[6]	= 2.0f * (q.cartesian.y *q.cartesian.z + q.cartesian.w*q.cartesian.x);
    m.flts[7]	= 0.0f;

    m.flts[8]	= 2.0f * (q.cartesian.x*q.cartesian.z + q.cartesian.w*q.cartesian.y);
    m.flts[9]	= 2.0f * (q.cartesian.y*q.cartesian.z - q.cartesian.w*q.cartesian.x);
    m.flts[10]	= 1.0f - 2.0f * (xx + yy);
    m.flts[11]	= 0.0f;

    m.flts[12]	= 0.0f;
    m.flts[13]	= 0.0f;
    m.flts[14]	= 0.0f;
    m.flts[15]	= 1.0f;

    return m;
}

C3DTMatrix quaternionToInvertedMatrix(_C3DTQuaternion q)
{
    C3DTMatrix	m;

    q = quaternionNormalize(q);

    float		xx = q.cartesian.x * q.cartesian.x;
    float		yy = q.cartesian.y * q.cartesian.y;
    float		zz = q.cartesian.z * q.cartesian.z;

    m.flts[0]	= -(1.0f - 2.0f * (yy + zz));
    m.flts[1]	= -(2.0f * (q.cartesian.x*q.cartesian.y + q.cartesian.w*q.cartesian.z));
    m.flts[2]	= -(2.0f * (q.cartesian.x*q.cartesian.z - q.cartesian.w*q.cartesian.y));
    m.flts[3]	= 0.0f;

    m.flts[4]	= 2.0f * (q.cartesian.x*q.cartesian.y - q.cartesian.w*q.cartesian.z);
    m.flts[5]	= 1.0f - 2.0f * (xx + zz);
    m.flts[6]	= 2.0f * (q.cartesian.y*q.cartesian.z + q.cartesian.w*q.cartesian.x);
    m.flts[7]	= 0.0f;

    m.flts[8]	= 2.0f * (q.cartesian.x*q.cartesian.z + q.cartesian.w*q.cartesian.y);
    m.flts[9]	= 2.0f * (q.cartesian.y*q.cartesian.z - q.cartesian.w*q.cartesian.x);
    m.flts[10]	= 1.0f - 2.0f * (xx + yy);
    m.flts[11]	= 0.0f;

    m.flts[12]	= 0.0f;
    m.flts[13]	= 0.0f;
    m.flts[14]	= 0.0f;
    m.flts[15]	= 1.0f;

    return m;
}


// Normalizing of a plane
inline C3DTPlane planeNormalize(C3DTPlane p)
{
    float dist = vectorLength(p);
    C3DTPlane	r;

    if (dist == 0.0f) {
        return p;
    }

    r.cartesian.x = p.cartesian.x / dist;
    r.cartesian.y = p.cartesian.y / dist;
    r.cartesian.z = p.cartesian.z / dist;
    r.cartesian.w = p.cartesian.w / dist;

    return r;
}

/***********************************
* N O I S E   O P E R A T I O N S
***********************************/

float	*cachedNoise	= NULL;

float _MANGLEDnoise(int x, int octave)
{
    int sample	= octave & 0x3;
    int n		= (x << 13) ^ x;

    switch (sample) {
        case 0:
            return (1.0f - (float)((n * (n * n * 15731 + 789221) + 1376312589) & 0x7FFFFFFF) / 1073741824.0f);
        case 1:
            return (1.0f - (float)((n * (n * n * 12497 + 604727) + 1345679039) & 0x7FFFFFFF) / 1073741824.0f);
        case 2:
            return (1.0f - (float)((n * (n * n * 19087 + 659047) + 1345679627) & 0x7FFFFFFF) / 1073741824.0f);
    }

    return (1.0f - (float)((n * (n * n * 16267 + 694541) + 1345679501) & 0x7FFFFFFF) / 1073741824.0f);
}

float noise(int x, int y, int octave) {
	
    return cachedNoise[((octave & 3) << 12) + ((x + y * 31) & 0x0FFF)];
}

float noise3(int x, int y, int z, int octave)
{
    return cachedNoise[((octave & 3) << 12) + ((x + y * 31 + z * 63) & 0x0FFF)];
}

float interpolate(float a, float b, float d) {

    float	f = (1.0f - cosf(d * (float)M_PI)) * 0.5f;

    return a + f * (b - a);
}

float interpolatedNoise(float x, float y, float maxx, float maxy, int octave)
{
    register int	intx	= (int)x;
    register int	inty	= (int)y;
    register int	nextx	= (intx == (int)maxx ? 0 : intx+1);
    register int	nexty	= (inty == (int)maxy ? 0 : inty+1);
    register float	fracx	= x - (float)intx;
    register float	fracy	= y - (float)inty;
	register float	i1		= interpolate(noise(intx, inty, octave), noise(nextx, inty, octave), fracx);
	register float	i2		= interpolate(noise(intx, nexty, octave), noise(nextx, nexty, octave), fracx);

    return interpolate(i1, i2, fracy);
}

float interpolatedNoise3(float x, float y, float z, float maxx, float maxy, float maxz, int octave)
{
    register int	intx	= (int)x;
    register int	inty	= (int)y;
    register int	intz	= (int)z;
    register int	nextx	= (intx == (int)maxx ? 0 : intx+1);
    register int	nexty	= (inty == (int)maxy ? 0 : inty+1);
    register int	nextz	= (intz == (int)maxz ? 0 : intz+1);
    register float	fracx	= x - (float)intx;
    register float	fracy	= y - (float)inty;
    register float	fracz	= z - (float)intz;
    register float	i1		= interpolate(noise3(intx, inty, intz, octave), noise3(nextx, inty, intz, octave), fracx);
    register float	i2		= interpolate(noise3(intx, nexty, intz, octave), noise3(nextx, nexty, intz, octave), fracx);
    register float	i3		= interpolate(noise3(intx, inty, nextz, octave), noise3(nextx, inty, nextz, octave), fracx);
    register float	i4		= interpolate(noise3(intx, nexty, nextz, octave), noise3(nextx, nexty, nextz, octave), fracx);
    register float	i5		= interpolate(i1, i2, fracy);
    register float	i6		= interpolate(i3, i4, fracy);

    return interpolate(i5, i6, fracz);
}

void initNoiseBuffer( void )
{
    register float	*pCachedNoise;
    register int	octave, i;
    
    cachedNoise = (float *)calloc(4 * 4096, sizeof(float));
    pCachedNoise = cachedNoise;

    for (octave = 0; octave < 4; octave++)
        for (i = 0; i < 4096; i++)
            *pCachedNoise++ = _MANGLEDnoise(i, octave);
}

float perlinNoise2d(int x, int y, int maxx, int maxy, float period, float persistence, int octaves)
{
    float	sum = 0;
    float	freq = 1.0f / period;
    float	amplitude	= persistence;
    int		i;
    
    for (i = 0; i < octaves; i++)
    {
        sum			+= amplitude * interpolatedNoise((float)x * freq, (float)y * freq,
                                               (float)maxx * freq, (float)maxy * freq, i);
        amplitude	*= persistence;
        freq		*= 2;
    }

    return trim(sum / persistence * 0.5f + 0.5f, 0.0f, 1.0f );
}

float perlinNoise3d(int x, int y, int z, int maxx, int maxy, int maxz, float period, float persistence, int octaves)
{
    float	sum			= 0;
    float	freq		= 1.0f / period;
    float	amplitude	= persistence;
    int		i;

    for (i = 0; i < octaves; i++)
    {
        sum += amplitude * interpolatedNoise3((float)x * freq, (float)y * freq, (float)z * freq, (float)maxx * freq, (float)maxy * freq, (float)maxz * freq, i);
        amplitude	*= persistence;
        freq *= 2.f;
    }

    return trim(sum / persistence * 0.5f + 0.5f, 0.0f, 1.0f);
}


/***********************************
* O T H E R   O P E R A T I O N S
* Practical application of all above
***********************************/

// Define the view frustum for culling
C3DTFrustum viewFrustum(const C3DTMatrix projection, const C3DTMatrix model)
{
    C3DTMatrix	clip;
    C3DTFrustum	r;

    clip = matrixMultiply(projection, model);

    // Right plane
    r.planes[0].cartesian.x = clip.flts[3] - clip.flts[0];
    r.planes[0].cartesian.y = clip.flts[7] - clip.flts[4];
    r.planes[0].cartesian.z = clip.flts[11] - clip.flts[8];
    r.planes[0].cartesian.w = clip.flts[15] - clip.flts[12];
    r.planes[0] = vectorNormalize(r.planes[0]);

    // Left plane
    r.planes[1].cartesian.x = clip.flts[3] + clip.flts[0];
    r.planes[1].cartesian.y = clip.flts[7] + clip.flts[4];
    r.planes[1].cartesian.z = clip.flts[11] + clip.flts[8];
    r.planes[1].cartesian.w = clip.flts[15] + clip.flts[12];
    r.planes[1] = vectorNormalize(r.planes[1]);

    // Bottom plane
    r.planes[2].cartesian.x = clip.flts[3] + clip.flts[1];
    r.planes[2].cartesian.y = clip.flts[7] + clip.flts[5];
    r.planes[2].cartesian.z = clip.flts[11] + clip.flts[9];
    r.planes[2].cartesian.w = clip.flts[15] + clip.flts[13];
    r.planes[2] = vectorNormalize(r.planes[2]);

    // Top plane
    r.planes[3].cartesian.x = clip.flts[3] - clip.flts[1];
    r.planes[3].cartesian.y = clip.flts[7] - clip.flts[5];
    r.planes[3].cartesian.z = clip.flts[11] - clip.flts[9];
    r.planes[3].cartesian.w = clip.flts[15] - clip.flts[13];
    r.planes[3] = vectorNormalize(r.planes[3]);

    // Far plane
    r.planes[4].cartesian.x = clip.flts[3] - clip.flts[2];
    r.planes[4].cartesian.y = clip.flts[7] - clip.flts[6];
    r.planes[4].cartesian.z = clip.flts[11] - clip.flts[10];
    r.planes[4].cartesian.w = clip.flts[15] - clip.flts[14];
    r.planes[4] = vectorNormalize(r.planes[4]);

    // Near plane
    r.planes[5].cartesian.x = clip.flts[3] + clip.flts[2];
    r.planes[5].cartesian.y = clip.flts[7] + clip.flts[6];
    r.planes[5].cartesian.z = clip.flts[11] + clip.flts[10];
    r.planes[5].cartesian.w = clip.flts[15] + clip.flts[14];
    r.planes[5] = vectorNormalize(r.planes[5]);

    return r;
}

// Returns if a point is included inside a certain distance from a frustum
// if dist is negative, that means that the point is allowed to stay OUTSIDE the frustum by at most dist
// if dist is 0.0, then the point MUST be included in the frustum itself
// if dist is positive, the point must be INSIDE the frustum by at least dist
int pointNearFrustum(C3DTFrustum f, C3DTVector p, float dist)
{
    int		ii;

    for( ii = 0; ii < 6; ii++ )
        if( f.planes[ii].cartesian.x * p.cartesian.x + f.planes[ii].cartesian.y * p.cartesian.y +
            f.planes[ii].cartesian.z * p.cartesian.z + f.planes[ii].cartesian.w < dist )
            return NOT_IN_FRUSTUM;

    return ALL_IN_FRUSTUM;
}

// Tells if a sphere has at least a part in the frustum
int isSphereInFrustum (C3DTFrustum f, _C3DTSpheroid s)
{
    return pointNearFrustum(f, s.center, -s.radius);
}

// Variation of the above, but returns a distance useful for LevelOfDetail calculations
// and an int reporting flags of the planes it's in
int sphereDistanceFromFrustum(C3DTFrustum f, _C3DTSpheroid s, float *dist)
{
    int		ii, flag;
    float	d;

    for( ii = 0, flag = 0; ii < 6; ii++ )
    {
        d = f.planes[ii].cartesian.x * s.center.cartesian.x + f.planes[ii].cartesian.y * s.center.cartesian.y +
        f.planes[ii].cartesian.z * s.center.cartesian.z + f.planes[ii].cartesian.w;
        if( d < -s.radius ) {
            *dist = 0.0f;
            return NOT_IN_FRUSTUM;
        }

        if( d > s.radius )
            flag |= 1 << ii;
    }

    *dist = d + s.radius;

    return flag;
}

// Gets a sphere that completely surrounds a bounding box
_C3DTSpheroid sphereFromBounds(_C3DTBounds b)
{
    _C3DTSpheroid	s;

    // Center is the middle point between the 2 bounds coordinate
    s.center.cartesian.x = (b.topRightFar.cartesian.x + b.bottomLeftNear.cartesian.x) / 2.0f;
    s.center.cartesian.y = (b.topRightFar.cartesian.y + b.bottomLeftNear.cartesian.y) / 2.0f;
    s.center.cartesian.z = (b.topRightFar.cartesian.z + b.bottomLeftNear.cartesian.z) / 2.0f;

    s.radius = vectorLength( vectorSubtract(b.topRightFar, s.center));

    return s;
}

_C3DTBounds unionOfBounds(_C3DTBounds a, _C3DTBounds b)
{
	_C3DTBounds resultBounds;
	// C3DTVector	bottomLeftNear;
	// C3DTVector	topRightFar;
	resultBounds.bottomLeftNear.cartesian.x = (a.bottomLeftNear.cartesian.x < b.bottomLeftNear.cartesian.x) ? a.bottomLeftNear.cartesian.x : b.bottomLeftNear.cartesian.x;
	resultBounds.bottomLeftNear.cartesian.y = (a.bottomLeftNear.cartesian.y < b.bottomLeftNear.cartesian.y) ? a.bottomLeftNear.cartesian.y : b.bottomLeftNear.cartesian.y;
	resultBounds.topRightFar.cartesian.x = (a.topRightFar.cartesian.x > b.topRightFar.cartesian.x) ? a.topRightFar.cartesian.x : b.topRightFar.cartesian.x;
	resultBounds.topRightFar.cartesian.y = (a.topRightFar.cartesian.y > b.topRightFar.cartesian.y) ? a.topRightFar.cartesian.y : b.topRightFar.cartesian.y;
	
	return resultBounds;
}
