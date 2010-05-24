//
//  LWEnvelope.m
//  SHGeometryKit
//
//  Created by Steven Hooley on 30/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "LWEnvelope.h"
#import "LWKey.h"
#import "G3DFunctions.h"

/*
======================================================================
range()

Given the value v of a periodic function, returns the equivalent value
v2 in the principal interval [lo, hi].  If i isn't NULL, it receives
the number of wavelengths between v and v2.

   v2 = v - i * (hi - lo)

For example, range( 3 pi, 0, 2 pi, i ) returns pi, with i = 1.
====================================================================== */
/*
 * sort of wraps a value to a given range. eg.. 540, 0-360 = 180 where i is the number of times it is outside the range: ie 1
*/
static CGFloat range( CGFloat v, CGFloat lo, CGFloat hi, int *i )
{
   CGFloat v2, r = hi - lo;

   if ( G3DCompareFloat(r, 0.0f, 0.00001f)==0 ) {
      if ( i ) *i = 0;
      return lo;
   }

   v2 = v - r*(CGFloat)floor(( v - lo ) / r );
   if ( i ) *i = -( int )(( v2 - v ) / r + ( v2 > v ? 0.5 : -0.5 ));

   return v2;
}

/*
======================================================================
bezier()

Interpolate the value of a 1D Bezier curve.
====================================================================== */

static CGFloat bezier( CGFloat x0, CGFloat x1, CGFloat x2, CGFloat x3, CGFloat t )
{
   CGFloat a, b, c, t2, t3;

   t2 = t * t;
   t3 = t2 * t;

   c = 3.0f * ( x1 - x0 );
   b = 3.0f * ( x2 - x1 ) - c;
   a = x3 - x0 - c - b;

   return a * t3 + b * t2 + c * t + x0;
}



/*
======================================================================
hermite()

Calculate the Hermite coefficients.
====================================================================== */

static void hermite( CGFloat t, CGFloat *h1, CGFloat *h2, CGFloat *h3, CGFloat *h4 )
{
   CGFloat t2, t3;

   t2 = t * t;
   t3 = t * t2;

   *h2 = 3.0f * t2 - t3 - t3;
   *h1 = 1.0f - *h2;
   *h4 = t3 - t2;
   *h3 = *h4 - t2 + t;
}



/*
======================================================================
bez2_time()

Find the t for which bezier() returns the input time.  The handle
endpoints of a BEZ2 curve represent the control points, and these have
(time, value) coordinates, so time is used as both a coordinate and a
parameter for this curve type.
====================================================================== */
// static int RECURSIONCOUNT;

static CGFloat bez2_time( CGFloat x0, CGFloat x1, CGFloat x2, CGFloat x3, CGFloat time, CGFloat *t0, CGFloat *t1)
{
   CGFloat v, t, oldt0, oldt1;
	// this recursive bit can infinite loop
	/* recursive version with error .0001f */
	t = *t0 + ( *t1 - *t0 ) * 0.5f;
	v = bezier( x0, x1, x2, x3, t );
	if ( fabs( time - v ) > .0001f )
	{
		oldt0 = *t0;
		oldt1 = *t1;
		if ( v > time )
		{
			*t1 = t;
		} else {
			*t0 = t;
		}
		
		if(G3DCompareFloat(oldt1, *t1, 0.00001f)==0 && G3DCompareFloat(oldt0, *t0, 0.00001f)==0){
			// NSLog(@"aborting fabs is %f", fabs( time - v ));
			goto LoopEnd;
		}
//		RECURSIONCOUNT++;
//		if(RECURSIONCOUNT>30)
//			NSLog(@"RECURSIONCOUNT is %i: t0 is %f, t1 is %f", RECURSIONCOUNT, t0, t1);

		return bez2_time( x0, x1, x2, x3, time, t0, t1 );
   }
	LoopEnd:

		// RECURSIONCOUNT = 0;
		return t;
}

