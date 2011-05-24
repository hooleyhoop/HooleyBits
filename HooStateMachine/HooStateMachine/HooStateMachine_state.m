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
#import "AbstractConfiguration.h"

@implementation HooStateMachine_state

- (id)initWithName:(NSString *)stateName {
    return [self initWithName:stateName parent:nil];
}

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
    [super dealloc];
}

- (HooStateMachine_transition *)addTransitionOn:(HooStateMachine_event *)event toState:(HooStateMachine_state *)targetState {
    
    NSParameterAssert(event && targetState);
    
    HooStateMachine_transition *t = [[[HooStateMachine_transition alloc] initWith:self trigger:event target:targetState] autorelease];
    
    NSString *key = [event name];
    NSAssert( [_transitions objectForKey:key]==nil, @"already exits!");
    [_transitions setObject:t forKey:key];
    return t;
}

//- (void)removeAllTransitions: () {
//    _transitions = new Object();
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

- (BOOL)hasTransition:(NSString *)eventName {
    
    BOOL hasT = [_transitions objectForKey:eventName]!=nil;
    if( hasT==NO && _parent!=nil )
        hasT = [_parent hasTransition:eventName];
    return hasT;
}

- (HooStateMachine_transition *)transitionForEvent:(NSString *)eventName {
    
    HooStateMachine_transition *transition = [_transitions objectForKey:eventName];
    if( transition==nil && _parent!=nil )
        transition = [_parent transitionForEvent:eventName];
    return transition;
}

- (HooStateMachine_state *)targetState:(NSString *)eventName {

    HooStateMachine_transition *transition = [self transitionForEvent:eventName];
    HooStateMachine_state *tState = [transition target];
    return tState;
}

- (void)executeEntryActions:(id)commandsChannel {
    
    for( HooStateMachine_command *value in _entryActions ) {
        [commandsChannel send:value];
    }
}

- (void)executeExitActions:(id)commandsChannel {
    
    for( HooStateMachine_command *value in _exitActions ) {
        [commandsChannel send:value];
    }
}

- (NSArray *)hierachyList {
    
    NSMutableArray *hierachy = [[[NSMutableArray alloc] init] autorelease];
    HooStateMachine_state *head = self;
    while( head != nil ){
        [hierachy insertObject:head atIndex:0];
         head = [head parent];
    }
    return hierachy;
}

- (HooStateMachine_state *)parent {
    return _parent;
}

@end
