/*
 *  C3DTMath.h
 *  Cocoa3DTutorial
 *
 *  Created by Paolo Manna on Sat May 17 2003.
 *  Copyright (c) 2003. All rights reserved.
 *
 *  Terms of use:
 *  - Short: OPEN SOURCE under Artistic License -- credit fairly, use freely, alter carefully.
 *  -  Full: <http://www.opensource.org/licenses/artistic-license.html>
 *


    @header C3DTMath
    @abstract   Math functions for Cocoa3DTutorial
    @discussion Contains all the basic functions to manipulate vectors & matrices, plus some utility functions specific for 3D
*/

#include <math.h>
#include <stdlib.h>

#ifdef	ALTIVEC
#include <vecLib/vecLib.h>
#endif // ALTIVEC
#include "C3DTTypes.h"

#ifndef __CUSTOM_C3DT_MATH__
#define __CUSTOM_C3DT_MATH__

// Some useful macros & constants
/*!
    @defined 	isPowerOfTwo
    @discussion Returns YES if x is a power of 2
*/
#define isPowerOfTwo(x)		(!(x & (x - 1)))

/*!
    @defined deg2rad, rad2deg
    @discussion Basic conversions between degrees and radians
*/
#define	deg2rad(x)				((x)*0.0174532925194f)
#define	rad2deg(x)				((x)*57.295779514719f)

/*!
    @defined trim, between
    @discussion Useful macros
*/
#define trim(x, min, max)		(((x)<min)?min:(((x)>max)?max:(x)))
#define between(x, min, max)	(((x)>=min)&&((x)<max))

/*!
    @defined EPSILON
    @discussion A minimal value for a calculation to be considered acceptable
*/
#define	EPSILON					.0001f

/*!
    @defined NOT_IN_FRUSTUM, ALL_IN_FRUSTUM
    @discussion Values for frustum visibility: intermediate values mean
     the object is partially included in the view frustum
*/
#define	NOT_IN_FRUSTUM			0x0000
#define	ALL_IN_FRUSTUM			0x003F

// Noise cache
extern float	*cachedNoise;


