//
//  HooStateMachine_abstractEvent.m
//  SHShared2
//
//  Created by Steven Hooley on 21/05/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import "HooStateMachine_abstractEvent.h"


@implementation HooStateMachine_abstractEvent

- (id)initWithName:(NSString *)name {
    
    self = [super init];
    if (self) {
        _name = [name retain];
    }
    
    return self;
}

- (void)dealloc {
    [_name release];
    [super dealloc];
}

- (NSString *)name {
    return _name;
}
@end
