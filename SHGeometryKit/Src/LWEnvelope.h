//
//  LWEnvelope.h
//  SHGeometryKit
//
//  Created by Steven Hooley on 30/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

@class LWKey;

#define BEH_RESET      0
#define BEH_CONSTANT   1
#define BEH_REPEAT     2
#define BEH_OSCILLATE  3
#define BEH_OFFSET     4
#define BEH_LINEAR     5

/*
 *
*/
@interface LWEnvelope : NSObject <NSCoding> {

	LWKey*		_key;
	NSUInteger	_nkeys;
	NSUInteger	_behavior[2];
	

	/* temp */
	NSString	*_name;
}

@property (nonatomic, readonly) NSUInteger nkeys;

#pragma mark -
#pragma mark class methods
+ (LWEnvelope *)lWEnvelope;
+ (LWEnvelope *)lWEnvelopeWithPoint:(CGPoint)pt;

#pragma mark init methods
- (id)init;
- (id)initWithPoint:(CGPoint)pt;

#pragma mark action methods
- (CGFloat)evalAtTime:(CGFloat)time;

#pragma mark Constructing paths
- (void)moveToPoint:(CGPoint)pt; /* watch out for differences in SH2dBezierPt arguments and G3DTuple2d arguments */

- (void)lineToPoint:(CGPoint)pt;

- (void)curveToPoint:(CGPoint)pt;
- (void)curveToPoint:(CGPoint)bPt cntrlPt:(CGPoint)cPt;

- (void)insertPt:(CGPoint)pt;
 
 /* this will let you insert points out of order so dont do it! - use the above method */
 - (void)insertPt:(CGPoint)pt atIndex:(NSUInteger)i;

- (void)removePointAtIndex:(NSUInteger)i;
- (void)removeAllPoints;

#pragma mark Querying paths
- (CGRect)bounds; 
- (void)getPts_Start:(CGFloat)startTime end:(CGFloat)endTime count:(NSUInteger)numberOfFrames into:(CGFloat *)vertexPositions;

-(BOOL)runsForwardAtKey:(LWKey *)aKey;

#pragma mark accessor methods
- (LWKey *)key;
- (void)setKey:(LWKey *)value;

- (NSUInteger *)behavior;
- (void)setPreBehavoir:(NSUInteger)behavoir;
- (void)setPostBehavoir:(NSUInteger)behavoir;

- (NSArray *)ptsAsArray;

/* temp methods */
- (NSString *)name;
- (void)setName:(NSString *)a;
- (NSNumber *)numberOfPts;
- (void)setNumberOfPts:(NSNumber *)a;

@end
