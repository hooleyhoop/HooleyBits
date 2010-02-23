//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DQuaterniond
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
// $Id: G3DQuaterniond.h,v 1.8 2002/10/25 10:14:51 probert Exp $
//-----------------------------------------------------------------------------

#ifndef __G3DQuaterniond_h_INCLUDE
#define __G3DQuaterniond_h_INCLUDE

#import <Foundation/Foundation.h>
#import "G3DTuple4d.h"

@class G3DMatrix3d;
@class G3DMatrix4d;
@class G3DVector3d;

/*!
   @class      G3DQuaterniond
   @abstract   A generic 4-element quaternion represenation.
   @discussion A generic 4-element represenation that is represented by
               double-precision floating point coordinates. The mathematical
               routines are partially based on the paper from Nick Bobick,
               GameDeveloper Vol.2, Issue 26.
*/

@interface G3DQuaterniond : G3DTuple4d
{
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

/*! 
   @method init   
   @abstract Creates a unity quaternion. 
   @result  Returns the newly initialised quaternion object or nil on error.
*/
- (id)init;

/*! 
   @method initWithElements:   
   @abstract Creates a quaternion with the passed elements. 
   @param values Quaternion elements
   @result Returns the newly initialised quaternion object or nil on error.
*/
- (id)initWithElements:(const double *)values;

/*! 
   @method initWithQuaternion:   
   @abstract Creates a quaternion with aTuple. 
   @param aTuple Another quaternion object
   @result Returns the newly initialised quaternion object or nil on error.
*/
- (id)initWithQuaternion:(G3DQuaterniond *)aTuple;

/*! 
   @method initWithMatrix4d:   
   @abstract Creates a quaternion from the rotational component of aMatrix. 
   @param aMatrix A rotation matrix
   @result Returns the newly initialised quaternion object or nil on error.
*/
- (id)initWithMatrix4d:(G3DMatrix4d *)aMatrix;

/*! 
   @method initWithEulerRep:   
   @abstract Creates a quaternion from Euler values. 
   @param ev Euler values
   @result Returns the newly initialised quaternion object or nil on error.
*/
- (id)initWithEulerRep:(double *)ev;

//-----------------------------------------------------------------------------
// Math
//-----------------------------------------------------------------------------

/*! 
   @method norm   
   @abstract Computes the norm of the receiver such as norm = sum(a_i^2). 
   @result Returns a double-precision value representing the norm of the receiver.
*/
- (double)norm;

/*! 
   @method conjugate   
   @abstract Negates the value of of each of the receivers coordinates in place such as 
             q* = [-v,w]. 
*/
- (void)conjugate;

/*! 
   @method conjugatedQuaternion   
   @abstract Copies the receiver and conjugates the copy afterwards.
   @result Returns an autoreleased, conjugated copy of the receiver.
*/
- (G3DQuaterniond *)conjugatedQuaternion;

/*! 
   @method invert   
   @abstract Inverts the receiver in place such as q^-1 = q* / N(q).
*/
- (void)invert;

/*! 
   @method invertedQuaternion   
   @abstract Copies the receiver and inverts the copy afterwards.
   @result Returns an autoreleased, inverted copy of the receiver.
*/
- (G3DQuaterniond *)invertedQuaternion;

/*! 
   @method normalise   
   @abstract Normalises the receiver in place such as q2 = q/L(q).
*/
- (void)normalise;

/*! 
   @method normalisedQuaternion   
   @abstract Copies the receiver and normalises the copy afterwards.
   @result Returns an autoreleased, normalised copy of the receiver.
*/
- (G3DQuaterniond *)normalisedQuaternion;

/*! 
   @method interpolate:factor:   
   @abstract Computes the spherical linear interpolation (SLERP) between the receiver and quat 
             and stores the result in the receiver.
   @param quat Another quaternion
   @param val The double-precision interpolation value
*/
- (void)interpolate:(G3DQuaterniond *)quat factor:(const double)val;

/*! 
   @method multiplyByQuaternion:   
   @abstract Multiplies the receiver by another quaternion and stores the result in the receiver.
   @param a Another quaternion
*/
- (void)multiplyByQuaternion:(G3DQuaterniond *)a;

/*! 
   @method multiplyByQuaternion:and:   
   @abstract Multiplies 2 quaternions and stores the result in the receiver.
   @param a First quaternion
   @param b Second quaternion
*/
- (void)multiplyByQuaternion:(G3DQuaterniond *)a and:(G3DQuaterniond *)b;

/*! 
   @method multiplyByInvertedQuaternion:   
   @abstract Multiplies the receiver by the inverse of another quaternion and stores the result in 
             the receiver.
   @param a Another quaternion
*/
- (void)multiplyByInvertedQuaternion:(G3DQuaterniond *)a;

/*! 
   @method multiplyByQuaternion:andInverted:   
   @abstract Multiplies the quaternion a by the inverse of quaternion b and stores the result in 
             the receiver.
   @param a First quaternion
   @param b Second quaternion
*/
- (void)multiplyByQuaternion:(G3DQuaterniond *)a andInverted:(G3DQuaterniond *)b;

/*! 
   @method multiplyByScalar:   
   @abstract Multiplies the receiver by the scalar value.
   @param value Double-precision scalar value
*/
- (void)multiplyByScalar:(double)value;

/*! 
   @method addQuaternion:   
   @abstract Adds aQuat to the receiver.
   @param aQuat Another quaternion
*/
- (void)addQuaternion:(G3DQuaterniond *)aQuat;

/*! 
   @method subQuaternion:   
   @abstract Subtracts aQuat from the receiver.
   @param aQuat Another quaternion
*/
- (void)subQuaternion:(G3DQuaterniond *)aQuat;

/*! 
   @method rotateByAngle:axis:   
   @abstract Creates a new quaternion q from angle and aVec and multiplies the receiver
             by q. The result is normalised again.
   @param angle Double-precision angle value
   @param aVec An axis vector
*/
- (void)rotateByAngle:(const double)angle axis:(G3DVector3d *)aVec;

//-----------------------------------------------------------------------------
// Accessor methods
//-----------------------------------------------------------------------------

/*! 
   @method setQuaternionWithMatrix4d:   
   @abstract Initialises the receiver with the rotational component of matrix m.
   @param m A matrix object
*/
- (void)setQuaternionWithMatrix4d:(G3DMatrix4d *)m;

/*! 
   @method rotationMatrix4d   
   @abstract Computes a rotation matrix based upon the receiver.
   @result Returns the rotation in 4 by 4 matrix representation.
*/
- (G3DMatrix4d *)rotationMatrix4d;

/*! 
   @method rotationMatrix3d   
   @abstract Computes a rotation matrix based upon the receiver.
   @result Returns the rotation in 3 by 3 matrix representation.
*/
- (G3DMatrix3d *)rotationMatrix3d;

/*! 
   @method setQuaternion:   
   @abstract Initialises the receiver with the quaternion q.
   @param q Another quaternion.
*/
- (void)setQuaternion:(G3DQuaterniond *)q;

/*! 
   @method setVector:angle:   
   @abstract Initialises the receiver from the passed angle and axis vector.
   @param vec An axis vector.
   @param val An angle.
*/
- (void)setVector:(G3DVector3d *)vec angle:(double)val;

/*! 
   @method angleAxisRepresentation
   @abstract Computes an angle and axis representation of the receiver.
   @result Returns a 4-element double-precision tuple object. The axis is thereby stored in the
           first 3 elements and the angle in the last element of the tuple.
*/
- (G3DTuple4d *)angleAxisRepresentation;

@end

extern NSString *G3DQuaterniondException;

#endif





