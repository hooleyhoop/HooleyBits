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

#define LOG_EXPR(_X_) do{\
__typeof__(_X_) _Y_ = (_X_);\
const char * _TYPE_CODE_ = @encode(__typeof__(_X_));\
 	NSString *_STR_ = VTPG_DDToStringFromTypeAndValue(_TYPE_CODE_, &_Y_);\
 	if(_STR_)\
 		NSLog(@"%s = %@", #_X_, _STR_);\
 	else\
 		NSLog(@"Unknown _TYPE_CODE_: %s for expression %s in function %s, file %s, line %d", _TYPE_CODE_, #_X_, __func__, __FILE__, __LINE__);\
}while(0)

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
@interface TPDissembler : NSObject {}
- (TPLine *)decompile:(TPData *)ablock fromOffset:(int)offset;
@end @implementation TPDissembler
- (TPLine *)decompile:(TPData *)ablock fromOffset:(int)offset {
    // what length does thos offset give us?
    // find the start point
    return nil;
}
@end

#pragma mark -
@interface TPAssembledCodeBlock : MemoryBlockStore {
    char *_startAddress;
    uint64 _length;
}
@end @implementation TPAssembledCodeBlock

- (id)initWithRawData:(char *)data start:(char *)memAddr length:(uint64)len {
    
    self = [super init];
    if(self){
        _startAddress = memAddr;
        _length = len;
        TPData *listHead = [[[TPData alloc] initWithStart:memAddr length:len] autorelease];
        [self insertMemoryBlock:listHead];
    }
    return self;
}

- (void)dealloc {

    [super dealloc];
}

- (BOOL)containsAddress:(int)address {
    
    return address>=_startAddress && address<_startAddress+_length;
}

// we already have the data object and the line by this points
splitData:dataBlk WithLine:line

    struct SplitDataResultIndexes *indexesAfterSplit = split( dataBlk->_sizeAndPoisition, line->_sizeAndPoisition );

    int num = indexesAfterSplit->numberOfMemSectionIndexes 
    int lineInd = indexesAfterSplit->indexOfSplitter

    -- split the data 3 ways (in reality, there will be at least 1 and at least 1 will be the line)
    data1 = memSectionIndexes[0].start, memSectionIndexes[0].length
    data2 = memSectionIndexes[1].start, memSectionIndexes[1].length
    data3 = memSectionIndexes[2].start, memSectionIndexes[2].length

    replaceDataWith( data1, data2, data3 )



enum datatype {
    datatype_LINE,
    datatype_DATA,
    datatype_ERROR
};

- (enum datatype)getItemAtAddress:(int)address item:(id *)ptr {
    
    SHMemoryBlock *bl = [self blockForAddress:address];
    *ptr = bl;
    if([bl isKindOfClass:[TPData class]])
        return datatype_DATA;
    if([bl isKindOfClass:[TPLine class]])
        return datatype_LINE;
    return datatype_ERROR;
}


@end

#pragma mark -
@interface TPAssembledCodeBlockTests : SenTestCase {	
} @end

@implementation TPAssembledCodeBlockTests

- (void)testContainsAddress {
    char simpleInData[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    id codeDataBlock = [[TPAssembledCodeBlock alloc] initWithRawData:simpleInData start:0 length:10];
    STAssertTrue([codeDataBlock containsAddress:0], nil);
    STAssertTrue([codeDataBlock containsAddress:9], nil);
    STAssertFalse([codeDataBlock containsAddress:9], nil);
}

- (void)testGetItemAtAddress {
    // - (enum datatype)getItemAtAddress:(int)address item:(id *)ptr
    
    char simpleInData[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    id codeDataBlock = [[TPAssembledCodeBlock alloc] initWithRawData:simpleInData start:0 length:10];
    
    id datBlock;
    STAssertTrue([codeDataBlock getItemAtAddress:0 item:&datBlock]==datatype_DATA, nil);
    STAssertTrue([codeDataBlock getItemAtAddress:5 item:&datBlock]==datatype_DATA, nil);
    STAssertTrue([codeDataBlock getItemAtAddress:9 item:&datBlock]==datatype_DATA, nil);
}


-- when we have implemented memory section splitting lets put this back

//- (void)testSetLine {
//
//    char simpleInData[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
//    id codeDataBlock = [[TPAssembledCodeBlock alloc] initWithRawData:simpleInData start:0 length:10];
//   
//    // -- add lines as interpretations of bytes at addressess
//    id mockLine1 = [[[TPLine alloc] initWithStart:(char *)1 length:1] autorelease];
//    id mockLine2 = [[[TPLine alloc] initWithStart:(char *)4 length:3] autorelease];
//    
//    [codeDataBlock setLine:mockLine1];
//    [codeDataBlock setLine:mockLine2];    
//}
@end

#pragma mark -
@interface TPDissemblerTests : SenTestCase {	
} @end

@implementation TPDissemblerTests
- (void)testDecompileToLine {
    char simpleInData[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    id codeDataBlock = [[TPAssembledCodeBlock alloc] initWithRawData:simpleInData start:0 length:10];
    
    TPData *ablock;
    TPDissembler *disassembler = [[TPDissembler alloc] init];
    TPLine *nextLine = [disassembler decompile:ablock fromOffset:5];
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
    id codeDataBlock = [[TPAssembledCodeBlock alloc] initWithRawData:simpleInData start:0 length:10];

 
//    [allDataBlock interpretation:line forAddress:095]
//    
//    lineLength = disasembleALine( inputData, &programCounter );
//
//    // obviously we need a loop or something
//	while(YES){
//		processLine( inputData, programCounter )
//	}
    
    -- make sure the disasembler just returns addresses and has no dependencies
    
    addresss - ?
    add hardware breakpoint
    
    debuggerDidStopped(){
        is address from debugger within data block?
        if(YES)
            -- get item at address
            -- is it a line or data
            if(line)
                step debugger
            if(data)
                line = [data decompile to line: fromOffset:address
                splitData: WithLine
        if(NO)
            step debugger
    }
}



@end
