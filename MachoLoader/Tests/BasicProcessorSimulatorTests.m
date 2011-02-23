//
//  BasicProcessorSimulator.m
//  MachoLoader
//
//  Created by Steven Hooley on 09/01/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

/*
 * I will endevour to TDD a nice layout for the simulator. This wont be the working code
 * but im hoping to arrive at the correct shape
 
 This actually wants to bee a graph
-app
	-block
		<line>
		<line>
	-<data>
	-block
		<line>
	-<data>

 */

#pragma mark -
@interface TPBlock : NSObject {}
@end @implementation TPBlock
@end

#pragma mark -
@interface TPData : NSObject {}
@end @implementation TPData
@end

#pragma mark -
@interface TPLine : NSObject {}
@end @implementation TPLine
@end

#pragma mark -
@interface TPDissembler : NSObject {}
@end @implementation TPDissembler
@end

#pragma mark -
@interface TPAssembledCodeBlock : NSObject {}
@end @implementation TPAssembledCodeBlock
- (id)initWithData:(char *)data {
    self = [super init];
    return self;
}
- (void)disasembleALine:( NSString *)inputData { /*do we pass all data or just data in correct position? */
    
//    newLine = [[[TPLine alloc] initWithAddress:currentAddress] autorelease]
//    bytesRead = 1;
//    return newLine
}

@end

#pragma mark -
@interface BasicProcessorSimulatorTests : SenTestCase {	
} @end

@implementation BasicProcessorSimulatorTests

- (void)testSettingLinesForAdresses {

    // -- make a data block
    char simpleInData[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    id codeDataBlock = [[TPAssembledCodeBlock alloc] initWithData:simpleInData];
    
    // -- add lines as interpretations of bytes at addressess
    id mockLine1 = [[[TPLine alloc] init] autorelease];
    id mockLine2 = [[[TPLine alloc] init] autorelease];
 
    [codeDataBlock setLine:mockLine1 atPos:1 forLength:1];
    [codeDataBlock setLine:mockLine2 atPos:4 forLength:3];
    
    // -- verify the output
    codeDataBlock:0 == 1 byte of dta
    codeDataBlock:1 == line length 1
    codeDataBlock:2 == 2 byte of dta
    codeDataBlock:4 == line length 3

}

- (void)testUnknownStuff {
	
//	01 = add
//	02 = jump
//	03 = call
//	04 = move
	
	int programCounter = 0;
    char simpleInData[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
//	
//    [allDataBlock interpretation:line forAddress:095]
//    
//    lineLength = disasembleALine( inputData, &programCounter );
//
//    // obviously we need a loop or something
//	while(YES){
//		processLine( inputData, programCounter )
//	}
    
    
}

@end
