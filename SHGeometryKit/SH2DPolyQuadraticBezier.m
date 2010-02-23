//
//  SHPolyLine.m
//  CurveInterpolatyion
//
//  Created by Steve Hooley on 24/01/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SH2DPolyQuadraticBezier.h"
#import "G3DTuple2d.h"
#import "SH2dBezierPt.h"
#import "G3DVectorFunc.h"
#import "SH2DPolyLine.h"
#import "math.h"
/*
 *
*/
@implementation SH2DPolyQuadraticBezier

#pragma mark -
#pragma mark class methods
//=========================================================== 
// + polyQuadraticBezier
//=========================================================== 
+ (SH2DPolyQuadraticBezier*) polyQuadraticBezier
{
	return [[[SH2DPolyQuadraticBezier alloc] init] autorelease];
}

//=========================================================== 
// + polyQuadraticBezierWithPoint
//=========================================================== 
+ (SH2DPolyQuadraticBezier*) polyQuadraticBezierWithPoint:(SH2dBezierPt*)pt
{
	return [[[SH2DPolyQuadraticBezier alloc] initWithPoint:pt] autorelease];
}

#pragma mark init methods
//=========================================================== 
// - initWithPoint
//=========================================================== 
- (SH2DPolyQuadraticBezier*) initWithPoint:(SH2dBezierPt*)pt
{
	SH2DPolyQuadraticBezier* newLine = [self init];
	[newLine moveToPoint:pt];
	return newLine;
}

//=========================================================== 
// - init
//=========================================================== 
- (SH2DPolyQuadraticBezier*) init
{
	if(self=[super init])
	{
		_allPoints = nil;
		_isEmpty = YES;
	}
	return self;
}

//=========================================================== 
// - dealloc
//=========================================================== 
- (void) dealloc {
	[_allPoints release];
	
	_allPoints = nil;
    [super dealloc];
}


#pragma mark action methods
#pragma mark Constructing paths
//=========================================================== 
// - moveToPoint
//=========================================================== 
- (void) moveToPoint:(SH2dBezierPt*)pt
{
	if(_isEmpty){
		_allPoints = [[NSMutableArray alloc] initWithCapacity:2];
		[_allPoints addObject:pt];
		_isEmpty = NO;
	}
}

//=========================================================== 
// - lineToPoint
//=========================================================== 
- (void) lineToPoint:(G3DTuple2d*)pt {
	[self curveToPoint:[[[SH2dBezierPt alloc] initWithBasePt:pt] autorelease]];
}

//=========================================================== 
// - curveToPoint: bPt:
//=========================================================== 
- (void) curveToPoint:(G3DTuple2d*)bPt cntrlPt:(G3DTuple2d*)cPt {
	[self curveToPoint:[[[SH2dBezierPt alloc] initWithBasePt:bPt CntrlPt:cPt] autorelease]];
}

//=========================================================== 
// - curveToPoint
//=========================================================== 
- (void) curveToPoint:(SH2dBezierPt*)pt
{
	if(_isEmpty)
		[self moveToPoint:pt];
	else {
		// check that the point doesnt equal the current end point
		int nOPts = [self elementCount];
		SH2dBezierPt* endPt = [_allPoints objectAtIndex:nOPts-1];
		if([endPt isEqualToBezierPt:pt])
			return;
		[_allPoints addObject:pt];
	}
}

//=========================================================== 
// - relativeLineToPoint
//=========================================================== 
//- (void) relativeLineToPoint:(SH2dBezierPt*)pt
//{
//	int nOPts = [self elementCount];
//	if(nOPts>0){
//		SH2dBezierPt* newEndPointCopy = [[[self elementAtIndex:nOPts-1] copy] autorelease]; // retain count 1?
//		[newEndPointCopy addTuple2d: pt];
//		[self lineToPoint:newEndPointCopy];
//	} else {
//		[self moveToPoint:pt];
//	}
//}

