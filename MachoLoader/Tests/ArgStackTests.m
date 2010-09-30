//
//  ArgStackTests.m
//  MachoLoader
//
//  Created by Steven Hooley on 30/09/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "ArgStack.h"

@interface ArgStackTests : SenTestCase {
	
}

@end

@implementation ArgStackTests

- (void)testLetsBuildAnArgStack {
	
	struct ArgStack aStack;
	argStack_Init( &aStack );
	argStack_Push( &aStack, 0 );
	argStack_Push( &aStack, 3 );
	argStack_Push( &aStack, 6 );
	
	uint32 stackSize = aStack.size;
	STAssertTrue(stackSize==3, nil);
	for(uint32 i=0;i<stackSize;i++) {
		STAssertTrue( aStack.data[i]==i*3, nil);
	}
}

@end
