//
//  AppController.m
//  AudioFileParser
//
//  Created by steve hooley on 22/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "AppController.h"
#import "BufferStore.h"
#import "AudioFileParser.h"
#import "SpectrumResults.h"

#import <SHShared/SHShared.h>

@implementation AppController

@synthesize in_AudioFilePath = _in_AudioFilePath;
@synthesize out_graphicsDirPath = _out_graphicsDirPath;


- (id)init {

	self = [super init];
	if(self){
		_in_AudioFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/in.wav"] retain];
		_out_graphicsDirPath = [@"shit" retain];
	}
	return self;
}

- (void)dealloc {
	
	[_in_AudioFilePath release];
	[_out_graphicsDirPath release];
	
	[super dealloc];
}

- (void)awakeFromNib {
	logError(@"what the fuuuuuu!");
	
}

- (void)doIt {
	
	// processed audio goes into here
	_bufferStore = [[BufferStore alloc] init];
	[_bufferStore setBlockSize:1024];

	AudioFileParser *afp = [[AudioFileParser alloc] initWithAudioFileURL:_in_AudioFilePath];
	
	NSInvocation *progressActionInv;
	[[NSInvocation makeRetainedInvocationWithTarget:_bufferStore invocationOut:&progressActionInv] addFrames:0 :nil];
	[afp setAQ_progressCallbackCustomInv: progressActionInv ];
	
	// make sure bufferstore flushes
	NSInvocation *completActionInv;
	[[NSInvocation makeRetainedInvocationWithTarget:_bufferStore invocationOut:&completActionInv] noMoreData];
	[afp setAQ_completeCallbackCustomInv: completActionInv ];
	
	[afp processInputFile];
	[afp release];
	
	SpectrumResults *spectroResults = [[SpectrumResults alloc] initWithFormattedData:_bufferStore];
	[spectroResults processInputData];
	[_bufferStore release];

	-- now we can get frames from spectroResults and render them to a movie!
	
	[spectroResults release];
	
	// generate spectrum data from the audio
	//	[movieWriter release];

	
	// ld stuff?
	//	_fft = [FFTHelper new];
	//	[_fft open];
	//	

	//		
	//#warning! fill with 1
	////		memset(samples, 1, sizeof(Float32)*1024 );
	//		
	//
	//		[_fft processSomeAudio:1024 :samples];
	//	[_fft close];
	//
	//	[_fft saveImage];
	//Doh!	[_fft saveImageSequence];
	
	//[_fft release];
	
	

	 
}
 
@end