//=========================================================== 
// - insertPt: atIndex:
//=========================================================== 
 - (void) insertPt:(SH2dBezierPt*)pt atIndex:(int)i {
	if(i>-1){
		if(i<=[self elementCount])
			[_allPoints insertObject:pt atIndex:i];
		else 
			[self curveToPoint:pt];
	}
}

//=========================================================== 
// - removePointAtIndex
//=========================================================== 
- (void) removePointAtIndex:(int)i 
{
	int nOPts = [self elementCount];
	if(i>-1 && i<nOPts){
		[_allPoints removeObjectAtIndex:i];
		if(nOPts-1==0 )
			_isEmpty = YES;
	}
}

//=========================================================== 
// - removeAllPoints
//=========================================================== 
- (void) removeAllPoints
{
	[_allPoints removeAllObjects];
	_isEmpty = YES;
}



#pragma mark accessor methods
#pragma mark Querying paths
//=========================================================== 
// - bounds
//=========================================================== 
- (NSRect) bounds
{
	double x1=0,x2=0,y1=0,y2=0;
	if(!_isEmpty)
	{
		SH2dBezierPt* bpt = [_allPoints objectAtIndex:0];
		G3DTuple2d* pt = [bpt bPoint];
		// do the first pt to get things going
		x1 = [pt x];
		y1 = [pt y];
		x2=x1;
		y2=y1;
		if([bpt curvePoint])
		{
			pt = [bpt cntrlPoint];
			double newX = [pt x];
			double newY = [pt y];
			if(newX<x1)
				x1=newX;
			if(newY<y1)
				y1=newY;
			if(newX>x2)
				x2=newX;
			if(newY>y2)
				y2=newY;
		}
		
		// loop throught the other points
		int i;
		int nOPts = [self elementCount];
		for(i=1;i<nOPts;i++)
		{
			bpt = [_allPoints objectAtIndex:i];
			pt = [bpt bPoint];
			
			double newX = [pt x];
			double newY = [pt y];
			if(newX<x1)
				x1=newX;
			if(newY<y1)
				y1=newY;
			if(newX>x2)
				x2=newX;
			if(newY>y2)
				y2=newY;

			if([bpt curvePoint])
			{
				pt = [bpt cntrlPoint];
				double newX = [pt x];
				double newY = [pt y];
				if(newX<x1)
					x1=newX;
				if(newY<y1)
					y1=newY;
				if(newX>x2)
					x2=newX;
				if(newY>y2)
					y2=newY;			
			}
		}
	}
	return NSMakeRect(x1,y1,x2-x1,y2-y1);
}

//=========================================================== 
// - nearestPoint
//=========================================================== 
//- (G3DTuple2d*) nearestPoint:(G3DTuple2d*)pt
//{
// 	to do
//}


/*
 * Evaluate the quadratic Bezier spline segment
 */
double eval_quadr_bezier_spline(u,xa,xb,xc)
double u,xa,xb,xc;
{
	double c;
	
	/* Check the value of u */
	if (u < 0 || u > 1.0 ) {
		(void) fprintf(stderr,"Error - attempt to evaluate u=%f outside [0,1] range\n",u);
		return(0.0);
	}
	c =   u*u*(   xa - 2*xb + xc)
		+   u*(-2*xa + 2*xb     )
		+     (   xa            );
	return(c);
}



