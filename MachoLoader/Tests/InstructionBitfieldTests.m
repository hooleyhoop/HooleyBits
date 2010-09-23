//
//  InstructionBitfieldTests.m
//  MachoLoader
//
//  Created by Steven Hooley on 22/09/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//




@interface InstructionBitfieldTests : SenTestCase {
	
}

@end


@implementation InstructionBitfieldTests


// notused isCompare isBranch isJump
// ie
int typeBitField;


- (void)testBitFieldStuff {
	
#define ISCHICKEN 1
#define ISDOG 2
#define ISCAT 4
#define ISBREAD 8

	uint16 typeBitField1 = ISCHICKEN | ISDOG | ISCAT | ISBREAD;
	
	uint16 test1 = typeBitField1 & ISCHICKEN;
	uint16 test2 = typeBitField1 & ISDOG;
	uint16 test3 = typeBitField1 & ISCAT;
	uint16 test4 = typeBitField1 & ISBREAD;
	STAssertTrue(test1, nil);
	STAssertTrue(test2, nil);
	STAssertTrue(test3, nil);
	STAssertTrue(test4, nil);
	
	uint16 typeBitField2 = ISCHICKEN;
	test1 = typeBitField2 & ISCHICKEN;
	test2 = typeBitField2 & ISDOG;
	test3 = typeBitField2 & ISCAT;
	test4 = typeBitField2 & ISBREAD;
	STAssertTrue(test1, nil);
	STAssertFalse(test2, nil);
	STAssertFalse(test3, nil);
	STAssertFalse(test4, nil);
	
	uint16 typeBitField3 = ISCHICKEN | ISDOG;
	test1 = typeBitField3 & ISCHICKEN;
	test2 = typeBitField3 & ISDOG;
	test3 = typeBitField3 & ISCAT;
	test4 = typeBitField3 & ISBREAD;
	STAssertTrue(test1, nil);
	STAssertTrue(test2, nil);
	STAssertFalse(test3, nil);
	STAssertFalse(test4, nil);	
}


@end
