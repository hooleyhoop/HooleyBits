//
//  SpectrumResultsTests.m
//  AudioFileParser
//
//  Created by steve hooley on 23/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "SpectrumResults.h"
#import "BufferStore.h"
#import <SHShared/SHShared.h>

@interface SpectrumResultsTests : SenTestCase {
	
	OCMockObject *_mockData;
	SpectrumResults *_specResults;
}

@end


@implementation SpectrumResultsTests

- (void)setUp {
	_mockData = MOCK(BufferStore);
	_specResults = [[SpectrumResults alloc] initWithFormattedData:(id)_mockData];
}

- (void)tearDown {
	[_specResults release];
}

- (void)testSomeLikeShit {
	
	[[_mockData expect] resetReading];
	[[[_mockData expect] andReturnBOOLValue:YES] hasMoreSamples];
	Float32 *samples = malloc(sizeof(Float32)*1024);
	samples[0] = 21.0f;
	samples[1] = 22.0f;

	NSValue *wrapper = [NSValue value:&samples withObjCType:@encode(Float32 *)];
	
	Float32 *test;
	[wrapper getValue:(void *)&test];
	Float32 v1 = test[0];
	Float32 v2 = test[1];
	STAssertTrue( G3DCompareFloat(v1, 21.0f, 0.001f)==0, nil );
	STAssertTrue( G3DCompareFloat(v2,22.0f,0.001f)==0, nil );
	
	[[[_mockData expect] andReturnValue:wrapper] nextSamples];
	[[[_mockData expect] andReturnBOOLValue:NO] hasMoreSamples];

	[_specResults processInputData];
	STAssertTrue([_specResults frameCount]==2, nil);
	
	struct HooSpectralBufferList *aFrame = [_specResults frameAtIndex:0];

	[_mockData verify];
}

@end
