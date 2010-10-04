//
//  BonkersRegTests.m
//  MachoLoader
//
//  Created by Steven Hooley on 04/10/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


@interface BonkersRegTests : SenTestCase {
	
}

@end

@implementation BonkersRegTests

struct TestReg {
	int f1;
	char f2[10];
	char f3[10];
};


static const struct TestReg regname16_Struct[4][8][2] = {
	{
		{{0,"abc01","abc"},{0,"abc02","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}}, 
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}}	
	},
	{	{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc03","abc"},{0,"abc04","abc"}},		
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}}
	},
	{	{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}}
	},
	{	{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}},
		{{0,"abc","abc"},{0,"abc","abc"}}
	}
};

- (void)testAwkwardRegStuff {
	
	const struct TestReg *test2 = regname16_Struct[0][0];
	
	struct TestReg test3 = test2[0];
	struct TestReg test4 = test2[1];
	
	STAssertTrue( !strcmp(test3.f2, "abc01"), nil );
	STAssertTrue( !strcmp(test4.f2, "abc02"), nil );
	
	const struct TestReg *test5 = regname16_Struct[1][2];
	struct TestReg test6 = test5[0];
	struct TestReg test7 = test5[1];
	
	STAssertTrue( !strcmp(test6.f2, "abc03"), nil );
	STAssertTrue( !strcmp(test7.f2, "abc04"), nil );	
}

@end
