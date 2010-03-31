//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class              	G3DIntersecting
// Creator            	Philippe C.D. Robert
// Maintainer         	Philippe C.D. Robert
// Creation Date      	2000-11-28 11:03:21 +0000
//
// Copyright (c) Philippe C.D. Robert
//
// The SHGeometryKit is free software; you can redistribute it and/or modify it 
// under the terms of the GNU LGPL Version 2 as published by the Free 
// Software Foundation
//
// $Id: G3DIntersecting.h,v 1.5 2002/10/21 19:32:54 probert Exp $
//
//-----------------------------------------------------------------------------

@class G3DMatrix4f;

/*!
   @protocol G3DIntersecting
   @discussion The G3DIntersecting informal protocol defines methods that GNU 3DKit classes must
               implement to make themselves available for intersection testing.
*/

@protocol G3DIntersecting <NSObject>

/*! 
   @method intersectsObject:   
   @abstract Checks if the receiver intersects the passed object. 
   @discussion Returns YES if the receiver intersects the passed object. The 
               argument...
   @result  Returns YES if the receiver intersects the passed object or NO otherwise.
*/
- (BOOL)intersectsObject:(id)anObject;

/*! 
   @method transform:   
   @abstract Transforms the receiver by the passed matrix. 
   @discussion Transforms the receiver by multiplying it by the passed matrix...
   @result  Transformed primitive object.
*/
- (void)transform:(G3DMatrix4f *)m;

@end
