//
//  HooStateMachineConfigurator.m
//  SHShared2
//
//  Created by Steven Hooley on 21/05/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import "HooStateMachineConfigurator.h"
#import "HooStateMachine_state.h"
#import "HooStateMachine_event.h"
#import "HooStateMachine_command.h"

@interface HooStateMachineConfigurator ()
- (void)parseStates;
- (void)parseEvents;
- (void)parseCommands;
- (void)parseTransitions;
- (void)parseActions;
- (void)parseResetEvents;
@end

@implementation HooStateMachineConfigurator

- (id)initWithConfig:(NSDictionary *)cnfg {
    
    self = [super init];
    if (self) {
        _config = [cnfg retain];
        _states = [[NSMutableDictionary alloc] init];
        _events = [[NSMutableDictionary alloc] init];
        _commands = [[NSMutableDictionary alloc] init];
        _resetEvents = [[NSMutableArray alloc] init];
        
        [self parseStates];
        [self parseEvents];
        [self parseCommands];
        [self parseTransitions];
        [self parseActions];
        [self parseResetEvents];
    }
    
    return self;
}

- (void)dealloc {
    
    [_config release];
    [_states release];
    [_events release];
    [_commands release];
    [_resetEvents release];
    [super dealloc];
}

- (void)parseStates {
    
    NSArray *states = [_config valueForKey:@"states"];
    for( id state in states ) {
        NSString *stateName = state;
        HooStateMachine_state *parentState = nil;
        if( [state isKindOfClass:[NSArray class]] ) {
            stateName = [state objectAtIndex:0];
            NSString *parentStateName = [state objectAtIndex:1];
            parentState = [_states objectForKey:parentStateName];
            NSAssert(parentState,@"parentState should exist");
        }
        HooStateMachine_state *newState = [[[HooStateMachine_state alloc] initWithName:stateName parent:parentState] autorelease];
        [_states setObject:newState forKey:stateName];
    }
}

- (void)parseEvents {

    NSArray *events = [_config valueForKey:@"events"];
    for( NSString *event in events ) {
        HooStateMachine_event *newEvent = [[[HooStateMachine_event alloc] initWithName:event] autorelease];
        [_events setObject:newEvent forKey:event];
    }
}

- (void)parseResetEvents {
    
    NSArray *resetEvents = [_config valueForKey:@"resetEvents"];
    for( NSString *resetEvent in resetEvents ) {
        HooStateMachine_event *ev = [_events objectForKey:resetEvent];
        NSAssert( ev, @"Error! is reset event a real event?" );
        [_resetEvents addObject:ev];
    }
}

- (void)parseCommands {

    NSArray *commands = [_config valueForKey:@"commands"];
    for( NSString *command in commands ) {
        HooStateMachine_command *newCommand = [[[HooStateMachine_command alloc] initWithName:command] autorelease];
        [_commands setObject:newCommand forKey:command];
    }
}

- (void)parseTransitions {

    NSArray *transitions = [_config valueForKey:@"transitions"];
    for( NSDictionary *transition in transitions ) {
        NSString *stateName = [transition objectForKey:@"state"];
        NSString *eventName = [transition objectForKey:@"event"];
        NSString *nextStateName = [transition objectForKey:@"nextState"];
        HooStateMachine_state *state = [_states objectForKey:stateName];
        HooStateMachine_state *nestState = [_states objectForKey:nextStateName];
        HooStateMachine_event *ev = [_events objectForKey:eventName];
        [state addTransitionOn:ev toState:nestState];
    }
}

- (void)parseActions {
    
    NSArray *actions = [_config valueForKey:@"actions"];
    for( NSDictionary *action in actions ) {
        NSString *stateName = [action objectForKey:@"state"];
        NSString *entryAction = [action objectForKey:@"entryAction"];
        NSString *exitAction = [action objectForKey:@"exitAction"];
        HooStateMachine_state *state = [_states objectForKey:stateName];
        if(entryAction!=nil) {
            HooStateMachine_command *entryCmd = [_commands objectForKey:entryAction];
            // alert("state > "+state+" entry cmd "+entryCmd);
            [state addEntryAction:entryCmd];
        }
        if(exitAction!=nil) {
            HooStateMachine_command *exitCmd = [_commands objectForKey:exitAction];            
            // alert("state > "+state+" exit cmd "+entryCmd);
            [state addExitAction:exitCmd];
        }
    }
}

- (HooStateMachine_state *)state:(NSString *)key {
    return [_states objectForKey:key];
}

- (NSMutableArray *)resetEvents {
    return _resetEvents;
}

@end
