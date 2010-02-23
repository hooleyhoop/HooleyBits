//-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class		G3DBezier
// Creator            	Frederic Chauvin
// Maintainer         	Frederic Chauvin, Philippe C.D. Robert
// Creation Date      	mer nov 24 22:25:29 CET 1999
//
// Copyright (c) Frederic Chauvin
//
// The SHGeometryKit is free software; you can redistribute it and/or modify it 
// under the terms of the GNU LGPL Version 2 as published by the Free 
// Software Foundation
//
//-----------------------------------------------------------------------------

#import "G3DBezier.h"
#import "G3DVector3f.h"
#import "G3DDefs.h"
#import "G3DVectorFunc.h"

@implementation G3DBezier

//-----------------------------------------------------------------------------
// init and free  methods
//-----------------------------------------------------------------------------

- (id)initWithBezier:(G3DBezier*)bezier
{
  return [self initWithControlPoints:[bezier controlPoints]];
}

- (id)initWithControlPoints:(NSMutableArray *)controlPoints
{
  if ((self = [super init])) {
    // controlPoints are deep copied
    _controlPoints = [controlPoints mutableCopyWithZone:NSDefaultMallocZone()];
  }
  return self;
}

//-----------------------------------------------------------------------------
// Bezier handling methods
//-----------------------------------------------------------------------------
 
-(void)setControlPoints:(NSMutableArray *)controlPoints
{
  // WARNING: shallow copy!
  if ( _controlPoints != controlPoints ) {
    [_controlPoints release];
    _controlPoints = [controlPoints retain];
  }
}

-(NSMutableArray *)controlPoints
{
  return _controlPoints;
}

-(G3DVector3f *)pointAtParameter:(float)u
{
  int i, k;
  float v = 1.0 - u;
  NSMutableArray* workCopy = [_controlPoints mutableCopyWithZone:NSDefaultMallocZone()];

  int NOV = [_controlPoints count]-1;

  IMP get = [workCopy methodForSelector:@selector(objectAtIndex:)];

  for( k=1; k<=NOV; k++ ) {
    for( i=0; i<=NOV-k; i++ ) {
        G3DVector3f* bi = [(*get)(workCopy, @selector(objectAtIndex:), i) vectorByMultiplyingBy:v];
        G3DVector3f* bj = [(*get)(workCopy, @selector(objectAtIndex:), i+1) vectorByMultiplyingBy:u];

      [bi addTuple3f:bj];
      [workCopy replaceObjectAtIndex:i withObject:bi];
    }
  }
  
  return [workCopy objectAtIndex:0];
}

-(G3DVector3f *)derivativeOfDegree:(unsigned)degree atParameter:(float)u
{
  int i, k;
  float v = 1.0 - u;
  NSMutableArray* workCopy = [_controlPoints mutableCopyWithZone:NSDefaultMallocZone()];

  int NOV = [_controlPoints count]-1;
  
  for(i=0; i<=NOV; i++) {
    G3DVector3f* diff = [[_controlPoints objectAtIndex:i+1] vectorBySubtracting:[_controlPoints objectAtIndex:i]];
    [diff multiplyBy:NOV];
    [workCopy insertObject:diff atIndex:i];
  }
  
  for(k=1; k<NOV; k++) {
    for(i=0; i<NOV-k; i++) {
      G3DVector3f* bi = [[workCopy objectAtIndex:i] vectorByMultiplyingBy:v];
      G3DVector3f* bj = [[workCopy objectAtIndex:i+1] vectorByMultiplyingBy:u];

      [bi addTuple3f:bj];
      [workCopy replaceObjectAtIndex:i withObject:bi];
    }
  }
  
  return [workCopy objectAtIndex:0];
}

-(BOOL)isEqualToBezier:(G3DBezier*)bezier
{
  NSArray *otherPoints = [bezier controlPoints];
  int count = [otherPoints count];
  int i;

  if( count != [otherPoints count] )
    return NO;
  
  for( i=0; i<count; i++ ) {
    if( [[_controlPoints objectAtIndex:i] isEqualToTuple:[otherPoints objectAtIndex:i]] == NO )
      return NO;
  }
  return YES;
}

//-----------------------------------------------------------------------------
// NSCopying
//-----------------------------------------------------------------------------

- (id)copyWithZone:(NSZone*)zone
{
  return [[G3DBezier allocWithZone:zone] initWithBezier:self];
}

-(NSString*)description
{
  return [_controlPoints description];
}

//-----------------------------------------------------------------------------
// NSCoding
//-----------------------------------------------------------------------------
 
-(void)encodeWithCoder:aCoder
{
  [aCoder encodeObject:_controlPoints];
}

- (id)initWithCoder:aDecoder
{
  self = [super init];
  _controlPoints = [[aDecoder decodeObject] retain];
  return self;
}

-(void)dealloc
{
  [_controlPoints release];

	[super dealloc];
}

@end
