//
//  AudioFileParser.h
//  AudioFileParser
//
//  Created by steve hooley on 18/12/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//
#import <CoreAudio/CoreAudioTypes.h>
#import "OffLineAudioQueueCallbackProtocol.h"
@class FFTHelper, BufferStore;

@interface AudioFileParser : NSObject <OffLineAudioQueueCallbackProtocol> {

	FFTHelper					*_fft;
	BufferStore					*_bufferStore;
		
	NSString					*_in_AudioFilePath, *_out_graphicsDirPath;
}

@property (retain) NSString *in_AudioFilePath;
@property (retain) NSString *out_graphicsDirPath;

+ (AudioFileParser *)afp;

- (IBAction)processFiles:(id)sender;

- (AudioChannelLayout *)inputChannelLayout;
- (AudioStreamBasicDescription *)captureFormat;

@end
