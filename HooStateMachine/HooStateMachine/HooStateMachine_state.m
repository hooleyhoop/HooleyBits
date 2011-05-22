//
//  HooStateMachine_state.m
//  SHShared2
//
//  Created by Steven Hooley on 21/05/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import "HooStateMachine_state.h"
#import "HooStateMachine_event.h"
#import "HooStateMachine_transition.h"
#import "HooStateMachine_command.h"

@implementation HooStateMachine_state

- (id)initWithName:(NSString *)stateName parent:(HooStateMachine_state *)parentState {
    
    self = [super initWithName:stateName];
    if (self) {
        _parent = [parentState retain];
        _entryActions = [[NSMutableArray alloc] init];
        _exitActions = [[NSMutableArray alloc] init];
        _transitions = [[NSMutableDictionary alloc] init];  
    }
    return self;
}

- (void)dealloc {
    
    [_parent release];
    [_entryActions release];
    [_exitActions release];
    [_transitions release];
    [_parent release];
    [super dealloc];
}

- (void)addTransitionOn:(HooStateMachine_event *)event toState:(HooStateMachine_state *)targetState {
    
    NSParameterAssert(event && targetState);
    
    HooStateMachine_transition *t = [[[HooStateMachine_transition alloc] initWith:self trigger:event target:targetState] autorelease];
    
    NSString *key = [event name];
    NSAssert( [_transitions objectForKey:key]==nil, @"already exits!");
    [_transitions setObject:t forKey:key];
}

//- (void)removeAllTransitions: () {
//    this.transitions = new Object();
//}

- (void)addEntryAction:(HooStateMachine_command *)cmd {
    [_entryActions addObject:cmd];
}

- (void)addExitAction:(HooStateMachine_command *)cmd {
    [_exitActions addObject:cmd];
}

// NOT yet updated for HSM
//- (void)getAllTargets: () {
//    var result = new Array();
//    $.each( transitions, function(index, value) {
//        alert(index + ': ' + value);
//        result.push( value.target );
//    });
//    return result;
//}

//- (void)hasTransition: ( eventName ) {
//    var hasT = this.transitions.hasOwnProperty( eventName );
//    if( hasT==false && this._parent!=null )
//        hasT = this._parent.hasTransition(eventName);
//    return hasT;
//}

//- (void)transitionForEvent: ( eventName ) {
//    var transition = this.transitions[eventName];
//    if( transition==null && this._parent!=null )
//        transition = this._parent.transitionForEvent(eventName);
//    return transition;
//}

//- (void)targetState: ( eventName ) {
//    var transition = this.transitionForEvent(eventName);
//    var tState = transition.target;
//    return tState;
//}

//- (void)executeEntryActions: ( commandsChannel ) {
//    
//    $.each( this.entryActions, function(index, value) {
//        commandsChannel.send( value );
//    });
//}

//- (void)executeExitActions: ( commandsChannel ) {
//    
//    $.each( this.exitActions, function(index, value) {
//        commandsChannel.send( value );
//    });
//}

//- (void)hierachyList: () {
//    var hierachy = new Array();
//    var head = this;
//    while( head != null ){
//        hierachy.unshift(head); // because insertAtBeginning would be too helpful
//        head = head._parent;
//    }
//    return hierachy;
//}

@end
