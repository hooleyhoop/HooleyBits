//
//  BBInterpolationPatch.m
//  SHExtras
//
//  Created by Steven Hooley on 16/01/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BBInterpolationPatch.h"
#import <SHGeometryKit/SHGeometryKit.h>		

/*
 *
*/
@implementation BBInterpolationPatch

//=========================================================== 
// + executionMode:
//=========================================================== 
+ (int)executionMode {
	return 3;
}

//=========================================================== 
// - timeMode:
//=========================================================== 
+ (int)timeMode {
	return 1;
}

//=========================================================== 
// - allowsSubpatches:
//=========================================================== 
+ (BOOL)allowsSubpatches {
	return FALSE;
}

//=========================================================== 
// - initWithIdentifier:
//=========================================================== 
- (id)initWithIdentifier:(id)fp8
{
	if (![super initWithIdentifier:fp8])
		return nil;
	[self setEnvelope: [LWEnvelope lWEnvelope]];
	[_envelope moveToPoint:[G3DTuple2d tupleWithX:0 y:10]];
	[_envelope lineToPoint:[G3DTuple2d tupleWithX:100 y:1]];

	return self;
}

#pragma mark action methods
//=========================================================== 
// - execute: time: arguments:
//=========================================================== 
- (BOOL)execute:(id)fp8 time:(double)compositionTime arguments:(id)fp20	
{
	// NSLog(@"BBInterpolationPatch: %@ executing at time %f", [self description], (float)compositionTime);
	
	/* all i know..
	[inputNumber didChangeValue] will cause this patch to execute, but nothing further down the chain if the value hasn't really changed
	doing this on the outport port has no effect
	[outputNumber setDoubleValue:xxx] will cause everything below in the chain to be updated but only if xxx is a different value
	[self _setNeedsExecution] will cause us to executed, but not the chain if no values have changed
	
//	[inputNumber setDoubleValue:[inputNumber doubleValue]+1];

	[outputNumber setDoubleValue:[inputNumber doubleValue]];
//	outputNumber updated
//	outputNumber wasUpdated

	/* returning no causes an exception */
	[outputValue setDoubleValue: [_envelope evalAtTime:compositionTime]];

	return YES;
}



#pragma mark accessor methods
- (LWEnvelope *)envelope {
    return _envelope;
}

- (void)setEnvelope:(LWEnvelope *)value {
    if (_envelope != value) {
        [_envelope release];
        _envelope = [value retain];
    }
}

// ===========================================================
// - name:
// ===========================================================
//- (NSString*) name
//{
//	// NSLog(@"getting name!!");
//	NSMutableDictionary* usrInfo = [self userInfo];
//	NSString* name = [usrInfo objectForKey:@"name"];
//	if(name){
//		return name;
//	}
//	if([self respondsToSelector:@selector(identifier)])
//	{
//		id identif = [self identifier];
//		// NSLog(@"identif is %@", identif);
//
//		// nodeForKey:identif
//		// nodes arrayOfKeys
//		if(identif)
//			return identif;
////	} 
//	if([self respondsToSelector:@selector(_baseKey)])
//	{
//		id akey = [self _baseKey];
//		///NSLog(@"key is %@", akey);
//		if(akey){
//			return akey;
//		}
//	} 
//	return NSStringFromClass([self class]);
//}


//=========================================================== 
// - setSh_name
//=========================================================== 
- (void)setSh_name:(NSString*)aName
{
	[super setSh_name:aName];
	[_envelope setName:[self sh_name]];
}

//=========================================================== 
// - setState
//=========================================================== 
- (BOOL)setState:(id)state 
{
	[super setState: state];

	NSData* curveData = [state valueForKey:@"curve"];
	id unArchivedCurve = [NSKeyedUnarchiver unarchiveObjectWithData:curveData];
	[self setEnvelope: unArchivedCurve];
	return TRUE;
}

//=========================================================== 
// - state
//=========================================================== 
- (id)state 
{
	/* we must fill out this for user added ports */
	NSMutableDictionary* state = [super state];

	NSData *curveData = [NSKeyedArchiver archivedDataWithRootObject:_envelope];
	[state setValue:curveData forKey:@"curve"];

	return state;
}



@end