/*
======================================================================
outgoing()

Return the outgoing tangent to the curve at key0.  The value returned
for the BEZ2 case is used when extrapolating a linear pre behavior and
when interpolating a non-BEZ2 span.
====================================================================== */

static CGFloat outgoing( LWKey *key0, LWKey *key1 )
{
	CGFloat a, b, d, t, out;

	CGFloat time0 = [key0 time], time1 = [key1 time];
	int shape0 = [key0 shape];
	CGFloat val0 = [key0 value], val1 = [key1 value];
	CGFloat tension0 = [key0 tension];
	CGFloat continuity0 = [key0 continuity];
	CGFloat *param0 = [key0 param];
	CGFloat bias0 = [key0 bias];
	LWKey* key0Prev = [key0 prev];
	
   switch ( shape0 )
   {
      case SHAPE_TCB:
         a = ( 1.0f - tension0 )
           * ( 1.0f + continuity0 )
           * ( 1.0f + bias0 );
         b = ( 1.0f - tension0 )
           * ( 1.0f - continuity0 )
           * ( 1.0f - bias0 );
         d = val1 - val0;

         if ( key0Prev ) {
            t = ( time1 - time0 ) / ( time1 - [key0Prev time] );
            out = t * ( a * ( val0 - [key0Prev value] ) + b * d );
         }
         else
            out = b * d;
         break;

      case SHAPE_LINE:
         d = val1 - val0;
         if ( key0Prev ) {
            t = ( time1 - time0 ) / ( time1 - [key0Prev time] );
            out = t * ( val0 - [key0Prev value] + d );
         }
         else
            out = d;
         break;

      case SHAPE_BEZI:
      case SHAPE_HERM:
         out = param0[ 1 ];
         if ( key0Prev )
            out *= ( time1 - time0 ) / ( time1 - [key0Prev time] );
         break;

      case SHAPE_BEZ2:
         out = param0[ 3 ] * ( time1 - time0 );
         if ( fabs( param0[ 2 ] ) > 1e-5f )
            out /= param0[ 2 ];
         else
            out *= 1e5f;
         break;
		case SHAPE_EASE:
		
		// break
      case SHAPE_STEP:
      default:
         out = 0.0f;
         break;
   }

   return out;
}


/*
======================================================================
incoming()

Return the incoming tangent to the curve at key1.  The value returned
for the BEZ2 case is used when extrapolating a linear post behavior.
====================================================================== */

static CGFloat incoming( LWKey *key0, LWKey *key1 )
{
	CGFloat a, b, d, t, in;

	CGFloat time0 = [key0 time], time1 = [key1 time];
	int shape1 = [key1 shape];
	CGFloat val0 = [key0 value], val1 = [key1 value];
	CGFloat tension1=[key1 tension];
	CGFloat continuity1 = [key1 continuity];
	CGFloat *param1 = [key1 param];
	CGFloat bias1 = [key1 bias];
	LWKey *key1Next = [key1 next];
	
   switch( shape1 )
   {
      case SHAPE_LINE:
         d = val1 - val0;
         if ( key1Next ) {
            t = ( time1 - time0 ) / ( [key1Next time] - time0 );
            in = t * ( [key1Next value] - val1 + d );
         }
         else
            in = d;
         break;

      case SHAPE_TCB:
         a = ( 1.0f - tension1 )
           * ( 1.0f - continuity1 )
           * ( 1.0f + bias1 );
         b = ( 1.0f - tension1 )
           * ( 1.0f + continuity1 )
           * ( 1.0f - bias1 );
         d = val1 - val0;

         if ( key1Next ) {
            t = ( time1 - time0 ) / ( [key1Next time] - time0 );
            in = t * ( b * ( [key1Next value] - val1 ) + a * d );
         }
         else
            in = a * d;
         break;

      case SHAPE_BEZI:
      case SHAPE_HERM:
         in = param1[ 0 ];
         if ( key1Next )
            in *= ( time1 - time0 ) / ( [key1Next time] - time0 );
         break;
         return in;

      case SHAPE_BEZ2:
         in = param1[ 1 ] * ( time1 - time0 );
         if ( fabs( param1[ 0 ] ) > 1e-5f )
            in /= param1[ 0 ];
         else
            in *= 1e5f;
         break;
		
		case SHAPE_EASE:
		
		//break;
      case SHAPE_STEP:
      default:
         in = 0.0f;
         break;
   }

   return in;
}


