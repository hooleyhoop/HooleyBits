//
//  OfflineAudioQueueWrapper.h
//  AudioFileParser
//
//  Created by steve hooley on 16/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreAudio/CoreAudioTypes.h>

@protocol OffLineAudioQueueCallbackProtocol;

@interface OfflineAudioQueueWrapper : NSObject {

	NSObject <OffLineAudioQueueCallbackProtocol>	*_callbackDelegate;
	NSString										*_in_AudioFilePath;
	
	AudioChannelLayout								*_inputChannelLayout;
	AudioStreamBasicDescription						*_captureFormat;

}

- (id)initWithAudioFilePath:(NSString *)pathArg dataConsumer:(NSObject <OffLineAudioQueueCallbackProtocol>*)callbackArg;
- (void)beginProcessing;

@end
