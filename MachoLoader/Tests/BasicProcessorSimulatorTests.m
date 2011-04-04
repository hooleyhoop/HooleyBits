//
//  BasicProcessorSimulator.m
//  MachoLoader
//
//  Created by Steven Hooley on 09/01/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//
#import "SHMemoryBlock.h"
#import "MemoryBlockStore.h"

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
//@interface TPBlock : NSObject {}
//@end @implementation TPBlock
//@end

#pragma mark -
@interface TPData : SHMemoryBlock {}
@end @implementation TPData
@end

#pragma mark -
@interface TPLine : SHMemoryBlock {}
@end @implementation TPLine
@end

#pragma mark -
//@interface TPDissembler : NSObject {}
//@end @implementation TPDissembler
//@end

#pragma mark -
@interface TPAssembledCodeBlock : MemoryBlockStore {
}
@end @implementation TPAssembledCodeBlock

- (id)initWithRawData:(char *)data start:(char *)memAddr length:(uint64)len {
    
    self = [super init];
    if(self){
        TPData *listHead = [[[TPData alloc] initWithStart:memAddr length:len] autorelease];
        [self insertMemoryBlock:listHead];
    }
    return self;
}

- (void)dealloc {

    [super dealloc];
}

- (void)setLine:(TPLine *)ln {
    
	NSUInteger ind = [self findInsertionPt:ln];

    //-- get previous object
    //-- shorten it
    //-- perhaps we need an object after it?
    
	[_memoryBlockStore insertObject:ln atIndex:ind];    
}

enum datatype {
    datatype_LINE,
    datatype_DATA,
    datatype_ERROR
};

- (enum datatype)getItemAtAddress:(int)address item:(id *)ptr {
    
//    NSUInteger low = 0;
//    NSUInteger high  = [_list count];
//    NSUInteger index = low;
//    
//    while( index < high ) {
//        const NSUInteger mid = (index + high)/2;
//        NSObject<Storable> *test = [_list objectAtIndex: mid];
//        NSInteger result = [test compareStartToAddress:address];
//        if ( result < 0) {
//            index = mid + 1;
//        } else {
//            high = mid;
//        }
//    }
//    //	return index;
//    NSLog(@"%i", index);
    return datatype_ERROR;
}


// - (void)disasembleALine:( NSString *)inputData { /*do we pass all data or just data in correct position? */
//    newLine = [[[TPLine alloc] initWithAddress:currentAddress] autorelease]
//    bytesRead = 1;
//    return newLine
//}

@end

#pragma mark -
@interface TPAssembledCodeBlockTests: : SenTestCase {	
} @end

@implementation TPAssembledCodeBlockTests
- (void)testStuff {
    STFail(@"come on");
}
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
    id codeDataBlock = [[TPAssembledCodeBlock alloc] initWithRawData:simpleInData start:0 length:10];
    
    // -- add lines as interpretations of bytes at addressess
    id mockLine1 = [[[TPLine alloc] initWithStart:(char *)1 length:1] autorelease];
    id mockLine2 = [[[TPLine alloc] initWithStart:(char *)4 length:3] autorelease];
 
    [codeDataBlock setLine:mockLine1];
    [codeDataBlock setLine:mockLine2];
    
    // d,<d>,d,d,<d,d,d>,d,d,d
    
    // -- fundamentally we want to interogate it at addresses and find out what is there
    // -- this has got to be arbitrary, ie, we dont access it in order
    
    // -- verify the output
    
    // if the line is 3 bytes long and you try to getItemAtAddress: which is not the start of the line
    // you must have gone wrong, unless some wierd copy protection stuff
    
    // - So, getItemAtAddress: might return line (if the line begins at that address), NSError (if you try to access mid line), or the nearest datablock (?? what use would this be?)
    id ob;
    STAssertTrue( [codeDataBlock getItemAtAddress:1 item:&ob]== datatype_LINE, nil );      //== line length 1
    
    STAssertTrue( [codeDataBlock getItemAtAddress:4 item:&ob]==datatype_LINE, nil );      //== line length 3
    STAssertTrue( [codeDataBlock getItemAtAddress:5 item:&ob]==datatype_ERROR, nil );    // can only access line from start
    STAssertTrue( [codeDataBlock getItemAtAddress:6 item:&ob]==datatype_ERROR, nil );    // can only access line from start

    // if we use SHMemoryBlock we must put in correct init
    
    STFail(@"what use would the data object be?", nil);
    
 //ptback   [codeDataBlock getItemAtAddress:0 item:&ob]==ThingyBob.DATA, nil );             //== 1 byte of dta
 //ptback     [codeDataBlock getItemAtAddress:2 item:&ob]==ThingyBob.DATA, nil );             //== 2 byte of dta
 //ptback     [codeDataBlock getItemAtAddress:3 item:&ob]==ThingyBob.DATA, nil );             //== ??

 //ptback     [codeDataBlock getItemAtAddress:7 item:&ob]==ThingyBob.DATA, nil );     // data length 3
 //ptback     [codeDataBlock getItemAtAddress:8 item:&ob]==ThingyBob.DATA, nil );
 //ptback     [codeDataBlock getItemAtAddress:9 item:&ob]==ThingyBob.DATA, nil );
    
//    id ob;
//    int resultCode = [codeDataBlock getgetItemAtAddress:3 item:&ob];
//    switch(resultCode){
//        -- -1
//            error
//        -- 0
//            data
//            offset = address - data.start
//            -- do we realy want to do this?
//        -- 1
//            line
//    }
    
//    new data
//    assert data.elementCount = 1
//    add line at begging 
//    assert data.elementCount = 2
//    addLine at end
//    asserrt data.elementCount = 3
//    add line in middle
//    assert data.elementCount = 5
    
    [codeDataBlock release];
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
