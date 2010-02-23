//
//  SHGlobalVarManagerTests.m
//  BBExtras
//
//  Created by Steven Hooley on 04/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHGlobalVarManagerTests.h"

#import "SHGlobalVarManager.h"
#import "SHNumberPort.h"


@implementation SHGlobalVarManagerTests

+ (void) initialize
{
//    NSBundle * myBundle = [NSBundle bundleForClass: [self class]];
//    NSString * bundlePath = [myBundle pathForResource: @"BBExtras" ofType: @"plugin"];
//    NSBundle * bundleToLoad = [NSBundle bundleWithPath: bundlePath];
//    NSAssert(bundleToLoad != nil, @"bundleToLoad should not be nil");
//    [bundleToLoad load];
}

// ===========================================================
// - setUp
// ===========================================================
- (void) setUp {}

// ===========================================================
// - tearDown
// ===========================================================
- (void) tearDown {}


// ===========================================================
// - testDefaultManager
// ===========================================================
- (void) testDefaultManager {
	
	SHGlobalVarManager* defaultManager1 = [SHGlobalVarManager defaultManager];
	STAssertNotNil(defaultManager1, @"SHGlobalVarManagerTests - no default manager");
	SHGlobalVarManager* defaultManager2 = [SHGlobalVarManager defaultManager];
	STAssertNotNil(defaultManager2, @"SHGlobalVarManagerTests - no default manager");
	STAssertTrue(defaultManager1 == defaultManager2, @"SHGlobalVarManagerTests - these should be equal" );
	[SHGlobalVarManager disposeCachedInstance];
}


// ===========================================================
// - testAddPort
// ===========================================================
- (void) testAddPort 
{
	SHGlobalVarManager* varManager = [[SHGlobalVarManager alloc] init];
	SHNumberPort* np = [[SHNumberPort alloc] init];
	STAssertNotNil(np, @"SHGlobalVarManagerTests - couldn't make a port");
	STAssertTrue([varManager numberOfPortsWithKey:@"default"]==0, @"SHGlobalVarManagerTests - number is %i", [varManager numberOfPortsWithKey:@"default"] );
	[varManager addPort:np withKey:@"default"];
	STAssertTrue([varManager numberOfPortsWithKey:@"default"]==1, @"SHGlobalVarManagerTests - should be 1" );
	SHNumberPort* np2 = [[SHNumberPort alloc] init];
	[varManager addPort:np2 withKey:@"default"];
	STAssertTrue([varManager numberOfPortsWithKey:@"default"]==2, @"SHGlobalVarManagerTests - should be 2" );
	SHNumberPort* np3 = [[SHNumberPort alloc] init];
	[varManager addPort:np3 withKey:@"wazzoo"];
	STAssertTrue([varManager numberOfPortsWithKey:@"wazzoo"]==1, @"SHGlobalVarManagerTests - number is %i", [varManager numberOfPortsWithKey:@"wazzoo"] );
	STAssertTrue([varManager numberOfPortsWithKey:@"default"]==2, @"SHGlobalVarManagerTests - should be 2" );
	
	STAssertTrue((int)[varManager valueForKey:@"wazzoo"]==0, @"SHGlobalVarManagerTests - default value is %i", (int)[varManager valueForKey:@"wazzoo"]);

	[varManager release];
}

// ===========================================================
// - testRemovePort
// ===========================================================
- (void) testRemovePort 
{
	SHGlobalVarManager* varManager = [[SHGlobalVarManager alloc] init];
	SHNumberPort* np = [[SHNumberPort alloc] init];
	SHNumberPort* np2 = [[SHNumberPort alloc] init];
	[varManager addPort:np withKey:@"default"];
	[varManager addPort:np2 withKey:@"default"];
	[varManager removePort:np];
	STAssertTrue([varManager numberOfPortsWithKey:@"default"]==1, @"SHGlobalVarManagerTests - should be 1" );
	[varManager removePort:np2];
	STAssertTrue([varManager numberOfPortsWithKey:@"default"]==0, @"SHGlobalVarManagerTests - should be 0" );
	[varManager release];
}


