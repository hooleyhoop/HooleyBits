//
//  HooStateMachine.h
//  SHShared2
//
//  Created by Steven Hooley on 21/05/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HooStateMachine_state;

@interface HooStateMachine : NSObject {
@private
    
    HooStateMachine_state *_startState;
    NSMutableArray *_resetEvents;
}

- (id)initWithStartState:(HooStateMachine_state *)startState resetEvents:(NSArray *)resetEvents;

- (BOOL)isResetEvent:(NSString *)eventName;
- (HooStateMachine_state *)startState;

@end
