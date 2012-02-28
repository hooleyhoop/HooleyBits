//
//  HooStateMachine_controller.m
//  SHShared2
//
//  Created by Steven Hooley on 21/05/2011.
//  Copyright 2011 AudioBoo. All rights reserved.
//

#import "HooStateMachine_controller.h"
#import "HooStateMachine_state.h"
#import "HooStateMachine.h"


@implementation HooStateMachine_controller

@synthesize currentState=_currentState;

- (id)initWithCurrentState:(HooStateMachine_state *)startState machine:(HooStateMachine *)stateMachineInstance commandsChannel:(id)cmdCnl {
    
    self = [super init];
    if (self) {
        _currentState = [startState retain];
        _machine = [stateMachineInstance retain];
        
        //TODO: probably don't retain this 
        _commandsChannel = cmdCnl;   
    }
    
    return self;
}

- (void)dealloc {

    [_currentState release];
    [_machine release];
    [super dealloc];
}

- (void)_transitionTo:(HooStateMachine_state *)targetState {
    
    NSArray *thisParentList = [_currentState hierachyList];
    NSArray *thatParentList = [targetState hierachyList];
    
    // eliminate shared parents from the front of the chain - the ones left in thisParentList are the ones we are exiting, the ones left in thatParentList are the ones we are entering
    NSUInteger shortestLength = [thisParentList count] < [thatParentList count] ? [thisParentList count] : [thatParentList count];
    NSUInteger sharedparentsIndex = -1;
    for( NSUInteger i=0; i<shortestLength; i++ ) {
        if( [thisParentList objectAtIndex:i]==[thatParentList objectAtIndex:i] )
            sharedparentsIndex = i;
        else
            break;
    }
    if( sharedparentsIndex > (NSUInteger)-1 ) {
        thisParentList = [thisParentList subarrayWithRange:NSMakeRange(0, sharedparentsIndex+1)];
        thatParentList = [thatParentList subarrayWithRange:NSMakeRange(0,sharedparentsIndex+1)];
    }
    
    for( id element in [thisParentList reverseObjectEnumerator]) {
        [element executeExitActions:_commandsChannel];        
    }
    
    self.currentState = targetState;
    
    for( id element in [thatParentList reverseObjectEnumerator]) {
        [element executeEntryActions:_commandsChannel];        
    }
}

- (void)handle:(NSString *)eventName {
    
    HooStateMachine_state *nextState = nil;
    
    if( [_currentState hasTransition:eventName] ){
        nextState = [_currentState targetState:eventName];
        
    } else if( [_machine isResetEvent:eventName] ) {
//        console.log("Found reset event");
        nextState = [_machine startState];
        
		// ignore unknown events
    } else {
        // console.log("unknown event "+eventName );
    }
    
    if(nextState) {
        [self _transitionTo:nextState];
    }
}

@end
