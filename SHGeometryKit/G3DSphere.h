//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class	        G3DSphere
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
// $Id: G3DSphere.h,v 1.7 2002/10/27 13:15:16 probert Exp $
//-----------------------------------------------------------------------------

#ifndef __G3DSphere_h_INCLUDE
#define __G3DSphere_h_INCLUDE

#import <Foundation/Foundation.h>
#import "G3DIntersecting.h"

@class G3DMatrix3f;
@class G3DMatrix4f;
@class G3DTuple3f;
@class G3DBox;
@class G3DLine;
@class G3DPlane;

/*!
   @class      G3DSphere
   @abstract   A generic sphere representation.
   @discussion A generic sphere represented by a single-precision floating point
               radius and a 3-element center tuple.
*/

@interface G3DSphere : NSObject < G3DIntersecting> // NSCoding,  NSCopying
{    
  float _radius;
  float _center[3];
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

/*! 
   @method   init
   @abstract Creates a sphere at [0.0, 0.0, 0.0] and radius 1.0. 
   @result   Returns the newly initialised sphere object or nil on error.
*/
- (id)init;

/*! 
   @method   initWithCenter:radius:
   @abstract Creates a sphere at aCenter with radius aRadius.
   @param    aCenter The center of the sphere
   @param    aRadius The radius of the sphere
   @result   Returns the newly initialised sphere object or nil on error.
*/
- (id)initWithCenter:(G3DTuple3f *)aCenter radius:(float)aRadius;

/*! 
   @method   initWithX:y:z:radius:
   @abstract Creates a sphere at [x, y,z] with radius aRadius. This is the designated initialiser.
   @param    x Single-precision X coordinate of the center of the sphere
   @param    y Single-precision Y coordinate of the center of the sphere
   @param    z Single-precision Z coordinate of the center of the sphere
   @param    aRadius The radius of the sphere
   @result   Returns the newly initialised sphere object or nil on error.
*/
- (id)initWithX:(float)x y:(float)y z:(float)z radius:(float)aRadius;

/*! 
   @method   initWithSphere:
   @abstract Creates a sphere object with an existing sphere. 
   @param    aSphere Another sphere
   @result   Returns the newly initialised sphere object or nil on error.
*/
- (id)initWithSphere:(G3DSphere *)aSphere;

//-----------------------------------------------------------------------------
// math
//-----------------------------------------------------------------------------

/*! 
   @method wrapPoint:
   @abstract Resizes the sphere so that it wraps the point pt. 
   @param pt The point to be wrapped by the receiver
*/
- (void)wrapPoint:(G3DTuple3f *)pt;

/*! 
   @method wrapBox:
   @abstract Resizes the sphere so that it wraps the box b. 
   @param b The box to be wrapped by the receiver
*/
- (void)wrapBox:(G3DBox *)b;

/*! 
   @method wrapSphere:
   @abstract Resizes the sphere so that it wraps the sphere s. 
   @param s The sphere to be wrapped by the receiver
*/
- (void)wrapSphere:(G3DSphere *)s;

/*! 
   @method transform:
   @abstract Transforms the receiver by the passed 4 by 4 matrix. Hence it calculates 
             m * center such as it can be used directly with OpenGL. The radius is scaled by the 
             biggest scaling factor.
   @param aMatrix A 4 by 4 transformation matrix
*/
- (void)transform:(G3DMatrix4f *)m;

/*! 
   @method intersectsObject:
   @abstract Tests if the receiver intersects the passed object. The method raises a
             G3DSphereException if it fails to perform the test. 
   @param anObject Another mathematical primitive
   @result  Returns YES if the 2 objects intersect, NO otherwise.
*/
- (BOOL)intersectsObject:(id<G3DIntersecting>)anObject;

/*! 
   @method intersectsLine:
   @abstract Tests if the receiver intersects the passed line. 
   @param l Another line object
   @result  Returns YES if the 2 spheres intersect, NO otherwise.
*/
- (BOOL)intersectsLine:(G3DLine *)l;

/*! 
   @method intersectsSphere:
   @abstract Tests if the receiver intersects the passed sphere.
   @param s A sphere object
   @result Returns YES if the sphere intersects the sphere, NO otherwise.
*/
- (BOOL)intersectsSphere:(G3DSphere *)s;

/*! 
   @method intersectsBox:
   @abstract Tests if the receiver intersects the passed box.
   @param b A box object
   @result Returns YES if the sphere intersects the box, NO otherwise.
*/
- (BOOL)intersectsBox:(G3DBox *)b;

/*! 
   @method intersectsPlane:
   @abstract Tests if the receiver intersects the passed plane.
   @param p A plane object
   @result Returns YES if the sphere intersects the plane, NO otherwise.
*/
- (BOOL)intersectsPlane:(G3DPlane *)p;

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

/*! 
   @method volume
   @abstract Returns the single-precision volume value. 
*/
- (float)volume;

/*! 
   @method isEmpty
   @abstract Returns YES if the volume is equal to 0, NO otherwise. 
*/
- (BOOL)isEmpty;

/*! 
   @method radius
   @abstract Returns the single-precision floating point radius of the sphere. 
*/
- (float)radius;

/*! 
   @method setRadius:
   @abstract Sets the radius of the sphere. 
   @param newRadius A single-precision floating point radius value 
*/
- (void)setRadius:(const float)newRadius;

/*! 
   @method center
   @abstract Returns the center of the sphere. 
*/
- (G3DTuple3f *)center;

/*! 
   @method setCenter:
   @abstract Sets the center of the sphere. 
   @param newCenter A 3-element center tuple. 
*/
- (void)setCenter:(G3DTuple3f *)newCenter;

/*! 
   @method isEqualToSphere:   
   @abstract Checks if the passed sphere is equal to the receiver. 
   @param aSphere Another sphere object.
   @result Returns YES if aSphere is equivalent to the receiver, NO otherwise.
*/
- (BOOL)isEqualToSphere:(G3DSphere *)aSphere;

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

extern NSString *G3DSphereException;

#endif




