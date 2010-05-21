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


/*************************************
* V E C T O R   O P E R A T I O N S
*************************************/

// adds 2 vectors
inline _C3DTVector vectorAdd(const _C3DTVector a, const _C3DTVector b)
{
    _C3DTVector	r;

    r.x = a.x + b.x;
    r.y = a.y + b.y;
    r.z = a.z + b.z;
    
    return r;
}

// subtracts 2 vectors
inline _C3DTVector vectorSubtract(const _C3DTVector a, const _C3DTVector b)
{
    _C3DTVector	r;

    r.x = a.x - b.x;
    r.y = a.y - b.y;
    r.z = a.z - b.z;
    
    return r;
}

// Dot product of 2 vectors
inline float vectorDotProduct(const _C3DTVector a, const _C3DTVector b)
{
    return (a.x*b.x + a.y*b.y + a.z*b.z);
}

// Returns vector product a x b
inline _C3DTVector vectorCrossProduct(const _C3DTVector a, const _C3DTVector b)
{
    _C3DTVector	r;

    r.x = a.y*b.z - b.y*a.z;
    r.y = a.z*b.x - b.z*a.x;
    r.z = a.x*b.y - b.x*a.y;

    return r;
}

// Returns (b-a) x (c-a)
inline _C3DTVector vectorCrossProductTri(const _C3DTVector a, const _C3DTVector b, const _C3DTVector c)
{
    return vectorCrossProduct(vectorSubtract(b,a), vectorSubtract(c,a));
}


// Lenght of a vector
inline float vectorLength(const _C3DTVector v)
{
    return (float)sqrt(v.flts[0]*v.flts[0] + v.flts[1]*v.flts[1] + v.flts[2]*v.flts[2]);
}

// Normalizing of a vector
inline _C3DTVector vectorNormalize(_C3DTVector v)
{
    float		dist = vectorLength(v);
    _C3DTVector	r;

    if (dist == 0.0f) {
        return v;
    }

    r.x = v.x / dist;
    r.y = v.y / dist;
    r.z = v.z / dist;

    return r;
}

// Normal of 2 vectors (0 centered)
inline _C3DTVector vectorNormal(const _C3DTVector a, const _C3DTVector b)
{
    return vectorNormalize(vectorCrossProduct(a, b));
}

// Normal of 2 vectors (centered on a 3rd point)
inline _C3DTVector vectorNormalTri(const _C3DTVector a, const _C3DTVector b, const _C3DTVector c)
{
    return vectorNormalize(vectorCrossProductTri(a, b, c));
}

// Multiplies a vector by a scalar
inline _C3DTVector vectorScale(const float s, const _C3DTVector a)
{
    _C3DTVector	r;
    
    r.x = a.x * s;
    r.y = a.y * s;
    r.z = a.z * s;

    return r;
}

// Returns the cos() of the angle between 2 vectors
inline float vectorAngleCos(const _C3DTVector a, const _C3DTVector b)
{
    return vectorDotProduct(vectorNormalize(a), vectorNormalize(b));
}

// Transforms the vector by matrix m
_C3DTVector vectorTransform(const _C3DTVector v, const _C3DTMatrix m)
{
    _C3DTVector				r;
    
    r.x = v.x*m.flts[0] + v.y*m.flts[4] + v.z*m.flts[8] + m.flts[12];
    r.y = v.x*m.flts[1] + v.y*m.flts[5] + v.z*m.flts[9] + m.flts[13];
    r.z = v.x*m.flts[2] + v.y*m.flts[6] + v.z*m.flts[10] + m.flts[14];

    return r;
}

/******************************************
* C O N V E R S I O N   O P E R A T I O N S
*******************************************/

inline _C3DTVector cartesianToSpherical(_C3DTVector v)
{
    _C3DTVector	r;

    r.theta	= atan2(v.z, v.x);
    r.phi	= atan2(v.y, sqrt(v.x*v.x + v.z*v.z));
    r.r		= sqrt(v.x*v.x + v.y*v.y + v.z*v.z);
    r.w		= 0.0;
    
    return r;
}

inline _C3DTVector sphericalToCartesian(_C3DTVector v)
{
    _C3DTVector	r;

    r.x	= v.r * cos(v.phi) * cos(v.theta);
    r.y	= v.r * sin(v.phi);
    r.z	= v.r * cos(v.phi) * sin(v.theta);
    r.w	= 0.0;
    
    return r;
}


