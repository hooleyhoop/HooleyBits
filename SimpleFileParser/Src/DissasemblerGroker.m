//
//  DissasemblerGroker.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 30/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "DissasemblerGroker.h"
#import "iMakeCodeBlocks.h"
#import "StringCounter.h"

@interface DissasemblerGroker ()

- (void)setState:(enum groker_state)state;

- (void)addLineToTarget:(NSString *)aLine;
- (void)categorizeLine:(NSString *)aLine;

- (void)_tokeniseLine:(NSString *)aLine;

@end
	
@implementation DissasemblerGroker

+ (id)groker {
	return [[[self alloc] init] autorelease];
}

- (id)init {

	self = [super init];
	if(self){
		_state = NO_FUNCTION;
		_unknownInstructions = [[NSMutableSet setWithCapacity:100] retain];		
	}
	return self;
}

- (void)dealloc {
	
	[_lastString release];
	[_unknownInstructions release];

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

- (void)addLineToTarget:(NSString *)aLine {

	if(_stateChanged) {
		if( _state==ANON_FUNCTION || _state==NAMED_FUNCTION ) {
			_target = _delegate;
			[_target newCodeBlockWithName:_lastString];

		} else if ( _state==NO_FUNCTION || _state==TEXT  ) {
			_target = nil;
		}
	}

	[self _tokeniseLine:aLine];
	[_target addCodeLine:aLine];	
}

// TODO: Replace knownInstructions with yaml stuff
- (BOOL)isKnownInstruction:(NSString *)instruction {
	
//Replace With yaml	NSArray *knownInstructions = [DissasemblerGroker knownInstructions];
//Replace with yaml	BOOL isFound = [knownInstructions containsObject:instruction];
	
	
	//	if(!isFound){
	//		NSLog(@"oopps %i", [knownInstructions indexOfObjectIdenticalTo:instruction]);
	//	}
	return YES;
}

// TODO: -- here
- (void)_tokeniseLine:(NSString *)aLine {
		
	NSString *instruction=nil, *arguments=nil, *functionHint=nil;
	
	NSArray *components = worderize( aLine );
	
	// not optional
	id lineOffset = [components objectAtIndex:0];
	id address = [components objectAtIndex:1];
	id code = [components objectAtIndex:2];
	instruction = [components objectAtIndex:3];
	
	// optional
	if([components count]>=5)
		arguments = [components objectAtIndex:4];
	if([components count]>=6)
		functionHint = [components objectAtIndex:5];
	
	if(instruction){
		BOOL isKnown = [self isKnownInstruction:instruction];
		if(!isKnown){
			[_unknownInstructions addObject:instruction];
			return;
		}
// eh ? What is this shit?		[self processInstruction:instruction argument:arguments];
	}
}

- (void)categorizeLine:(NSString *)aLine {

	if ([aLine length]==0) {
		[_lastString retain];
		_lastString = nil;
		[self setState:NO_FUNCTION];
	} else {
		
		if ([aLine characterAtIndex:0]=='+') {
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

- (NSObject <iMakeCodeBlocks> *)target {
	return _target;
}

- (void)setDelegate:(NSObject <iMakeCodeBlocks>	*)obj {
	_delegate = obj;
}

@end
