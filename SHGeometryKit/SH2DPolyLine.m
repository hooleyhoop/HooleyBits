//
//  SHPolyLine.m
//  CurveInterpolatyion
//
//  Created by Steve Hooley on 24/01/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SH2DPolyLine.h"
#import "G3DTuple2d.h"
#import "G3DVectorFunc.h"

@implementation SH2DPolyLine

#pragma mark -
#pragma mark class methods
//=========================================================== 
// + polyLine
//=========================================================== 
+ (SH2DPolyLine*)polyLine
{
	return [[[SH2DPolyLine alloc] init] autorelease];
}

//=========================================================== 
// + polyLineWithPoint
//=========================================================== 
+ (SH2DPolyLine*)polyLineWithPoint:(G3DTuple2d*)pt
{
	return [[[SH2DPolyLine alloc] initWithPoint:pt] autorelease];
}

#pragma mark init methods
//=========================================================== 
// - initWithPoint
//=========================================================== 
- (SH2DPolyLine*) initWithPoint:(G3DTuple2d*)pt
{
	SH2DPolyLine* newLine = [self init];
	[newLine moveToPoint:pt];
	return newLine;
}

//=========================================================== 
// - init
//=========================================================== 
- (SH2DPolyLine*) init
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
//=========================================================== 
// - splitAtU: into: and:
//=========================================================== 
- (void) splitAtU:(double)u into:(SH2DPolyLine*)line1 and:(SH2DPolyLine*)line2 
{
	// iterate thro line adding points to line 1
	// until u_onLine is greater than u
	NSAssert(line1!=nil, @"ERROR");
	NSAssert(line1!=nil, @"ERROR");
	NSAssert(u>=0 && u<=1.0 , @"ERROR");

	int i, count = [_allPoints count];
	double currentLength =0, cumulativeU=0;
	double totalLength = [self length];
	G3DTuple2d *pt1 = [_allPoints objectAtIndex:0];
	[line1 moveToPoint:pt1];
	
	for(i=1;i<count-1;i++)
	{
		pt1 = [_allPoints objectAtIndex:i];
		double lengthOfSeg = [self lengthOfSegment:i];
		currentLength = currentLength + lengthOfSeg;
		cumulativeU = currentLength/totalLength;
		if(cumulativeU>u)
			break;
		[line1 lineToPoint:pt1];
	}		
	// add pt u to end of line1
	G3DTuple2d *pt2 = [self getPointFor_u:u];
	[line1 lineToPoint:pt2];
	
	// add pt u to start of line2
	[line2 moveToPoint:pt2];

	// continue iterating thro self adding pts to line2
	int j;
	for(j=i;j<count;j++)
	{
		pt1 = [_allPoints objectAtIndex:j];
		[line2 lineToPoint:pt1];
	}

}

#pragma mark Constructing paths
//=========================================================== 
// - moveToPoint
//=========================================================== 
- (void) moveToPoint:(G3DTuple2d*)pt
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
- (void) lineToPoint:(G3DTuple2d*)pt
{
	if(_isEmpty)
		[self moveToPoint:pt];
	else {
		// check that the point doesnt equal the current end point
		int nOPts = [self elementCount];
		G3DTuple2d* endPt = [_allPoints objectAtIndex:nOPts-1];
		if([endPt isEqualToTuple:pt])
			return;
		[_allPoints addObject:pt];
	}
}

//=========================================================== 
// - relativeLineToPoint
//=========================================================== 
- (void) relativeLineToPoint:(G3DTuple2d*)pt
{
	int nOPts = [self elementCount];
	if(nOPts>0){
		G3DTuple2d* newEndPointCopy = [[[self elementAtIndex:nOPts-1] copy] autorelease]; // retain count 1?
		[newEndPointCopy addTuple2d: pt];
		[self lineToPoint:newEndPointCopy];
	} else {
		[self moveToPoint:pt];
	}
}