/*************************************
* M A T R I X   O P E R A T I O N S
*************************************/

// Returns the identity (i.e. standard) matrix
inline _C3DTMatrix matrixIdentity(void)
{
    _C3DTMatrix	m = {
    {
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
    }
    };
    
    return m;
}

// Return a matrix multiplication from right (mostly for transformation)
_C3DTMatrix matrixMultiply(const _C3DTMatrix m1, const _C3DTMatrix m2)
{
    _C3DTMatrix	m;

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
void matrixTransform(_C3DTMatrix *m, const _C3DTMatrix n)
{
    *m = matrixMultiply(*m, n);
}

// Return the transpose of a matrix
_C3DTMatrix matrixTranspose(const _C3DTMatrix m)
{
    _C3DTMatrix	t;

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
_C3DTMatrix matrixInverse(const _C3DTMatrix m)
{
    _C3DTMatrix		r;

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
static _C3DTMatrix matrixForTranslation(const float dx, const float dy, const float dz)
{
    _C3DTMatrix	m = matrixIdentity();

    m.flts[3] = dx;
    m.flts[7] = dy;
    m.flts[11] = dz;

    return m;
}

// Returns a matrix to operate non-uniform scaling
static _C3DTMatrix matrixForScaling(const float sx, const float sy, const float sz)
{
    _C3DTMatrix	m = matrixIdentity();

    m.flts[3] = sx;
    m.flts[5] = sy;
    m.flts[10] = sz;

    return m;
}

// Returns a matrix to operate uniform scaling
static _C3DTMatrix matrixForUniformScaling(const float s)
{
    return matrixForScaling(s, s, s);
}

// Returns a matrix to operate rotation
static _C3DTMatrix matrixForRotation(const float ax, const float ay, const float az)
{
    _C3DTMatrix	r = matrixIdentity();
    float		s;
    float		c;

    if (fabs(ax) > EPSILON)
    {
        _C3DTMatrix	m = matrixIdentity();

        s = sin(ax);
        c = cos(ax);

        m.flts[5] = c;
        m.flts[6] = s;
        m.flts[9] = -s;
        m.flts[10] = c;

        matrixTransform(&r, m);
    }

    if (fabs(ay) > EPSILON)
    {
        _C3DTMatrix	m = matrixIdentity();

        s = sin(ay);
        c = cos(ay);

        m.flts[0] = c;
        m.flts[2] = s;
        m.flts[8] = -s;
        m.flts[10] = c;

        matrixTransform(&r, m);
    }

    if (fabs(az) > EPSILON)
    {
        _C3DTMatrix	m = matrixIdentity();

        s = sin(az);
        c = cos(az);

        m.flts[0] = c;
        m.flts[1] = s;
        m.flts[4] = -s;
        m.flts[5] = c;

        matrixTransform(&r, m);
    }

    return r;
}

// Operates a translation on a matrix
void matrixTranslate(_C3DTMatrix *m, const float dx, const float dy, const float dz)
{
    matrixTransform(m, matrixForTranslation(dx,dy,dz));
}

// Operates a scaling on a matrix non-uniformly
void matrixScale(_C3DTMatrix *m, const float sx, const float sy, const float sz)
{
    matrixTransform(m, matrixForScaling(sx, sy, sz));
}

// Operates a scaling on a matrix uniformly
void matrixUniformScale(_C3DTMatrix *m, const float s)
{
    matrixTransform(m, matrixForUniformScaling(s));
}

// Operates a rotation on a matrix
void matrixRotate(_C3DTMatrix *m, const float ax, const float ay, const float az)
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
        1.0, 0.0, 0.0, 0.0
    }
    };

    return q;
}

inline _C3DTQuaternion quaternionInverse(_C3DTQuaternion q)
{
    _C3DTQuaternion	r;

    r.x = -q.x;
    r.y = -q.y;
    r.z = -q.z;
    r.w = q.w;

    return r;
}

inline float quaternionLength(_C3DTQuaternion q)
{
    return sqrt(q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w);
}

// Normalizing of a quaternion
inline _C3DTQuaternion quaternionNormalize(_C3DTQuaternion q)
{
    float			dist = quaternionLength(q);
    _C3DTQuaternion	r;

    if (dist == 0.0f) {
        return q;
    }

    r.x = q.x / dist;
    r.y = q.y / dist;
    r.z = q.z / dist;
    r.w = q.w / dist;

    return r;
}

