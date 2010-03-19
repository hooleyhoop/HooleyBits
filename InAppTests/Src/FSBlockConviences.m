//
//  FSBlockConviences.m
//  InAppTests
//
//  Created by steve hooley on 15/03/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "FSBlockConviences.h"
#import "FScript/FScript.h"


@implementation FSBlockConviences

+ (FSBlock *)_assertEqualObjectsBlock {
	return _BLOCK(@"[:arg1 :arg2 | arg2 isEqualTo: arg1]");	
}

+ (FSBlock *)_assertFailBlock {
	return _BLOCK(@"[:arg1 | arg1 isEqual: (FSBoolean fsFalse)]");	
}

+ (FSBlock *)_assertTrueBlock {
	return _BLOCK(@"[:arg1 | arg1 isEqual: (FSBoolean fsTrue)]");	
}

+ (FSBlock *)_assertNilBlock {
	return _BLOCK(@"[:arg1 | arg1 == nil]");	
}

+ (FSBlock *)_assertNotNilBlock {
	return _BLOCK(@"[:arg1 | (arg1 == nil) not]");	
}

@end
