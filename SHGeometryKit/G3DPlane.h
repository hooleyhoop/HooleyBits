//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DPlane
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
// $Id: G3DPlane.h,v 1.7 2002/10/27 13:15:16 probert Exp $
//-----------------------------------------------------------------------------

#ifndef __G3DPlane_h_INCLUDE
#define __G3DPlane_h_INCLUDE

#import <Foundation/Foundation.h>
#import "G3DIntersecting.h"

@class G3DTuple3f;
@class G3DVector3f;
@class G3DMatrix4f;
@class G3DBox;
@class G3DLine;
@class G3DSphere;

/*!
   @class      G3DPlane
   @abstract   A generic plane representation.
   @discussion A generic plane represented by a single-precision 4-element floating
               point tuple, such as ax+by+cz+d=0 where normal = (a,b,c) and
               distance = d.
*/

@interface G3DPlane : NSObject <G3DIntersecting> // NSCoding NSCopying
{
  float _values[4];
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

/*! 
   @method   init
   @abstract Creates a plane initialised with normal [0.0, 0.0, 1.0] and
             distance 0.0. 
   @result   Returns the newly initialised plane object or nil on error.
*/
- (id)init;

/*! 
   @method   initWithElements:
   @abstract Creates a plane with the passed plane equation values. This is
             the designated initialiser.
   @param    vals Single-precision plane equation values
   @result   Returns the newly initialised plane object or nil on error.
*/
- (id)initWithElements:(const float *)vals;

/*! 
   @method   initWithNormal:point:
   @abstract Creates a plane object with a normal vector and a point on the plane. 
   @param    norm A normal vector
   @param    aTuple A point on the plane
   @result   Returns the newly initialised plane object or nil on error.
*/
- (id)initWithNormal:(G3DVector3f *)norm point:(G3DTuple3f *)aTuple;

/*! 
   @method   initWithPlane:
   @abstract Creates a plane object with an existing plane. 
   @param    aPlane Another plane
   @result   Returns the newly initialised plane object or nil on error.
*/
- (id)initWithPlane:(G3DPlane *)aPlane;

//-----------------------------------------------------------------------------
// math
//-----------------------------------------------------------------------------

/*! 
   @method   shiftByDistance:
   @abstract Shifts the plane by factor in the direction of the plane normal. 
   @param    factor Single-precision shift factor
   @result   Returns the newly initialised plane object or nil on error.
*/
- (void)shiftByDistance:(const float)factor;

/*! 
   @method intersectsObject:
   @abstract Tests if the receiver intersects the passed object. The method raises a
             G3DLineException if it fails to perform the test. 
   @param anObject Another mathematical primitive
   @result  Returns YES if the 2 objects intersect, NO otherwise.
*/
- (BOOL)intersectsObject:(id<G3DIntersecting>)anObject;

/*! 
   @method intersectsLine:at:
   @abstract Tests if the receiver intersects the passed line. 
   @param ln Another line object
   @result  Returns YES if the 2 lines intersect, NO otherwise.
*/
- (BOOL)intersectsLine:(G3DLine *)line at:(G3DTuple3f *)pt;

/*! 
   @method intersectsSphere:
   @abstract Tests if the receiver intersects the passed sphere. Invokes the appropriate method on 
             the G3DSphere.
   @param sphere A sphere object
   @result  Returns YES if the plane intersects the sphere, NO otherwise.
*/
- (BOOL)intersectsSphere:(G3DSphere *)sph;

/*! 
   @method intersectsPlane:
   @abstract Tests if the receiver intersects the passed plane, based on the Algorithm as descibed 
             in Graphics Gem III, P.519
   @param pl A plane object
   @result Returns YES if the receiver intersects the plane, NO otherwise.
*/
- (BOOL)intersectsPlane:(G3DPlane *)pl;

/*! 
   @method intersectsBox:
   @abstract Tests if the receiver intersects the passed box. Invokes the appropriate method on 
             the G3DBox.
   @param aBox A box object
   @result Returns YES if the plane intersects the box, NO otherwise.
*/
- (BOOL)intersectsBox:(G3DBox *)aBox;

/*! 
   @method transform:
   @abstract Transforms the receiver by the passed 4 by 4 matrix. Hence it calculates 
             m * [n1,n2,n3,d] such as it can be used directly with OpenGL.
   @param aMatrix A 4 by 4 transformation matrix
*/
- (void)transform:(G3DMatrix4f *)aMatrix;

/*! 
   @method isParallel:
   @abstract Tests if the receiver is parallel to the passed plane. 
   @param aPlane Another plane object
   @result Returns YES if the 2 lines are parallel, NO otherwise.
*/
- (BOOL)isParallel:(G3DPlane *)aPlane;

/*! 
   @method   isEqualToPlane:   
   @abstract Checks if the passed plane is equal to the receiver. 
   @param aPlane Another plane object.
   @result   Returns YES if aPlane is equivalent to the receiver, NO otherwise.
*/
- (BOOL)isEqualToPlane:(G3DPlane *)aPlane;

/*! 
   @method isInHalfSpace:   
   @abstract Checks if the passed vector is within the half space as defined by the normal
             of the plane. 
   @param vec A vector.
   @result Returns YES if vec is within the receiver's half space, NO otherwise.
*/
- (BOOL)isInHalfSpace:(G3DTuple3f *)vec;

/*! 
   @method distanceFromPoint:   
   @abstract Calculates the nearest distance from the passed point to the receiver. 
   @param aTuple A point in space.
   @result Returns the single-precision distance from the point to the plane.
*/
- (float)distanceFromPoint:(G3DTuple3f *)aTuple;

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

/*! 
   @method setDistance:
   @abstract Sets the distance to the coordinate system's origin. 
   @param aDistance A single-precision distance value 
*/
- (void)setDistance:(const float)aDistance;

/*! 
   @method distance
   @abstract Returns the single-precision distance value. 
*/
- (float)distance;

/*! 
   @method setNormal:
   @abstract Sets the normal of the plane. aNorm is normalised beforehand. 
   @param aNorm A 3-element vector 
*/
- (void)setNormal:(G3DVector3f *)aNorm;

/*! 
   @method normal
   @abstract Returns the 3-element plane normal vector. 
*/
- (G3DVector3f *)normal;

/*! 
   @method setElements:
   @abstract Sets the normal and distance values of the plane equation as is.
   @param vals 4 single-precision plane equation values. 
*/
- (void)setElements:(const float *)vals;

/*! 
   @method getElements:
   @abstract Copies the normal and distance values of the plane equation to vals.
   @param vals A 4-element single-precision floating point array. 
*/
- (void)getElements:(float *)vals;

/*! 
   @method elements
   @abstract Returns a pointer to the 4 single-precision floating point values of
             the plane equation. 
*/
- (const float *)elements;

//-----------------------------------------------------------------------------
// NSCoding
//-----------------------------------------------------------------------------

/*! 
   @method encodeWithCoder:
   @abstract Encodes the receiver using encoder.
*/
- (void)encodeWithCoder:(NSCoder *)aCoder;

/*! 
   @method initWithCoder:
   @abstract Initializes a newly allocated instance from data in aCoder.
   @result Returns self.
*/
- (id)initWithCoder:(NSCoder *)aCoder;

//-----------------------------------------------------------------------------
// NSCopying
//-----------------------------------------------------------------------------

/*! 
   @method copyWithZone:
   @abstract Returns a new instance that's a copy of the receiver. Memory for the new 
             instance is allocated from zone, which may be nil. If zone is nil, the new 
             instance is allocated from the default zone, which is returned from the 
             function NSDefaultMallocZone. The returned object is implicitly retained 
             by the sender, who is responsible for releasing.
   @result Returns a new instance that's a copy of the receiver.
*/
- (id)copyWithZone:(NSZone *)zone;

@end

extern NSString *G3DPlaneException;

#endif




