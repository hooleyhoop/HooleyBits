//
//  PDDac.h
//  SHMathOperators
//
//  Created by Steve Hooley on 13/03/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
 * 64 samples = 1.15 msec at 44100
*/
@interface PDDac : SHProtoOperator {

	SHInputAttribute			*leftSignalIn;
	SHInputAttribute			*rightSignalIn;
	SHOutputAttribute			*portAudioOut;

	NSInvocation				*_advanceTimeInvocation;
}

#pragma mark -
#pragma mark init methods
- (id)initWithParentNodeGroup:(SHNodeGroup*)aNG;

- (void)initInputs;
- (void)initOutputs;

#pragma mark action methods
- (int) advanceTimePerFrame;

- (void) evaluate;

#pragma mark accessor methods

@end
