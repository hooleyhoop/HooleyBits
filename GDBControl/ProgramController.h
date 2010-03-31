//
//  ProgramController.h
//  GDBControl
//
//  Created by Steven Hooley on 06/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ProgramController : NSObject {

	NSTask *gdbTask;
	NSPipe *outputPipe, *inputPipe;
	NSFileHandle *taskOutput, *taskInput;
}

@end
