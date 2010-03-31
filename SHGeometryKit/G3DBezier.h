//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DBezier
// Creator            	Frederic Chauvin
// Maintainer         	Frederic Chauvin, Philippe C.D. Robert
// Creation Date      	mer nov 24 20:07:40 CET 1999
//
// Copyright (c) Frederic Chauvin
//
// The SHGeometryKit is free software; you can redistribute it and/or modify it 
// under the terms of the GNU LGPL Version 2 as published by the Free 
// Software Foundation
//
//-----------------------------------------------------------------------------

#ifndef __G3DBezier_h_INCLUDE
#define __G3DBezier_h_INCLUDE

#include <Foundation/Foundation.h>

@class G3DVector3f;

/*!
@class      G3DBezier
@abstract   A generic Bezier curve representation.
@discussion A generic Bezier curve represented by an array of 3-element single-
precision control points.
*/

@interface G3DBezier : NSObject <NSCoding,NSCopying>
{
  NSMutableArray *_controlPoints; // array of G3DVector3f
}

//-----------------------------------------------------------------------------
// init and free  methods
//-----------------------------------------------------------------------------

- (id)initWithBezier:(G3DBezier*)bezier;
- (id)initWithControlPoints:(NSMutableArray*)controlPoints;

//-----------------------------------------------------------------------------
// Bezier handling methods
//-----------------------------------------------------------------------------

-(void)setControlPoints:(NSMutableArray*)controlPoints;

-(NSMutableArray*)controlPoints;

-(G3DVector3f*)pointAtParameter:(float)u;

-(G3DVector3f*)derivativeOfDegree:(unsigned)degree atParameter:(float)u;

-(BOOL)isEqualToBezier:(G3DBezier*)bezier;

//-----------------------------------------------------------------------------
// NSCopying
//-----------------------------------------------------------------------------

- (id)copyWithZone:(NSZone*)zone;

- (NSString*)description;

//-----------------------------------------------------------------------------
// NSCoding
//-----------------------------------------------------------------------------

- (void)encodeWithCoder:aCoder;

- (id)initWithCoder:aDecoder;

- (void)dealloc;

@end

#endif




