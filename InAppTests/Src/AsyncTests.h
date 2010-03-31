//
//  AsyncTests.h
//  InAppTests
//
//  Created by steve hooley on 09/02/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//
#import <SenTestingKit/SenTestCase.h>
@class FSBlock;
@interface AsyncTests : SenTestCase {

}
- (void)assert_arg1:(id)value1 ofBlock:(FSBlock *)fscript failMsg:(NSString *)errorMsg;
- (void)assert_arg1:(id)value1 arg2:(id)value2 ofBlock:(FSBlock *)fscript failMsg:(NSString *)errorMsg;

@end
