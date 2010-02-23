//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DPlane
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
// $Id: G3DPlane.m,v 1.3 2002/10/25 10:13:24 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DPlane.h"

#import "G3DTuple3f.h"
#import "G3DVector3f.h"
#import "G3DMatrix4f.h"
#import "G3DBox.h"
#import "G3DLine.h"
#import "G3DSphere.h"
#import "G3DFunctions.h"
#import "G3DDefs.h"
#import "G3DVectorFunc.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

NSString *G3DPlaneException = @"G3DPlaneException";

@implementation G3DPlane

static Class G3DLineClass;
static Class G3DSphereClass;
static Class G3DBoxClass;
static Class G3DPlaneClass;

+ (void)initialize
{
  static BOOL tooLate = NO;
  
  if (tooLate == NO) 
  {
    G3DLineClass   = [G3DLine class];
    G3DSphereClass = [G3DSphere class];
    G3DBoxClass    = [G3DBox class];
    G3DPlaneClass  = [G3DPlane class];
    
    tooLate = YES;
  }
}

//-----------------------------------------------------------------------------
// init and free
//-----------------------------------------------------------------------------

- (id)init
{
  return [self initWithElements:(float*)G3DDefaultPlane4f];
}

- (id)initWithElements:(const float *)vals
{
  if ((self = [super init])) {
    G3DCopyVector4fv(_values,vals);
  }
  return self;
}

- (id)initWithNormal:(G3DVector3f *)norm point:(G3DTuple3f *)aTuple
{
  float vals[4];
  float tmp[3];

  G3DCopyVector3fv(tmp,[norm elements]);
  G3DNormalise3fv(vals,tmp);

  G3DCopyVector3fv(tmp,[aTuple elements]);
  vals[3] = G3DScalarProduct3fv(_values,tmp);;

  return [self initWithElements:vals];
}

- (id)initWithPlane:(G3DPlane *)aPlane
{
  return [self initWithElements:(float*)[aPlane elements]];
}

//-----------------------------------------------------------------------------
// math
//-----------------------------------------------------------------------------

- (void)shiftByDistance:(const float)factor
{
  _values[3] += factor;
}

- (BOOL)intersectsObject:(id<G3DIntersecting>)anObject
{
  Class objClass = [anObject class];

  if (objClass == G3DLineClass) {
    return [self intersectsLine:anObject at:nil];
  }
  else if (objClass == G3DSphereClass) {
    return [self intersectsSphere:anObject];
  }
  else if (objClass == G3DBoxClass) {
    return [self intersectsBox:anObject];
  }
  else if (objClass == G3DPlaneClass) {
    return [self intersectsPlane:anObject];
  }
  else {
    [NSException raise:G3DPlaneException format:@"Unknown volume class!"];
  }
  return NO;
}

- (BOOL)intersectsLine:(G3DLine *)line at:(G3DTuple3f *)pt
{
    float isect[3];
    int ret = G3DIntersectLinePlanef( isect, 
                                      [[line direction] elements], 
				      [[line origin] elements], 
				      _values);

    if ( ret && pt ) {
	[pt setElements:isect];
    }

    return ret;
}

- (BOOL)intersectsSphere:(G3DSphere *)sph
{
  return [sph intersectsPlane:self];
}

- (BOOL)intersectsPlane:(G3DPlane *)pl
{
  float pl2[3];
  float dir[3];
  float dir2[3];
  const float *tmp = [[pl normal] elements];

  // The other 'plane'  
  pl2[0] = tmp[0];
  pl2[1] = tmp[1];
  pl2[2] = tmp[2];

  G3DVectorProduct3fv(dir,_values,pl2);

  dir2[0] = dir[0]*dir[0];
  dir2[1] = dir[1]*dir[1];
  dir2[2] = dir[2]*dir[2];

  if (dir2[2] > dir2[1] && dir2[2] > dir2[0] && dir2[2] > G3DEPSILON) {
    // On XY Plane...
    return YES;
  }
  else if (dir2[1] > dir2[0] && dir2[1] > G3DEPSILON) {
    // On XZ Plane...
    return YES;
  }
  else if (dir2[0] > G3DEPSILON) {
    // On YZ Plane...
    return YES;
  }
  return NO;
}

- (BOOL)intersectsBox:(G3DBox *)aBox
{
  return [aBox intersectsPlane:self];
}

- (void)transform:(G3DMatrix4f *)aMatrix
{
  float res[4];

  G3DMatrix4fXVector4f(res, [aMatrix elements], _values);
  G3DCopyVector4fv(_values,res);
}

- (BOOL)isParallel:(G3DPlane *)aPlane
{
  float tmp = G3DScalarProduct3fv(_values,[[aPlane normal] elements]);

  return (tmp == 0.0) ? YES : NO;
}

- (BOOL)isEqualToPlane:(G3DPlane *)aPlane
{
  return ([self isParallel:aPlane] && _values[3] == [aPlane distance]) ? YES : NO;
}

- (BOOL)isInHalfSpace:(G3DTuple3f *)vec
{
  return (G3DScalarProduct3fv(_values,[vec elements]) - _values[3] > 0.0f) ? YES : NO;
}

- (float)distanceFromPoint:(G3DTuple3f *)aTuple
{
  return (G3DScalarProduct3fv(_values,[aTuple elements]) + _values[3]);
}

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

- (void)setDistance:(const float)aDistance
{
  _values[3] = aDistance;
}

- (float)distance
{
  return _values[3];
}

- (void)setNormal:(G3DVector3f *)aNorm
{
  G3DNormalise3fv(_values,[aNorm elements]);
}

- (G3DVector3f *)normal
{
  return [[[G3DVector3f alloc] initWithElements:_values] autorelease];
}

- (void)setElements:(const float *)vals
{
  G3DCopyVector4fv(_values,vals);
}

- (void)getElements:(float *)vals
{
  G3DCopyVector4fv(vals,_values);
}

- (const float *)elements
{
  return (const float*)_values;  
}

//-----------------------------------------------------------------------------
// NSCoding
//-----------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeArrayOfObjCType:@encode(float) count:4 at:_values];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
  self = [super init];
  [aCoder decodeArrayOfObjCType:@encode(float) count:4 at:_values];
  return self;
}

//-----------------------------------------------------------------------------
// NSCopying
//-----------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
  return [[G3DPlane allocWithZone:zone] initWithPlane:self];
}

@end





