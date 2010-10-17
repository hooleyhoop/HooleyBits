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


struct TestReg2 {
	int f1;
	struct TestReg2 *innerReg;
	char f2[10];
	char f3[10];
};

struct TestReg2 reg1 = {1,0,"one","abc"};
struct TestReg2 reg2 = {2,&reg1,"two","abc"};
struct TestReg2 reg3 = {3,&reg2,"three","abc"};
struct TestReg2 reg4 = {4,&reg3,"four","abc"};

static const struct TestReg2 *areg2Array[4] = { &reg1, &reg2, &reg3, &reg4 };

// just put the ptr to the array in - later we will deference it
struct TestReg2 reg5 = {5, (void *)areg2Array, "five", "abc"};

static const struct TestReg2 *areg2Array2[5] = { &reg1, &reg2, &reg3, &reg4, &reg5 };

- (void)testStashTheArrayInsteadOfAReg {

	int f1 = areg2Array[3]->innerReg->f1;
	STAssertTrue( f1==3, @"%i", f1 );
	
	struct TestReg2 *(*array) = (void *)areg2Array2[4]->innerReg;
	struct TestReg2 *innerElement = array[3];
	int f2 = innerElement->innerReg->f1;
	STAssertTrue( f2==3, @"%i", f2 );
	
	if( (char *)(areg2Array2[4]->innerReg) != reg1 ){
		STFail(@"Doh");
	}
}

@end
