//
//  SpectralImage.m
//  AudioFileParser
//
//  Created by steve hooley on 23/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "SpectralImage.h"
#import "HooSpectralProcessor.h"
#import <ApplicationServices/ApplicationServices.h>


@implementation SpectralImage

- (id)initWithSpectrum:(struct HooSpectralBufferList *)specList {
	
	self = [super init];
	if(self){
		// what do we know about specList? 	DSPSplitComplex mDSPSplitComplex[1];

		/*  values are between -2048 - +2048. scale it by  2n. */
//TODO: i think we are here!
//		num = num + 2048
//		num = num * (MAXFLOAT/4096)

	}
	return self;
}

- (void)dealloc {
	
	[super dealloc];
}

- (CGImageRef)imageRef {
	return nil;
}

@end
