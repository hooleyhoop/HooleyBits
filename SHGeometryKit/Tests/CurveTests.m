//
//  CurveTests.m
//  CurveInterpolatyion
//
//  Created by Steve Hooley on 09/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface CurveTests : SenTestCase {
	
}

@end


@implementation CurveTests

//lineto
//linear test
//
//	b = make a curve( linear )
//
//	b.addPoint(0,0)
//	b.addPoint(100,100)
//
//	t = b.getXForY(50);
//	assert t = 50
//
//	t = b.getYForX(50);
//	assert t = 50
//
//	b.addPoint( 50, 50 )
//
//	assert numberOfPoints = 3
//
//	pIndex = b.nearestPoint( 50, 50 )
//
//	assert pIndex = 1
//
//	b.removePointAtIndex( 1 )
//
//	assert numberOfPoints = 2
//
//	b.addPointAtY( 10 )
//
//	b.movePoint:1 to ( 10, 20 )
//
//	t = b.getXForY(50);
//	assert t = ??
//
//	t = b.getYForX(50);
//	assert t = ??
//
//
//make a curve( cubic )
//
//make a curve( quadratic )
//
//add a point


@end
