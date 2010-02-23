//
//  AsyncTests.m
//  InAppTests
//
//  Created by steve hooley on 09/02/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "AsyncTests.h"
#import <FScript/Fscript.h>

@implementation AsyncTests

- (void)assertResultOfBlockIsTrue:(FSBlock *)fscript arg1:(id)value1 arg2:(id)value2 msg:(NSString *)errorMsg {
	
	FSBoolean *result = [fscript value:value1 value:value2];
	BOOL success = [result isEqual:[FSBoolean fsTrue]];
	STAssertTrue( success, errorMsg ); // could use a block for this error msg
}

@end