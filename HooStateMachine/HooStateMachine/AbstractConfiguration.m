//
//  AbstractConfiguration.m
//  HooStateMachine
//
//  Created by Steven Hooley on 22/05/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import "AbstractConfiguration.h"
#import "HooStateMachineConfigurator.h"
#import "HooStateMachine_state.h"
#import "HooStateMachine.h"
#import "HooStateMachine_controller.h"
#import "HooStateMachine_command.h"

@interface AbstractConfiguration ()
- (void)setupStateMachines:(HooStateMachineConfigurator *)config;
@end

@implementation AbstractConfiguration

@synthesize stateMachineController=_stateMachineController;

+ (id)smConfiguration:(NSString *)configName inBundle:(NSBundle *)bndl delegate:(id)cntrl {
    
	HooStateMachineConfigurator *simpleStateMachineParser = [HooStateMachineConfigurator configNamed:configName inBundle:bndl]; 
    return [[[self alloc] initWithConfig:simpleStateMachineParser controller:cntrl] autorelease];
}

- (id)initWithConfig:(HooStateMachineConfigurator *)config controller:(id)cntrllr {
    
    self = [super init];
    if (self) {
        _controller = cntrllr;
        [self setupStateMachines:config];
    }
    
    return self;
}

- (void)dealloc {
    [_stateMachineController release];
    [super dealloc];
}

- (void)setupStateMachines:(HooStateMachineConfigurator *)config {

    // assume first state is start state
    HooStateMachine_state *startState = [config firstState];

    HooStateMachine *stateMachineInstance = [[[HooStateMachine alloc] initWithStartState:startState 
                                                                             transitions:[config transitions]
                                                                             resetEvents:[config resetEvents]] autorelease];

    _stateMachineController = [[HooStateMachine_controller alloc] initWithCurrentState:startState machine:stateMachineInstance commandsChannel:self];
}

// input
- (void)processInputSignal:(NSString *)signal {
    [_stateMachineController handle: signal];
}

// output from sm
- (void)send:(HooStateMachine_command *)command {

    NSString *funcName = [command name];
    SEL selector = NSSelectorFromString(funcName);
    if( [_controller respondsToSelector:selector] ) {
        [_controller performSelector:selector];
    } else {
        // console.warn("Didnt find function "+command.name);
    }
}

- (NSString *)currentStateName {
    return [[_stateMachineController currentState] name];
}


@end
