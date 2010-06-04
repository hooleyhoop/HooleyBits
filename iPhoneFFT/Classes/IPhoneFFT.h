//
//  IPhoneFFT.h
//  iPhoneFFT
//
//  Created by Steven Hooley on 27/05/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>


@interface IPhoneFFT : NSObject {

	//without graph
	AudioUnit		_inputRemoteIOUnit;
	
	// Graph way
	AUGraph			_audioGraph;
	AUNode			_inputNode1, _mixerNode;
	AudioUnit		_inputUnit1;

}

- (void)beginRecording;

@end
