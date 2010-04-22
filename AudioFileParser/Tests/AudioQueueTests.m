//
//  AudioQueueTests.m
//  AudioFileParser
//
//  Created by steve hooley on 16/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//


#import "OfflineAudioQueueWrapper.h"

@interface AudioQueueTests : SenTestCase {
	
}

@end


@implementation AudioQueueTests

- (void)testCreateAudioOfflineQueueWrapper {
	
	OfflineAudioQueueWrapper *qw = [[OfflineAudioQueueWrapper alloc] initWithAudioFilePath:@"/in.wav" dataConsumer:self];
	STAssertNotNil(qw, nil, nil);
	
	[qw beginProcessing];
	
	[qw release];	
}

- (void)_aq_callback_error:(id)hmm {
	
}
- (void)_aq_callback_withData:(struct HooAudioBuffer *)hmm {
	
}
- (void)_aq_callback_complete:(id)hmm {
	
}

@end
