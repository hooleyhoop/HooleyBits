//
//  SHGlobalVar.h
//  BBExtras
//
//  Created by Steve Hooley on 02/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "QCClasses.h"


@class QCIndexPort, QCNumberPort, QCStringPort, QCBooleanPort, QCVirtualPort, QCColorPort, QCGLImagePort, QCStructurePort;
@class SHNumberPort;

@interface SHGlobalVar : QCPatch 
{
	// inputs must be called *inputBlah
	QCStringPort	*inputKeyForVariable;
	QCBooleanPort	*inputTakeSampleSignal;
	QCNumberPort	*inputSignal;

	// and outputs must be called *outputBlah… how tedious!
	SHNumberPort	*outputValue;
	
}

#pragma mark -
#pragma mark class methods
+ (int)executionMode;
+ (BOOL)allowsSubpatches;

- (id)initWithIdentifier:(id)fp8;
- (BOOL)execute:(id)fp8 time:(double)fp12 arguments:(id)fp20;

@end

