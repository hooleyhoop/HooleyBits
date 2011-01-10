//
//  BasicProcessorSimulator.m
//  MachoLoader
//
//  Created by Steven Hooley on 09/01/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

//-app
//	-block
//		<line>
//		<line>
//	-<data>
//	-block
//		<line>
//	-<data>

#pragma mark -
@interface Block : NSObject { }
@end @implementation Block

@end

#pragma mark -
@interface Data : NSObject { }
@end @implementation Data

@end

#pragma mark -
@interface Line : NSObject {}
@end @implementation Line

@end


#pragma mark -
@interface BasicProcessorSimulator : SenTestCase {	
} @end

@implementation BasicProcessorSimulator

- (void)testUnknownStuff {
	
	01 = add
	02 = jump
	03 = call
	04 = move
	
	programCounter = 0
	inputData = "010203040506070809"
	
	while(YES){
		processLine( inputData, programCounter )
	}
}

@end
