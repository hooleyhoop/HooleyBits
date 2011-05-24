//
//  HooStateMachine_transition.h
//  SHShared2
//
//  Created by Steven Hooley on 21/05/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HooStateMachine_state, HooStateMachine_event;

@interface HooStateMachine_transition : _ROOT_OBJECT_ {
@private
    HooStateMachine_state *_srcState;
    HooStateMachine_event *_triggerEv;
    HooStateMachine_state *_trgtState;
}


- (id)initWith:(HooStateMachine_state *)srcState trigger:(HooStateMachine_event *)event target:(HooStateMachine_state *)trgtState;

- (HooStateMachine_state *)target;
- (void)cleanUp;

@end
