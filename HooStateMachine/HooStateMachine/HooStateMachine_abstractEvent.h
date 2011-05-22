//
//  HooStateMachine_abstractEvent.h
//  SHShared2
//
//  Created by Steven Hooley on 21/05/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HooStateMachine_abstractEvent : NSObject {
@private
    NSString *_name;
}

- (id)initWithName:(NSString *)name;
- (NSString *)name;

@end
