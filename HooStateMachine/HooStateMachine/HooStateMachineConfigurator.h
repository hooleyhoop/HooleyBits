//
//  HooStateMachineConfigurator.h
//  SHShared2
//
//  Created by Steven Hooley on 21/05/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HooStateMachine_state;

@interface HooStateMachineConfigurator : _ROOT_OBJECT_ {
@private
    NSDictionary *_config;
    NSMutableDictionary *_states;
    NSMutableDictionary *_events;
    NSMutableDictionary *_commands;
    NSMutableArray *_transitions;
    NSMutableArray *_resetEvents;
}

+ (id)configNamed:(NSString *)cnfgName inBundle:(NSBundle *)bund;
- (id)initWithConfig:(NSDictionary *)cnfg;
- (HooStateMachine_state *)state:(NSString *)key;
- (NSMutableArray *)resetEvents;
- (NSMutableArray *)transitions;

@end