//=========================================================== 
// - insertPt: atIndex:
//=========================================================== 
 - (void) insertPt:(G3DTuple2d*)pt atIndex:(int)i 
 {
	// does it matter if we have zero length segments?
	if(i>-1){
		if(i<=[self elementCount])
			[_allPoints insertObject:pt atIndex:i];
		else 
			[self lineToPoint:pt];
	}
}


//=========================================================== 
// - insertPt:atU:
//=========================================================== 
 -(int) insertPt:(G3DTuple2d*)pt atU:(double)u
 {
	/* there may well be zero length segments */
	/* if a point already exists at u then the behavoir is undefined  */
	
	int i, count = [_allPoints count];
	G3DTuple2d *pt1, *pt2;
	BOOL flag = NO;
	double currentLength=0.0, totalLength = [self length], previousLength=0.0;
	double cumulativeU = 0;
	unsigned firstPt, secondPt;
	
	
	/* special cases */ 
	if(u==0.0){
		[self insertPt:pt atIndex:1.0];
		return 1;
	} else if(u==1.0){
		[self insertPt:pt atIndex:count-1];
		return count-1;
	}
	
	for(i=0;i<count-1;i++)
	{
		pt1 = [_allPoints objectAtIndex:i];
		pt2 = [_allPoints objectAtIndex:i+1];
	
		double lengthOfSeg = [self lengthOfSegment:i];
		
		currentLength = currentLength + lengthOfSeg;
		cumulativeU = currentLength/totalLength;
		
		if(cumulativeU>u){
			firstPt=i;
			secondPt=firstPt+1;
			flag = YES;
			break;
		}
		previousLength = currentLength;
	}	
	if(flag){
		[self insertPt:pt atIndex:secondPt];
	} else {
		secondPt = -1;
	}
	return secondPt;
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
	if(!_isEmpty){
		G3DTuple2d* pt = [_allPoints objectAtIndex:0];
		x1 = [pt x];
		y1 = [pt y];
		x2=x1;
		y2=y1;
		int i;
		int nOPts = [self elementCount];
		for(i=1;i<nOPts;i++)
		{
			pt = [_allPoints objectAtIndex:i];
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
	return NSMakeRect(x1,y1,x2-x1,y2-y1);
}

//=========================================================== 
// - nearestPoint
//=========================================================== 
//- (G3DTuple2d*) nearestPoint:(G3DTuple2d*)pt
//{
// 	to do
//}

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
		G3DTuple2d* pt1 = [_allPoints objectAtIndex:0];
		G3DTuple2d* resultPt = [[[G3DTuple2d alloc] initWithTuple:pt1] autorelease];
		return resultPt;
	}
	if(u==1.0){
		G3DTuple2d* pt1 = [_allPoints objectAtIndex:count-1];
		G3DTuple2d* resultPt = [[[G3DTuple2d alloc] initWithTuple:pt1] autorelease];
		return resultPt;
	}
	
 	// where does u lie along the length?
	double ln = [self length];
	double soughtLn = ln*u;
	double currentLength=0, previousLength=0;
	int firstPt=0, secondPt=0;
	// find the 2 pts that our desired pt is between
	G3DTuple2d *pt1, *pt2;
	
	for(i=0;i<count-1;i++)
	{
		pt1 = [_allPoints objectAtIndex:i];
		pt2 = [_allPoints objectAtIndex:i+1];
	
		double lengthOfSeg = G3DDistance2dv([pt1 elements], [pt2 elements]);

		currentLength = currentLength + lengthOfSeg;
		if(currentLength>soughtLn){
			firstPt=i;
			secondPt=firstPt+1;
			break;
		}
		previousLength = currentLength;
	}	
	// reult lies x% between pt[firstPt] and pt[secondPt]
	double xPercent = (soughtLn-previousLength)/(currentLength-previousLength); // not really a % but between 0 and 1

	G3DTuple2d* resultPt = [[[G3DTuple2d alloc] init] autorelease];
	// NSLog(@"SH2DPolyLine: interpolating between [%f, %f] and [%f,%f]", [pt1 x], [pt1 y], [pt2 x], [pt2 y] );
	
	double newX = ([pt2 x] - [pt1 x])*xPercent + [pt1 x];
	double newY = ([pt2 y] - [pt1 y])*xPercent + [pt1 y];
	
//	[resultPt interpolateBetween:pt1 and:pt2 factor:xPercent];
	[resultPt setX: newX];
	[resultPt setY: newY];	
	
	return resultPt;
}