#ifdef __cplusplus
extern "C" {
#endif

    /*
     * Vector operations
     */
    /*!
     @function vectorAdd
     @discussion Adds 2 vectors
     @param      a First vector
     @param      b Second vector
     @result     The sum of the two vectors (a + b)
     */
    inline C3DTVector	vectorAdd(const C3DTVector a, const C3DTVector b);
    
    /*!
     @function vectorSubtract
     @discussion Subtracts 2 vectors
     @param      a First vector
     @param      b Second vector
     @result     The difference of the two vectors (a - b)
     */
    inline C3DTVector	vectorSubtract(const C3DTVector a, const C3DTVector b);

    /*!
     @function vectorDotProduct
     @discussion Dot product of 2 vectors
     @param      a First vector
     @param      b Second vector
     @result     The dot product of the two vectors (a . b)
     */
    inline float		vectorDotProduct(const C3DTVector a, const C3DTVector b);

    /*!
     @function vectorCrossProduct
     @discussion Cross product of 2 vectors
     @param      a First vector
     @param      b Second vector
     @result     The cross product of the two vectors (a x b)
     */
    inline C3DTVector	vectorCrossProduct(const C3DTVector a, const C3DTVector b);

    /*!
     @function vectorCrossProductTri
     @discussion Cross product of 3 vectors
     @param      a First vector
     @param      b Second vector
     @param      c Second vector
     @result     The cross product of the 3 vectors (b - a) x (c - a)
     */
    inline C3DTVector	vectorCrossProductTri(const C3DTVector a, const C3DTVector b, const C3DTVector c);

    /*!
     @function vectorLength
     @discussion Length of a vector
     @param      v The vector
     @result     The length of a vector
     */
    float vectorLength(const C3DTVector v);

    /*!
     @function vectorNormalize
     @discussion Calculates a "normalized" version of the vector, i.e. a vector with the same orientation but length 1.0
     @param      v The vector
     @result     The normalized vector
     */
    inline C3DTVector	vectorNormalize(C3DTVector v);

    /*!
     @function vectorNormal
     @discussion Calculates a vector "normal" (i.e. perpendicular) to the two given: the two vectors must have a common origin in (0, 0, 0)
     @param      a First vector
     @param      b Second vector
     @result     The normal vector (normalized)
     */
    inline C3DTVector	vectorNormal(const C3DTVector a, const C3DTVector b);

    /*!
     @function vectorNormalTri
     @discussion Calculates a vector "normal" (i.e. perpendicular) to the two vectors given, that have a common origin in a third vector
     @param      a First vector (origin)
     @param      b Second vector
     @param      c Third vector
     @result     The normal & normalized vector for vectors b & c centered in position a
     */
    inline C3DTVector	vectorNormalTri(C3DTVector a, C3DTVector b, C3DTVector c);

    /*!
     @function vectorScale
     @discussion Calculates a scaled version of the vector, i.e. a vector with the same orientation but scaled length
     @param      s The scaling factor
     @param      a The vector
     @result     The scaled vector
     */
    inline C3DTVector	vectorScale(const float s, const C3DTVector a);

    /*!
     @function vectorAngleCos
     @discussion Calculates the cos() between 2 vectors, centered in (0, 0, 0)
     @param      a First vector
     @param      b Second vector
     @result     The cosinus of the angle between the 2 vectors
     */
    inline float		vectorAngleCos(const C3DTVector a, const C3DTVector b);


    /*!
     @function vectorTransform
     @discussion Calculates the transformation of a vector by a given matrix
     @param      v The vector
     @param      m The matrix
     @result     The transformed vector
     */
    C3DTVector	vectorTransform(const C3DTVector v, const C3DTMatrix m);

    /*
     * Conversion operations
     */
    inline C3DTVector cartesianToSpherical(C3DTVector v);
    inline C3DTVector sphericalToCartesian(C3DTVector v);
    
    /*
     * Matrix operations
     */
    inline C3DTMatrix	matrixIdentity(void);
    C3DTMatrix	matrixMultiply(const C3DTMatrix m1, const C3DTMatrix m2);
    void		matrixTransform(C3DTMatrix *m, const C3DTMatrix n);
    C3DTMatrix matrixTranspose(const C3DTMatrix m);
    C3DTMatrix	matrixInverse(const C3DTMatrix m);
    void		matrixTranslate(C3DTMatrix *m, const float dx, const float dy, const float dz);
    void		matrixScale(C3DTMatrix *m, const float sx, const float sy, const float sz);
    void		matrixUniformScale(C3DTMatrix *m, const float s);
    void		matrixRotate(C3DTMatrix *m, const float ax, const float ay, const float az);

    /*
     * Quaternion operations
     */
    inline _C3DTQuaternion	quaternionIdentity(void);
    inline _C3DTQuaternion	quaternionInverse(_C3DTQuaternion q);
    inline float			quaternionLength(_C3DTQuaternion q);
    inline _C3DTQuaternion	quaternionNormalize(_C3DTQuaternion q);
    inline _C3DTQuaternion	quaternionMultiply(_C3DTQuaternion a, _C3DTQuaternion b);
    C3DTVector	quaternionToDirectionVector(_C3DTQuaternion q);
    C3DTMatrix	quaternionToMatrix(_C3DTQuaternion q);
    C3DTMatrix	quaternionToInvertedMatrix(_C3DTQuaternion q);

    /*
     * Noise generation functions
     */
    void		initNoiseBuffer();
    float		perlinNoise2d(int x, int y, int maxx, int maxy, float period, float persistence, int octaves);
    float		perlinNoise3d(int x, int y, int z, int maxx, int maxy, int maxz, float period, float persistence, int octaves);
    
    /*
     * Some practical use of the above
     */
    inline C3DTPlane	planeNormalize(C3DTPlane p);
    C3DTFrustum viewFrustum(const C3DTMatrix projection, const C3DTMatrix model);
    int				pointNearFrustum(C3DTFrustum f, C3DTVector p, float dist);
    int				isSphereInFrustum (C3DTFrustum f, _C3DTSpheroid s);
    int				sphereDistanceFromFrustum(C3DTFrustum f, _C3DTSpheroid s, float *dist);
    _C3DTSpheroid	sphereFromBounds(_C3DTBounds b);
	
	_C3DTBounds unionOfBounds(_C3DTBounds a, _C3DTBounds b);
#ifdef __cplusplus
}
#endif

#endif /* __CUSTOM_C3DT_MATH__ */