/*
======================================================================
bez2()

Interpolate the value of a BEZ2 curve.
====================================================================== */

static CGFloat bez2( LWKey* key0, LWKey* key1, CGFloat time ) // t between 0.0-1.0
{
	CGFloat x, y, t, t0 = 0.0f, t1 = 1.0f;
	CGFloat time0 = [key0 time], time1 = [key1 time];
	int shape0 = [key0 shape];
	CGFloat val0 = [key0 value], val1 = [key1 value];
	CGFloat *param0 = [key0 param], *param1 = [key1 param];
	
   if( shape0 == SHAPE_BEZ2 )
      x = time0 + param0[2];
   else
      x = time0 + ( time1 - time0 ) / 3.0f;

   t = bez2_time( time0, x, time1 + param1[0], time1, time, &t0, &t1 );

   if( shape0 == SHAPE_BEZ2 )
      y = val0 + param0[3];
   else
      y = val0 + param0[1] / 3.0f;

   return bezier( val0, y, param1[1]+val1, val1, t );
}



/* 
 *=====================================================================*
 * --------------------------------------------------------------------*
 * ease-in/ease-out                                                    *
 * --------------------------------------------------------------------*
 * By Dr. Richard E. Parent, The Ohio State University                 *
 * (parent@cis.ohio-state.edu)                                         *
 * --------------------------------------------------------------------*
 * using parabolic blending at the end points                          *
 * first leg has constant acceleration from 0 to v during time 0 to t1 *
 * second leg has constant velocity of v during time t1 to t2          *
 * third leg has constant deceleration from v to 0 during time t2 to 1 *
 * these are integrated to get the 'distance' traveled at any time     *
 * --------------------------------------------------------------------*
 */
CGFloat ease(CGFloat t, CGFloat t1, CGFloat t2)
{
  CGFloat  a,b,c,rt;
  CGFloat  v,a1,a2;

  v = 2/(1+t2-t1);  /* constant velocity attained */
  a1 = v/t1;        /* acceleration of first leg */
  a2 = -v/(1-t2);   /* deceleration of last leg */

  if (t<t1) {
    rt = 0.5f*a1*t*t;       /* pos = 1/2 * acc * t*t */
  }
  else if (t<t2) {
    a = 0.5f*a1*t1*t1;      /* distance from first leg */
    b = v*(t-t1);            /* distance = vel * time  of second leg */
    rt = a + b;
  }
  else {
    a = 0.5f*a1*t1*t1;      /* distance from first leg */
    b = v*(t2-t1);           /* distance from second leg */
    c = ((v + v + (t-t2)*a2)/2) * (t-t2);  /* distance = ave vel. * time */
    rt = a + b + c;
  }
  return(rt);
}

