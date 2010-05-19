//
//  LWKeyTests.m
//  SHGeometryKit
//
//  Created by Steven Hooley on 05/12/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "GTMSenTestCase.h"
#import "LWKey.h"

@interface LWKeyTests : SenTestCase {
	
}

@end

/*
 *
*/
@implementation LWKeyTests

- (void)setUp {
	// STAssertNotNil(_nodeGraphModel, @"SHNodeTest ERROR.. Couldnt make a nodeModel");
}

- (void)tearDown {

}

- (void)testKeyWithPt {
	// + (LWKey*) keyWithPt:(G3DTuple2d*)pt;

	LWKey* aKey = [LWKey keyWithPt:CGPointMake(10.0, 100.0) envelope:nil];
	STAssertNotNil(aKey, @"should be a valid object");
	STAssertEquals([aKey x], (float)10.0, @"should be equal");
	STAssertEquals([aKey time], (float)10.0, @"should be equal");
	STAssertEquals([aKey y], (float)100.0, @"should be equal");
	STAssertEquals([aKey value], (float)100.0, @"should be equal");
}

- (void)testInit {
	// - (id) init;

	LWKey* aKey = [[[LWKey alloc] init] autorelease];
	STAssertNotNil(aKey, @"should be a valid object");
	STAssertEquals([aKey x], (float)0.0, @"should be equal");
	STAssertEquals([aKey time], (float)0.0, @"should be equal");
	STAssertEquals([aKey y], (float)0.0, @"should be equal");
	STAssertEquals([aKey value], (float)0.0, @"should be equal");
}

- (void)testInitWithPoint {
	//- (id)initWithPoint:(CGPoint)pt envelope:(LWEnvelope *)env
	
	LWKey* aKey = [[[LWKey alloc] initWithPoint:CGPointMake(10.0, 100.0) envelope:nil] autorelease];
	STAssertNotNil(aKey, @"should be a valid object");
	STAssertEquals([aKey x], (float)10.0, @"should be equal");
	STAssertEquals([aKey time], (float)10.0, @"should be equal");
	STAssertEquals([aKey y], (float)100.0, @"should be equal");
	STAssertEquals([aKey value], (float)100.0, @"should be equal");
}

- (void)testAddKey {
	// - (void) addKey:(LWKey*) next;

	LWKey* aKey1 = [LWKey keyWithPt:CGPointMake(10.0, 100.0) envelope:nil];
	LWKey* aKey2 = [LWKey keyWithPt:CGPointMake(100.0, 1000.0) envelope:nil];

	[aKey1 addKey:aKey2];
	STAssertEquals([aKey1 next], aKey2, @"should be equal");
	STAssertEquals([aKey2 prev], aKey1, @"should be equal");
}

- (void)testInsertKeyAfter {
	// - (void)insertKeyAfter:(LWKey *)next;

	LWKey* aKey1 = [LWKey keyWithPt:CGPointMake(10.0, 100.0) envelope:nil];
	LWKey* aKey2 = [LWKey keyWithPt:CGPointMake(100.0, 1000.0) envelope:nil];
	LWKey* aKey3 = [LWKey keyWithPt:CGPointMake(1000.0, 10000.0) envelope:nil];
	
	[aKey1 addKey:aKey3];
	[aKey1 insertKeyAfter:aKey2];
	
	STAssertEquals([aKey1 next], aKey2, @"should be equal");
	STAssertEquals([aKey2 next], aKey3, @"should be equal");
	STAssertNil([aKey3 next], @"%@ should be nil", [aKey3 next]);

	STAssertEquals([aKey3 prev], aKey2, @"should be equal");
	STAssertEquals([aKey2 prev], aKey1, @"should be equal");
	STAssertNil([aKey1 prev], @"%@ should be nil", [aKey1 prev]);
}

- (void)testInsertKeyBefore {
	// - (void) insertKeyBefore:(LWKey*) next;

	LWKey* aKey1 = [LWKey keyWithPt:CGPointMake(10.0, 100.0) envelope:nil];
	LWKey* aKey2 = [LWKey keyWithPt:CGPointMake(100.0, 1000.0) envelope:nil];
	LWKey* aKey3 = [LWKey keyWithPt:CGPointMake(1000.0, 10000.0) envelope:nil];
	
	[aKey1 addKey:aKey3];
	[aKey3 insertKeyBefore:aKey2];
	
	STAssertEquals([aKey1 next], aKey2, @"should be equal");
	STAssertEquals([aKey2 next], aKey3, @"should be equal");
	STAssertNil([aKey3 next], @"%@ should be nil", [aKey3 next]);

	STAssertEquals([aKey3 prev], aKey2, @"should be equal");
	STAssertEquals([aKey2 prev], aKey1, @"should be equal");
	STAssertNil([aKey1 prev], @"%@ should be nil", [aKey1 prev]);
}

- (void)testRemoveKey {
	// - (void) removeKey;

	LWKey* aKey1 = [LWKey keyWithPt:CGPointMake(10.0, 100.0) envelope:nil];
	LWKey* aKey2 = [LWKey keyWithPt:CGPointMake(100.0, 1000.0) envelope:nil];
	LWKey* aKey3 = [LWKey keyWithPt:CGPointMake(1000.0, 10000.0) envelope:nil];
	
	[aKey1 addKey:aKey2];
	[aKey2 addKey:aKey3];
	[aKey2 removeKey];
	
	STAssertNil([aKey2 prev], @"%@ should be nil", [aKey2 prev]);
	STAssertNil([aKey2 next], @"%@ should be nil", [aKey2 next]);
	STAssertEquals([aKey1 next], aKey3, @"should be equal");
	STAssertEquals([aKey3 prev], aKey1, @"should be equal");
}

- (void)testIsEqualToKey {
	// - (BOOL) isEqualToKey:(LWKey*)aKey;
	
	LWKey* aKey1 = [LWKey keyWithPt:CGPointMake(10.0, 100.0) envelope:nil];
	LWKey* aKey2 = [LWKey keyWithPt:CGPointMake(50.0, 50.0) envelope:nil];
	
	[aKey2 setX:10.0];
	[aKey2 setY:100.0];

	STAssertTrue([aKey1 isEqualToKey:aKey2], @"should be equal");
}


@end
