//
//  SpectralImageTests.m
//  AudioFileParser
//
//  Created by steve hooley on 23/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//
#import "SpectralImage.h"

@interface SpectralImageTests : SenTestCase {
	
	SpectralImage	*_img;
}

@end

@implementation SpectralImageTests

- (void)setUp {
	struct HooSpectralBufferList *specList;
	_img = [[SpectralImage alloc] initWithSpectrum:specList];
}

- (void)tearDown {
	[_img release];
}

- (void)testStuff {
	CGImageRef imageRef = [_img imageRef];
	STAssertNotNil(imageRef, nil);
}

@end