static CGFloat ease2( LWKey* key0, LWKey* key1, CGFloat time ) // t between 0.0-1.0
{
//	double x
	CGFloat y, t;
//	double t0 = 0.0f;
//	double t1 = 1.0f;
//	double time0 = [key0 time], time1 = [key1 time];
	//int shape0 = [key0 shape];
	// double val0 = [key0 value];
//	double val1 = [key1 value];
	//CGFloat *param0 = [key0 param], *param1 = [key1 param];
	
  // if( shape0 == SHAPE_BEZ2 )
  //    x = time0 + param0[2];
 //  else
  //    x = time0 + ( time1 - time0 ) / 3.0f;

 // t = bez2_time( time0, x, time1 + param1[0], time1, time, &t0, &t1 );

 //  if( shape0 == SHAPE_BEZ2 )
 //     y = val0 + param0[3];
 //  else
 //     y = val0 + param0[1] / 3.0f;
 
 
	t = ( time - [key0 time] ) / ( [key1 time] - [key0 time] );
//	y = [key0 value] + t * ( [key1 value] - [key0 value] );


	t = ease( t, 0.33f, 0.66f ); // t is now a non-linear value between 0 & 1
	y = [key0 value] + t * ( [key1 value] - [key0 value] );

//	double newTime = t*( [key1 time] - [key0 time] )+[key0 time];
	
	
//	x = time1-time0;
//	double x1 = time - time0;

	// t = ( time - [key0 time] ) / ( [key1 time] - [key0 time] );
//	t = [key0 value] + t * ( [key1 value] - [key0 value] );

	// get linear time
	// t = ( time - [key0 time] ) / ( [key1 time] - [key0 time] );
	
	// linear value at this time
//	y = [key0 value] + t * ( [key1 value] - [key0 value] );
	
	// t = x1*1/x;
//	NSLog(@"time is %f", t);
	
	// y = ease( t, val0, val1 );
	return y;
}


/*
 * 
*/
@implementation LWEnvelope

@synthesize nkeys=_nkeys;

#pragma mark -
#pragma mark class methods
+ (LWEnvelope *)lWEnvelope {

	return [[[LWEnvelope alloc] init] autorelease];
}

+ (LWEnvelope *)lWEnvelopeWithPoint:(CGPoint)pt {

	return [[[LWEnvelope alloc] initWithPoint:pt] autorelease];
}

#pragma mark init methods
- (id)init {

	self=[super init];
    if(self) {
		_key = nil;
		_nkeys=0;
		_behavior[0]=BEH_CONSTANT;
		_behavior[1]=BEH_CONSTANT;
    }
    return self;
}

