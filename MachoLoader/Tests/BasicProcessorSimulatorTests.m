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
#import <Foundation/NSDebug.h>
#import <sys/stat.h>

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
//@interface CallbackProxy : NSObject {
//    NSObject *_callbackObject;
//    NSThread *_callbackThread;
//    SEL _callbackSelector;
//}
//- (void)setup:(NSObject *)o :(NSThread *)t :(SEL)s;
//
//@end @implementation CallbackProxy
//- (void)dealloc {
//    [_callbackObject release];
//    [super dealloc];
//}
//- (void)setup:(NSObject *)o :(NSThread *)t :(SEL)s {
//    _callbackObject = [o retain];
//    _callbackThread = t;
//    _callbackSelector = s;
//}
//- (void)msg {
//    [_callbackObject performSelector:_callbackSelector onThread:_callbackThread withObject:nil waitUntilDone:NO];
//}
//@end

//#pragma mark -
//@interface CallbackProxyTests : SenTestCase {	
//} @end
//@implementation CallbackProxyTests
//int count = 0;
//- (void)_callback {
//    count++;
//}
//- (void)testCallback {
//    CallbackProxy *cp = [[[CallbackProxy alloc] init] autorelease];
//    [cp setup:self :[NSThread currentThread] :@selector(_callback)];
//    [cp msg];
//    STAssertTrue( count==1, nil );
//}
//@end


#pragma mark -
@interface RepeatingAsyncOperationTests : SenTestCase {	
} @end
@implementation RepeatingAsyncOperationTests

- (void)testRepeatingAsyncObject {
    //    action = new ASyncAction( instrStepper. step:&address )
    //    instrStepper.callback = action.asyncActionCompleted;        // what thread?
    
//duh    RepeatingAsyncTaskController *repeatingOp = [[RepeatingAsyncTaskController alloc] init];
//duh    repeatingOp.action = 
//duh    repeatingOp.howDoWeKnowWhenFinished?
//duh    [repeatingOp go];
    
 //duh   -- how do we test that it executes three times then action signals that it is complete
}
@end

#pragma mark -
@interface TPinstructionStepper : NSObject {}
@end @implementation TPinstructionStepper
- (BOOL)step:(int *)address {
    
    //in trace we start already explicitely start a thread that the exceptions are delivered on, then we call our Block that kicks it off again
    
    //-- enable hardware breakpoint
    //-- start target app thread
    
    //-- wait for callback
    //-- can't block the original thread if it is the main thread
    //-- set address, callback on original thread
    // address = 0;
    return NO;
}
@end

#pragma mark -
@interface TPinstructionStepperTests : SenTestCase {	
} @end
@implementation TPinstructionStepperTests
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
    STAssertTrue( address==0, nil );

    STAssertTrue( [instrStepper step:&address], nil );
    STAssertTrue( address==3, nil );

    STAssertTrue( [instrStepper step:&address], nil );
    STAssertTrue( address==6, nil );

    STAssertTrue( [instrStepper step:&address], nil );
    STAssertTrue( address==8, nil );

    STAssertFalse( [instrStepper step:&address], nil );
}

int timeToDoWork;
- (void)testThreadWaitStuff {

    timeToDoWork=0;
    NSCondition *cocoaCondition = [[NSCondition alloc] init];
    [cocoaCondition lock];

    NSLog(@"In first thread - launching");

    //-- start a new thread that does something after 1 sec
    [NSThread detachNewThreadSelector: @selector(aTestThreadMain:) toTarget:self withObject:cocoaCondition];       

    NSLog(@"In first thread - waiting");

    while (timeToDoWork <= 0)
        [cocoaCondition wait];

    timeToDoWork--;

    // Do real work here.

    [cocoaCondition unlock];
    [cocoaCondition release];
    NSLog(@"In first thread - compete");   
}

- (void)aTestThreadMain:(NSCondition *)cocoaCondition {

    NSLog(@"In secondry thread");
    [NSThread sleepForTimeInterval:0.5];

    NSLog(@"In secondry awoke");

    [cocoaCondition lock];
    timeToDoWork++;
    [cocoaCondition signal];
    [cocoaCondition unlock];
    
    NSLog(@"In secondry finis");    
}

- (void)testThreadCallbackStuff {
    
//doh    CallbackProxy *callback = [[CallbackProxy alloc] init];
//doh    [callback setup:self :[NSThread currentThread] :@selector(fakeCallback)];
    
//doh    [NSThread detachNewThreadSelector: @selector(aTestThreadMain) toTarget:self withObject:callback];
    
    //--oops, crash
//doh    [callback release];
}

- (void)fakeCallback {

}
- (void)fakeExceptionThread:(id)callback {
    
//doh    [callback msg];
}









//        decmpleAddress:address {
//        BOOL isOurs = [codeDataBlock1 containsAddress:address];
//            if( isOurs ) {
//                SHMemoryBlock *blk;
//                NSInteger index = [codeDataBlock1 block:&blk forAddress:address]

//                if([blk isKindOfClass:[TPLine class]]) {
//                    //-- ignore or increment count
//                } else if([blk isKindOfClass:[TPData class]]) {

//                    TPLine *line = [dissasembler decompile:blk fromOffset:??];

//                    [codeDataBlock1 splitData:[codeDataBlock memoryBlockAtIndex:2] atIndex:2 withLine:mockLine3];                        
//                }
//            }

@end
