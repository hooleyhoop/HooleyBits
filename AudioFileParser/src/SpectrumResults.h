//
//  SpectrumResults.h
//  AudioFileParser
//
//  Created by steve hooley on 22/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BufferStore, HooSpectralProcessor;
@interface SpectrumResults : NSObject {

	HooSpectralProcessor	*_spectralProcessor;
	BufferStore				*_bufferStore;
}

- (id)initWithFormattedData:(BufferStore *)arg;
- (void)processInputData;

@end
