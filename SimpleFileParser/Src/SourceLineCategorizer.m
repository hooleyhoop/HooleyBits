//
//  SourceLineCategorizer.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 30/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "SourceLineCategorizer.h"
#import "iParseSrc.h"

@interface SourceLineCategorizer ()

- (void)setState:(enum groker_state)state;

- (void)addLineToTarget:(NSString *)aLine;
- (void)categorizeLine:(NSString *)aLine;

@end
	
@implementation SourceLineCategorizer

+ (id)grokerWithDelegate:(NSObject <iParseSrc> *)obj {
	return [[[self alloc] initWithDelegate:obj] autorelease];
}

- (id)initWithDelegate:(NSObject <iParseSrc> *)obj {

	self = [super init];
	if(self){
		_state = NO_FUNCTION;
		_delegate = obj;
	}
	return self;
}

- (void)dealloc {
	
	[_lastString release];

	[super dealloc];
}

- (void)eatLine:(NSString *)aLine {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSCharacterSet *wsp = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSString *strippedline = [aLine stringByTrimmingCharactersInSet:wsp];
	
	[self categorizeLine: strippedline];
	[self addLineToTarget: strippedline];
	
	[pool release];
}

- (void)noMoreLines {
	[_target noMoreLinesComing];
}

- (void)addLineToTarget:(NSString *)aLine {

	static NSUInteger _blockCount=0;
	
	if(_stateChanged) {
		if( _state==ANON_FUNCTION || _state==NAMED_FUNCTION ) {
			_target = _delegate;
			[_target processSrcLine:_lastString type:BLOCK_TITLE];
			_blockCount++;
		} else if ( _state==NO_FUNCTION || _state==TEXT  ) {
			_target = nil;
		}
	}
	
	[_target processSrcLine:aLine type:BLOCK_LINE];	
}

- (void)categorizeLine:(NSString *)aLine {

	if ([aLine length]==0) {
		[_lastString retain];
		_lastString = nil;
		[self setState:NO_FUNCTION];
	} else {
		
		// is it a code line?
		char char1 = [aLine characterAtIndex:0];
		char char2 = [aLine characterAtIndex:1];
		if( char1=='+' && char2>47 && char2<58 ) {
			if( _state==NO_FUNCTION ) {
				[self setState:ANON_FUNCTION];
			} else if( _state==TEXT ) {
				[self setState:NAMED_FUNCTION];
			} else {
				_stateChanged = NO;
			}

		} else {
			[self setState:TEXT];
			_lastString = [aLine retain];
		}
	}
}

- (enum groker_state)state {
	return _state;
}

- (void)setState:(enum groker_state)state {
	
	if(state!=_state){
		_state = state;
		_stateChanged = YES;
	} else {
		_stateChanged = NO;
	}
}

- (BOOL)stateChanged {
	return _stateChanged;
}

- (NSObject <iParseSrc> *)target {
	return _target;
}

@end