- (id)initWithPoint:(CGPoint)pt {

	LWEnvelope* newLine = [self init];
	[newLine moveToPoint:pt];
	return newLine;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc {
	[_key release];
	_key = nil;
    [super dealloc];
}

#pragma mark action methods

/*
======================================================================
evalEnvelope()

Given a list of keys and a time, returns the interpolated value of the
envelope at that time.
====================================================================== */

- (CGFloat)evalAtTime:(CGFloat)time
{
	LWKey *key0, *key1, *startKey, *endKey;
	CGFloat t, h1, h2, h3, h4, in, out, offset = 0.0f;
	int noff;

	/* if there's no key, the value is 0 */
	if( _nkeys==0 ) return 0.0f;

	/* if there's only one key, the value is constant */
	if( _nkeys==1 )
		return [_key value];

	/* find the first and last keys */
	startKey = endKey = _key;
	while( [endKey next] ) 
		endKey = [endKey next];

   /* use pre-behavior if time is before first key time */
   if ( time < [startKey time] ) 
   {
      switch( _behavior[ 0 ] )
      {
         case BEH_RESET:
            return 0.0f;

         case BEH_CONSTANT:
            return [startKey value];

         case BEH_REPEAT:
            time = range( time, [startKey time], [endKey time], NULL );
            break;

         case BEH_OSCILLATE:
            time = range( time, [startKey time], [endKey time], &noff );
            if ( noff % 2 )
               time = [endKey time] - [startKey time] - time;
            break;

         case BEH_OFFSET:
            time = range( time, [startKey time], [endKey time], &noff );
            offset = noff * ( [endKey value] - [startKey value] );
            break;

         case BEH_LINEAR:
            out = outgoing( startKey, [startKey next] ) / ( [[startKey next] time] - [startKey time] );
            return out * ( time - [startKey time] ) + [startKey value];
      }
   }

   /* use post-behavior if time is after last key time */
   else if( time > [endKey time] )
   {
      switch( _behavior[ 1 ] )
      {
         case BEH_RESET:
            return 0.0f;

         case BEH_CONSTANT:
            return [endKey value];

         case BEH_REPEAT:
            time = range( time, [startKey time], [endKey time], NULL );
            break;

         case BEH_OSCILLATE:
            time = range( time, [startKey time], [endKey time], &noff );
            if ( noff % 2 )
               time = [endKey time] - [startKey time] - time;
            break;

         case BEH_OFFSET:
            time = range( time, [startKey time], [endKey time], &noff );
            offset = noff * ( [endKey value] - [startKey value] );
            break;

         case BEH_LINEAR:
            in = incoming( [endKey prev], endKey ) / ( [endKey time] - [[endKey prev] time] );
            return in * ( time - [endKey time] ) + [endKey value];
      }
   }

   /* get the endpoints of the interval being evaluated */
   key0 = _key;
   while ( time > [[key0 next] time] )
      key0 = [key0 next];
   key1 = [key0 next];

   /* check for singularities first */
	
   if( G3DCompareFloat(time, [key0 time], 0.00001f)==0 )
      return [key0 value] + offset;

   else if( G3DCompareFloat(time, [key1 time], 0.00001f)==0 )
      return [key1 value] + offset;

   /* get interval length, time in [0, 1] */
   t = ( time - [key0 time] ) / ( [key1 time] - [key0 time] );

   /* interpolate */
   switch ( [key1 shape] )
   {
      case SHAPE_TCB:
      case SHAPE_BEZI:
      case SHAPE_HERM:
         out = outgoing( key0, key1 );
         in = incoming( key0, key1 );
         hermite( t, &h1, &h2, &h3, &h4 );
         return h1 * [key0 value] + h2 * [key1 value] + h3 * out + h4 * in + offset;

      case SHAPE_BEZ2:
         return bez2( key0, key1, time ) + offset;

      case SHAPE_LINE:
         return [key0 value] + t * ( [key1 value] - [key0 value] ) + offset;

      case SHAPE_STEP:
         return [key0 value] + offset;
	
		case SHAPE_EASE:
			return ease2( key0, key1, time ) + offset;
		break;
      default:
         return offset;
   }
}

#pragma mark Constructing paths
- (void)moveToPoint:(CGPoint)pt {

	if(_nkeys<1){
		/* make a new key */
		LWKey* firstKey = [LWKey keyWithPt:pt envelope:self];
		[self setKey:firstKey];
		_nkeys = 1;

		BOOL ok = [self runsForwardAtKey:firstKey];
		if(!ok)
			NSLog(@"LWEnvelope: ERROR moveToPoint");
	}
}

- (void) lineToPoint:(CGPoint)pt {

	[self curveToPoint:pt];
}

- (void)curveToPoint:(CGPoint)pt {

	if(_nkeys<1)
		[self moveToPoint:pt];
	else {
		// get the end point..
		LWKey* endKey = _key;
		while( [endKey next] ) 
			endKey = [endKey next];
		
		// check that the point doesnt equal the current end point		
		// then add it onto the end
		if(G3DCompareFloat([endKey time], (CGFloat)pt.x, 0.00001f)==0)
			return;
		LWKey* newKey = [LWKey keyWithPt:pt envelope:self];
		[endKey addKey:newKey];
		_nkeys++;
		BOOL ok = [self runsForwardAtKey:newKey];
		if(!ok)
			[NSException raise:@"LWEnvelope: ERROR curveToPoint" format:@""];		
	}
}

- (void)curveToPoint:(CGPoint)bPt cntrlPt:(CGPoint)cPt {

	[self curveToPoint:bPt]; // how to set the control pt?
}

- (void)insertPt:(CGPoint)pt {

	/* if we dont have any points */
	if(_nkeys<1){
		[self moveToPoint:pt];
		return;
	}
	
	/* else find where to insert it */
	CGFloat newx = pt.x;
	
	int index =0;
	LWKey* endKey = _key;
	while(newx>[endKey x])
	{
		if([endKey next]!=nil)
		{
			endKey = [endKey next];
			index++;
		} else {
			/* new pt needs to be appended to the end */
			index++;
			break;
		}
	}
	/* newx is now > [endKey x] or there aren't any more points */
	if(newx>[endKey x])
		[self insertPt:pt atIndex:index+1];
	else
		[self insertPt:pt atIndex:index];
 }
 
/* points can only go in order of x - so this is a bit stupid! */ 
- (void)insertPt:(CGPoint)pt atIndex:(NSUInteger)i {

	if(i<=_nkeys)
	{
		NSUInteger index=0;
		LWKey* newKey = [LWKey keyWithPt:pt envelope:self];
		LWKey* endKey = _key;
		if(i==0){
			[endKey insertKeyBefore:newKey];
			_nkeys++;
			[self setKey:newKey];
			BOOL ok = [self runsForwardAtKey:newKey];
			if(!ok)
				NSLog(@"LWEnvelope: ERROR insertPt:atIndex:");		
	
		} else {
			do {
				NSUInteger previousIndex = i-1;
				if(index==previousIndex){
					[endKey insertKeyAfter:newKey];
					_nkeys++;
					BOOL ok = [self runsForwardAtKey:newKey];
					if(!ok)
						[NSException raise:@"LWEnvelope: ERROR insertPt:atIndex:" format:@""];

					return;
				}
				endKey=[endKey next];
				index++;
			} while([endKey next]);
			/* shouldn't ever get here! */
			[NSException raise:@"LWEnvelope: ERROR" format:@""];
		}
	} else { 
		[self curveToPoint:pt];
	}
 }
 
- (void)removePointAtIndex:(NSUInteger)i {

	NSParameterAssert(i<_nkeys);

	NSUInteger index=0;
	LWKey* endKey = _key;
	
	/* if we are removing the first pt handle special case */
	if(i==0){
		endKey=[endKey next];
		[_key removeKey];
		[self setKey:endKey];
		_nkeys--;			
		return;
	}
	while( [endKey next] ) 
	{
		endKey=[endKey next];
		index++;
		if(index==i)
		{
			[endKey removeKey];
			_nkeys--;			
			break;
		}
	}
}

- (void)removeAllPoints {

	[self setKey: nil];
	_nkeys = 0;
}

#pragma mark Querying paths
//=========================================================== 
// - bounds
//=========================================================== 
- (CGRect) bounds
{
	CGFloat x1=0,x2=0,y1=0,y2=0;
	if(_nkeys>0)
	{
		LWKey *bpt = _key;
		// do the first pt to get things going
		x1 = [bpt time];
		y1 = [bpt value];
		x2=x1;
		y2=y1;
		
		// not sure how these LWKeys work yet.. will do this later
//		if([bpt curvePoint])
//		{
//			pt = [bpt cntrlPoint];
//			double newX = pt.x;
//			double newY = pt.y;
//			if(newX<x1)
//				x1=newX;
//			if(newY<y1)
//				y1=newY;
//			if(newX>x2)
//				x2=newX;
//			if(newY>y2)
//				y2=newY;
//		}
		
		// loop throught the other points
		while( (bpt=[bpt next]) ) 
		{
			// bpt = [bpt next];
			CGFloat newX = [bpt time];
			CGFloat newY = [bpt value];

			if(newX<x1)
				x1=newX;
			if(newY<y1)
				y1=newY;
			if(newX>x2)
				x2=newX;
			if(newY>y2)
				y2=newY;

//			if([bpt curvePoint])
//			{
//				pt = [bpt cntrlPoint];
//				double newX = pt.x;
//				double newY = pt.y;
//				if(newX<x1)
//					x1=newX;
//				if(newY<y1)
//					y1=newY;
//				if(newX>x2)
//					x2=newX;
//				if(newY>y2)
//					y2=newY;			
//			}
		}
	}
	return CGRectMake(x1,y1,x2-x1,y2-y1);	
}


- (void)getPts_Start:(CGFloat)startTime end:(CGFloat)endTime count:(NSUInteger)numberOfFrames into:(CGFloat *)vertexPositions {
	
	CGFloat time;
	CGFloat stepSize = (endTime-startTime) / numberOfFrames;
	NSUInteger i, counter;
	for( i=0; i<numberOfFrames; i++)
	{
		counter = i*2;
		time = startTime+(i*stepSize);
		CGFloat y = [self evalAtTime:time];
		vertexPositions[counter] = time;
		vertexPositions[counter+1] = y;
	}
}

 
- (BOOL)runsForwardAtKey:(LWKey*)aKey {
	/* sample the curve from prev to next to check that it runs forward */

	if(_nkeys==1)
		return YES;
	LWKey* prevKey = [aKey prev];
	LWKey* nextKey = [aKey next];
	CGFloat prevTime, nextTime;
	
	if(prevKey)
		prevTime = [prevKey time];
	else 
		prevTime = [aKey time];
	if(nextKey)
		nextTime = [nextKey time];
	else 
		nextTime = [aKey time];	
	
	if(G3DCompareFloat(prevTime, nextTime, 0.00001f)==0)
		return NO;
	
	int numberOfFrames = 100;
	CGFloat* vertexPositions = malloc(sizeof(CGFloat)*numberOfFrames*2);
	[self getPts_Start:prevTime end:nextTime count:numberOfFrames into:vertexPositions];
	int i;
	float xPos, prevXpos = vertexPositions[0];
	for(i=1;i<numberOfFrames;i++)
	{
		xPos = vertexPositions[i*2];
		// NSLog(@"xPos is %f",xPos);
		if(xPos>prevXpos+.0001f){
			prevXpos = xPos;
		} else 
			return NO;
	}
	free(vertexPositions);
	return YES;
}


#pragma mark accessor methods
- (LWKey *)key {
	return _key;
}

- (void)setKey:(LWKey *)value {

    if (_key != value) {
        [_key release];
		[value retain];
        _key = value;
    }
}

- (NSUInteger *)behavior {
	return _behavior;
}

- (void)setPreBehavoir:(NSUInteger)behavoir {

	_behavior[0] = behavoir;
}

- (void)setPostBehavoir:(NSUInteger)behavoir {

	_behavior[1] = behavoir;
}

- (NSArray *)ptsAsArray {

	NSMutableArray* array = [NSMutableArray arrayWithCapacity:_nkeys];
	LWKey* startKey = _key;
	[array addObject:startKey];
	while( [startKey next] ) 
	{
		startKey = [startKey next];
		[array addObject:startKey];
	}
	return array;
}

- (NSString *)name
{
	if(_name)
		return _name;
	else 
		return @"no name yet!";
}

- (NSNumber *)numberOfPts {

	return [NSNumber numberWithInt:100];
}

- (void)setName:(NSString *)a {

	// NSLog(@"LWEnvelope: setName %@", a);
	if(a!=_name){
		[a retain];
		[_name release];
		_name = a;
	}
}

- (void)setNumberOfPts:(NSNumber *)a {
	NSLog(@"LWEnvelope: ERROR setNumberOfPts");
}

#pragma mark NSCoding methods

- (void)encodeWithCoder:(NSCoder *)coder
{
	// NSLog(@"LWEnvelope: encodeWithCoder");
	// [super encodeWithCoder:coder];
	[coder encodeObject:_key forKey:@"_key"];
    [coder encodeInt:_nkeys forKey:@"_nkeys"];
	[coder encodeArrayOfObjCType:@encode(int) count:2 at:_behavior];
	[coder encodeObject:_name forKey:@"_name"];	
    return;
}

- (id)initWithCoder:(NSCoder *)aCoder {
	// NSLog(@"LWEnvelope: initWithCoder");
	self=[super init];
	if(self)
	{
		[self setKey:[aCoder decodeObjectForKey:@"_key"]];
		_nkeys = [aCoder decodeIntForKey:@"_nkeys"];
		[aCoder decodeArrayOfObjCType:@encode(int) count:2 at:_behavior];
		[self setName: [aCoder decodeObjectForKey:@"_name"]];
	}
	return self;
}

@end

