//
//  AudioFileParserTests.m
//  AudioFileParser
//
//  Created by steve hooley on 22/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "AudioFileParser.h"
#import "HooleyStuff.h"
#import <SHShared/SHShared.h>

@interface AudioFileParserTests : SenTestCase {
	
	AudioFileParser *_afp;
}

@end


@implementation AudioFileParserTests

- (void)setUp {
	_afp = [[AudioFileParser alloc] init];
}

- (void)tearDown {
	[_afp release];
}

static int _frameCountTest, _offsetTest, _lengthTests;
- (void)_makeSurethisIsCalled:(NSUInteger)frameCount :(struct HooAudioBuffer *)inputBuffer {
	
	_frameCountTest = frameCount;
	_offsetTest = inputBuffer->theOffset;
	_lengthTests = inputBuffer->length;
}

static int _wasCalled;
- (void)_makeSurethisIsAsWell {
	_wasCalled = 7;
}

- (void)testSetAQ_progressCallbackCustomInv {
	
	NSInvocation *actionInv;
	[[NSInvocation makeRetainedInvocationWithTarget:self invocationOut:&actionInv] _makeSurethisIsCalled:0 :nil];
	[_afp setAQ_progressCallbackCustomInv: actionInv ];
	
	struct HooAudioBuffer hmm;
	hmm.theOffset = 97;
	hmm.length = 62;
	
	// this should trigger our action
	[_afp _aq_callback_withData:&hmm];
	
	STAssertTrue( _frameCountTest==62, nil);
	STAssertTrue( _offsetTest==97, nil);
	STAssertTrue( _lengthTests==62, nil);
}

- (void)testSetAQ_completeCallbackCustomInv {
	
	NSInvocation *actionInv;
	[[NSInvocation makeRetainedInvocationWithTarget:self invocationOut:&actionInv] _makeSurethisIsAsWell];
	[_afp setAQ_completeCallbackCustomInv: actionInv ];
	
	// this should trigger our action
	[_afp _aq_callback_complete:nil];
	
	STAssertTrue( _wasCalled==7, nil);
}


@end
