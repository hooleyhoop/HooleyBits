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

<<<<<<< HEAD
struct privateTestStructKamel1 {
	char * p1;
};

struct privateTestStructKamel2 {
	char * p1;
	char * p2;
};

const struct privateTestStructKamel1 K1 = {"carrot"};
const struct privateTestStructKamel1 K2 = {"scredriver"};
const struct privateTestStructKamel2 K3 = {"shipshape", "donkeycock"};

these would need initializeing at runtime
 struct privateTestStructKamel1 testArray[4] = {
	
	&K1, &K2, &K3, K1
};


- (void)testStaticInitialize {

	STAssertTrue( !strcmp(testArray[0].p1,"carrot"), nil);
	struct privateTestStructKamel1 complicated = testArray[1];
	STAssertTrue( !strcmp(complicated.p1,"shipshape"), nil);
	struct privateTestStructKamel2 whatThe;
//	whatThe = complicated;
	//STAssertTrue( !strcmp(((struct privateTestStructKamel2)(testArray[1])).p2,"donkeycock"), nil);	
	STAssertTrue( !strcmp(testArray[2].p1,"scredriver"), nil);
	STAssertTrue( !strcmp(testArray[3].p1,"hampster"), nil);
=======

- (void)testStaticInitialize {

	size_t runtimeInstanceSize = class_getInstanceSize([SmallClass class]);

	struct SmallClass_struct wooooo = {"s", "Hello World"};
	object_setClass(&wooooo,[SmallClass class]);

	SmallClass *sc = &wooooo;
>>>>>>> a933a25b48ee773c66eda02bf28e08cf6cde3dc9

}

@end
