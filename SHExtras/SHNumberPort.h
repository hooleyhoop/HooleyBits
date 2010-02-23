//
//  SHNumberPort.h
//  BBExtras
//
//  Created by Steve Hooley on 02/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#ifndef __SHSHNumberPort
#define __SHSHNumberPort

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"


@interface SHNumberPort : QCNumberPort {

	NSString*	_key;	
}

#pragma mark -
#pragma mark class methods

#pragma mark init methods
- (id) initWithNode:(id)fp8 arguments:(id)fp12;
- (void) portWillDeleteFromNode;

#pragma mark accessor methods
- (NSString *)key;
- (void)setKey:(NSString *)aKey;

// - (double)doubleValue;
- (void)setDoubleValue:(double)fp8;
- (void)updateDoubleValue:(double)fp8;

@end
#endif