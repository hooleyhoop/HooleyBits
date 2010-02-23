//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DBox
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
// $Id: G3DBox.h,v 1.8 2002/10/27 20:17:02 probert Exp $
//-----------------------------------------------------------------------------

#ifndef __G3DBox_h_INCLUDE
#define __G3DBox_h_INCLUDE

#import <Foundation/Foundation.h>
#import "G3DIntersecting.h"

@class G3DMatrix4f;
@class G3DTuple3f;
@class G3DSphere;
@class G3DLine;
@class G3DPlane;

/*!
   @class      G3DBox
   @abstract   A generic box representation.
   @discussion A generic, axis aligned box represented by 2 single-precision 3-element floating 
               point tuples.
*/

@interface G3DBox : NSObject <G3DIntersecting> // NSCoding, NSCopying
{
  G3DTuple3f *min;
  G3DTuple3f *max;
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

/*! 
   @method   init
   @abstract Creates an axis aligned box with min [0.0, 0.0, 0.0] and max [1.0, 1.0, 1.0]. 
   @result   Returns the newly initialised box object or nil on error.
*/
- (id)init;

/*! 
   @method   initWithMin:max:
   @abstract Creates an axis aligned box from minimum to maximum.
   @param    minimum The minimum of the box
   @param    maximum The maximum of the box
   @result   Returns the newly initialised box object or nil on error.
*/
- (id)initWithMin:(G3DTuple3f *)minimum max:(G3DTuple3f *)maximum;

/*! 
   @method   initWithBox:
   @abstract Creates a box object with an existing box. 
   @param    aBox Another box
   @result   Returns the newly initialised box object or nil on error.
*/
- (id)initWithBox:(G3DBox *)aBox;

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
   @method intersectsObject:
   @abstract Tests if the receiver intersects the passed object. The method raises a
             G3DBoxException if it fails to perform the test. 
   @param anObject Another mathematical primitive
   @result  Returns YES if the 2 objects intersect, NO otherwise.
*/
- (BOOL)intersectsObject:(id<G3DIntersecting>)anObject;

/*! 
   @method intersectsLine:
   @abstract Tests if the receiver intersects the passed line. 
   @param l Another line object
   @result  Returns YES if the 2 boxes intersect, NO otherwise.
*/
- (BOOL)intersectsLine:(G3DLine *)l;

/*! 
   @method intersectsBox:
   @abstract Tests if the receiver intersects the passed box. It actually currently tests 
             whether aBox is contained within the receiver.
   @param b A box object
   @result Returns YES if the box intersects the box, NO otherwise.
*/
- (BOOL)intersectsBox:(G3DBox *)aBox;

/*! 
   @method intersectsPlane:
   @abstract Tests if the receiver intersects the passed plane.
   @param p A plane object
   @result Returns YES if the box intersects the plane, NO otherwise.
*/
- (BOOL)intersectsPlane:(G3DPlane *)aPlane;

/*! 
   @method intersectsSphere:
   @abstract Tests if the receiver intersects the passed sphere.
   @param s A sphere object
   @result Returns YES if the box intersects the sphere, NO otherwise.
*/
- (BOOL)intersectsSphere:(G3DSphere *)aSphere;

/*! 
   @method wrapsPoint:
   @abstract Tests if the receiver wraps pt.
   @param pt A point
   @result Returns YES if the box wraps the point, NO otherwise.
*/
- (BOOL)wrapsPoint:(G3DTuple3f *)pt;

/*! 
   @method transform:
   @abstract Transforms the receiver by the passed 4 by 4 matrix. Hence it calculates 
             m * min and m * max such as it can be used directly with OpenGL. 
   @param m A 4 by 4 transformation matrix
*/
- (void)transform:(G3DMatrix4f *)m;

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

/*! 
   @method setMin:max:
   @abstract Sets the minimum and the maximum of the receiver. 
   @param minVec The lower left of the box 
   @param maxVec The upper right of the box 
*/
- (void)setMin:(G3DTuple3f *)minVec max:(G3DTuple3f *)maxVec;

/*! 
   @method getMin:max:
   @abstract Copies the minimum and the maximum of the receiver to the passed tuples. 
   @param minVec The lower left of the box 
   @param maxVec The upper right of the box 
*/
- (void)getMin:(G3DTuple3f **)minVec max:(G3DTuple3f **)maxVec;

/*! 
   @method setMin:
   @abstract Sets the minimum of the receiver. 
   @param m The lower left of the box 
*/
- (void)setMin:(G3DTuple3f *)m;

/*! 
   @method min
   @abstract Returns the lower left of the receiver. 
*/
- (G3DTuple3f *)min;

/*! 
   @method setMax:
   @abstract Sets the maximum of the receiver. 
   @param m The lower left of the box 
*/
- (void)setMax:(G3DTuple3f *)m;

/*! 
   @method min
   @abstract Returns the upper right of the receiver. 
*/
- (G3DTuple3f *)max;

/*! 
   @method center
   @abstract Returns the center point of the receiver. 
*/
- (G3DTuple3f *)center;

/*! 
   @method volume
   @abstract Returns the volume of the receiver. 
*/
- (float)volume;

/*! 
   @method isEmpty
   @abstract Returns YES if the volume of the receiver is equal to 0.0, NO otherwise. 
*/
- (BOOL)isEmpty;

/*! 
   @method isEqualToBox:   
   @abstract Checks if the passed box is equal to the receiver. 
   @param aBox Another box object.
   @result Returns YES if aSphere is equivalent to the receiver, NO otherwise.
*/
- (BOOL)isEqualToBox:(G3DBox *)aBox;

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

extern NSString *G3DBoxException;

#endif




