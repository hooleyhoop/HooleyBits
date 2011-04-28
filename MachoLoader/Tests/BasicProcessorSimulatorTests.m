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
//TODO: rename contiguousMemoryBlockStore - note doesnt store anything!
@interface TPAssembledCodeBlock : MemoryBlockStore {}
@end @implementation TPAssembledCodeBlock
//NB this doesnt save the data at the mo - just the pointers into it
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

- (uint64)contiguousLength {
    return [self lastAddress]-[self startAddress]+1;
}

- (BOOL)containsAddress:(char *)address {
    return address >= [self startAddress] && address<=[self lastAddress];
}

// just a test, if we cant just split the data in half we arent going to get anywhere
- (void)simpleTemporarySplit {
    
 //putback   -- do this, just split the initial bit in half
 //putback    0 1 2 3 4   5 6 7 8 9
    
     SHMemoryBlock *ob1 = [self memoryBlockAtIndex:0];
    [ob1 shrinkToLength: 5];
    
    SHMemoryBlock *newBlock = [[[SHMemoryBlock alloc] initWithStart:[ob1 lastAddress]+1 length:5] autorelease];
	[_memoryBlockStore insertObject:newBlock atIndex:1];

}

// we already have the data object and the line by this points
//putback splitData:dataBlk WithLine:line

//putback     struct SplitDataResultIndexes *indexesAfterSplit = split( dataBlk->_sizeAndPoisition, line->_sizeAndPoisition );

//putback     int num = indexesAfterSplit->numberOfMemSectionIndexes 
//putback     int lineInd = indexesAfterSplit->indexOfSplitter

//putback     -- split the data 3 ways (in reality, there will be at least 1 and at least 1 will be the line)
//putback     data1 = memSectionIndexes[0].start, memSectionIndexes[0].length
//putback     data2 = memSectionIndexes[1].start, memSectionIndexes[1].length
//putback     data3 = memSectionIndexes[2].start, memSectionIndexes[2].length

//putback     replaceDataWith( data1, data2, data3 )



enum datatype {
    datatype_LINE,
    datatype_DATA,
    datatype_ERROR
};

