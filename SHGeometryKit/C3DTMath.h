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


/*!
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
    inline _C3DTVector	vectorAdd(const _C3DTVector a, const _C3DTVector b);
    
    /*!
     @function vectorSubtract
     @discussion Subtracts 2 vectors
     @param      a First vector
     @param      b Second vector
     @result     The difference of the two vectors (a - b)
     */
    inline _C3DTVector	vectorSubtract(const _C3DTVector a, const _C3DTVector b);

    /*!
     @function vectorDotProduct
     @discussion Dot product of 2 vectors
     @param      a First vector
     @param      b Second vector
     @result     The dot product of the two vectors (a . b)
     */
    inline float		vectorDotProduct(const _C3DTVector a, const _C3DTVector b);

    /*!
     @function vectorCrossProduct
     @discussion Cross product of 2 vectors
     @param      a First vector
     @param      b Second vector
     @result     The cross product of the two vectors (a x b)
     */
    inline _C3DTVector	vectorCrossProduct(const _C3DTVector a, const _C3DTVector b);

    /*!
     @function vectorCrossProductTri
     @discussion Cross product of 3 vectors
     @param      a First vector
     @param      b Second vector
     @param      c Second vector
     @result     The cross product of the 3 vectors (b - a) x (c - a)
     */
    inline _C3DTVector	vectorCrossProductTri(const _C3DTVector a, const _C3DTVector b, const _C3DTVector c);

    /*!
     @function vectorLength
     @discussion Length of a vector
     @param      v The vector
     @result     The length of a vector
     */
    inline float		vectorLength(const _C3DTVector v);

    /*!
     @function vectorNormalize
     @discussion Calculates a "normalized" version of the vector, i.e. a vector with the same orientation but length 1.0
     @param      v The vector
     @result     The normalized vector
     */
    inline _C3DTVector	vectorNormalize(_C3DTVector v);

    /*!
     @function vectorNormal
     @discussion Calculates a vector "normal" (i.e. perpendicular) to the two given: the two vectors must have a common origin in (0, 0, 0)
     @param      a First vector
     @param      b Second vector
     @result     The normal vector (normalized)
     */
    inline _C3DTVector	vectorNormal(const _C3DTVector a, const _C3DTVector b);

    /*!
     @function vectorNormalTri
     @discussion Calculates a vector "normal" (i.e. perpendicular) to the two vectors given, that have a common origin in a third vector
     @param      a First vector (origin)
     @param      b Second vector
     @param      c Third vector
     @result     The normal & normalized vector for vectors b & c centered in position a
     */
    inline _C3DTVector	vectorNormalTri(_C3DTVector a, _C3DTVector b, _C3DTVector c);

    /*!
     @function vectorScale
     @discussion Calculates a scaled version of the vector, i.e. a vector with the same orientation but scaled length
     @param      s The scaling factor
     @param      a The vector
     @result     The scaled vector
     */
    inline _C3DTVector	vectorScale(const float s, const _C3DTVector a);

    /*!
     @function vectorAngleCos
     @discussion Calculates the cos() between 2 vectors, centered in (0, 0, 0)
     @param      a First vector
     @param      b Second vector
     @result     The cosinus of the angle between the 2 vectors
     */
    inline float		vectorAngleCos(const _C3DTVector a, const _C3DTVector b);


    /*!
     @function vectorTransform
     @discussion Calculates the transformation of a vector by a given matrix
     @param      v The vector
     @param      m The matrix
     @result     The transformed vector
     */
    _C3DTVector	vectorTransform(const _C3DTVector v, const _C3DTMatrix m);

    /*
     * Conversion operations
     */
    inline _C3DTVector cartesianToSpherical(_C3DTVector v);
    inline _C3DTVector sphericalToCartesian(_C3DTVector v);
    
    /*
     * Matrix operations
     */
    inline _C3DTMatrix	matrixIdentity(void);
    _C3DTMatrix	matrixMultiply(const _C3DTMatrix m1, const _C3DTMatrix m2);
    void		matrixTransform(_C3DTMatrix *m, const _C3DTMatrix n);
    _C3DTMatrix matrixTranspose(const _C3DTMatrix m);
    _C3DTMatrix	matrixInverse(const _C3DTMatrix m);
    void		matrixTranslate(_C3DTMatrix *m, const float dx, const float dy, const float dz);
    void		matrixScale(_C3DTMatrix *m, const float sx, const float sy, const float sz);
    void		matrixUniformScale(_C3DTMatrix *m, const float s);
    void		matrixRotate(_C3DTMatrix *m, const float ax, const float ay, const float az);

    /*
     * Quaternion operations
     */
    inline _C3DTQuaternion	quaternionIdentity(void);
    inline _C3DTQuaternion	quaternionInverse(_C3DTQuaternion q);
    inline float			quaternionLength(_C3DTQuaternion q);
    inline _C3DTQuaternion	quaternionNormalize(_C3DTQuaternion q);
    inline _C3DTQuaternion	quaternionMultiply(_C3DTQuaternion a, _C3DTQuaternion b);
    _C3DTVector	quaternionToDirectionVector(_C3DTQuaternion q);
    _C3DTMatrix	quaternionToMatrix(_C3DTQuaternion q);
    _C3DTMatrix	quaternionToInvertedMatrix(_C3DTQuaternion q);

    /*
     * Noise generation functions
     */
    void		initNoiseBuffer();
    float		perlinNoise2d(int x, int y, int maxx, int maxy, float period, float persistence, int octaves);
    float		perlinNoise3d(int x, int y, int z, int maxx, int maxy, int maxz, float period, float persistence, int octaves);
    
    /*
     * Some practical use of the above
     */
    inline _C3DTPlane	planeNormalize(_C3DTPlane p);
    _C3DTFrustum	viewFrustum(const _C3DTMatrix projection, const _C3DTMatrix model);
    int				pointNearFrustum(_C3DTFrustum f, _C3DTVector p, float dist);
    int				isSphereInFrustum (_C3DTFrustum f, _C3DTSpheroid s);
    int				sphereDistanceFromFrustum(_C3DTFrustum f, _C3DTSpheroid s, float *dist);
    _C3DTSpheroid	sphereFromBounds(_C3DTBounds b);
	
	_C3DTBounds unionOfBounds(_C3DTBounds a, _C3DTBounds b);
#ifdef __cplusplus
}
#endif

#endif /* __CUSTOM_C3DT_MATH__ */
