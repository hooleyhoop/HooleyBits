//
//  BasicDIYOOTests.m
//  MachoLoader
//
//  Created by Steven Hooley on 08/11/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

// a function pointer must always have the same signiture. ie 2 functions with different signitures cant be stashed in the same var
float Plus    (float a, float b) { return a+b; }
float Minus   (float a, float b) { return a-b; }
float Multiply(float a, float b) { return a*b; }
float Divide  (float a, float b) { return a/b; }

struct DIYClass {
	char name[10];
	float (*pt2Function1)(float, float);
};

struct TestStruct {
	struct DIYClass *class;
	float someData;
};

struct DIYClass instance1 = { "steven", Plus };
struct DIYClass instance2 = { "david", Minus };

struct TestStruct struct1 = { &instance1, 10.0f };
struct TestStruct struct2 = { &instance2, 20.0f };

@interface BasicDIYOOTests : SenTestCase {
	
}

@end


@implementation BasicDIYOOTests

- (void)testStuff {

	// short and long way
	float (*pt2Function1)(float, float) = Plus;
	float (*pt2Function2)(float, float) = &Minus;
	
	float result1 = (*pt2Function1) (1.0f,2.0f);
	float result2 = pt2Function2(1.0f,2.0f);
	
	printf("%f %f", result1, result2 );
	
	float result = struct2.class->pt2Function1(5.0f,3.0f);
	printf("%f", result );

}

@end
