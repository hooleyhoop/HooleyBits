//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DBox
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
// $Id: G3DBox.m,v 1.4 2002/10/27 20:18:14 probert Exp $
//-----------------------------------------------------------------------------

#import "G3DBox.h"

#import "G3DMatrix4f.h"
#import "G3DTuple3f.h"
#import "G3DSphere.h"
#import "G3DLine.h"
#import "G3DPlane.h"

#import "G3DFunctions.h"
#import "G3DDefs.h"
#import "G3DVectorFunc.h"
#import "G3DMatrixFunc.h"

NSString *G3DBoxException = @"G3DBoxException";

@implementation G3DBox

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
  id box;
    
  const float vals1[3] = {0.0,0.0,0.0};
  const float vals2[3] = {1.0,1.0,1.0};

  G3DTuple3f *m1 = [[G3DTuple3f alloc] initWithElements:vals1];
  G3DTuple3f *m2 = [[G3DTuple3f alloc] initWithElements:vals2];

  box = [self initWithMin:m1 max:m2];
  
  [m1 release];
  [m2 release];
  
  return box;
}

- (id)initWithMin:(G3DTuple3f *)minimum max:(G3DTuple3f *)maximum
{
  if ((self = [super init])) {
    // We should have assertions about the size here!
    min = [minimum retain];
    max = [maximum retain];
  }
  return self;
}

- (id)initWithBox:(G3DBox *)aBox
{
  return [self initWithMin:[aBox min] max:[aBox max]];
}

- (void)dealloc
{
  [min release];
  [max release];

  [super dealloc];
}

//-----------------------------------------------------------------------------
// math
//-----------------------------------------------------------------------------

- (void)wrapPoint:(G3DTuple3f *)aPoint
{
  const float *pt = [aPoint elements];
  const float *m1 = [min elements];
  const float *m2 = [max elements];

  if ([self isEmpty]) {
    [min setElements:[aPoint elements]];
    [max setElements:[aPoint elements]];
  }
  else {
    float tmp[3];
    
    if (pt[0] < m1[0]) tmp[0] = pt[0];
    else tmp[0] = m1[0];    
    if (pt[1] < m1[1]) tmp[1] = pt[1] ;
    else tmp[1] = m1[1];
    if (pt[2] < m1[2]) tmp[2] = pt[2] ;
    else tmp[2] = m1[2];
    
    [min setElements:tmp];

    if (pt[0] > m2[0]) tmp[0] = pt[0] ;
    else tmp[0] = m2[0];    
    if (pt[1] > m2[1]) tmp[1] = pt[1] ;
    else tmp[1] = m2[1];
    if (pt[2] > m2[2]) tmp[2] = pt[2] ;
    else tmp[2] = m2[2];

    [max setElements:tmp];
  }
}

- (void)wrapBox:(G3DBox *)aBox
{
  if ([aBox isEmpty]) {
    return;
  }

  if ([self isEmpty]) {
    [self setMin:[aBox min] max:[aBox max]];
  }
  else {
    [self wrapPoint:[aBox min]]; // Needs some tuning...
    [self wrapPoint:[aBox max]];
  }
}

- (void)wrapSphere:(G3DSphere *)s
{
  id tuple;
  float srad = [s radius];
  const float *tmp = [[s center] elements];
  float vals[3];

  if (srad <= 0.0) { 
    return;
  }

  // Build a box around self and wrap it - slow and ugly...
  G3DCopyVector3f(vals,tmp[0]+srad,tmp[1]+srad,tmp[2]+srad);
  
  tuple = [[G3DTuple3f alloc] initWithElements:vals];
  [self wrapPoint:tuple];

  G3DCopyVector3f(vals,tmp[0]-srad,tmp[1]-srad,tmp[2]-srad);
  
  [tuple setElements:vals];
  [self wrapPoint:tuple];
  
  [tuple release];
}

- (BOOL)intersectsObject:(id<G3DIntersecting>)anObject
{
  Class objClass = [anObject class];

  if (objClass == G3DLineClass) {
    return [self intersectsLine:anObject];
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
    [NSException raise:G3DBoxException format:@"Unknown volume class!"];
  }
  return NO;
}

- (BOOL)intersectsLine:(G3DLine *)l
{
    return YES;
}

- (BOOL)intersectsBox:(G3DBox *)aBox
{
  const float *m1 = [min elements];
  const float *m2 = [max elements];
  const float *b1 = [[aBox min] elements];
  const float *b2 = [[aBox max] elements];

  if (m1[0] > b2[0] || b1[0] > m2[0]) return NO;
  if (m1[1] > b2[1] || b1[1] > m2[1]) return NO;
  if (m1[2] > b2[2] || b1[2] > m2[2]) return NO;

  return YES;
}

