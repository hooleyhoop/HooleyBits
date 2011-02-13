//
//  PolygonRasterizerTests.m
//  InnerRender
//
//  Created by Steven Hooley on 07/12/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


@interface PolygonRasterizerTests : SenTestCase {
@private
}

@end

@implementation PolygonRasterizerTests

- (void)setUp {
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}

/* This only works with bytes! 
    BOOL val = 255; // == false !!
    I did not know this
 */
    
- (void)testBitfieldStuffIHaveForgottenAbout {

	unsigned char mask_table[] = { 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80 };

	char value = 0;
	
	// this is garbage - value is uninitialized!
	value |= mask_table[ 3 ];
	STAssertTrue( value==8, nil );
	value |= mask_table[ 1 ];
	STAssertTrue( value==10, nil );

	STAssertTrue( (value & mask_table[0])==0, nil );
	STAssertTrue( (value & mask_table[1])!=0, nil );
	STAssertTrue( (value & mask_table[2])==0, nil );
	STAssertTrue( (value & mask_table[3])!=0, nil );
	STAssertTrue( (value & mask_table[4])==0, nil );

	value &= ~mask_table[ 1 ];
	value &= ~mask_table[ 3 ];
	
	STAssertTrue( (value & mask_table[0])==0, nil );
	STAssertTrue( (value & mask_table[1])==0, nil );
	STAssertTrue( (value & mask_table[2])==0, nil );
	STAssertTrue( (value & mask_table[3])==0, nil );
	STAssertTrue( (value & mask_table[4])==0, nil );
	
	// test a bit
	// value & mask_table[ 0 ];
	
	// set a bit
	// value |= mask_table[ 0 ];
	
	// clear a bit
	// value &= ~mask_table[ 0 ];

}

@end
