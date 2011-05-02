//
//  BasicProcessorSimulator.m
//  MachoLoader
//
//  Created by Steven Hooley on 09/01/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//
#import "SHMemoryBlock.h"
#import "MemoryBlockStore.h"
#import "MemorySectionIndexStructure.h"
#import "TPData.h"
#import "TPLine.h"
#import "ContiguousMemoryBlockStore.h"

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
@interface TPinstructionStepper : NSObject {}
@end @implementation TPinstructionStepper
- (BOOL)step:(int *)address {
    address = 0;
    return NO;
}
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
@interface TPinstructionStepperTests : SenTestCase {	
} @end
@implementation TPinstructionStepperTests
@end

#pragma mark -
@interface TPDissemblerTests : SenTestCase {	
} @end
@implementation TPDissemblerTests
- (void)testDecompileToLine {
//putback    char simpleInData[10] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
//putback    id codeDataBlock = [[ContiguousMemoryBlockStore alloc] initWithRawData:simpleInData start:0 length:10];
    
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
    id codeDataBlock = [[ContiguousMemoryBlockStore alloc] initWithRawData:simpleInData start:0 length:10];
    
    // -- add lines as interpretations of bytes at addressess
    id mockLine1 = [[[TPLine alloc] initWithStart:(char *)1 length:1] autorelease];
    id mockLine2 = [[[TPLine alloc] initWithStart:(char *)4 length:3] autorelease];
 
    [codeDataBlock release];
}

enum TP_INSTR {
    INSTR_MOV,
    INSTR_ADD,
    INSTR_JMP
};

- (void)testInstructionStepper {

    char simpleAppData[10] = {  
        INSTR_MOV, 0x01, 0x02,  // 0
        INSTR_ADD, 0x03, 0x04,  // 3
        INSTR_JMP, 0xff         // 6
    };

    int address;
    TPinstructionStepper *instrStepper = [[TPinstructionStepper alloc] init];

    STAssertTrue( [instrStepper step:&address], nil );
    STAssertTrue( address==3, nil );

    STAssertTrue( [instrStepper step:&address], nil );
    STAssertTrue( address==6, nil );

    STAssertTrue( [instrStepper step:&address], nil );
}

- (void)testUnknownStuff {


    
    id codeDataBlock1 = [[ContiguousMemoryBlockStore alloc] initWithRawData:simpleAppData start:(char *)0 length:11];
    
    TPDissembler *dissasembler = [[TPDissembler alloc] init];
    
    int address;
    TPinstructionStepper *instrStepper = [[TPinstructionStepper alloc] init];
    
	while( [instrStepper step:&address]) {
        
        BOOL isOurs = [codeDataBlock1 containsAddress:address];
        
        if( isOurs ) {
            SHMemoryBlock *blk;
            NSInteger index = [codeDataBlock1 block:&blk forAddress:address]

            if([blk isKindOfClass:[TPLine class]]) {
                //-- ignore or increment count
            } else if([blk isKindOfClass:[TPData class]]) {
                
                TPLine *line = [dissasembler decompile:blk fromOffset:??];

                [codeDataBlock1 splitData:[codeDataBlock memoryBlockAtIndex:2] atIndex:2 withLine:mockLine3];                        
            }
        }
    }
 
    [instrStepper release];
    [codeDataBlock1 release];
    [dissasembler release];
}



@end