// ===========================================================
// - testChangeKeyTo
// ===========================================================
- (void) testChangeKeyTo 
{
	SHGlobalVarManager* varManager = [[SHGlobalVarManager alloc] init];
	SHNumberPort* np = [[SHNumberPort alloc] init];
	SHNumberPort* np2 = [[SHNumberPort alloc] init];
	[varManager addPort:np withKey:@"default"];
	[varManager addPort:np2 withKey:@"default"];
	[varManager setValue:888 forKey:@"default"];
	STAssertTrue((int)[varManager valueForKey:@"default"]==888, @"SHGlobalVarManagerTests - ports with key are %i" );
	[varManager changeKeyTo:@"chicken" forPort:np];
	STAssertTrue((int)[varManager valueForKey:@"chicken"]==888, @"SHGlobalVarManagerTests - ports with key are %i" );
	
	STAssertTrue([varManager numberOfPortsWithKey:@"default"]==1, @"SHGlobalVarManagerTests - ports with key are %i",[varManager numberOfPortsWithKey:@"default"] );
	STAssertTrue([varManager numberOfPortsWithKey:@"chicken"]==1, @"SHGlobalVarManagerTests - ports with key are %i",[varManager numberOfPortsWithKey:@"chicken"] );

	[varManager setValue:777 forKey:@"chicken"];
	SHNumberPort* np3 = [[SHNumberPort alloc] init];
	[varManager addPort:np3 withKey:@"chicken"];
	STAssertTrue((int)[np3 doubleValue]==777, @"SHGlobalVarManagerTests - doubleValue is %i", (int)[np3 doubleValue] );

	[varManager release];
}


// ===========================================================
// - testValueForKey
// ===========================================================
- (void) testValueForKey
{
	SHGlobalVarManager* varManager = [[SHGlobalVarManager alloc] init];
	SHNumberPort* np = [[SHNumberPort alloc] init];
	[varManager addPort:np withKey:@"default"];
	[varManager setValue:888 forKey:@"default"];
	STAssertTrue((int)[varManager valueForKey:@"default"]==888, @"SHGlobalVarManagerTests - ports with key are %i" );
	[varManager removePort:np];
	STAssertTrue((int)[varManager valueForKey:@"default"]==-9999999, @"SHGlobalVarManagerTests - number of values %i",(int)[varManager valueForKey:@"default"] );

	[varManager release];
}


// ===========================================================
// - testNumberOfPortsWithKey
// ===========================================================
- (void) testNumberOfPortsWithKey
{
	SHGlobalVarManager* varManager = [SHGlobalVarManager defaultManager];

	SHNumberPort* np = [[SHNumberPort alloc] initWithNode:nil arguments:nil];
	STAssertNotNil(np, @"SHNumberPortTests - couldn't make a port");
	
	// there should be 1 port in the manager with key 'default'
	STAssertTrue([varManager numberOfPortsWithKey:@"default"]==1, @"SHGlobalVarManagerTests - there are %i ports in the manager", [varManager numberOfPortsWithKey:@"default"] );

	SHNumberPort* np2 = [[SHNumberPort alloc] initWithNode:nil arguments:nil];
	STAssertTrue([varManager numberOfPortsWithKey:@"default"]==2, @"SHGlobalVarManagerTests - there should be 2 ports in the manager %@", np2 );
	[np portWillDeleteFromNode];
	STAssertTrue([varManager numberOfPortsWithKey:@"default"]==1, @"SHGlobalVarManagerTests - there should be a port in the manager" );
	[np2 portWillDeleteFromNode];
	STAssertTrue([varManager numberOfPortsWithKey:@"default"]==0, @"SHGlobalVarManagerTests - there shouldnt be a port in the manager" );
	
	[SHGlobalVarManager disposeCachedInstance];
}


@end