inline _C3DTQuaternion quaternionMultiply(_C3DTQuaternion a, _C3DTQuaternion b)
{
    _C3DTQuaternion	q;

    q.x = a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y;
    q.y = a.w*b.y + a.y*b.w + a.z*b.x - a.x*b.z;
    q.z = a.w*b.z + a.z*b.w + a.x*b.y - a.y*b.x;
    q.w = a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z;

    return q;
}

_C3DTQuaternion quaternionFromAxisAngle(_C3DTVector v)
{
    v = vectorNormalize(v);

    _C3DTQuaternion	q;
    float			sinHalfAngle = sin(v.w / 2.0f);


    q.x = v.x * sinHalfAngle;
    q.y = v.y * sinHalfAngle;
    q.z = v.z * sinHalfAngle;
    q.w = cos(v.w / 2.0f);

    return q;
}

_C3DTVector quaternionToAxisAngle(_C3DTQuaternion q)
{
    float		lenOfVector = vectorLength(q);
    _C3DTVector	r;

    if(lenOfVector < EPSILON)
    {
        // Arbitrary vector, no rotation
        r.x = 1.0f;
        r.y = 0.0f;
        r.z = 0.0f;
        r.w = 0.0f;
    }
    else
    {
        float invLen = 1.0 / lenOfVector;

        r.x = q.x * invLen;
        r.y = q.y * invLen;
        r.z = q.z * invLen;
        r.w = 2.0f * acos(q.w);
    }

    return r;
}

_C3DTVector quaternionToDirectionVector(_C3DTQuaternion q)
{
    _C3DTVector	v;
    
    q = quaternionNormalize(q);

    v.x = 2.0f * (q.x*q.z - q.w*q.y);
    v.y = 2.0f * (q.y*q.z + q.w*q.x);
    v.z = 1.0f - 2.0f * (q.x*q.x + q.y*q.y);
    v.w = 0.0;
    
    return v;
}

_C3DTMatrix quaternionToMatrix(_C3DTQuaternion q)
{
    _C3DTMatrix	m;
    
    q = quaternionNormalize(q);
    
    float		xx	= q.x * q.x;
    float		yy	= q.y * q.y;
    float		zz	= q.z * q.z;

    m.flts[0]	= 1.0f - 2.0f * (yy + zz);
    m.flts[1]	= 2.0f * (q.x*q.y + q.w*q.z);
    m.flts[2]	= 2.0f * (q.x*q.z - q.w*q.y);
    m.flts[3]	= 0.0f;

    m.flts[4]	= 2.0f * (q.x*q.y - q.w*q.z);
    m.flts[5]	= 1.0f - 2.0f * (xx + zz);
    m.flts[6]	= 2.0f * (q.y *q.z + q.w*q.x);
    m.flts[7]	= 0.0f;

    m.flts[8]	= 2.0f * (q.x*q.z + q.w*q.y);
    m.flts[9]	= 2.0f * (q.y*q.z - q.w*q.x);
    m.flts[10]	= 1.0f - 2.0f * (xx + yy);
    m.flts[11]	= 0.0f;

    m.flts[12]	= 0.0f;
    m.flts[13]	= 0.0f;
    m.flts[14]	= 0.0f;
    m.flts[15]	= 1.0f;

    return m;
}

_C3DTMatrix quaternionToInvertedMatrix(_C3DTQuaternion q)
{
    _C3DTMatrix	m;

    q = quaternionNormalize(q);

    float		xx = q.x * q.x;
    float		yy = q.y * q.y;
    float		zz = q.z * q.z;

    m.flts[0]	= -(1.0f - 2.0f * (yy + zz));
    m.flts[1]	= -(2.0f * (q.x*q.y + q.w*q.z));
    m.flts[2]	= -(2.0f * (q.x*q.z - q.w*q.y));
    m.flts[3]	= 0.0f;

    m.flts[4]	= 2.0f * (q.x*q.y - q.w*q.z);
    m.flts[5]	= 1.0f - 2.0f * (xx + zz);
    m.flts[6]	= 2.0f * (q.y*q.z + q.w*q.x);
    m.flts[7]	= 0.0f;

    m.flts[8]	= 2.0f * (q.x*q.z + q.w*q.y);
    m.flts[9]	= 2.0f * (q.y*q.z - q.w*q.x);
    m.flts[10]	= 1.0f - 2.0f * (xx + yy);
    m.flts[11]	= 0.0f;

    m.flts[12]	= 0.0f;
    m.flts[13]	= 0.0f;
    m.flts[14]	= 0.0f;
    m.flts[15]	= 1.0f;

    return m;
}


