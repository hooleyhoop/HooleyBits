//
//  LinesInStringIterator.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 09/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "iConsumeLines.h"

@interface LinesInStringIterator : NSObject {

	NSObject <iConsumeLines>	*_consumer;
	NSString					*_fileString;
}

@property (retain) NSObject <iConsumeLines>	*consumer;

+ (void)feedLines:(NSString *)fileString to:(NSObject<iConsumeLines> *)consumer;

+ (id)iteratorWithString:(NSString *)val;

- (id)initWithString:(NSString *)val;

- (void)doIt;

@end
