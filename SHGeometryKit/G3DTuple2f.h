//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DTuple2f
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
// $Id: G3DTuple2f.h,v 1.4 2002/10/25 10:14:51 probert Exp $
//-----------------------------------------------------------------------------

/*!
   @class      G3DTuple2d
   @abstract   A generic 2-element tuple represenation. 
   @discussion A generic 2-element tuple that is represented by single-precision 
               floating point coordinates.
*/

#ifndef __G3DTuple2f_h_INCLUDE
#define __G3DTuple2f_h_INCLUDE

#import <Foundation/Foundation.h>

@interface G3DTuple2f : NSObject <NSCoding, NSCopying>
{
  float _tuple[2];
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

/*! 
   @method init   
   @abstract Creates a tuple initialised with the elements [0.0, 0.0]
             by invoking initWithElements:. 
   @result  Returns the newly initialised tuple object or nil on error.
*/
- (id)init;

/*! 
   @method initWithElements:   
   @abstract Creates a tuple initialised with the elements 
             specified in the C array. This is the designated initialiser!
   @param vals A C array specifying the tuple.
   @result  Returns the newly initialised tuple object or nil on error.
*/
- (id)initWithElements:(const float *)vals;

/*! 
   @method initWithX:y:   
   @abstract Creates a tuple initialised with the elements X and Y by 
             invoking initWithElements:.
   @param x single-precision x value.
   @param y single-precision y value.
   @result  Returns the newly initialised tuple object or nil on error.
*/
- (id)initWithX:(float)x y:(float)y;

/*! 
   @method initWithTuple:   
   @abstract Creates a tuple initialised with another tuple by invoking 
             initWithElements:. 
   @param aTuple Another tuple object.
   @result  Returns the newly initialised tuple object or nil on error.
*/
- (id)initWithTuple:(G3DTuple2f *)aTuple;

//-----------------------------------------------------------------------------
// Math
//-----------------------------------------------------------------------------

/*! 
   @method absolute   
   @abstract Sets each component of this tuple to its absolute value.
*/
- (void)absolute;

/*! 
   @method clamp   
   @abstract Clamps this tuple to the range [0.0, 1.0].
*/
- (void)clamp;

/*! 
   @method clamp   
   @abstract Clamps this tuple to the passed range values.
   @param low The lowest value in this tuple after clamping.
   @param high The highest value in this tuple after clamping.
*/
- (void)clampLow:(float)low high:(float)high;

/*! 
   @method addTuple2f:   
   @abstract Sets the value of this tuple to the vector sum of itself and aTuple. 
   @param aTuple The tuple to add.
*/
- (void)addTuple2f:(G3DTuple2f *)aTuple;

/*! 
   @method subTuple2f:   
   @abstract Sets the value of this tuple to the vector difference of itself and 
             aTuple. 
   @param aTuple The tuple to substract.
*/
- (void)subTuple2f:(G3DTuple2f *)aTuple;

/*! 
   @method multiplyBy:   
   @abstract Sets the value of this tuple to the scalar multiplication of itself by 
             the passed single-precision value.
   @param aScalar The scalar value.
*/
- (void)multiplyBy:(float)aScalar;

/*! 
   @method divideBy:   
   @abstract Sets the value of this tuple to the scalar division of itself by 
             the passed single-precision value. Raises a G3DTuple2fException exception
             if aScalar is equal to 0.0.
   @param aScalar The scalar value.
*/
- (void)divideBy:(float)aScalar;

/*! 
   @method interpolateBetween:and:
   @abstract Sets the value of this tuple to the linear interpolation of the 2 tuples
             using the single-precision factor value.
   @param first The first tuple.
   @param second The second tuple.
   @param factor The factor scalar value.
   @result Sets the values of the tuple to (1-factor)*first + factor*second
*/
- (void)interpolateBetween:(G3DTuple2f *)first and:(G3DTuple2f *)second factor:(float)factor;

/*! 
   @method negate:   
   @abstract Negates the value of this tuple in place.
*/
- (void)negate;

/*! 
   @method isEqualToTuple:   
   @abstract Checks if the passed object is a tuple, if it is of the same dimension 
             and if all elements of the receiver are equal to the corresponding 
             elements in the passed tuple.
   @param anObj Another tuple.
   @result Returns YES if anObj is equivalent to the receiver, NO otherwise.
*/
- (BOOL)isEqualToTuple:(id)anObj;

//-----------------------------------------------------------------------------
// Accessing
//-----------------------------------------------------------------------------

/*! 
   @method elements   
   @abstract Returns the pointer to the receiver's single-precision element values.
   @result Returns double pointer.
*/
- (const float *)elements;

/*! 
   @method setElements:   
   @abstract Set the values of the receiver to the passed single-precision elements.
   @param values The new single-precision tuple values.
*/
- (void)setElements:(const float *)values;

/*! 
   @method getElements:   
   @abstract Copies the receiver's single-precision elements into the passed buffer.
   @param values A 2-element single-precision array.
   @result Returns the receivers elements.
*/
- (void)getElements:(float *)values;

/*! 
   @method x   
   @abstract Returns the 1st element of the tuple.
   @result Returns a single-precision value representing the 1st element of the tuple.
*/
- (float)x;

/*! 
   @method setX:
   @abstract Sets the 1st element of the tuple.
   @param x A single-precision value.
*/
- (void)setX:(float)x;

/*! 
   @method y
   @abstract Returns the 2nd element of the tuple.
   @result Returns a single-precision value representing the 2nd element of the tuple.
*/
- (float)y;

/*! 
   @method setY:
   @abstract Sets the 2nd element of the tuple.
   @param y A single-precision value.
*/
- (void)setY:(float)y;

/*! 
   @method setValuesWithTuple:
   @abstract Sets the elements of the receiver to those of the passed tuple.
   @param aTuple A 2-element single-precision tuple.
*/
- (void)setValuesWithTuple:(G3DTuple2f *)aTuple;

/*! 
   @method description
   @abstract Returns a description of the tuple.
   @result Returns a NSString object describing the receiver's elements.
*/
- (NSString *)description;

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

extern NSString *G3DTuple2fException;

#endif