//=========================================================== 
// - getPointFor_u
//=========================================================== 
- (G3DTuple2d*) getPointFor_u:(float)u
{
	if(u<0 || u>1.0)
		return nil;
	int i, count = [_allPoints count];
	if(count<2)
		return nil;
		
	// take care of endpoint cases
	if(u==0.0){
		SH2dBezierPt* pt1 = [_allPoints objectAtIndex:0];
		G3DTuple2d* resultPt = [[[G3DTuple2d alloc] initWithTuple:[pt1 bPoint]] autorelease];
		return resultPt;
	}
	if(u==1.0){
		SH2dBezierPt* pt1 = [_allPoints objectAtIndex:count-1];
		G3DTuple2d* resultPt = [[[G3DTuple2d alloc] initWithTuple:[pt1 bPoint]] autorelease];
		return resultPt;
	}
	
 	// where does u lie along the length?
	double ln = [self length]; // cache this mo-fo
	double soughtLn = ln*u;
	double currentLength=0, previousLength=0;
	int firstPt=0, secondPt=0;
	// find the 2 pts that our desired pt is between
	for(i=0;i<count-1;i++)
	{
		double lengthOfSeg = [self lengthOfSegment:i]; // cache this mofo as well-fo

		currentLength = currentLength + lengthOfSeg;
		if(currentLength>soughtLn){
			firstPt=i;
			secondPt=firstPt+1;
			break;
		}
		previousLength = currentLength;
	}	
	// reult lies x% between pt[firstPt] and pt[secondPt]
	
	SH2dBezierPt* pt1 = [_allPoints objectAtIndex:firstPt];
	SH2dBezierPt* pt2 = [_allPoints objectAtIndex:secondPt];
	G3DTuple2d* resultPt;
	double xPercent = (soughtLn-previousLength)/(currentLength-previousLength); // not really a % but between 0 and 1
	
	if([pt1 curvePoint])
	{
		double x = eval_quadr_bezier_spline(xPercent,[[pt1 bPoint]x], [[pt1 cntrlPoint]x], [[pt2 bPoint]x]);
		double y = eval_quadr_bezier_spline(xPercent,[[pt1 bPoint]y], [[pt1 cntrlPoint]y], [[pt2 bPoint]y]);
		// resultPt = getPtOnQuadraticBezierAtU( [pt1 bPoint], [pt1 cntrlPoint], [pt2 bPoint], xPercent);
		resultPt = [G3DTuple2d tupleWithX:x y:y];
	} else {
		resultPt = [[[G3DTuple2d alloc] init] autorelease];
		G3DTuple2d* pp1 = [pt1 bPoint];
		G3DTuple2d* pp2 = [pt2 bPoint];
		double newX = ([pp2 x] - [pp1 x])*xPercent + [pp1 x];
		double newY = ([pp2 y] - [pp1 y])*xPercent + [pp1 y];
		[resultPt setX: newX];
		[resultPt setY: newY];
	}
	return resultPt;
}

/* Method 1 */
//=========================================================== 
// - getPolyLineWithNParametricPoints
//=========================================================== 
- (SH2DPolyLine*) getPolyLineWithNParametricPoints:(int)n
{
	if(n<1)
		return nil;

	// calculate equal spaced parameter u for n pts along the length
	NSMutableArray* arrayOfVals = [NSMutableArray arrayWithCapacity:n]; 
	double firstVal=0;
	[arrayOfVals addObject:[NSNumber numberWithDouble:firstVal]];

	double increment = 1.0/(n-1.0);
	int i;
	for(i=1;i<n;i++)
	{
		firstVal = firstVal+increment;
		NSNumber* numWrapper = [NSNumber numberWithDouble:firstVal];
		[arrayOfVals addObject:numWrapper];
	}
	/* finished making arrayOfVals */
	
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];
	
	/*** 
		V E R Y  T E M P O R A R Y
	***/
	for(i=0;i<n;i++)
	{
		double percentageAlong = [[arrayOfVals objectAtIndex:i] doubleValue];
		G3DTuple2d* pt = [self getPointFor_u:percentageAlong]; // auto released object
		[aLine lineToPoint:pt];
	}
	/*** 
		E N D  V E R Y  T E M P O R A R Y
	***/
	
	return aLine;
}


