//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DLine
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
// $Id: G3DLine.h,v 1.6 2002/10/25 10:11:16 probert Exp $
//-----------------------------------------------------------------------------

#ifndef __G3DLine_h_INCLUDE
#define __G3DLine_h_INCLUDE

#import <Foundation/Foundation.h>
#import "G3DIntersecting.h"

@class G3DVector3f;
@class G3DTuple3f;
@class G3DBox;
@class G3DPlane;
@class G3DSphere;

/*!
   @class      G3DLine
   @abstract   A generic line representation.
   @discussion A generic line represented by single-precision floating point tuples,
               parametric defined as L(t) = Origin + t * Direction, where Direction is
               normalised.
*/

@interface G3DLine : NSObject < G3DIntersecting> //NSCoding NSCopying
{
    G3DTuple3f  *origin;
    G3DVector3f *direction;
    float        t;
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

/*! 
   @method init
   @abstract Creates a line initialised with the origin [0.0, 0.0, 0.0],
             direction [1.0,1.0,1.0] and factor 1.0. 
   @result  Returns the newly initialised line object or nil on error.
*/
- (id)init;

/*! 
   @method initWithOrigin:direction:factor:
   @abstract Creates a parametric line. The direction vector thereby gets is 
             normalised. This is the designated initialiser.
   @param o A 3-element tuple representing the origin
   @param d A 3-element vector representing the direction
   @param f A single-precision value representing the line factor
   @result  Returns the newly initialised line object or nil on error.
*/
- (id)initWithOrigin:(G3DTuple3f *)o direction:(G3DVector3f *)d factor:(const float)f;

/*! 
   @method initWithLine:
   @abstract Creates a line object with an existing line. 
   @param aLine Another line object
   @result  Returns the newly initialised line object or nil on error.
*/
- (id)initWithLine:(G3DLine *)aLine;

//-----------------------------------------------------------------------------
// math
//-----------------------------------------------------------------------------

/*! 
   @method isParallel:
   @abstract Tests if the receiver is parallel to the passed line. 
   @param aLine Another line object
   @result  Returns YES if the 2 lines are parallel, NO otherwise.
*/
- (BOOL)isParallel:(G3DLine *)aLine;

/*! 
   @method intersectsObject:
   @abstract Tests if the receiver intersects the passed object. The method raises a
             G3DLineException if it fails to perform the test. 
   @param anObject Another mathematical primitive
   @result  Returns YES if the 2 objects intersect, NO otherwise.
*/
- (BOOL)intersectsObject:(id<G3DIntersecting>)anObject;

/*! 
   @method intersectsLine:
   @abstract Tests if the receiver intersects the passed line. 
   @param ln Another line object
   @result  Returns YES if the 2 lines intersect, NO otherwise.
*/
- (BOOL)intersectsLine:(G3DLine *)ln;

/*! 
   @method intersectsSphere:
   @abstract Tests if the receiver intersects the passed sphere. 
   @param sphere A sphere object
   @result  Returns YES if the line intersects the sphere, NO otherwise.
*/
- (BOOL)intersectsSphere:(G3DSphere *)sphere;

/*! 
   @method intersectsBox:
   @abstract Tests if the receiver intersects the passed box. 
   @param box A box object
   @result  Returns YES if the line intersects the box, NO otherwise.
*/
- (BOOL)intersectsBox:(G3DBox *)box;

/*! 
   @method intersectsPlane:at:
   @abstract Tests if the receiver intersects the passed plane. The point of intersection
             is returned if a valid tuple is passed. 
   @param plane A plane object
   @param pt A 3-element tuple
   @result  Returns YES if the line intersects the box, NO otherwise.
*/
- (BOOL)intersectsPlane:(G3DPlane *)plane at:(G3DTuple3f *)pt;

/*! 
   @method transform:
   @abstract Transforms the receiver by the passed 4 by 4 matrix. 
   @param aMatrix A 4 by 4 transformation matrix
*/
- (void)transform:(G3DMatrix4f *)aMatrix;

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

/*! 
   @method setFactor:
   @abstract Sets the line factor which must be bigger than 0.0! 
   @param val A single-precision value 
*/
- (void)setFactor:(const float)val;

/*! 
   @method factor
   @abstract Returns the single-precision line factor. 
*/
- (float)factor;

/*! 
   @method setOrigin:
   @abstract Sets the line origin. 
   @param o A 3-element tuple 
*/
- (void)setOrigin:(G3DTuple3f *)o;

/*! 
   @method origin
   @abstract Returns the 3-element line origin. 
*/
- (G3DTuple3f *)origin;

/*! 
   @method setDirection:
   @abstract Sets the line direction. The vector is normalised beforehand. 
   @param d A 3-element vector 
*/
- (void)setDirection:(G3DVector3f *)d;

/*! 
   @method direction
   @abstract Returns the 3-element line direction vector. 
*/
- (G3DVector3f *)direction;

/*! 
   @method isEqualToLine:   
   @abstract Checks if the passed line is equal to the receiver. 
   @param aLine Another line object.
   @result Returns YES if aLine is equivalent to the receiver, NO otherwise.
*/
- (BOOL)isEqualToLine:(G3DLine *)aLine;

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

extern NSString *G3DLineException;

#endif




