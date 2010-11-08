//
//  InnerFunctionBlockTests.m
//  MachoLoader
//
//  Created by Steven Hooley on 08/11/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


@interface InnerFunctionBlockTests : SenTestCase {
	
}

@end


@implementation InnerFunctionBlockTests

- (void)setUp {
	
	struct hooleyFuction *newFunc = calloc( 1, sizeof(struct hooleyFuction) );

	struct hooleyCodeLine *newLine1 = calloc( 1, sizeof(struct hooleyCodeLine) );
	struct hooleyCodeLine *newLine2 = calloc( 1, sizeof(struct hooleyCodeLine) );
	struct hooleyCodeLine *newLine3 = calloc( 1, sizeof(struct hooleyCodeLine) );
	
	struct hooleyCodeLine *firstLine;	
	struct hooleyCodeLine *lastLine;
	struct label *labels;
	
}

- (void)tearDown {
	
}


-- before this we must break into inner blocks

-- so, given an inner block, what do we want to do exactly?

-- for each line, identify inputs and outputs

for each line make a node with input and outputs

• ordered unique inputs: 1_a, 2_b, 5_c, 7_zch, 10_ff123
• ordered unique outputs 3_a,6_d, 9_b
a,b		add		a
a,c		add		d
zch,b	mul		b
ff123	call

• inputs: 1_d, 2_a, 4_ff123
• outputs: 3_c
d,a		add		c
ff123	call

Look for input that also occurs in outputs
ELIMINATE inputs with greater index than output

so, given a line how do we identify inputs and outputs?

mov ARGS[a1, b1]
@1 = @2

in:@1,@2 out:@1

@end
