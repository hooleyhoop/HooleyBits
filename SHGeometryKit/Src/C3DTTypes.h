/*
 *  C3DTTypes.h
 *  Cocoa3DTutorial
 *
 *  Created by Paolo Manna on Sat May 17 2003.
 *  Copyright (c) 2003. All rights reserved.
 *
 *  Terms of use:
 *  - Short: OPEN SOURCE under Artistic License -- credit fairly, use freely, alter carefully.
 *  -  Full: <http://www.opensource.org/licenses/artistic-license.html>
 *
 * $Id: C3DTTypes.h,v 1.1.1.1 2004/11/29 11:35:56 shooley Exp $
 *
 * $Log: C3DTTypes.h,v $
 * Revision 1.1.1.1  2004/11/29 11:35:56  shooley
 * Initial Import
  */

/*!
    @header C3DTTypes
    @abstract   Basic types for Cocoa3DTutorial
    @discussion Contains the basic data types for Cocoa3DTutorial. Note that vectors are dimension 4 (i.e. a weight component is included) even though no calculation is performed on the w component: similarly, matrices are 4x4. This allows us to use the same structure for plane description (ax + by + cz + d) & quaternions (scalar + complex components) . Note also that the Altivec equivalent has been left in place, but all the actual implementation has been removed from the code.
*/





#ifndef __C3DTTYPES_H__
#define __C3DTTYPES_H__

	#include <math.h>
	#include <OpenGL/gl.h>
	
#ifndef NULL
#define	NULL	0
#endif

#ifndef true
#define	true	1
#define	false	0
#endif

// Multiple appearance for floats, vectors and matrices, to be easy to use
// yet compatible with AltiVec operation
/*!
 @typedef _C3DTVector
 @abstract   Coordinate vector
 @discussion The base unit for calculation: a "weight" component is present, but actually ignored
 @field      x The X coordinate
 @field      y The Y coordinate
 @field      z The Z coordinate
 @field      w The W coordinate, AKA "weight"
 @field      r The r (distance) coordinate (spherical coordinates)
 @field      theta The theta (azimuth) angle (spherical coordinates)
 @field      phi The phi (elevation) angle (spherical coordinates)
 */
typedef union {
#ifdef	ALTIVEC
    vector float	a_vec;
#endif
    float			flts[4];
    struct {
        GLfloat	r;
        GLfloat	theta;
        GLfloat	phi;
        GLfloat	w;
    };
    struct {
        GLfloat	x;
        GLfloat	y;
        GLfloat	z;
        GLfloat	w;
    };
} _C3DTVector;





/*!
    @typedef _C3DTQuaternion
    @abstract   Quaternion representation
    @discussion Represents a quaternion, i.e. a mathematical structure with a scalar a 3 complex numbers: it's used mostly
 with rotations, as it represents a better solution that avoids "gimbal lock"
 (see http://gamedev.net/reference/articles/article1095.asp)
*/
typedef _C3DTVector		_C3DTQuaternion;

/*!
 @typedef _C3DTPlane
 @abstract   Plane representation
 @discussion Represents a plane equation (ax + by + cz + d = 0): used to define a view frustum
  */
typedef _C3DTVector		_C3DTPlane;

/*!
 @typedef _C3DTMatrix
 @abstract   Matrix type
 @discussion The type used to transform the coordinates: is implemented as a union to allow different presentation possibilities
 @field      vectors An array of 4 vectors
 */
typedef union {
#ifdef	ALTIVEC
    vector float	a_vec[4];
#endif
    float			flts[16];
    _C3DTVector		vectors[4];
} _C3DTMatrix;

/*!
 @typedef _C3DTVertex
 @abstract   3D Vertex
 @discussion The type that represents a 3D vertex: includes spatial data & normal data used for lighting & orientation
 @field      pos The spatial position of the vertex
 @field      norm The spatial orientation of the vertex, to define facing and lighting
 */
typedef struct {
    _C3DTVector	pos;
    _C3DTVector	norm;
} _C3DTVertex;

/*!
 @typedef _C3DTTriangle
 @abstract   The simplest shape
 @discussion Defines a triangular shape
 @field      vert The pointers to the 3 vertices
 */
typedef struct {
    _C3DTVertex	*vert[3];
} _C3DTTriangle;

/*!
 @typedef _C3DTQuad
 @abstract   A 4 points shape
 @discussion Defines a 4 points shape: to be correctly represented, the 4 points must lay on the same plane though
 @field      vert The pointers to the 4 vertices
 */
typedef struct {
    _C3DTVertex	*vert[4];
} _C3DTQuad;

/*!
 @typedef _C3DTFrustum
 @abstract   The view frustum
 @discussion Defines a geometrical frustum, used to cull objects that are not included in it
 @field      planes The 6 planes defining the frustum, in the order right, left, bottom, top, far, near
 */
typedef struct {
    _C3DTPlane	planes[6];
} _C3DTFrustum;

/*!
 @typedef _C3DTSpheroid
 @abstract   A sphere
 @discussion The simplest definition of a sphere, based on spatial position of the center and its radius
 @field      center The center position
 @field      radius The sphere radius
 */
typedef struct {
    _C3DTVector	center;
    float		radius;
} _C3DTSpheroid;

/*!
 @typedef _C3DTBounds
 @abstract   A bounding box
 @discussion Defines a bounding box for an object: it is assumed to be a "box" with one side always facing the viewer
 @field      bottomLeftNear The lowest and nearest coordinate on the left
 @field      topRightFar The highest and farest coordinate on the right
 */
typedef struct {
    _C3DTVector	bottomLeftNear;
    _C3DTVector	topRightFar;
} _C3DTBounds;






#endif	/*__C3DTTYPES_H__ */
