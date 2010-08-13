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

- (NSString *)increment:(NSString *)fileName {

	NSString *path = [fileName stringByDeletingLastPathComponent];
	NSString *name = [fileName lastPathComponent];
	NSString *extension = [name pathExtension];
	NSString *dotExtension = [NSString stringWithFormat:@".%@", extension];

	if([name hasSuffix:dotExtension]) {
		name = [name stringByDeletingPathExtension];
	} else {
		extension = @"";
	}
	
	NSUInteger number = 0;
	NSRange numberRange = [name rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet] options:NSBackwardsSearch];
	if( numberRange.location!=NSNotFound ) {
		NSString *nameWithOutNumber = [name substringToIndex:numberRange.location];
		NSString *numberAsString = [name substringFromIndex:numberRange.location];
		name = nameWithOutNumber;
		number = [numberAsString intValue];
	}

	while( [[NSFileManager defaultManager] fileExistsAtPath:fileName] )
	{
		number++;
		NSString *newName = [NSString stringWithFormat:@"%@%i.%@", name, number, extension];
		fileName = [path stringByAppendingPathComponent:newName];
	}
	return fileName;
}

- (void)asyncCreateOutputFile:(NSString *)filePath {
	
	NSAssert( _oStream==nil, @"already outputting");

	filePath = [self increment:filePath];
	NSAssert( [[NSFileManager defaultManager] fileExistsAtPath:filePath]==NO, @"SHIT");

    _oStream = [[NSOutputStream alloc] initToFileAtPath:filePath append:YES];
    [_oStream setDelegate:self];
    [_oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_oStream open];
}

- (void)end {
	[self closeOutputFile];
	[_completeTarget performSelector:_completeCallBack];
}

- (void)closeOutputFile {
	
	[_oStream close];
	[_oStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_oStream release];
	_oStream = nil;
}

- (void)_readLine {

	NSString *nextLine;
//	if(nextLine==nil)
//		[self end];

	while( nextLine=[_src performSelector:_callback] ) {
				
		NSLog(@"%@", nextLine);
		nextLine = [nextLine stringByAppendingFormat:@"\n"];
		NSUInteger lineLen = [nextLine length];
		NSAssert( lineLen!=0, @"Output Error?" );
		const char *lineBuffer = [nextLine UTF8String];
		NSInteger result = [_oStream write:lineBuffer maxLength:lineLen];
		NSAssert( result==lineLen, @"Output Error?");
	}
	[self end];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
	
    switch(eventCode) {
        case NSStreamEventHasSpaceAvailable:
	//		[self _readLine];
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

- (void)whenFinishedTarget:(id)target callback:(SEL)callback {

	_completeTarget = target;
	_completeCallBack = callback;
}

@end
