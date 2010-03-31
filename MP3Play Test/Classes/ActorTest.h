//
//  ActorTest.h
//  iphonePlay
//
//  Created by Steven Hooley on 2/3/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import "SHooleyObject.h"


@interface ActorTest : SHooleyObject {

}

- (oneway void) asynchronousEcho: (NSString *) text listener: (id) echoListener;
- (NSString *) synchronousEcho: (NSString *) text;
	
@end