/* Method 2 */
//=========================================================== 
// - getPolyLineWithMaxSegmentLength
//=========================================================== 
- (SH2DPolyLine*) getPolyLineWithMaxSegmentLength:(double)l
{
	SH2DPolyLine* aLine = [SH2DPolyLine polyLine];

	int segs = [self elementCount]-1, i;
	for(i=0;i<segs;i++)
	{
		SH2dBezierPt* pt1 = [_allPoints objectAtIndex:i];
		SH2dBezierPt* pt2 = [_allPoints objectAtIndex:i+1];

		if([pt1 curvePoint])
		{
			// split curve to pollyline(0.5)
			recursive_QuadraticBezier([[pt1 bPoint] x], [[pt1 bPoint] y], [[pt1 cntrlPoint] x], [[pt1 cntrlPoint] y], [[pt2 bPoint] x], [[pt2 bPoint] y], aLine, l );
				
		} else {
			// split line to pollyline
			if([aLine isEmpty]){
				//NSLog(@"Line is empty");
				[aLine moveToPoint:[pt1 bPoint]];
			}
			double segLength = [self lengthOfSegment:i];
			int outSegs = ceil(segLength/l);
			if(outSegs>1)
			{
				double xDist = ([[pt2 bPoint]x]-[[pt1 bPoint]x]);
				double yDist = ([[pt2 bPoint]y]-[[pt1 bPoint]y]);
				double xStep = xDist/outSegs;
				double yStep = yDist/outSegs;
				double baseX = [[pt1 bPoint] x];
				double baseY = [[pt1 bPoint] y];

				int j;
				for(j=0;j<(outSegs-1);j++)
				{
					// needs to be relative position
					[aLine lineToPoint:[G3DTuple2d tupleWithX:baseX+((j+1)*xStep) y:baseY+((j+1)*yStep)]];
				}
				[aLine lineToPoint:[pt2 bPoint]];

			} else {
				[aLine lineToPoint:[pt2 bPoint]];
			}
		}

	}
	return aLine;
}

/* Method 3 */
//=========================================================== 
// - getPolyLineWithNEqualSpacedPoints
//=========================================================== 
- (SH2DPolyLine*) getPolyLineWithNEqualSpacedPoints:(int)n
{	
	/* get the unequally spaced pts */
	SH2DPolyLine* aLine = [self getPolyLineWithNParametricPoints:n];
	
	/* we are going to work out what the parameters of u would be for these points u was linear along the curve */
	SH2DPolyLine* uParameters = [SH2DPolyLine polyLineWithPoint:[G3DTuple2d tupleWithX:0 y:0]]; // first pt

	int segs = n-1;  
	int uPtsToCalculate = segs-1;
	double length = [aLine length];
	int i;
	double cumulativeLength = 0;
	
	/* reparameterize each pt */	
	for(i=0; i<uPtsToCalculate; i++)
	{
		double segLength = [aLine lengthOfSegment:i];
		cumulativeLength = cumulativeLength+segLength;
		
		double u_param = (i+1)/(double)segs;
		
		/* a new line plotting distance against u */
		[uParameters lineToPoint:[G3DTuple2d tupleWithX:cumulativeLength y:u_param]];
		// NSLog(@"SH2DPolyQuadraticBezier: adding pt to parameter line (%f, %f)", (float)cumulativeLength, (float)u_param );
	}
	
	[uParameters lineToPoint:[G3DTuple2d tupleWithX:length y:1.0]]; // add on the last point
	
	/* The best way to do it according to some sources */
	/* On a straight line each pt would be 'idealUSpacing' away from the point behind and point in front */
	double idealPtSpacing = length/segs;
	
	// get n pts on the line at equal u - 
	// NSArray* reparameterizedUValues = [uParameters get_n_EqualSpacedPointsAlongLength:n];
	SH2DPolyLine* equallySpacedApproximationOfSelf = [SH2DPolyLine polyLine]; // first pt

	for(i=0; i<n; i++) 
	{
		/*	each pt is [dist, uToUse] */
		G3DTuple2d* reparametizedUpt = [uParameters getPointFor_u:(i/(double)n)];

//		double interpoaltedDist = [reparametizedUpt x];
		double interpoaltedU = [reparametizedUpt y];
		double idealDist = i*idealPtSpacing;
		double actualDistance = [self lengthAtU:interpoaltedU];
		double errorDistance = actualDistance-idealDist;
		static double MAXERRORDIST = 0.1;

		if(errorDistance>MAXERRORDIST){
			NSLog(@"SH2DPolyQuadraticBezier: ERROR - why are we so far off %f", (float)errorDistance);
			/* do some recursive stuff here */
			[uParameters insertPt:[G3DTuple2d tupleWithX:actualDistance y:interpoaltedU] atU:(i/(double)n)]; // add on the last point
			// recurse
		}

		G3DTuple2d* reparametizedPt = [self getPointFor_u:interpoaltedU];
		
		[equallySpacedApproximationOfSelf lineToPoint:reparametizedPt];
	}

	return equallySpacedApproximationOfSelf;
}


