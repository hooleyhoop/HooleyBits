//
//  LWKey.h
//  SHGeometryKit
//
//  Created by Steven Hooley on 30/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#define SHAPE_TCB   0
#define SHAPE_HERM  1
#define SHAPE_BEZI  2
#define SHAPE_LINE  3
#define SHAPE_STEP  4
#define SHAPE_BEZ2  5
#define SHAPE_EASE  6

@class LWEnvelope;

/*
 *
*/
@interface LWKey : NSObject <NSCoding> {

	LWKey			*_prev, *_next;

	CGFloat		_value;	// y
	CGFloat		_time;	// x
	NSUInteger		_shape;
	CGFloat		_tension;
	CGFloat		_continuity;
	CGFloat		_bias;
	CGFloat		_param[4];
	
   LWEnvelope		*_envelope;
}

@property (nonatomic, assign) LWKey *prev;
@property (nonatomic, retain) LWKey *next;
@property (nonatomic) CGFloat tension, continuity, bias;

#pragma mark -
#pragma mark class methods
+ (id)keyWithPt:(CGPoint)pt envelope:(LWEnvelope *)env;

#pragma mark init methods
- (id)initWithPoint:(CGPoint)pt envelope:(LWEnvelope *)env;

#pragma mark action methods
- (void)addKey:(LWKey *)next;
- (void)insertKeyAfter:(LWKey *)aKey;
- (void)insertKeyBefore:(LWKey *)aKey;
- (void)removeKey;

- (BOOL)isEqualToKey:(LWKey *)aKey;

/*
 * is a point within a specified distance of this point
*/
- (BOOL)ispointX:(CGFloat)x py:(CGFloat)y withDistX:(CGFloat)mx distX:(CGFloat)my;
- (BOOL)isCntrlPt1X:(CGFloat)x py:(CGFloat)y withDistX:(CGFloat)mx distX:(CGFloat)my;
- (BOOL)isCntrlPt2X:(CGFloat)x py:(CGFloat)y withDistX:(CGFloat)mx distX:(CGFloat)my;

#pragma mark manipulate methods
- (BOOL)translateByX:(CGFloat)x byY:(CGFloat)y;

#pragma mark accessor methods
- (CGFloat)value;
- (void)setValue:(CGFloat)v;
- (CGFloat)y;
- (void)setY:(CGFloat)v;

- (CGFloat)time;
- (BOOL)setTime:(CGFloat)t;
- (CGFloat)x;
- (BOOL)setX:(CGFloat)v;


- (NSUInteger)shape;
- (NSUInteger)incomingCurveBehavoir;
- (void)setIncomingCurveBehavoir:(NSUInteger)shape;

- (CGFloat *)param;

- (void)setParam0:(CGFloat)t;
- (void)setParam1:(CGFloat)t;
- (void)setParam2:(CGFloat)t;
- (void)setParam3:(CGFloat)t;

@end
