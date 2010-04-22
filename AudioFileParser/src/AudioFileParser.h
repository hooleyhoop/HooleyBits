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
		
	NSInvocation				*_aq_progressCallbackCustomInv, *_aq_completeCallbackCustomInv;
	NSString					*_inputFile;
}

- (id)initWithAudioFileURL:(NSString *)arg1;
- (void)processInputFile;

//- (AudioChannelLayout *)inputChannelLayout;
//- (AudioStreamBasicDescription *)captureFormat;

- (void)setAQ_progressCallbackCustomInv:(NSInvocation *)arg;
- (void)setAQ_completeCallbackCustomInv:(NSInvocation *)arg;

@end