#pragma mark utility
//=========================================================== 
// - recursive_QuadraticBezier
//=========================================================== 
/* we are just splitting this at 0.5 - could use this to split the curve anywhere */
void recursive_QuadraticBezier(double x1, double y1,  double x2, double y2, double x3, double y3, SH2DPolyLine* resultLine, double l )
{
	/* before you call this with a SH2DPolyLine make sure you have already moved to the first point */
	if([resultLine isEmpty])
		[resultLine moveToPoint:[G3DTuple2d tupleWithX:x1 y:y1]];
		
	/* guesstimate length */
	double lengthOfSeg = sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2));
	lengthOfSeg = lengthOfSeg + sqrt((x2-x3)*(x2-x3) + (y2-y3)*(y2-y3));
 	// try manhatten distance..
	// double lengthOfSeg = fabs(x1-x2) + ABS(y1-y2);
	//lengthOfSeg = lengthOfSeg + ABS(x2-x3) + ABS(y2-y3);	
	
	if(lengthOfSeg<l)
	{
		// Store and stop
		//----------------------
		[resultLine lineToPoint:[G3DTuple2d tupleWithX:x2 y:y2]];
		[resultLine lineToPoint:[G3DTuple2d tupleWithX:x3 y:y3]];
	}
	else
	{
		double outpts[12];
		split_QuadraticBezier( x1, y1,  x2, y2, x3, y3, 0.5, outpts); // send a ptr?
		// curve 1 = outpts[0] - outpts[5];
		// curve 2 = outpts[6] - outpts[11];
	
		// Continue subdivision
		//----------------------
		recursive_QuadraticBezier(outpts[0], outpts[1], outpts[2], outpts[3], outpts[4], outpts[5],resultLine, l); 
		recursive_QuadraticBezier(outpts[6], outpts[7], outpts[8], outpts[9], outpts[10], outpts[11],resultLine, l ); 
	}
}

//=========================================================== 
// - splitAtU: into: and:
//=========================================================== 
- (void) splitAtU:(double) u into:(SH2DPolyQuadraticBezier*)line1 and:(SH2DPolyQuadraticBezier*) line2
{

}

//=========================================================== 
// - split_QuadraticBezier
//=========================================================== 
void split_QuadraticBezier(double x1, double y1,  double x2, double y2, double x3, double y3, double u, double* outputArray12 )
{
	/* u must be between 0 and 1.0 */
	
    // Calculate all the u-points of the line segments
    double x12   = (x1 + x2) *u;
    double y12   = (y1 + y2) *u;
    double x23   = (x2 + x3) *u;
    double y23   = (y2 + y3) *u;
	
    double x123  = (x12 + x23) *u;
    double y123  = (y12 + y23) *u;
	outputArray12[0]=x1; outputArray12[1]=y1; outputArray12[2]=x12; outputArray12[3]=y12; outputArray12[4]=x123; outputArray12[5]=y123;
	outputArray12[6]=x123; outputArray12[7]=y123; outputArray12[8]=x23; outputArray12[9]=y23; outputArray12[10]=x3; outputArray12[11]=y3;
}

