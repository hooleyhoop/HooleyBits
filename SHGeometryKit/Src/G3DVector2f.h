//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DVector2f
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
// $Id: G3DVector2f.h,v 1.4 2002/10/25 10:14:51 probert Exp $
//-----------------------------------------------------------------------------

/*!
   @class      G3DVector2f
   @abstract   A generic 2-element vector representation. 
   @discussion A generic 2-element vector that is represented by single-precision 
               floating point coordinates.
*/

#ifndef __G3DVector2f_h_INCLUDE
#define __G3DVector2f_h_INCLUDE

#import <Foundation/Foundation.h>
#import "G3DTuple2f.h"

@interface G3DVector2f : G3DTuple2f
{
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

/*! 
   @method initWithVector:   
   @abstract Creates a vector initialised with another vector by invoking 
             initWithX:y:. 
   @param vec Another vector object.
   @result  Returns the newly initialised vector object or nil on error.
*/
- (id)initWithVector:(G3DVector2f *)vec;

//-----------------------------------------------------------------------------
// Math
//-----------------------------------------------------------------------------

/*! 
   @method vectorByAdding:   
   @abstract Vector addition. 
   @param aVector Another vector object.
   @result  Returns the autoreleased vector sum of the receiver and aVector.
*/
- (G3DVector2f *)vectorByAdding:(G3DVector2f *)aVector;

/*! 
   @method vectorBySubtracting:   
   @abstract Vector subtraction. 
   @param aVector Another vector object.
   @result  Returns the autoreleased vector difference of the receiver and aVector.
*/
- (G3DVector2f *)vectorBySubtracting:(G3DVector2f *)aVector;

/*! 
   @method vectorByMultiplyingBy:   
   @abstract Vector scalar multiplication. 
   @param aVector The scalar value
   @result  Returns the autoreleased scalar product of the receiver and aScalar.
*/
- (G3DVector2f *)vectorByMultiplyingBy:(float)aScalar;

/*! 
   @method vectorByDividingBy:   
   @abstract Vector scalar division. 
   @param aVector The scalar value
   @result  Returns the autoreleased scalar division of the receiver and aScalar.
*/
- (G3DVector2f *)vectorByDividingBy:(float)aScalar;

/*! 
   @method dotProduct:   
   @abstract Computes the dot product of the this vector and vector aVec. 
   @param aVector Another vector
   @result  Returns a single-precision value representing the the dot product of the receiver and the passed vector.
*/
- (float)dotProduct:(G3DVector2f *)aVec;

/*! 
   @method length   
   @abstract Vector length. 
   @result  Returns the length of the receiver.
*/
- (float)length;

/*! 
   @method squaredLength   
   @abstract Vector squared length. 
   @result  Returns a single-precision value representing the squared length of the receiver.
*/
- (float)squaredLength;

/*! 
   @method normalise   
   @abstract Normalies this vector in place. 
*/
- (void)normalise;

/*! 
   @method normalisedVector   
   @abstract Vector normalisation. 
   @result  Returns an autoreleased, normalised copy of the receiver.
*/
- (G3DVector2f *)normalisedVector;

@end

#endif







