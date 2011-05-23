//
//  HooStateMachine.m
//  SHShared2
//
//  Created by Steven Hooley on 21/05/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import "HooStateMachine.h"
#import "HooStateMachine_state.h"
#import "HooStateMachine_event.h"

@implementation HooStateMachine

- (id)initWithStartState:(HooStateMachine_state *)startState resetEvents:(NSArray *)resetEvents {
    
    self = [super init];
    if (self) {
        _startState = startState;
        _resetEvents = resetEvents ? [resetEvents retain] : [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_resetEvents release];
    [super dealloc];
}

//- (void)getStates: () {
//    var result = new Array();
//    this.collectStates( result, startState );
//    return result;
//}

// private
//- (void)collectStates: ( result, s ) {
//    if( $.inArray(s, result) )
//        return;
//    result.push(s);
//    var allTargets = s.getAllTargets();
//    $.each( allTargets, function(index, value) {
//        collectStates(result, value);
//    });
//}

- (void)addResetEvents:(NSArray *)events {
    [_resetEvents addObjectsFromArray:events];
}

- (NSArray *)resetEventNames {
    
    NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
    for( HooStateMachine_event *ev in _resetEvents ) {
        [result addObject:[ev name]];
    }
    return result;
}

- (BOOL)isResetEvent:(NSString *)eventName {

    NSArray *resetEventNames = [self resetEventNames];
    return [resetEventNames containsObject:eventName];
}

- (HooStateMachine_state *)startState {
    return _startState;
}

@end