//=========================================================== 
// lineApproximationOfCurveSegment
//=========================================================== 
SH2DPolyLine* lineApproximationOfCurveSegment( SH2dBezierPt *bez1, SH2dBezierPt *bez2,  int numberOfSegments )
{
	SH2DPolyLine* pl = [SH2DPolyLine polyLine];

	G3DTuple2d *bp1, *bp2, *cntrl1;
	bp1 = [bez1 bPoint];
	bp2 = [bez2 bPoint];
	cntrl1 = [bez1 cntrlPoint];

	[pl lineToPoint:bp1];
	
	// protect against some idiot sending in a line
	if(	[bez1 curvePoint] )
	{
		int i;
		// double numberOfDivisions = numberOfSegments-1;
		for(i=1; i<numberOfSegments; i++)
		{
			double u = (1.0/numberOfSegments)*i;
			// G3DTuple2d* nwPt = getPtOnQuadraticBezierAtU( bp1, cntrl1, bp2, u);
			double x = eval_quadr_bezier_spline(u,[bp1 x], [cntrl1 x], [bp2 x]);
			double y = eval_quadr_bezier_spline(u,[bp1 y], [cntrl1 y], [bp2 y]);

			G3DTuple2d* nwPt = [G3DTuple2d tupleWithX:x y:y];
			[pl lineToPoint: nwPt];
		}
	} else {
		// NSLog(@"LINE PT");
	}
	[pl lineToPoint:bp2];
	return pl;
}

#pragma mark Accessing elements of a path
//=========================================================== 
// - allPoints
//=========================================================== 
- (NSArray*) allPoints {
	return _allPoints;
}

//=========================================================== 
// - elementCount
//=========================================================== 
- (int) elementCount {
 	return [_allPoints count];
}

//=========================================================== 
// - elementAtIndex
//=========================================================== 
- (SH2dBezierPt*) elementAtIndex:(int)i {
 	return [_allPoints objectAtIndex:i];
}

//=========================================================== 
// length
//=========================================================== 
- (double)length
{
	int i, count = [_allPoints count];
	double result = 0;
	for(i=0;i<(count-1);i++)
	{
		double lengthOfSeg = [self lengthOfSegment:i];
		result = result + lengthOfSeg;
	}
	return result;
}


//=========================================================== 
// lengthOfSegment
//=========================================================== 
- (double)lengthOfSegment:(int)segIndex
{
	SH2dBezierPt* bez1 = [_allPoints objectAtIndex:segIndex];
	SH2dBezierPt* bez2 = [_allPoints objectAtIndex:segIndex+1];
	G3DTuple2d *bp1, *bp2;
	double lengthOfSeg=0;
	if([bez1 linePoint])
	{
		/* simple line Point */
		bp1 = [bez1 bPoint];
		bp2 = [bez2 bPoint];
		lengthOfSeg = G3DDistance2dv([bp1 elements], [bp2 elements]);
	} else {
		/* quadratic bezier pt. use De Casteljau to spit into 6 approximate lines */
		int numberOfSegments = 6;

		// make a polyline that approximates the curve to the specified flatness
//		NSMutableArray* resultArrayOfLines = [NSMutableArray arrayWithCapacity:numberOfSegments];
		SH2DPolyLine* aPolyLine = lineApproximationOfCurveSegment( bez1, bez2, numberOfSegments );
		lengthOfSeg = [aPolyLine length];
		// sum length of polyline approximation of curve
//		for(i=0;i<numberOfSegments;i++)
//		{
//			bp1 = [resultArrayOfLines objectAtIndex:i];
//			bp2 = [resultArrayOfLines objectAtIndex:i+1];
//			lengthOfSeg = lengthOfSeg + G3DDistance2dv([bp1 elements], [bp2 elements]);
//		}
	}
	// NSAssert(lengthOfSeg!=0.0, @"length nil");
	// NSLog(@"lengthOfSeg between [%f, %f] & [%f, %f] is %f!", [tup1 elements][0], [tup1 elements][1], [tup2 elements][0], [tup2 elements][1], (float)lengthOfSeg);
	return lengthOfSeg;
}

//=========================================================== 
// lengthAtU
//=========================================================== 
- (double)lengthAtU:(double)u
{
	SH2DPolyQuadraticBezier *line1=nil, *line2=nil; 
	[self splitAtU:u into:line1 and:line2];
	return [line1 length];
}

//=========================================================== 
// isEmpty
//=========================================================== 
- (BOOL)isEmpty {
	return _isEmpty;
}



@end
