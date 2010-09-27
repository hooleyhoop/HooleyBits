//
//  ExperimentalFrankenStructsTetsts.m
//  MachoLoader
//
//  Created by Steven Hooley on 23/09/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "ExperimentalFrankenStructs.h"
#import <objc/objc-runtime.h>

#pragma mark -
struct SmallClass_struct {
	char _var1[8];
	char _var2[12];
};
@interface SmallClass : NSObject {
	char _var2[12];
}
@end
@implementation SmallClass
@end
#pragma mark -

@interface ExperimentalFrankenStructsTetsts : SenTestCase {
	
}

@end


@implementation ExperimentalFrankenStructsTetsts


- (void)testStaticInitialize {

	size_t runtimeInstanceSize = class_getInstanceSize([SmallClass class]);

	struct SmallClass_struct wooooo = {"s", "Hello World"};
	object_setClass(&wooooo,[SmallClass class]);

	SmallClass *sc = &wooooo;

}

@end
