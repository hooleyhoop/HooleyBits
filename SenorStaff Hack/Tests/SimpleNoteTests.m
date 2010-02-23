//
//  SimpleNoteTests.m
//  SenorStaff Hack
//
//  Created by Steven Hooley on 6/20/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SimpleNote.h"

@interface SimpleNoteTests : SenTestCase {
	
}

@end

@implementation SimpleNoteTests

- (void)testNoteWithPitchVelocity {
	//- (SimpleNote *)noteWithPitch:(CGFloat)c1 velocity:(CGFloat)c2
	
	SimpleNote *aNote = [SimpleNote noteWithPitch:33.0 velocity:124.0];
	STAssertNotNil(aNote, @"oops");
	STAssertTrue(aNote.pitch==33, @"grr");
	STAssertTrue(aNote.velocity==124, @"grr");
}

- (void)testEncode_Decode {
	
	SimpleNote *aNote1 = [SimpleNote noteWithPitch:33.0 velocity:124.0];

	NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:aNote1];
	STAssertNotNil(archive, @"ooch");

	SimpleNote *aNote2 = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
	STAssertNotNil(aNote2, @"ooch");

	STAssertTrue(aNote2.pitch==33, @"grr");
	STAssertTrue(aNote2.velocity==124, @"grr");
}

@end
