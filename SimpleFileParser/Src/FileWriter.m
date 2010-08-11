//
//  FileWriter.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 11/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "FileWriter.h"


@implementation FileWriter

- (id)init {

    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {

	[super dealloc];
}


- (void)asyncCreateOutputFile:(NSString *)filePath {
	
	NSAssert( _oStream==nil, @"already outputting");
	
    // oStream is an instance variable
    _oStream = [[NSOutputStream alloc] initToFileAtPath:filePath append:YES];
    [_oStream setDelegate:self];
    [_oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_oStream open];
}

- (void)end {
	[self closeOutputFile];
	[_src performSelector:_completeCallBack]
}

- (void)closeOutputFile {
	
	[_oStream close];
	[_oStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_oStream release];
	_oStream = nil;
}

- (void)_readLine {

	NSString *nextLine = [_src performSelector:_callback];
	if(nextLine==nil)
		[self end];

	NSUInteger lineLen = [nextLine length];
	NSAssert( lineLen!=0, @"Output Error?" );
	const uint8_t *lineBuffer = [nextLine UTF8String];
	NSInteger result = [_oStream write:lineBuffer maxLength:lineLen];
	NSAssert( result==lineLen, @"Output Error?");
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
	
    switch(eventCode) {
        case NSStreamEventHasSpaceAvailable:
			NSLog(@"NSStreamEventHasSpaceAvailable");
            break;
		case NSStreamEventNone:
			NSLog(@"NSStreamEventNone");
			break;
		case NSStreamEventOpenCompleted:
			NSLog(@"NSStreamEventOpenCompleted");
			[self _readLine];
			break;
		case NSStreamEventHasBytesAvailable:
			NSLog(@"NSStreamEventHasBytesAvailable");
			break;
		case NSStreamEventErrorOccurred:
			NSLog(@"NSStreamEventErrorOccurred");
			break;
		case NSStreamEventEndEncountered:
			NSLog(@"NSStreamEventEndEncountered");
			break;
		default :
			[NSException raise:@"Unknown Stream event" format:@"%i", eventCode];
	}
}


- (void)setLineSrc:(id)src selector:(SEL)callback {
	
	_src = src;
	_callback = callback;
}

- (void)whenFinished:(SEL)callback {
	_completeCallBack = callback;
}

@end
