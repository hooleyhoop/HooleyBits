//
//  SHNumberPortTests.m
//  BBExtras
//
//  Created by Steven Hooley on 04/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHNumberPortTests.h"
#import "SHNumberPort.h"
#import "SHGlobalVarManager.h"

@implementation SHNumberPortTests



// ===========================================================
// - setUp
// ===========================================================
- (void) setUp
{
}

// ===========================================================
// - tearDown
// ===========================================================
- (void) tearDown
{
}


// ===========================================================
// - testInitWithNode
// ===========================================================
- (void) testInitWithNode 
{
	SHGlobalVarManager* varManager = [SHGlobalVarManager defaultManager];

	SHNumberPort* np = [[SHNumberPort alloc] initWithNode:nil arguments:nil];
	STAssertNotNil(np, @"SHNumberPortTests - couldn't make a port");
	
	// there should be 1 port in the manager with key 'default'
	STAssertTrue([varManager numberOfPortsWithKey:@"default"]==1, @"SHGlobalVarManagerTests - testInitWithNode, there should be a port in the manager" );

	SHNumberPort* np2 = [[SHNumberPort alloc] initWithNode:nil arguments:nil];
	STAssertTrue([varManager numberOfPortsWithKey:@"default"]==2, @"SHGlobalVarManagerTests - testInitWithNode, there should be 2 ports in the manager %@", np2 );

	[SHGlobalVarManager disposeCachedInstance];
}

// ===========================================================
// - testPortWillDeleteFromNode
// ===========================================================
- (void) testPortWillDeleteFromNode 
{
	SHGlobalVarManager* defaultManager = [SHGlobalVarManager defaultManager];

	SHNumberPort* np = [[SHNumberPort alloc] initWithNode:nil arguments:nil];
	SHNumberPort* np2 = [[SHNumberPort alloc] initWithNode:nil arguments:nil];

	[np portWillDeleteFromNode];
	STAssertTrue([defaultManager numberOfPortsWithKey:@"default"]==1, @"SHGlobalVarManagerTests - testInitWithNode, there should be a port in the manager" );
	[np2 portWillDeleteFromNode];
	STAssertTrue([defaultManager numberOfPortsWithKey:@"default"]==0, @"SHGlobalVarManagerTests - testInitWithNode, there shouldnt be a port in the manager" );

	[SHGlobalVarManager disposeCachedInstance];
}

// ===========================================================
// - testKey
// ===========================================================
- (void) testKey {

//todo - (NSString *)key;

}

// ===========================================================
// - testSetKey
// ===========================================================
- (void) testSetKey {

//todo - (void)setKey:(NSString *)aKey;
}

// ===========================================================
// - testSetDoubleValue
// ===========================================================
- (void) testSetDoubleValue {

// - (double)doubleValue;
//todo - (void)setDoubleValue:(double)fp8;
//todo - (void)updateDoubleValue:(double)fp8;
}
@end
