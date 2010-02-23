//
//  AudioFileParser.h
//  AudioFileParser
//
//  Created by steve hooley on 18/12/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//
#import <CoreAudio/CoreAudioTypes.h>

@class FFTHelper, BufferStore;

@interface AudioFileParser : NSObject {

	FFTHelper		*_fft;
	BufferStore		*_bufferStore;
	
	AudioChannelLayout *_inputChannelLayout;
	AudioStreamBasicDescription *_captureFormat;
}

+ (AudioFileParser *)afp;

- (IBAction)processFiles:(id)sender;

- (AudioChannelLayout *)inputChannelLayout;
- (AudioStreamBasicDescription *)captureFormat;
@end
