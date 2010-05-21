//
//  ByteAlignmentTests.m
//  SHGeometryKit
//
//  Created by Steven Hooley on 20/05/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <math.h>
#import <OpenGL/gl.h>
#import <Accelerate/Accelerate.h>


@interface ByteAlignmentTests : SenTestCase {
	
}

@end


@implementation ByteAlignmentTests

- (void)testSomeByteAlignmentMuthaFucker {

	{
		int aba = sizeof(float);	// 4 bytes
		int aaa = sizeof(GLfloat);	// 4 bytes
		int bbb = sizeof(CGFloat);	// 8 bytes
		STAssertTrue( aba==aaa, @"if using the builin vector type i want to know it is the same size as GLfloat");
	}
	
	C3DTVector aa = {{ 10.0f, 20.0f, 30.0f, 40.0f }};
	int ccc = sizeof(C3DTVector); // 16 bytes
	
	GLfloat *fourFloats = malloc(sizeof(GLfloat)*4);
	int rrr = malloc_size(fourFloats); // 16 bytes
	free(fourFloats);
	
	{
		int off1 = offsetof( C3DTVector, radial );		// 0 bytes
		int off2 = offsetof( C3DTVector, cartesian );	// 0 bytes
		int off3 = offsetof( C3DTVector, flts );			// 0 bytes
	}
	
	{
		int sizeof1 = sizeof( aa.flts );			// 0 bytes
		int sizeof2 = sizeof( aa.radial );			// 0 bytes
		int sizeof3 = sizeof( aa.cartesian );		// 0 bytes
		STAssertTrue( sizeof1==16, @"%i", sizeof2 );
		STAssertTrue( sizeof2==16, @"%i", sizeof2 );
		STAssertTrue( sizeof3==16, @"%i", sizeof2 );
	}
	
	{
		GLfloat hmmm1 = aa.flts[2];
		GLfloat hmmm2 = aa.cartesian.z;
		GLfloat hmmm3 = aa.radial.phi;
		NSLog(@"%f %f %f", hmmm1, hmmm2, hmmm3 );
	}
	
	vFloat aVectorFloat1 = aa.flts;
	float firstFloat = aVectorFloat1[0];
	float secondFloat = aVectorFloat1[1];
	STAssertTrue(firstFloat==10.0f, @"fuck %f", firstFloat);
	STAssertTrue(secondFloat==20.0f, @"fuck %f", secondFloat);

	aa.flts[1] = 999.0f;
	aa.cartesian.z = 333.0f;

	vFloat aVectorFloat2 = aa.flts;
	float firstFloat2 = aVectorFloat2[0];
	float secondFloat2 = aVectorFloat2[1];
	float thirdFloat2 = aVectorFloat2[2];
	
	STAssertTrue(firstFloat2==10.0f, @"fuck %f", firstFloat);
	STAssertTrue(secondFloat2==999.0f, @"fuck %f", secondFloat);
	STAssertTrue(thirdFloat2==333.0f, @"fuck %f", thirdFloat2);


	vFloat flts = {10.0f,20.0f,30.0f,40.0f};
	NSLog(@"%f", flts[0]);

	aa.flts[0];
	aa.flts[1];
	aa.flts[2];
	aa.flts[3];
	

	
	//	GLfloat yval = aVectorFloat.y;
//	GLfloat zval = aVectorFloat.z;

}

- (void)testVectorLength {

	C3DTVector aa = {{ 2.0f, 10.0f, 150.0f, 800.0f }};
	vFloat f = aa.flts;

	CGFloat sum = 2.0f*2.0f + 10.0f*10.0f + 150.0f*150.0f + 800.0f*800.0f;
	CGFloat calculatedSum = f[0]*f[0] + f[1]*f[1] + f[2]*f[2] + f[3]*f[3];
	STAssertTrue( sum==calculatedSum, @"Doh" );
	
	GLfloat vecLength = sqrtf(sum);
//	GLfloat calcvecLength = vectorLength(aa);
//	STAssertTrue( vecLength==calcvecLength, @"Doh" );

		//	return (float)sqrt( f_ptr[0]*f_ptr[0] + f_ptr[1]*f_ptr[1] + f_ptr[2]*f_ptr[2] );
	
	vFloat brrrrrr = {4,4,4,4};
	brrrrrr[0] = 33.f;
}



@end
