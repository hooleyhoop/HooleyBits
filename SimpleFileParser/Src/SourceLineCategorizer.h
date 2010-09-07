//
//  SourceLineCategorizer.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 30/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "iConsumeLines.h"

@protocol iParseSrc;

enum groker_state {
    NO_FUNCTION,
	TEXT,
    NAMED_FUNCTION,
    ANON_FUNCTION
};

enum srcLineType {
    BLOCK_TITLE,
	BLOCK_LINE
};

@interface SourceLineCategorizer : NSObject <iConsumeLines> {

	enum groker_state			_state;
	BOOL						_stateChanged;
	NSObject <iParseSrc>		*_target;
	NSObject <iParseSrc>		*_delegate;
	NSString					*_lastString;
	NSCharacterSet				*_wsp;
}

+ (id)grokerWithDelegate:(NSObject <iParseSrc> *)obj;

- (id)initWithDelegate:(NSObject <iParseSrc> *)obj;

- (void)eatLine:(NSString *)aLine;
- (enum groker_state)state;
- (BOOL)stateChanged;
- (NSObject <iParseSrc> *)target;

@end
