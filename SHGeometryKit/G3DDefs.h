/*-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class              	G3DDefs
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
// $Id: G3DDefs.h,v 1.9 2002/10/25 10:09:33 probert Exp $
//
//---------------------------------------------------------------------------*/

/*!
  @header G3DDefs
  Some assorted macros and defines.
*/

#ifndef __G3DDefs_h_INCLUDE
#define __G3DDefs_h_INCLUDE

#include <limits.h>
#include <math.h>

/******************************************************************************
 *
 * Miscellaneous defines 
 *
 *****************************************************************************/

/*!
   @defined DEG2RAD
   @discussion Converts degree values into radian values. The numerical
               factor is computed by evaluating PI / 180.0
*/
#define DEG2RAD  0.017453292519943295

/*!
   @defined RAD2DEG
   @discussion Converts radian values into degree values. The numerical
               factor is computed by evaluating 180.0 / PI.
*/
#define RAD2DEG  57.29577951308232

#ifndef __G3DIE__
/*!
   @defined __G3DIE__
*/
#define __G3DIE__ __inline__ extern
#endif

#ifndef __G3DI__
/*!
   @defined __G3DI__
*/
#define __G3DI__ __inline__
#endif

#ifndef __G3DE__
/*!
   @defined __G3DE__
*/
#define __G3DE__ extern
#endif

#ifndef CFLOAT
/*!
   @defined CFLOAT
*/
#define CFLOAT const float
#endif

#ifndef CDOUBLE
/*!
   @defined CDOUBLE
*/
#define CDOUBLE const double
#endif

/******************************************************************************
 *
 * Macros with 1 argument as defined i.e. in Graphics Gem II
 *
 *****************************************************************************/

#ifndef ABS
/*!
   @defined ABS
   @discussion Returns the absolut value of a.
*/
#define ABS(a) (((a)<0) ? -(a) : (a))
#endif

#ifndef FLOOR
/*!
   @defined FLOOR
   @discussion Rounds to the largest integral value not greater than a.
*/
#define FLOOR(a) (((a)<0) ? (int)(a) : -(int)(-a))
#endif

#ifndef CEIL
/*!
   @defined CEIL
   @discussion Rounds to the smallest integral value not greater than a.
*/
#define CEIL(a) (((a)==(int)(a)) ? (a) : (a)>0 ? 1+(int)(a) : -(1+ (int)(-a)))
#endif

#ifndef ROUND
/*!
   @defined ROUND
   @discussion Rounds the parameter a.
*/
#define ROUND(a) (((a)>0) ? (int)(a+0.5) : -(int)(0.5-a))
#endif

#ifndef ZSGN
/*!
   @defined ZSGN
   @discussion Returns -1 or 1 depending on the sign of a or 0 if a is equal to 0.
*/
#define ZSGN(a) (((a)<0) ? -1 : ((a)>0) ? 1 : 0)
#endif

#ifndef SGN
/*!
   @defined SGN
   @discussion Returns -1 or 0 depending on the sign of a.
*/
#define SGN(a) (((a)<0) ? -1 : 0)
#endif

#ifndef SQR
/*!
   @defined SQR
   @discussion Returns the square of a.
*/
#define SQR(a) ((a)*(a))
#endif

/******************************************************************************
 *
 * Macros with 2 argument as defined i.e. in Graphics Gem II
 *
 *****************************************************************************/

#ifndef MIN
/*!
   @defined MIN
   @discussion Returns the minimum of a and b.
*/
#define MIN(a,b) (((a)<(b)) ? (a) : (b)) 
#endif

#ifndef MAX
/*!
   @defined MAX
   @discussion Returns the maximum of a and b.
*/
#define MAX(a,b) (((a)>(b)) ? (a) : (b)) 
#endif

#ifndef SWAP
/*!
   @defined SWAP
   @discussion Swaps a and b in place.
*/
#define SWAP(a,b) { a^=b; b^=a; a^=b} 
#endif

/******************************************************************************
 *
 * Linear interpolation between l and h
 *
 *****************************************************************************/

#ifndef LERP
/*!
   @defined LERP
   @discussion Linear interpolation between l and h.
*/
#define LERP(v,l,h) ((l) + (((h)-(l)) * (v))) 
#endif

/******************************************************************************
 *
 * Clamp to range [l,h]
 *
 *****************************************************************************/

#ifndef CLAMP
/*!
   @defined CLAMP
   @discussion Clamps the scalar v to l and h.
*/
#define CLAMP(v,l,h) ((v)<(l) ? (l) : (v)>(h) ? (h) : (v)) 
#endif

/******************************************************************************
 *
 * Mathematical Constants
 *
 *****************************************************************************/

#ifndef PI
#ifdef M_PI
/*!
   @defined PI
   @discussion The number PI
*/
#define PI  M_PI
#else
#define PI  3.14159265358979323846
#endif
#endif

#ifndef TWOPI
/*!
   @defined TWOPI
   @discussion PI multiplied by 2
*/
#define TWOPI  6.2831853071795864
#endif

#ifndef PIOVER2
#ifdef M_PI_2
/*!
   @defined PIOVER2
   @discussion PI divided by 2
*/
#define PIOVER2 M_PI_2
#else
#define PIOVER2  1.5707963267948966
#endif
#endif

#ifndef E
#ifdef M_E
/*!
   @defined E
   @discussion The Euler number
*/
#define E M_E
#else
#define E  2.7182818284590452
#endif
#endif

#ifndef SQRT2
#ifdef M_SQRT2
/*!
   @defined SQRT2
   @discussion The square root of 2
*/
#define SQRT2 M_SQRT2
#else
#define SQRT2  1.4142135623730951
#endif
#endif

#ifndef SQRT3
/*!
   @defined SQRT3
   @discussion The square root of 3
*/
#define SQRT3 1.7320508075688772
#endif

#ifndef G3DEPSILON
/*!
   @defined G3DEPSILON
   @discussion A really small epsilon value
*/
#define G3DEPSILON 1.0e-8
#endif

#ifndef G3DBIGEPSILON
/*!
   @defined G3DBIGEPSILON
   @discussion A not so small epsilon value
*/
#define G3DBIGEPSILON 0.00001
#endif

#endif
