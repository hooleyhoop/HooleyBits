//
//  HooStateMachine_transition.m
//  SHShared2
//
//  Created by Steven Hooley on 21/05/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import "HooStateMachine_transition.h"
#import "HooStateMachine_state.h"
#import "HooStateMachine_event.h"


@implementation HooStateMachine_transition

- (id)initWith:(HooStateMachine_state *)srcState trigger:(HooStateMachine_event *)event target:(HooStateMachine_state *)trgtState {
    
    NSParameterAssert(srcState && event && trgtState);
    
    self = [super init];
    if (self) {
        _srcState = [srcState retain];
        _triggerEv = [event retain];
        _trgtState = [trgtState retain];
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (HooStateMachine_state *)target {
    return _trgtState;
}

- (void)cleanUp {

    [_srcState release];
    [_triggerEv release];
    [_trgtState release];
}

//- (void)getEventName: () {
 //   return this.trigger.name;
//}
@end
