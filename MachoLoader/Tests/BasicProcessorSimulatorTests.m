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
- (id)initWithData:(NSString *)data {
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
@interface BasicProcessorSimulator : SenTestCase {	
} @end

@implementation BasicProcessorSimulatorTests

- (void)testSettingLinesForAdresses {

    // -- make a data block
    id inputData = 0x@"010203040506070809";
    id appCode = [[TPAssembledCodeBlock alloc] initWithData:inputData];
    
    // -- add lines as interpretations of bytes at addressess
    id line1 = [[[TPLine alloc] init] autorelease];
    [appCode :line1];
    [appCode :line2];
    // -- verify the output
}

- (void)testUnknownStuff {
	
//	01 = add
//	02 = jump
//	03 = call
//	04 = move
//	
//	programCounter = 0
//	inputData = "010203040506070809"
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
