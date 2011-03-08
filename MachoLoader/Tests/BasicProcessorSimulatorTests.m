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
@interface TPAssembledCodeBlock : NSObject {
    NSMutableArray *_list;
}
@end @implementation TPAssembledCodeBlock

- (id)initWithRawData:(char *)data {
    self = [super init];
    _list = [[NSMutableArray alloc] initWithCapacity:1000000];
    TPData *listHead = [[[TPData alloc] init] autorelease];
    [_list addObject:listHead];
    return self;
}

- (void)setLine:(TPLine *)ln atPos:(int)linePos forLength:(int)lineLength {
    
}

- (id)itemAtAddress:(int)add {
    return nil;
}

- (NSInteger)findInsertionPt:(SHMemoryBlock *)memBlock {
	
	NSUInteger low = 0;
	NSUInteger high  = [_memoryBlockStore count];
	NSUInteger index = low;
	
	while( index < high ) {
		const NSUInteger mid = (index + high)/2;
		SHMemoryBlock *test = [_memoryBlockStore objectAtIndex: mid];
		NSInteger result = [test compareStartAddress:memBlock];
		if ( result < 0) {
			index = mid + 1;
		} else {
			high = mid;
		}
	}
	return index;
}

// - (void)disasembleALine:( NSString *)inputData { /*do we pass all data or just data in correct position? */
//    newLine = [[[TPLine alloc] initWithAddress:currentAddress] autorelease]
//    bytesRead = 1;
//    return newLine
//}

@end

#pragma mark -
@interface BasicProcessorSimulatorTests : SenTestCase {	
} @end

@implementation BasicProcessorSimulatorTests

/*
 * I dont think at this point functionas should be objects, they should just be labels on the line objects
 */
- (void)testSettingLinesForAdresses {

    // -- make a data block
    char simpleInData[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    id codeDataBlock = [[TPAssembledCodeBlock alloc] initWithRawData:simpleInData];
    
    // -- add lines as interpretations of bytes at addressess
    id mockLine1 = [[[TPLine alloc] init] autorelease];
    id mockLine2 = [[[TPLine alloc] init] autorelease];
 
    [codeDataBlock setLine:mockLine1 atPos:1 forLength:1];
    [codeDataBlock setLine:mockLine2 atPos:4 forLength:3];
    
    // -- fundamentally we want to interogate it at addresses and find out what is there
    // -- this has got to be arbitrary, ie, we dont access it in order
    
    // -- verify the output
    STAssertNotNil([codeDataBlock itemAtAddress:0], nil);    //== 1 byte of dta
    STAssertNotNil([codeDataBlock itemAtAddress:1], nil);    //== line length 1
    STAssertNotNil([codeDataBlock itemAtAddress:2], nil);    //== 2 byte of dta
    STAssertNotNil([codeDataBlock itemAtAddress:3], nil);    //== ??
    STAssertNotNil([codeDataBlock itemAtAddress:4], nil);    //== line length 3

    
//    new data
//    assert data.elementCount = 1
//    add line at begging 
//    assert data.elementCount = 2
//    addLine at end
//    asserrt data.elementCount = 3
//    add line in middle
//    assert data.elementCount = 5
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
