//
//  FileWriter.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 11/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


@interface FileWriter : NSObject <NSStreamDelegate> {

	NSOutputStream		*_oStream;
	
	id					_src;
	SEL					_callback;
	
	id					_completeTarget;
	SEL					_completeCallBack;
}

- (void)asyncCreateOutputFile:(NSString *)filePath;

- (void)setLineSrc:(id)src selector:(SEL)callback;
- (void)whenFinishedTarget:(id)target callback:(SEL)callback;

- (void)closeOutputFile;

@end
