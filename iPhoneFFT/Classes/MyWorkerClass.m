//
//  MyWorkerClass.m
//  iPhoneFFT
//
//  Created by Steven Hooley on 05/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "MyWorkerClass.h"
#import "NSPortMessage.h"

#define kCheckinMessage 100

@implementation MyWorkerClass

// Handle Messages from the main thread
- (void)handlePortMessage:(NSPortMessage *)portMessage {
	
    unsigned int message = [(id)portMessage msgid];
    NSPort *distantPort = nil;
	
//    if (message == kCheckinMessage)
//    {
//        // Get the worker thread’s communications port.
//        distantPort = [portMessage sendPort];
//		
//        // Retain and save the worker port for later use.
//        [self storeDistantPort:distantPort];
//    }
//    else
//    {
//        // Handle other messages.
//    }
}

// Worker thread check-in method
- (void)sendCheckinMessage:(NSPort *)outPort {
	
    // Retain and save the remote port for future use.
    _remotePort = [outPort retain];
	
    // Create and configure the worker thread port.
    NSPort *myPort = [NSMachPort port];
    [myPort setDelegate:self];
    [[NSRunLoop currentRunLoop] addPort:myPort forMode:NSDefaultRunLoopMode];
	
    // Create the check-in message.
    NSPortMessage *messageObj = [[NSPortMessage alloc] initWithSendPort:outPort receivePort:myPort components:nil];
	
    if(messageObj)
    {
        // Finish configuring the message and send it immediately.
        [messageObj setMsgid:kCheckinMessage];
        [messageObj sendBeforeDate:[NSDate date]];
    }
}

@end
