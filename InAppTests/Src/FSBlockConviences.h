//
//  FSBlockConviences.h
//  InAppTests
//
//  Created by steve hooley on 15/03/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//
@class FSBlock;
@interface FSBlockConviences : NSObject {

}

+ (FSBlock *)_assertEqualObjectsBlock;
+ (FSBlock *)_assertFailBlock;
+ (FSBlock *)_assertTrueBlock;
+ (FSBlock *)_assertNilBlock;
+ (FSBlock *)_assertNotNilBlock;

@end
