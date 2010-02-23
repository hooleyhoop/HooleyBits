//
//  FFTHelper.m
//  AudioFileParser
//
//  Created by Steven Hooley on 02/01/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "FFTHelper.h"
#import "ProcessingStuff.h"


@implementation FFTHelper

- (id)init {
	
	self = [super init];
	if (self) {
		_processor = [[ProcessingStuff alloc] init];
	}
	return self;
}

- (void)dealloc {
	
	[_processor release];
	[super dealloc];
}

- (void)open {
	[_processor openWriteFile];
}
- (void)close {
	[_processor closeWriteFile];
}

- (void)processSomeAudio:(UInt32)inFramesToProcess :(Float32 *)aSingleBlock {

	// can we reuse on buffer list?
	AudioBufferList *inInput = (AudioBufferList *)calloc(1, sizeof(AudioBufferList));
	inInput->mNumberBuffers = 1;

//	AudioBuffer *aBuf = (AudioBuffer *)calloc(1, sizeof(AudioBuffer));
//	inInput->mBuffers[0] = *aBuf;

	AudioBuffer *aBuf = inInput->mBuffers;
	aBuf->mNumberChannels=1;
	aBuf->mDataByteSize = inFramesToProcess*sizeof(Float32);
	aBuf->mData = aSingleBlock;


	
//	AudioBuffer mBuffers[kVariableLengthArray];
//	mBuffers[0] = *aBuf;
//	mBuffers = aBuf;
//	AudioBuffer huh = inInput->mBuffers[0];
	

	[_processor processSomeAudio:inFramesToProcess :inInput];

	free(inInput);
//	free(aBuf);
}

- (void)saveImage {
	
	NSPointerArray *allMags = [_processor allFFTMagnitudes];

	BOOL hasAlpha = NO;
	BOOL isPlanar = NO;
	NSInteger width = [allMags count];
	NSInteger height = 512;
	NSInteger bitsPerSample = 8; // 1, 2, 4, 8, or 16
	NSInteger spp = 1;
	NSString *colorSpaceName = NSCalibratedWhiteColorSpace;
	NSBitmapFormat bitmapFormat = 0;
	NSInteger rowBytes = spp*width;
	NSInteger pixelBits = bitsPerSample*spp;
	unsigned char *data_ptr = calloc(width*height, sizeof(unsigned char));
	unsigned char **planes = &data_ptr;// 1 buffer as not planar

	NSBitmapImageRep *outImageRep = [[NSBitmapImageRep alloc]
									 initWithBitmapDataPlanes:planes 
									 pixelsWide:width 
									 pixelsHigh:(NSInteger)height 
									 bitsPerSample:pixelBits
									 samplesPerPixel:spp 
									 hasAlpha:hasAlpha 
									 isPlanar:isPlanar 
									 colorSpaceName:colorSpaceName 
									 bitmapFormat:bitmapFormat 
									 bytesPerRow:rowBytes 
									 bitsPerPixel:pixelBits];
	
	for( NSUInteger row=0; row<height; row++ )
	{
		for( NSUInteger col=0; col<width; col++ )
		{
			NSUInteger dstPix = row*width+col;
			
			Float32 *buffer = (Float32 *)[allMags pointerAtIndex:col];
			Float32 floatVal = buffer[row];
			Float32 floatValBetweenZeroAndOne = floatVal/625.0f;
			Float32 root = sqrt(floatValBetweenZeroAndOne);
			Float32 floatVal2 = root*255.0f;;
		
			unsigned char val = round(floatVal2);
			data_ptr[dstPix] = val;
		}
	}
	
//	for( NSUInteger row=0; row<[allMags count]; row++ ){
//		for( NSUInteger j=0; j<height; j++ ){
//	
//		}
//	}
	NSData *zNsDataTiffData2 = [outImageRep TIFFRepresentation];
	BOOL result = [zNsDataTiffData2 writeToFile:[@"~/Desktop/ooooo.tif" stringByExpandingTildeInPath] atomically:YES];
	NSLog(@"saved file %i", result);
	[outImageRep release];
	free(data_ptr);
}


@end