- (enum datatype)getItemAtAddress:(char *)address item:(id *)ptr {
    
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

- (void)testContiguousLength {
    
    char simpleInData1[1] = {0xff};  
    char simpleInData2[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    id codeDataBlock1 = [[TPAssembledCodeBlock alloc] initWithRawData:simpleInData1 start:(char *)0 length:1];
    STAssertTrue([codeDataBlock1 contiguousLength]==1, nil);
    [codeDataBlock1 release];
    
    id codeDataBlock2 = [[TPAssembledCodeBlock alloc] initWithRawData:simpleInData2 start:(char *)1 length:10];
    STAssertTrue([codeDataBlock2 contiguousLength]==10, nil);
    [codeDataBlock2 release];   
}

- (void)testContainsAddress {
    
    char simpleInData1[1] = {0xff};  
    char simpleInData2[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    id codeDataBlock1 = [[TPAssembledCodeBlock alloc] initWithRawData:simpleInData1 start:(char *)0 length:1];
    STAssertTrue([codeDataBlock1 containsAddress:(char *)0], nil);
    STAssertFalse([codeDataBlock1 containsAddress:(char *)9], nil);
    [codeDataBlock1 release];
    
    id codeDataBlock2 = [[TPAssembledCodeBlock alloc] initWithRawData:simpleInData2 start:(char *)1 length:10];
    STAssertFalse([codeDataBlock2 containsAddress:(char *)0], nil);
    STAssertTrue([codeDataBlock2 containsAddress:(char *)1], nil);
    STAssertTrue([codeDataBlock2 containsAddress:(char *)5], nil);
    STAssertTrue([codeDataBlock2 containsAddress:(char *)10], nil);
    STAssertFalse([codeDataBlock2 containsAddress:(char *)11], nil);    
    [codeDataBlock2 release];
}

- (void)testGetItemAtAddress {
    // - (enum datatype)getItemAtAddress:(int)address item:(id *)ptr
    
    char simpleInData[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    id codeDataBlock = [[TPAssembledCodeBlock alloc] initWithRawData:simpleInData start:0 length:10];
    
    id datBlock;
    STAssertTrue([codeDataBlock getItemAtAddress:(char *)0 item:&datBlock]==datatype_DATA, nil);
    STAssertTrue([codeDataBlock getItemAtAddress:(char *)5 item:&datBlock]==datatype_DATA, nil);
    STAssertTrue([codeDataBlock getItemAtAddress:(char *)9 item:&datBlock]==datatype_DATA, nil);
    
    [codeDataBlock release];
}

// -- when we have implemented memory section splitting lets put this back
- (void)testTemporarySimpleSplit {
    
    char simpleInData[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    id codeDataBlock = [[TPAssembledCodeBlock alloc] initWithRawData:simpleInData start:0 length:10];
    
    [codeDataBlock simpleTemporarySplit];
    STAssertTrue( [codeDataBlock startAddress]==0, nil);
    STAssertTrue( [codeDataBlock contiguousLength]==10, nil);
    STAssertTrue( [codeDataBlock itemCount]==2, nil);
    
    SHMemoryBlock *item1 = [codeDataBlock memoryBlockAtIndex:0];
    STAssertTrue( [item1 startAddress]==(char *)0, nil);
    STAssertTrue( [item1 length]==5, nil);
    STAssertTrue( [item1 lastAddress]==(char *)4, nil);
    
    SHMemoryBlock *item2 = [codeDataBlock memoryBlockAtIndex:1];
    STAssertTrue( [item2 startAddress]==(char *)5, nil);
    STAssertTrue( [item2 length]==5, nil);
    STAssertTrue( [item2 lastAddress]==(char *)9, @"%i", [item1 lastAddress] );
    
    [codeDataBlock release];
}

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
//putback    char simpleInData[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
//putback    id codeDataBlock = [[TPAssembledCodeBlock alloc] initWithRawData:simpleInData start:0 length:10];
    
//putback    TPData *ablock;
//putback    TPDissembler *disassembler = [[TPDissembler alloc] init];
//putback    TPLine *nextLine = [disassembler decompile:ablock fromOffset:5];
}
@end

#pragma mark -
@interface BasicProcessorSimulatorTests : SenTestCase {	
} @end

@implementation BasicProcessorSimulatorTests


/*
 * I dont think at this point functionas should be objects, they should just be labels on the line objects
 */
- (void)testSettingLinesForAdressess {

    // -- make a data block
    char simpleInData[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    id codeDataBlock = [[TPAssembledCodeBlock alloc] initWithRawData:simpleInData start:0 length:10];
    
    // -- add lines as interpretations of bytes at addressess
    id mockLine1 = [[[TPLine alloc] initWithStart:(char *)1 length:1] autorelease];
    id mockLine2 = [[[TPLine alloc] initWithStart:(char *)4 length:3] autorelease];
 
 //derp   [codeDataBlock setLine:mockLine1];
//derp    [codeDataBlock setLine:mockLine2];
    
    // d,<d>,d,d,<d,d,d>,d,d,d
    
    // -- fundamentally we want to interogate it at addresses and find out what is there
    // -- this has got to be arbitrary, ie, we dont access it in order
    
    // -- verify the output
    
    // if the line is 3 bytes long and you try to getItemAtAddress: which is not the start of the line
    // you must have gone wrong, unless some wierd copy protection stuff
    
    // - So, getItemAtAddress: might return line (if the line begins at that address), NSError (if you try to access mid line), or the nearest datablock (?? what use would this be?)
    id ob;
    STAssertTrue( [codeDataBlock getItemAtAddress:(char *)1 item:&ob]== datatype_LINE, nil );      //== line length 1
    
    STAssertTrue( [codeDataBlock getItemAtAddress:(char *)4 item:&ob]==datatype_LINE, nil );      //== line length 3
    STAssertTrue( [codeDataBlock getItemAtAddress:(char *)5 item:&ob]==datatype_ERROR, nil );    // can only access line from start
    STAssertTrue( [codeDataBlock getItemAtAddress:(char *)6 item:&ob]==datatype_ERROR, nil );    // can only access line from start

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
    
//putback     -- make sure the disasembler just returns addresses and has no dependencies
    
//putback     addresss - ?
//putback     add hardware breakpoint
    
//putback     debuggerDidStopped(){
//putback         is address from debugger within data block?
//putback         if(YES)
//putback             -- get item at address
//putback             -- is it a line or data
//putback             if(line)
//putback                 step debugger
//putback             if(data)
//putback                 line = [data decompile to line: fromOffset:address
//putback                 splitData: WithLine
//putback         if(NO)
//putback             step debugger
//putback     }
}



@end
