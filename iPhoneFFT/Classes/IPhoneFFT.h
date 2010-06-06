//
//  IPhoneFFT.h
//  iPhoneFFT
//
//  Created by Steven Hooley on 27/05/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

@class OouraFFT;

@interface IPhoneFFT : NSObject <NSPortDelegate> {

	//without graph
	AudioUnit		_inputRemoteIOUnit;
	
	// Graph way
	AUGraph		_audioGraph;
	AUNode			_inputNode1, _mixerNode;
	AudioUnit		_inputUnit1;

	// Background thread
	NSPort			*_distantPort;
	int32_t		_hasData;
	OouraFFT		*_myFFT
}

- (void)beginRecording;

@end