// Normalizing of a plane
inline _C3DTPlane planeNormalize(_C3DTPlane p)
{
    float		dist = vectorLength(p);
    _C3DTPlane	r;

    if (dist == 0.0f) {
        return p;
    }

    r.x = p.x / dist;
    r.y = p.y / dist;
    r.z = p.z / dist;
    r.w = p.w / dist;

    return r;
}

/***********************************
* N O I S E   O P E R A T I O N S
***********************************/

float	*cachedNoise	= NULL;

float _noise(int x, int octave)
{
    int sample	= octave & 0x3;
    int n		= (x << 13) ^ x;

    switch (sample) {
        case 0:
            return (1.0 - (float)((n * (n * n * 15731 + 789221) + 1376312589) & 0x7FFFFFFF) / 1073741824.0);
        case 1:
            return (1.0 - (float)((n * (n * n * 12497 + 604727) + 1345679039) & 0x7FFFFFFF) / 1073741824.0);
        case 2:
            return (1.0 - (float)((n * (n * n * 19087 + 659047) + 1345679627) & 0x7FFFFFFF) / 1073741824.0);
    }

    return (1.0 - (float)((n * (n * n * 16267 + 694541) + 1345679501) & 0x7FFFFFFF) / 1073741824.0);
}

inline float noise(int x, int y, int octave)
{
    return cachedNoise[((octave & 3) << 12) + ((x + y * 31) & 0x0FFF)];
}

inline float noise3(int x, int y, int z, int octave)
{
    return cachedNoise[((octave & 3) << 12) + ((x + y * 31 + z * 63) & 0x0FFF)];
}

