//
//  AppController.h
//  AudioFileParser
//
//  Created by steve hooley on 22/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BufferStore;

@interface AppController : NSObject {

	NSString					*_in_AudioFilePath, *_out_graphicsDirPath;
	BufferStore					*_bufferStore;
}


@property (retain) NSString *in_AudioFilePath;
@property (retain) NSString *out_graphicsDirPath;

- (NSString *)in_AudioFilePath;
- (void)setIn_AudioFilePath:(NSString *)value;

@end
