//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DQuaternionf
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
// $Id: G3DQuaternionf.h,v 1.8 2002/10/25 10:14:51 probert Exp $
//-----------------------------------------------------------------------------

#ifndef __G3DQuaternionf_h_INCLUDE
#define __G3DQuaternionf_h_INCLUDE

#import <Foundation/Foundation.h>
#import "G3DTuple4f.h"

@class G3DMatrix3f;
@class G3DMatrix4f;
@class G3DVector3f;

/*!
   @class      G3DQuaternionf
   @abstract   A generic 4-element quaternion represenation.
   @discussion A generic 4-element represenation that is represented by
               single-precision floating point coordinates. The mathematical
               routines are partially based on the paper from Nick Bobick,
               GameDeveloper Vol.2, Issue 26.
*/

@interface G3DQuaternionf : G3DTuple4f
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
- (id)initWithElements:(const float *)values;

/*! 
   @method initWithQuaternion:   
   @abstract Creates a quaternion with aTuple. 
   @param aTuple Another quaternion object
   @result Returns the newly initialised quaternion object or nil on error.
*/
- (id)initWithQuaternion:(G3DQuaternionf *)aTuple;

/*! 
   @method initWithMatrix4f:   
   @abstract Creates a quaternion from the rotational component of aMatrix. 
   @param aMatrix A rotation matrix
   @result Returns the newly initialised quaternion object or nil on error.
*/
- (id)initWithMatrix4f:(G3DMatrix4f *)aMatrix;

/*! 
   @method initWithEulerRep:   
   @abstract Creates a quaternion from Euler values. 
   @param ev Euler values
   @result Returns the newly initialised quaternion object or nil on error.
*/
- (id)initWithEulerRep:(float *)ev;

//-----------------------------------------------------------------------------
// Math
//-----------------------------------------------------------------------------

/*! 
   @method norm   
   @abstract Computes the norm of the receiver such as norm = sum(a_i^2). 
   @result Returns a single-precision value representing the norm of the receiver.
*/
- (float)norm;

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
- (G3DQuaternionf *)conjugatedQuaternion;

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
- (G3DQuaternionf *)invertedQuaternion;

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
- (G3DQuaternionf *)normalisedQuaternion;

/*! 
   @method interpolate:factor:   
   @abstract Computes the spherical linear interpolation (SLERP) between the receiver and quat 
             and stores the result in the receiver.
   @param quat Another quaternion
   @param val The double-precision interpolation value
*/
- (void)interpolate:(G3DQuaternionf *)quat factor:(const float)val;

/*! 
   @method multiplyByQuaternion:   
   @abstract Multiplies the receiver by another quaternion and stores the result in the receiver.
   @param a Another quaternion
*/
- (void)multiplyByQuaternion:(G3DQuaternionf *)a;

/*! 
   @method multiplyByQuaternion:and:   
   @abstract Multiplies 2 quaternions and stores the result in the receiver.
   @param a First quaternion
   @param b Second quaternion
*/
- (void)multiplyByQuaternion:(G3DQuaternionf *)a and:(G3DQuaternionf *)b;

/*! 
   @method multiplyByInvertedQuaternion:   
   @abstract Multiplies the receiver by the inverse of another quaternion and stores the result in 
             the receiver.
   @param a Another quaternion
*/
- (void)multiplyByInvertedQuaternion:(G3DQuaternionf *)a;

/*! 
   @method multiplyByQuaternion:andInverted:   
   @abstract Multiplies the quaternion a by the inverse of quaternion b and stores the result in 
             the receiver.
   @param a First quaternion
   @param b Second quaternion
*/
- (void)multiplyByQuaternion:(G3DQuaternionf *)a andInverted:(G3DQuaternionf *)b;

/*! 
   @method multiplyByScalar:   
   @abstract Multiplies the receiver by the scalar value.
   @param value Single-precision scalar value
*/
- (void)multiplyByScalar:(float)value;

/*! 
   @method addQuaternion:   
   @abstract Adds aQuat to the receiver.
   @param aQuat Another quaternion
*/
- (void)addQuaternion:(G3DQuaternionf *)aQuat;

/*! 
   @method subQuaternion:   
   @abstract Subtracts aQuat from the receiver.
   @param aQuat Another quaternion
*/
- (void)subQuaternion:(G3DQuaternionf *)aQuat;

/*! 
   @method rotateByAngle:axis:   
   @abstract Creates a new quaternion q from angle and aVec and multiplies the receiver
             by q. The result is normalised again.
   @param angle Double-precision angle value
   @param aVec An axis vector
*/
- (void)rotateByAngle:(const float)angle axis:(G3DVector3f *)aVec;

//-----------------------------------------------------------------------------
// Accessor methods
//-----------------------------------------------------------------------------

/*! 
   @method setQuaternionWithMatrix4f:   
   @abstract Initialises the receiver with the rotational component of matrix m.
   @param m A matrix object
*/
- (void)setQuaternionWithMatrix4f:(G3DMatrix4f *)m;

/*! 
   @method rotationMatrix4f   
   @abstract Computes a rotation matrix based upon the receiver.
   @result Returns the rotation in 4 by 4 matrix representation.
*/
- (G3DMatrix4f *)rotationMatrix4f;

/*! 
   @method rotationMatrix3f   
   @abstract Computes a rotation matrix based upon the receiver.
   @result Returns the rotation in 3 by 3 matrix representation.
*/
- (G3DMatrix3f *)rotationMatrix3f;

/*! 
   @method setQuaternion:   
   @abstract Initialises the receiver with the quaternion q.
   @param q Another quaternion.
*/
- (void)setQuaternion:(G3DQuaternionf *)q;

/*! 
   @method setVector:angle:   
   @abstract Initialises the receiver from the passed angle and axis vector.
   @param vec An axis vector.
   @param val An angle.
*/
- (void)setVector:(G3DVector3f *)vec angle:(float)val;

/*! 
   @method angleAxisRepresentation
   @abstract Computes an angle and axis representation of the receiver.
   @result Returns a 4-element double-precision tuple object. The axis is thereby stored in the
           first 3 elements and the angle in the last element of the tuple.
*/
- (G3DTuple4f *)angleAxisRepresentation;

@end

extern NSString *G3DQuaternionfException;

#endif