- (BOOL)intersectsPlane:(G3DPlane *)aPlane
{
  const float *plane = [aPlane elements];
  const float *m1 = [min elements];
  const float *m2 = [max elements];
  float v_min[3];
  float v_max[3];

  /*
   * First, find the diagonal of the AABB that fits most the normal 
   * of the plane. Then insert the 2 vertices of that diagonal into the
   * plane equation, if the signs of the results differ or one is 0.0 then
   * the plane intersects the box. Using loop unrolling is perhaps faster...
   *
   */

  // Parameter a
  if (plane[0] >= 0.0f) {
    v_min[0] = m1[0];
    v_max[0] = m2[0];
  }
  else {
    v_min[0] = m2[0];
    v_max[0] = m1[0];
  }

  // Parameter b
  if (plane[1] >= 0.0f) {
    v_min[1] = m1[1];
    v_max[1] = m2[1];
  }
  else {
    v_min[1] = m2[1];
    v_max[1] = m1[1];
  }

  // Parameter c
  if (plane[2] >= 0.0f) {
    v_min[2] = m1[2];
    v_max[2] = m2[2];
  }
  else {
    v_min[2] = m2[2];
    v_max[2] = m1[2];
  }
  
  // Overlap!
  if (G3DScalarProduct3fv(plane,v_max) + plane[3] >= 0.0f) {
    return YES;  
  }

  // Disjoint - not needed to calculate...;-)
  /*
  if (G3DScalarProduct3fv(plane,v_min) + plane[3] > 0.0f) {
    return NO;  
  }
  */

  return NO;
}

- (BOOL)intersectsSphere:(G3DSphere *)aSphere
{
  return [aSphere intersectsBox:self];
}

- (BOOL)wrapsPoint:(G3DTuple3f *)pt
{
  const float *p = [pt elements];
  const float *m1 = [min elements];
  const float *m2 = [max elements];

  if ((p[0] > m1[0] && p[0] < m2[0]) &&
      (p[1] > m1[1] && p[1] < m2[1]) &&
      (p[2] > m1[2] && p[2] < m2[2])) 
  {
    return YES;
  }
    
  return NO;
}

- (void)transform:(G3DMatrix4f *)aMatrix
{
  const float *m = [aMatrix elements];
  const float *m1 = [min elements];
  const float *m2 = [max elements];
  float tmp[3];

  /*
   * Minimum and maximum - the homogen 4th coordinate is thought to be 1.0f
   *
   */

  tmp[0] = m[0] * m1[0] + m[4] * m1[1] + m[8]  * m1[2] + m[12];
  tmp[1] = m[1] * m1[0] + m[5] * m1[1] + m[9]  * m1[2] + m[13];
  tmp[2] = m[2] * m1[0] + m[6] * m1[1] + m[10] * m1[2] + m[14];
  [min setElements:tmp];

  tmp[0] = m[0] * m2[0] + m[4] * m2[1] + m[8]  * m2[2] + m[12];
  tmp[1] = m[1] * m2[0] + m[5] * m2[1] + m[9]  * m2[2] + m[13];
  tmp[2] = m[2] * m2[0] + m[6] * m2[1] + m[10] * m2[2] + m[14];
  [max setElements:tmp];
}

//-----------------------------------------------------------------------------
// accessor methods
//-----------------------------------------------------------------------------

- (void)setMin:(G3DTuple3f *)minimum max:(G3DTuple3f *)maximum
{
  [min autorelease];
  min = [minimum retain];

  [max autorelease];
  max = [maximum retain];
}

- (void)getMin:(G3DTuple3f **)minVec max:(G3DTuple3f **)maxVec
{
  [(*minVec) setValuesWithTuple:min];
  [(*maxVec) setValuesWithTuple:max];
}

- (void)setMin:(G3DTuple3f *)minimum
{
  [min autorelease];
  min = [minimum retain];
}

- (G3DTuple3f *)min
{
  return min;
}

- (void)setMax:(G3DTuple3f *)maximum
{
  [max autorelease];
  max = [maximum retain];
}

- (G3DTuple3f *)max
{
  return max;
}

- (G3DTuple3f *)center
{
    float c[3];
    const float *_min = [min elements];
    const float *_max = [max elements];

    // Maybe we should check the MAX/MIN values to be sure?
    c[0] = (_max[0] - _min[0])/2 + _min[0];
    c[1] = (_max[1] - _min[1])/2 + _min[1];
    c[2] = (_max[2] - _min[2])/2 + _min[2];

    return [[[G3DTuple3f alloc] initWithElements:(const float*)c] autorelease];
}

- (float)volume
{
  const float *p1 = [min elements];
  const float *p2 = [max elements];

  return (float)(p2[0] - p1[0]) * (p2[1] - p1[1]) * (p2[2] - p1[2]); 
}

- (BOOL)isEmpty
{
  return [self volume] <= 0.0 ? YES : NO;
}

- (BOOL)isEqualToBox:(G3DBox *)aBox
{
  if ([min isEqualToTuple:[aBox min]] && [max isEqualToTuple:[aBox max]]) {
    return YES;
  }
  return NO;
}

//-----------------------------------------------------------------------------
// NSCoding
//-----------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:min];
  [aCoder encodeObject:max];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
  self = [super init];
  min = [[aCoder decodeObject] retain];
  max = [[aCoder decodeObject] retain];
  return self;
}

//-----------------------------------------------------------------------------
// NSCopying
//-----------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
  return [[G3DBox allocWithZone:zone] initWithBox:self];
}

@end






