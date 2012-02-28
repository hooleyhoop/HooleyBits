//
//  HooStateMachine_state.h
//  SHShared2
//
//  Created by Steven Hooley on 21/05/2011.
//  Copyright 2011 AudioBoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HooStateMachine_abstractEvent.h"

@class HooStateMachine_event, HooStateMachine_state, HooStateMachine_command, HooStateMachine_transition;

@interface HooStateMachine_state : HooStateMachine_abstractEvent {
@private
    NSMutableArray *_entryActions;
    NSMutableArray *_exitActions;
    NSMutableDictionary *_transitions;
    HooStateMachine_state *_parent;
}

- (id)initWithName:(NSString *)stateName parent:(HooStateMachine_state *)parentState;

- (HooStateMachine_transition *)addTransitionOn:(HooStateMachine_event *)event toState:(HooStateMachine_state *)targetState;
- (void)addEntryAction:(HooStateMachine_command *)cmd;
- (void)addExitAction:(HooStateMachine_command *)cmd;

- (void)executeEntryActions:(id)commandsChannel;
- (void)executeExitActions:(id)commandsChannel;

- (BOOL)hasTransition:(NSString *)eventName;
- (HooStateMachine_state *)targetState:(NSString *)eventName;
- (HooStateMachine_transition *)transitionForEvent:(NSString *)eventName;
- (NSArray *)hierachyList;
- (HooStateMachine_state *)parent;

@end