//=========================================================== 
// - get_n_EqualSpacedPointsAlongLength
//=========================================================== 
- (NSArray*) get_n_EqualSpacedPointsAlongLength:(int)n
{
	if([self elementCount]<2)
		return nil;
		
	if(n<1)
		return nil;
		
	if(n==[self elementCount]){
		// NSLog(@"SH2DPolyLine: special case that we should check for!!");
		return [_allPoints copy];
	}
	// calculate u for n pts along the length
	NSMutableArray* arrayOfVals = [NSMutableArray arrayWithCapacity:n]; 
	double firstVal=0;
	[arrayOfVals addObject:[NSNumber numberWithDouble:firstVal]];

	double increment = 1.0/(n-1.0);
	int i;
	for(i=1;i<n;i++){
		firstVal = firstVal+increment;
		NSNumber* numWrapper = [NSNumber numberWithDouble:firstVal];
		[arrayOfVals addObject:numWrapper];
	}
	// arrayOfVals;
	
	NSMutableArray* arrayOfPts = [NSMutableArray arrayWithCapacity:n]; 
	
	/*** 
		V E R Y  T E M P O R A R Y
	***/
	for(i=0;i<n;i++){
		double percentageAlong = [[arrayOfVals objectAtIndex:i] doubleValue];
		G3DTuple2d* pt = [self getPointFor_u:percentageAlong]; // auto released object
		[arrayOfPts addObject:pt];
	}
	/*** 
		E N D  V E R Y  T E M P O R A R Y
	***/
	
	return arrayOfPts;
}

#pragma mark Accessing elements of a path
//=========================================================== 
// - elementCount
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
- (G3DTuple2d*) elementAtIndex:(int)i {
 	return [_allPoints objectAtIndex:i];
}

//=========================================================== 
// length
//=========================================================== 
- (double)length
{
	int i, count = [_allPoints count];
	double result = 0;
	for(i=0;i<count-1;i++)
	{
		double lengthOfSegment = [self lengthOfSegment:i];
		result = result + lengthOfSegment;
	}
	return result;
}

//=========================================================== 
// lengthOfSegment
//=========================================================== 
- (double)lengthOfSegment:(int)segIndex
{
	G3DTuple2d* tup1 = [_allPoints objectAtIndex:segIndex];
	G3DTuple2d* tup2 = [_allPoints objectAtIndex:segIndex+1];
	double lengthOfSeg = G3DDistance2dv([tup1 elements], [tup2 elements]);
	// NSAssert(lengthOfSeg!=0.0, @"length nil");
	// NSLog(@"lengthOfSeg between [%f, %f] & [%f, %f] is %f!", [tup1 elements][0], [tup1 elements][1], [tup2 elements][0], [tup2 elements][1], (float)lengthOfSeg);
	return lengthOfSeg;
}


//=========================================================== 
// lengthAtU
//=========================================================== 
- (double)lengthAtU:(double)u
{
	SH2DPolyLine* line1 = [SH2DPolyLine polyLine]; 
	SH2DPolyLine* line2 = [SH2DPolyLine polyLine];
	[self splitAtU:u into:line1 and:line2];
	return [line1 length];
}

// For line that goes from x1,y1,z1 to x2,y2,z2 ... and crosses zC.  
// Find xC, yC: where zC = 75


// Solution: 
// %along = (zC-z1)/(z2-z1)    'since you know all 3 Z values 
// xC = (%along * (x2 - x1)) + x1 
// yC = (%along * (y2 - y1)) + y1 


//=========================================================== 
// isEmpty
//=========================================================== 
- (BOOL)isEmpty {
	return _isEmpty;
}



@end
