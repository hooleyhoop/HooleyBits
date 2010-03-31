//
//  LWKey.m
//  SHGeometryKit
//
//  Created by Steven Hooley on 30/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "LWKey.h"
#import "LWEnvelope.h"
#import "G3DFunctions.h"

/*
 *
*/
@implementation LWKey

@synthesize prev=_prev, next=_next;
@synthesize tension=_tension, continuity=_continuity, bias=_bias;

#pragma mark -
#pragma mark class methods
+ (id)keyWithPt:(CGPoint)pt envelope:(LWEnvelope *)env {

	return [[[LWKey alloc] initWithPoint:pt envelope:env] autorelease];
}

#pragma mark init methods
- (id)init {

	self=[super init];
    if(self) 
	{
		_next = nil;
		_prev = nil;
		_envelope = nil;
		_value=0.0;	// y
		_time=0.0;	// x
		_shape=0;
		_tension=0.0;
		_continuity=0.0;
		_bias=0.0;
		_param[0] = 0;
		_param[1] = 0;
		_param[2] = 100;
		_param[3] = 100;	
    }
    return self;
}

- (id)initWithPoint:(CGPoint)pt envelope:(LWEnvelope *)env {

	LWKey* newKey = [self init];
	[newKey setTime:pt.x];
	[newKey setValue:pt.y];
	_envelope = env;
	return newKey;
}

- (void)dealloc {

	[_next setPrev:nil];
	[self setNext:nil];
	_envelope = nil;
    [super dealloc];
}

#pragma mark action methods
- (void)addKey:(LWKey *)next {

	[self setNext:next];
	[_next setPrev:self];
}

- (void)insertKeyAfter:(LWKey *)aKey {

	LWKey* key3 = _next;
	LWKey* key2 = aKey;
	LWKey* key1 = self;
	
	[key2 setNext:key3];
	[key3 setPrev:key2];
	[key1 addKey:key2];
}

- (void)insertKeyBefore:(LWKey *)aKey {

	LWKey* key3 = self;
	LWKey* key2 = aKey;
	LWKey* key1 = _prev;
	
	[key2 setNext:key3];
	[key2 setPrev:key1];
	
	[key1 setNext:aKey];
	[key3 setPrev:key2];
}

- (void)removeKey {

	[_next setPrev:_prev];
	[_prev setNext:_next];
	[self setPrev:nil];
	[self setNext:nil];
}

- (BOOL)isEqualToKey:(LWKey *)aKey {
	if(	G3DCompareFloat(_value, [aKey value], 0.00001f)==0 && G3DCompareFloat(_time, [aKey time], 0.00001f)==0){
		// dont know how these work at the mo so will do the rest later
		return YES;
	}
	return NO;
}
 
- (BOOL)ispointX:(CGFloat)x py:(CGFloat)y withDistX:(CGFloat)mx distX:(CGFloat)my {

	CGPoint p = CGPointMake(x, y);
	CGRect r;
	r = CGRectMake( _time-mx, _value-my, mx*2, my*2);
	return CGRectContainsPoint(r,p);
}

- (BOOL)isCntrlPt1X:(CGFloat)x py:(CGFloat)y withDistX:(CGFloat)mx distX:(CGFloat)my {
	
	// NSLog(@"point is [%f, %f], we are [%f, %f]", x, y, _time+_param[0], _value+_param[1]);
	CGPoint p  = CGPointMake(x, y);
	CGRect r;
	// what type of curve are we?
	switch(_shape){
		/* bez 2 */
		case 5:
			r = CGRectMake( _time+_param[0]-mx, _value+_param[1]-my, mx*2, my*2);
			BOOL hit = CGRectContainsPoint(r,p);
			if(hit)
				return YES;
			break;
	}
	return NO;
}

- (BOOL)isCntrlPt2X:(CGFloat)x py:(CGFloat)y withDistX:(CGFloat)mx distX:(CGFloat)my {
	
	CGPoint p  = CGPointMake(x, y);
	CGRect r;
	// what type of curve are we?
	switch(_shape){
		/* bez 2 */
		case 5:
			r = CGRectMake( _time+_param[2]-mx, _value+_param[3]-my, mx*2, my*2);
			BOOL hit = CGRectContainsPoint(r,p);
			if(hit)
				return YES;
			break;
	}
	return NO;
}

#pragma mark manipulate methods
- (BOOL)translateByX:(CGFloat)x byY:(CGFloat)y {

	CGFloat prevX, nextX;
	CGFloat oldX = _time;
	CGFloat oldValue = _value;
	CGFloat newxX = _time+x;

	if(_prev)
		prevX = [_prev time];
	else prevX = newxX-1;	// just to make sure it will pass the next conditional 
	if(_next)
		nextX = [_next time];
	else nextX = newxX+1;
	
	// -- check bounds of previous and last keys
	if(newxX<nextX && newxX>prevX)
		_time =newxX;
	else 
		return NO;
	_value=_value+y;
	
	// check that it runs forward..
	BOOL runsForward = [_envelope runsForwardAtKey:self];

	if(!runsForward)
	{
		_time =oldX;
		_value=oldValue;
		return NO;
	} // else {
	// 	NSLog(@"we sure are running forward");
	// }
	return YES; // it all worked out ok
}

