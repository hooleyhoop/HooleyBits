/*
 *  OffLineAudioQueueCallbackProtocol.h
 *  AudioFileParser
 *
 *  Created by steve hooley on 16/04/2010.
 *  Copyright 2010 BestBefore Ltd. All rights reserved.
 *
 */

@protocol OffLineAudioQueueCallbackProtocol <NSObject>

- (void)_callback_error:(id)hmm;
- (void)_callback_withData:(struct HooAudioBuffer *)hmm;
- (void)_callback_complete:(id)hmm;

@end
