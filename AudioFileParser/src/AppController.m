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
#import "SpectralImage.h"
#import <SHShared/SHShared.h>

@interface AppController()

- (void)requestImageAtFrame:(NSUInteger)arg;

@end

@implementation AppController

@synthesize in_AudioFilePath = _in_AudioFilePath;
@synthesize out_graphicsDirPath = _out_graphicsDirPath;
@synthesize frameLabel = _frameLabel;

- (id)init {

	self = [super init];
	if(self){
		_in_AudioFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/in.wav"] retain];
		_out_graphicsDirPath = [@"shit" retain];
		_frameLabel = [[NSNumber numberWithInt:70] retain];
	}
	return self;
}

- (void)dealloc {
	
	[_in_AudioFilePath release];
	[_out_graphicsDirPath release];
	[_frameLabel release];
	
	[_spectroResults release];
	
	[super dealloc];
}

- (void)awakeFromNib {
	
}

- (IBAction)openPath:(id)sender {
	
}
- (IBAction)savePath:(id)sender {
	
}

- (IBAction)doit:(id)sender {
	
}

- (IBAction)stepperClicked:(id)sender {
	self.frameLabel = [NSNumber numberWithInt:[sender intValue]];
	[self requestImageAtFrame:[sender intValue]];
}

- (void)doIt {

	NSAssert( _spectroResults==nil, @"Hai");

	// processed audio goes into here
	BufferStore *bufferStore = [[BufferStore alloc] init];
	[bufferStore setBlockSize:1024];

	AudioFileParser *afp = [[AudioFileParser alloc] initWithAudioFileURL:_in_AudioFilePath];
	
	NSInvocation *progressActionInv;
	[[NSInvocation makeRetainedInvocationWithTarget:bufferStore invocationOut:&progressActionInv] addFrames:0 :nil];
	[afp setAQ_progressCallbackCustomInv: progressActionInv ];
	
	// make sure bufferstore flushes
	NSInvocation *completActionInv;
	[[NSInvocation makeRetainedInvocationWithTarget:bufferStore invocationOut:&completActionInv] closeInput];
	[afp setAQ_completeCallbackCustomInv: completActionInv ];
	
	[afp processInputFile];
	[afp release];
	
	_spectroResults = [[SpectrumResults alloc] initWithFormattedData:bufferStore];
	[_spectroResults processInputData];
	[bufferStore release];

	// -- now we can get frames from _spectroResults and render them to a movie!
	NSAssert( [_spectroResults frameCount]==([bufferStore numberOfWholeBuffers]*2 - 1),  nil);
	
	[_spectroResults release];
	
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
 
- (void)requestImageAtFrame:(NSUInteger)arg {
	
	struct HooSpectralBufferList *specList = [_spectroResults frameAtIndex:arg];
	SpectralImage *si = [[[SpectralImage alloc] initWithSpectrum:specList] autorelease];
	
	[_imageView setImage:[si imageRef] imageProperties:nil];
	 

}

@end