#pragma mark accessor methods
- (CGFloat)value {
	return _value;
}

- (void)setValue:(CGFloat)v {
	_value=v;
}

- (CGFloat)y {
	return _value;
}

- (void)setY:(CGFloat)v {
	_value=v;
}

- (CGFloat)time {
	return _time;
}

- (BOOL)setTime:(CGFloat)t {

	// -- check bounds of previous and last keys
	float prevX, nextX;
	
	if(_prev)
		prevX = [_prev time];
	else prevX = t-1;	// just to make sure it will pass the next conditional 
	if(_next)
		nextX = [_next time];
	else nextX = t+1;
	
	if(t<nextX && t>prevX)
	{
		_time = t;
		return YES;
	}
	return NO;
}

- (CGFloat)x {
	return _time;
}

- (BOOL)setX:(CGFloat)v {

	return [self setTime:v];
}

- (NSUInteger)shape {
	return _shape;
}

- (NSUInteger)incomingCurveBehavoir {
	return [self shape];
}

- (void)setIncomingCurveBehavoir:(NSUInteger)shape {

	if(shape!=_shape)
	{
		_shape = shape;
		CGFloat prex, nextx;
		/* set some default values */
		switch(_shape){
			case 0:
				break;
			case 1:
			case 2:
				[self setParam0:0];
				[self setParam1:0];
				break;
			case 3:
				break;
			case 4:
				break;
			case 5:
				/* make up some initial values for the bezier control pts */
				if(_prev)
					prex = [_prev x];
				else
					prex = -5;
				if(_next)
					nextx = [_next x];
				else
					nextx = 5.0;
				[self setParam0: -((_time-prex)/20)];	// arbitrarily 20 % toawards previous pt without
				[self setParam1: 0];					// any checking to see if it clashes with previous pts 
				[self setParam2:(nextx-_time)/20];		// control pts
				[self setParam3: 0];
				break;
		}
	}
}

- (CGFloat *)param {
	return _param;
}

- (void)setParam0:(CGFloat)t {

	CGFloat oldParam0 = _param[0];
	_param[0] = t;
	BOOL ok = [_envelope runsForwardAtKey:self];
	if(!ok){
		NSLog(@"LWKey: ERROR setParam0");
		_param[0] = oldParam0;
	}
}

- (void)setParam1:(CGFloat)t {

	CGFloat oldParam1 = _param[1];
	_param[1] = t;
	BOOL ok = [_envelope runsForwardAtKey:self];
	if(!ok){
		NSLog(@"LWKey: ERROR setParam1");
		_param[1] = oldParam1;
	}	
}

- (void)setParam2:(CGFloat)t {

	CGFloat oldParam2 = _param[2];
	_param[2] = t;
	BOOL ok = [_envelope runsForwardAtKey:self];
	if(!ok){
		NSLog(@"LWKey: ERROR setParam2");
		_param[2] = oldParam2;
	}		
}

- (void)setParam3:(CGFloat)t {

	CGFloat oldParam3 = _param[3];
	_param[3] = t;
	BOOL ok = [_envelope runsForwardAtKey:self];
	if(!ok){
		NSLog(@"LWKey: ERROR setParam3");
		_param[3] = oldParam3;
	}		
}


#pragma mark NSCoding methods

- (void)encodeWithCoder:(NSCoder *)coder {

	// [super encodeWithCoder:coder];
	[coder encodeObject:_next forKey:@"_next"];
	[coder encodeObject:_prev forKey:@"_prev"];

    [coder encodeFloat:_value forKey:@"_value"];
    [coder encodeFloat:_time forKey:@"_time"];
    [coder encodeInt:_shape forKey:@"_shape"];
    [coder encodeFloat:_tension forKey:@"_tension"];
    [coder encodeFloat:_continuity forKey:@"_continuity"];
    [coder encodeFloat:_bias forKey:@"_bias"];
	[coder encodeObject:_envelope forKey:@"_envelope"];
	[coder encodeArrayOfObjCType:@encode(CGFloat)count:4 at:_param];
	
    return;
}

- (id)initWithCoder:(NSCoder *)aCoder {

	self=[super init];
	if (self)
	{
		[self setNext:[aCoder decodeObjectForKey:@"_next"]] ;
		[self setPrev: [aCoder decodeObjectForKey:@"_prev"]];
		
		_value = [aCoder decodeFloatForKey:@"_value"];
		_time = [aCoder decodeFloatForKey:@"_time"];
		_shape = [aCoder decodeIntForKey:@"_shape"];
		_tension = [aCoder decodeFloatForKey:@"_tension"];
		_continuity = [aCoder decodeFloatForKey:@"_continuity"];
		_bias = [aCoder decodeFloatForKey:@"_bias"];
		
		// retained somewhere else
		_envelope = [aCoder decodeObjectForKey:@"_envelope"];
		
		// NSLog(@"_envelope is %@", _envelope);
		[aCoder decodeArrayOfObjCType:@encode(float)count:4 at:_param];
	}
	return self;
}

//- (id)copyWithZone:(NSZone *)zone
//{
//  return [[[self class] allocWithZone:zone] initWithTuple:self];
//}

@end
