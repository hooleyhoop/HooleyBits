//
//  DissasemblerGroker.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 30/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@protocol iMakeCodeBlocks;

enum groker_state {
    NO_FUNCTION,
	TEXT,
    NAMED_FUNCTION,
    ANON_FUNCTION
};

@interface DissasemblerGroker : NSObject {

	enum groker_state			_state;
	BOOL						_stateChanged;
	NSObject <iMakeCodeBlocks>	*_target;
	NSObject <iMakeCodeBlocks>	*_delegate;
	NSString					*_lastString;
}

+ (id)groker;

- (void)eatLine:(NSString *)aLine;
- (enum groker_state)state;
- (BOOL)stateChanged;
- (NSObject <iMakeCodeBlocks> *)target;
- (void)setDelegate:(NSObject <iMakeCodeBlocks>	*)obj;

@end
