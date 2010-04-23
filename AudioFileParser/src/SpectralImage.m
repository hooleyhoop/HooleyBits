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
