//
//  ExperimentalFrankenStructsTetsts.m
//  MachoLoader
//
//  Created by Steven Hooley on 23/09/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "ExperimentalFrankenStructs.h"
#import <objc/objc-runtime.h>

@interface ExperimentalFrankenStructsTetsts : SenTestCase {
	
}

@end


@implementation ExperimentalFrankenStructsTetsts

struct privateTestStructKamel {
	NSUInteger field1;
};

Class Chicken = { NULL };

- (void)testStaticInitialize {

//	Class chicken =  NSObject;
//	struct objc_class *chicken;
	//struct privateTestStructKamel testVar1 = { @class(NSObject) };
}

@end
