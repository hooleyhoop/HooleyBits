//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DTrigonometry
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
// $Id: G3DTrigonometry.h,v 1.4 2002/10/21 19:27:11 probert Exp $
//-----------------------------------------------------------------------------

#ifndef __G3DTrigonometry_h_INCLUDE
#define __G3DTrigonometry_h_INCLUDE

#import <Foundation/Foundation.h>

/*!
   @class      G3DTrigonometry
   @abstract   Fast trigonometry computations via table lookups.
   @discussion A special purpose classes implementing optimised trigonometry functions
               via precalculated table lookups.
*/

@interface G3DTrigonometry : NSObject
{
}

//-----------------------------------------------------------------------------
// class methods
//-----------------------------------------------------------------------------

/*! 
   @method initialize   
   @abstract Initialises the lookup tables. 
*/
+ (void)initialize;

/*! 
   @method fastSinf:   
   @abstract Returns the sinus of the angle a. 
   @param a An integer value representing an angle in the range [0, 3600]  
   @result  Returns a single-precision sinus value.
*/
+ (float)fastSinf:(const int)a;

/*! 
   @method fastSin:   
   @abstract Returns the sinus of the angle a. 
   @param a An integer value representing an angle in the range [0, 3600]  
   @result  Returns a double-precision sinus value.
*/
+ (double)fastSin:(const int)a;

/*! 
   @method fastCosf:   
   @abstract Returns the cosinus of the angle a. 
   @param a An integer value representing an angle in the range [0, 3600]  
   @result  Returns a single-precision cosinus value.
*/
+ (float)fastCosf:(const int)a;

/*! 
   @method fastCos:   
   @abstract Returns the cosinus of the angle a. 
   @param a An integer value representing an angle in the range [0, 3600]  
   @result  Returns a double-precision cosinus value.
*/
+ (double)fastCos:(const int)a;

@end

extern NSString *G3DTrigonometryTableAllocationException;

#endif




