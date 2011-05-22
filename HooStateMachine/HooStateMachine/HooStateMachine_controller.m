//
//  HooStateMachine_controller.m
//  SHShared2
//
//  Created by Steven Hooley on 21/05/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import "HooStateMachine_controller.h"
#import "HooStateMachine_state.h"
#import "HooStateMachine.h"


@implementation HooStateMachine_controller

- (id)intWithCurrentState:(HooStateMachine_state *)startState machine:(HooStateMachine *)stateMachineInstance commandsChannel:(id)cmdCnl {
    
    self = [super init];
    if (self) {
        _currentState = [startState retain];
        _machine = [stateMachineInstance retain];
        
        //TODO: probably don't retain this 
        _commandsChannel = [cmdCnl retain];   
    }
    
    return self;
}

- (void)dealloc {

    [_currentState release];
    [_machine release];
    [_commandsChannel release];
    [super dealloc];
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

- (void)_transitionTo:(HooStateMachine_state *)targetState {
    
//    var self = this;
//    var thisParentList = _currentState.hierachyList();
//    var thatParentList = targetState.hierachyList();
//    
//    // eliminate shared parents from the front of the chain - the ones left in thisParentList are the ones we are exiting, the ones left in thatParentList are the ones we are entering
//    var shortestLength = thisParentList.length < thatParentList.length ? thisParentList.length : thatParentList.length;
//    var sharedparentsIndex = -1;
//    for( var i=0; i<shortestLength; i++ ) {
//        if(thisParentList[i]==thatParentList[i])
//            sharedparentsIndex = i;
//        else
//            break;
//    }
//    if(sharedparentsIndex > -1) {
//        thisParentList.splice(0,sharedparentsIndex+1);
//        thatParentList.splice(0,sharedparentsIndex+1);
//    }
//    
//    thisParentList.reverse();
//    $.each( thisParentList, function(index, element) {
//        element.executeExitActions( _commandsChannel );
//    });
//    
//    _currentState = targetState;
//    
//    $.each( thatParentList, function(index, element) {
//        element.executeEntryActions( _commandsChannel );
//    });
}

- (HooStateMachine_state *)currentState {
    return _currentState;
}
@end
