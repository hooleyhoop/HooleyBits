//
//  AbstractConfiguration.h
//  HooStateMachine
//
//  Created by Steven Hooley on 22/05/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HooStateMachine_controller, HooStateMachine_command, HooStateMachineConfigurator;

@interface AbstractConfiguration : _ROOT_OBJECT_ {
@private
    HooStateMachine_controller *_stateMachineController;
    id _controller;
    
    HooStateMachineConfigurator *_savedConfig;    
}

@property (retain) HooStateMachine_controller *stateMachineController;

+ (id)smConfiguration:(NSString *)config delegate:(id)cntrl;
+ (id)smConfiguration:(NSString *)configName inBundle:(NSBundle *)bndl delegate:(id)cntrl;
    
- (id)initWithConfig:(HooStateMachineConfigurator *)config controller:(id)cntrllr;

- (void)processInputSignal:(NSString *)signal;
- (void)send:(HooStateMachine_command *)command;

- (NSString *)currentStateName;

- (void)_setCurrentStateName:(NSString *)evName;

@end