float interpolate(float a, float b, float d)
{
    float	f	= (1.0 - cos(d * M_PI)) * 0.5f;

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

void initNoiseBuffer()
{
    register float	*pCachedNoise;
    register int	octave, i;
    
    cachedNoise = (float *)calloc(4 * 4096, sizeof(float));
    pCachedNoise = cachedNoise;

    for (octave = 0; octave < 4; octave++)
        for (i = 0; i < 4096; i++)
            *pCachedNoise++ = _noise(i, octave);
}

float perlinNoise2d(int x, int y, int maxx, int maxy, float period, float persistence, int octaves)
{
    float	sum			= 0;
    float	freq		= 1.0 / period;
    float	amplitude	= persistence;
    int		i;
    
    for (i = 0; i < octaves; i++)
    {
        sum			+= amplitude * interpolatedNoise((float)x * freq, (float)y * freq,
                                               (float)maxx * freq, (float)maxy * freq, i);
        amplitude	*= persistence;
        freq		*= 2;
    }

    return trim(sum / persistence * 0.5 + 0.5, 0.0, 1.0);
}

float perlinNoise3d(int x, int y, int z, int maxx, int maxy, int maxz, float period, float persistence, int octaves)
{
    float	sum			= 0;
    float	freq		= 1.0 / period;
    float	amplitude	= persistence;
    int		i;

    for (i = 0; i < octaves; i++)
    {
        sum			+= amplitude * interpolatedNoise3((float)x * freq, (float)y * freq, (float)z * freq,
                                                (float)maxx * freq, (float)maxy * freq, (float)maxz * freq, i);
        amplitude	*= persistence;
        freq		*= 2;
    }

    return trim(sum / persistence * 0.5 + 0.5, 0.0, 1.0);
}


/***********************************
* O T H E R   O P E R A T I O N S
* Practical application of all above
***********************************/

// Define the view frustum for culling
_C3DTFrustum viewFrustum(const _C3DTMatrix projection, const _C3DTMatrix model)
{
    _C3DTMatrix	clip;
    _C3DTFrustum	r;

    clip = matrixMultiply(projection, model);

    // Right plane
    r.planes[0].x = clip.flts[3] - clip.flts[0];
    r.planes[0].y = clip.flts[7] - clip.flts[4];
    r.planes[0].z = clip.flts[11] - clip.flts[8];
    r.planes[0].w = clip.flts[15] - clip.flts[12];
    r.planes[0] = vectorNormalize(r.planes[0]);

    // Left plane
    r.planes[1].x = clip.flts[3] + clip.flts[0];
    r.planes[1].y = clip.flts[7] + clip.flts[4];
    r.planes[1].z = clip.flts[11] + clip.flts[8];
    r.planes[1].w = clip.flts[15] + clip.flts[12];
    r.planes[1] = vectorNormalize(r.planes[1]);

    // Bottom plane
    r.planes[2].x = clip.flts[3] + clip.flts[1];
    r.planes[2].y = clip.flts[7] + clip.flts[5];
    r.planes[2].z = clip.flts[11] + clip.flts[9];
    r.planes[2].w = clip.flts[15] + clip.flts[13];
    r.planes[2] = vectorNormalize(r.planes[2]);

    // Top plane
    r.planes[3].x = clip.flts[3] - clip.flts[1];
    r.planes[3].y = clip.flts[7] - clip.flts[5];
    r.planes[3].z = clip.flts[11] - clip.flts[9];
    r.planes[3].w = clip.flts[15] - clip.flts[13];
    r.planes[3] = vectorNormalize(r.planes[3]);

    // Far plane
    r.planes[4].x = clip.flts[3] - clip.flts[2];
    r.planes[4].y = clip.flts[7] - clip.flts[6];
    r.planes[4].z = clip.flts[11] - clip.flts[10];
    r.planes[4].w = clip.flts[15] - clip.flts[14];
    r.planes[4] = vectorNormalize(r.planes[4]);

    // Near plane
    r.planes[5].x = clip.flts[3] + clip.flts[2];
    r.planes[5].y = clip.flts[7] + clip.flts[6];
    r.planes[5].z = clip.flts[11] + clip.flts[10];
    r.planes[5].w = clip.flts[15] + clip.flts[14];
    r.planes[5] = vectorNormalize(r.planes[5]);

    return r;
}

// Returns if a point is included inside a certain distance from a frustum
// if dist is negative, that means that the point is allowed to stay OUTSIDE the frustum by at most dist
// if dist is 0.0, then the point MUST be included in the frustum itself
// if dist is positive, the point must be INSIDE the frustum by at least dist
int pointNearFrustum(_C3DTFrustum f, _C3DTVector p, float dist)
{
    int		ii;

    for( ii = 0; ii < 6; ii++ )
        if( f.planes[ii].x * p.x + f.planes[ii].y * p.y +
            f.planes[ii].z * p.z + f.planes[ii].w < dist )
            return NOT_IN_FRUSTUM;

    return ALL_IN_FRUSTUM;
}

// Tells if a sphere has at least a part in the frustum
int isSphereInFrustum (_C3DTFrustum f, _C3DTSpheroid s)
{
    return pointNearFrustum(f, s.center, -s.radius);
}

// Variation of the above, but returns a distance useful for LevelOfDetail calculations
// and an int reporting flags of the planes it's in
int sphereDistanceFromFrustum(_C3DTFrustum f, _C3DTSpheroid s, float *dist)
{
    int		ii, flag;
    float	d;

    for( ii = 0, flag = 0; ii < 6; ii++ )
    {
        d = f.planes[ii].x * s.center.x + f.planes[ii].y * s.center.y +
        f.planes[ii].z * s.center.z + f.planes[ii].w;
        if( d < -s.radius ) {
            *dist = 0.0;
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
    s.center.x = (b.topRightFar.x + b.bottomLeftNear.x) / 2.0;
    s.center.y = (b.topRightFar.y + b.bottomLeftNear.y) / 2.0;
    s.center.z = (b.topRightFar.z + b.bottomLeftNear.z) / 2.0;

    s.radius = vectorLength(vectorSubtract(b.topRightFar, s.center));

    return s;
}

_C3DTBounds unionOfBounds(_C3DTBounds a, _C3DTBounds b)
{
	_C3DTBounds resultBounds;
	// _C3DTVector	bottomLeftNear;
	// _C3DTVector	topRightFar;
	resultBounds.bottomLeftNear.x = (a.bottomLeftNear.x < b.bottomLeftNear.x) ? a.bottomLeftNear.x : b.bottomLeftNear.x;
	resultBounds.bottomLeftNear.y = (a.bottomLeftNear.y < b.bottomLeftNear.y) ? a.bottomLeftNear.y : b.bottomLeftNear.y;
	resultBounds.topRightFar.x = (a.topRightFar.x > b.topRightFar.x) ? a.topRightFar.x : b.topRightFar.x;
	resultBounds.topRightFar.y = (a.topRightFar.y > b.topRightFar.y) ? a.topRightFar.y : b.topRightFar.y;
	
	return resultBounds;
}
