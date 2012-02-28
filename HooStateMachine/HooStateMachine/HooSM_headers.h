//
//  AbstractConfiguration.h
//  HooStateMachine
//
//  Created by Steven Hooley on 22/05/2011.
//  Copyright 2011 AudioBoo. All rights reserved.
//

#if HOOSM_IS_LIBRARY

#import <HooStateMachine/HooStateMachine_abstractEvent.h>
#import <HooStateMachine/HooStateMachine_command.h>
#import <HooStateMachine/HooStateMachine_event.h>
#import <HooStateMachine/HooStateMachine_state.h>
#import <HooStateMachine/HooStateMachine_transition.h>
#import <HooStateMachine/HooStateMachine.h>
#import <HooStateMachine/HooStateMachine_controller.h>
#import <HooStateMachine/HooStateMachineConfigurator.h>
#import <HooStateMachine/AbstractConfiguration.h>

#else 

#import "HooStateMachine_abstractEvent.h"
#import "HooStateMachine_command.h"
#import "HooStateMachine_event.h"
#import "HooStateMachine_state.h"
#import "HooStateMachine_transition.h"
#import "HooStateMachine.h"
#import "HooStateMachine_controller.h"
#import "HooStateMachineConfigurator.h"
#import "AbstractConfiguration.h"

#endif