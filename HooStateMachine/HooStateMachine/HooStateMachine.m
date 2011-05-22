//
//  HooStateMachine.m
//  SHShared2
//
//  Created by Steven Hooley on 21/05/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import "HooStateMachine.h"
#import "HooStateMachine_state.h"

@implementation HooStateMachine

- (id)initWithStartState:(HooStateMachine_state *)startState resetEvents:(NSArray *)resetEvents {
    
    self = [super init];
    if (self) {
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

//- (void)addResetEvents: ( events ) {
//    var self = this;
//    $.each( events, function(index, value) {
//        self.resetEvents.push(value);
//    });
//}

//- (void)isResetEvent: ( eventName ) {
//    var resetEventNames = this.resetEventNames();
//    var result = $.inArray( eventName, resetEventNames );
//    return result > -1;
//}

//- (void)resetEventNames: () {
//    var result = new Array();
//    $.each( this.resetEvents, function(index, value) {
//        result.push( value.name );
//    });
//    return result;
//}


@end
