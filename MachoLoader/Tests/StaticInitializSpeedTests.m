//
//  StaticInitializSpeedTests.m
//  MachoLoader
//
//  Created by Steven Hooley on 25/09/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "GenericTimer.h"
#import <objc/objc-runtime.h>

#pragma mark -
struct LinkdClass_struct {
	char _var1[8];
	char _var2[12];
};
@interface LinkdClass : NSObject {
	char _var2[12];
}
@end
@implementation LinkdClass
@end
#pragma mark -

@interface StaticInitializSpeedTests : SenTestCase {
	
}

@end


@implementation StaticInitializSpeedTests

- (NSObject)blah {
	return nil;
}

- (void)testHighLevelWay {
	
	NSLog(@"begin");
	GenericTimer *readTimer = [[[GenericTimer alloc] init] autorelease];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *array = [NSMutableArray array];
	for(NSUInteger i=0;i<1000000;i++){
		LinkdClass *testOb = [[[LinkdClass alloc] init] autorelease];
		[array addObject:testOb];
	}
	[readTimer close];  // 4.6 secs
	[pool release];	
	NSLog(@"end");
	
	GenericTimer *readTimer2 = [[[GenericTimer alloc] init] autorelease];
	NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
	
	for(NSUInteger j=0;j<1000000;j++){

		LinkdClass *testOb = calloc(1, class_getInstanceSize([LinkdClass class]) );
		object_setClass(testOb,[LinkdClass class]);
	}
	[pool2 release];
	[readTimer2 close];  // 4.6 secs
	

}

@end
