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
@interface CallbackProxy : NSObject {
NSObject *_callbackObject;
NSThread *_callbackThread;
SEL _callbackSelector;
}
- (void)setup:(NSObject *)o :(NSThread *)t :(SEL)s;
@end @implementation CallbackProxy
- (void)dealloc {
    [_callbackObject release];
    [super dealloc];
}
- (void)setup:(NSObject *)o :(NSThread *)t :(SEL)s {
    _callbackObject = [o retain];
    _callbackThread = t;
    _callbackSelector = s;
}
- (void)msg {
    [_callbackObject performSelector:_callbackSelector onThread:_callbackThread withObject:nil waitUntilDone:NO];
}
@end

#pragma mark -
@interface CallbackProxyTests : SenTestCase {	
} @end
@implementation CallbackProxyTests
int count = 0;
- (void)_callback {
    count++;
}
- (void)testCallback {
    CallbackProxy *cp = [[[CallbackProxy alloc] init] autorelease];
    [cp setup:self :[NSThread currentThread] :@selector(_callback)];
    [cp msg];
    STAssertTrue( count==1, nil );
}
@end

#pragma mark -
@interface AsyncAction : NSObject {
    NSDictionary *_callbacks;
}

@end @implementation AsyncAction
- (void)setCallbacks:(NSDictionary *)callbacks {
    _callbacks = [callbacks retain];
}
- (void)call:(NSString *)key {
    id ob = [_callbacks objectForKey:key];
    [ob msg];
}
@end

#pragma mark -
@interface AsyncActionTests : SenTestCase {	
} @end
@implementation AsyncActionTests
int count1 = 0;
int count2 = 0;
- (void)_callback1 {
    count1++;
}
- (void)_callback2 {
    count2++;
}
- (void)testAsyAction {
    
    CallbackProxy *cp1 = [[[CallbackProxy alloc] init] autorelease];
    [cp1 setup:self :[NSThread currentThread] :@selector(_callback1)];

    CallbackProxy *cp2 = [[[CallbackProxy alloc] init] autorelease];
    [cp2 setup:self :[NSThread currentThread] :@selector(_callback2)];
    
    NSDictionary *callbacks = [NSDictionary dictionaryWithObjectsAndKeys:cp1, @"doit1", cp2, @"doit2", nil];
    
    AsyncAction *action = [[[AsyncAction alloc] init] autorelease];
    [action setCallbacks:callbacks];
    
    [action call:@"doit1"];
    [action call:@"doit2"];

    STAssertTrue( count1==1, nil );
    STAssertTrue( count2==1, nil );
}
@end

#pragma mark -
@interface RepeatingAsyncTaskController : NSObject {
    AsyncAction *_task;
}
- (void)setTask:(AsyncAction *)tsk;
- (void)go;
- (void)waitUntillComplete;
@end
@implementation RepeatingAsyncTaskController

- (void)setTask:(AsyncAction *)tsk {
    _task = [tsk retain];
}

/* these are called on the original thread */
- (void)taskDidComplete {
}
- (void)taskDidError {
}
- (void)taskIsWaiting {
    [_task call:@"step"];
}

- (void)go {
    
}
- (void)waitUntillComplete {
    
}
@end

#pragma mark -
@interface RepeatingAsyncOperationTests : SenTestCase {	
} @end
@implementation RepeatingAsyncOperationTests

- (void)testRepeatingAsyncObject {
    //    action = new ASyncAction( instrStepper. step:&address )
    //    instrStepper.callback = action.asyncActionCompleted;        // what thread?
    
    RepeatingAsyncTaskController *repeatingOp = [[RepeatingAsyncTaskController alloc] init];
    repeatingOp.action = 
    repeatingOp.howDoWeKnowWhenFinished?
    [repeatingOp go];
    
    -- how do we test that it executes three times then action signals that it is complete
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


@interface StandinForStepper : SenTestCase {
@public
    int count;
} @end
@implementation StandinForStepper
- (void)fakeStep:(AsyncAction *)thisTask {
    [NSThread detachNewThreadSelector: @selector(fakeCatch:) toTarget:self withObject:thisTask];       
}
- (void)fakeCatch:(AsyncAction *)thisTask {
    [NSThread sleepForTimeInterval:0.5];
    count++;
    if(count==3)
        [thisTask call:@"noMoreCallback"];
    else
        [thisTask call:@"stoppedCallback"];
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
    
    CallbackProxy *callback = [[CallbackProxy alloc] init];
    [callback setup:self :[NSThread currentThread] :@selector(fakeCallback)];
    
    [NSThread detachNewThreadSelector: @selector(aTestThreadMain) toTarget:self withObject:callback];
    
    //--oops, crash
    [callback release];
}

- (void)fakeCallback {

}
- (void)fakeExceptionThread:(CallbackProxy *)callback {
    
    [callback msg];
}





- (void)testUnknownStuff {

//    id codeDataBlock1 = [[ContiguousMemoryBlockStore alloc] initWithRawData:simpleAppData start:(char *)0 length:11];
    
//    TPDissembler *dissasembler = [[TPDissembler alloc] init];
    
//    int address;
//    TPinstructionStepper *instrStepper = [[TPinstructionStepper alloc] init];
//        exception_thread = new thread( callbackObject )
//        startTarget()
//        -- you need to give it the address of the first instruction - we use a hardware breakpont to stop
//        -- wait for 1st eception to be thrown when app starts - before first instr ?
//        -- clear hardware breakpt
//        -- really we should check dr6 that the breakpoint was matched

    StandinForStepper *stepperStandin = [[StandinForStepper alloc] init];
    
    RepeatingAsyncTaskController *repeatingAsyncTaskController = [[RepeatingAsyncTaskController alloc] init];
    
    // Ensure that these are called on the desired thread
    CallbackProxy *stepMsg = [[[CallbackProxy alloc] init] autorelease];
    [stepMsg setup:stepperStandin :[NSThread currentThread] :@selector(fakeStep)];
    
    CallbackProxy *noMoreCallback = [[[CallbackProxy alloc] init] autorelease];
    [noMoreCallback setup:repeatingAsyncTaskController :[NSThread currentThread] :@selector(taskDidComplete)];
    
    CallbackProxy *errorCallback = [[[CallbackProxy alloc] init] autorelease];
    [errorCallback setup:repeatingAsyncTaskController :[NSThread currentThread] :@selector(taskDidError)];
    
    CallbackProxy *stoppedCallback = [[[CallbackProxy alloc] init] autorelease];
    [stoppedCallback setup:repeatingAsyncTaskController :[NSThread currentThread] :@selector(taskIsWaiting)];
    
    AsyncAction *asyncTask = [[[AsyncAction alloc] init] autorelease];
    NSDictionary *callbacks = [NSDictionary dictionaryWithObjectsAndKeys:stepMsg, @"step", 
                                                                        noMoreCallback, @"noMoreCallback",
                                                                        errorCallback, @"errorCallback", 
                                                                        stoppedCallback, @"stoppedCallback", 
                                                                        nil];
    [asyncTask setCallbacks:callbacks];
    
    [repeatingAsyncTaskController setTask:asyncTask];
    [repeatingAsyncTaskController go];
    
    [repeatingAsyncTaskController waitUntillComplete];
    
    STAssertTrue( stepperStandin->count == 3, nil );
    

    

//        }
        
//    }
 
//    [instrStepper release];
//    [codeDataBlock1 release];
//    [dissasembler release];
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
