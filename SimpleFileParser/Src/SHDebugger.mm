//
//  Debugger.mm
//  SimpleFileParser
//
//  Created by Steven Hooley on 17/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "SHDebugger.h"
#import <LLDB/LLDB.h>


@implementation SHDebugger

- (BOOL)handleIOEvent:(lldb::SBEvent)event {
	
    const uint32_t event_type = event.GetType();
	const char *command_string = lldb::SBEvent::GetCStringFromEvent(event);
	if (command_string == NULL)
		command_string == "";
	
	// -- get current line 
    lldb::SBTarget target = lldb::SBDebugger::GetCurrentTarget();
    lldb::SBProcess process = target.GetProcess();
		
	lldb::StateType state = process.GetState();
	if( state==lldb::eStateStopped ) {
		
		char hmmm[255];
		process.GetSTDOUT (hmmm, 255);

		lldb::SBThread thread1 = process.GetThreadAtIndex(0);
		lldb::SBDebugger::HandleCommand ("step");    
	}
	
	return NO;
}

int	stdoutwrite(void *inFD, const char *buffer, int size) {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]	;
	NSString *tmp = [NSString stringWithCString:buffer length:size]	;	// choose the best encoding for your app
	NSLog(@"%@", tmp);
	// do what you need with the tmp string here
	// like appending it to a NSTextView
	// you may like to scan for a char(12) == CLEARSCREEN
	// and others "special" characters...
	
	[pool release];
	return size;
}

- (void)goforit {

	::setbuf (stdin, NULL);
	::setbuf (stdout, NULL);
	
	lldb::SBDebugger::SetErrorFileHandle( stderr, false );
	lldb::SBDebugger::SetOutputFileHandle( stdout, false );
	lldb::SBDebugger::SetInputFileHandle( stdin, true );

	lldb::SBCommunication master_out_comm("driver.editline");

	lldb::SBDebugger::Initialize();
	lldb::SBHostOS::ThreadCreated ("[main]");
	lldb::SBDebugger::SetAsync(false);

	lldb::SBCommandInterpreter sb_interpreter = lldb::SBDebugger::GetCommandInterpreter();
	lldb::SBTarget target = lldb::SBDebugger::CreateTargetWithFileAndArch("/Applications/6-386.app", "i386");
 	bool flag1 = target.IsValid();
	NSAssert( flag1, @"oops - target failed");
	
//	lldb::SBProcess process = target.CreateProcess();
// 	bool flag2 = process.IsValid();
//	NSAssert( flag2, @"oops - process failed");
	
	lldb::SBBreakpoint bp1 = target.BreakpointCreateByName( "start", NULL );	
	lldb::SBDebugger::HandleCommand ("process launch");
	
    lldb::SBTarget currentTarget = lldb::SBDebugger::GetCurrentTarget();
	NSAssert( currentTarget==target, @"oops - what going on?");

	lldb::SBProcess currentProcess = currentTarget.GetProcess();
	bool flag2 = currentProcess.IsValid();
	NSAssert( flag2, @"oops - process failed");
	
    uint32_t threadCount = currentProcess.GetNumThreads();
	
	//	lldb::StateType state = currentProcess.GetState();
//	while(state < lldb::eStateStopped) {
//		state = currentProcess.GetState();
//	}

    lldb::SBThread currentThread = currentProcess.GetThreadAtIndex(0);
	while ( currentThread.IsValid() ) {
		//currentThread.StepInto( lldb::eOnlyDuringStepping );
		currentThread.StepInstruction(true);
	//	currentThread.StepOver();
	//	currentThread.Backtrace (1);
		
		uint32_t frameCount = currentThread.GetNumFrames();		
		lldb::SBFrame sf = currentThread.GetFrameAtIndex(0);
		
		lldb::SBModule module = sf.GetModule ();
		if(module.IsValid())
		{
			lldb::SBFileSpec fs = module.GetFileSpec();
			const char * fn = fs.GetFileName();
			if( strcmp("Sibelius 6", fn )==0 )
			{
				NSLog(@"woo");
			} else {
				NSLog(@"Boooooo");
			}

			lldb::SBLineEntry who = sf.GetLineEntry ();
			lldb::SBAddress address = who.GetStartAddress();
			lldb::addr_t hexVal = address.GetFileAddress ();
			
	//		const char *woo = sf.Disassemble ();

			NSLog(@"Step %x", hexVal);
		}
	}
	
	
//	lldb::SBThread mainThread = currentProcess.GetThreadAtIndex(0);
//	bool flag3 = mainThread.IsValid();
//
//	lldb::addr_t startAddress = 0x00002ac0;
//    mainThread.RunToAddress( startAddress );

//	lldb::StopReason sr = mainThread.GetStopReason();

//	lldb::SBDebugger::HandleCommand ("file --arch=i386 '/Applications/6-386.app'");
//	lldb::SBDebugger::HandleCommand ("breakpoint set --name=start");
//	char hmmm[255];
//	currentProcess.GetSTDOUT (hmmm, 255);	

	lldb::SBListener listener(lldb::SBDebugger::GetListener());
//    if (listener.IsValid())
//    {
//		lldb::SBEvent event;
//		bool done = false;
//		
//		int	(*realStdOut)(void *, const char *, int) = stdout->_write;
//
//		while (!done)
//		{
//			// Hijack stdout
//			stdout->_write = stdoutwrite;
//
//			listener.WaitForEvent (UINT32_MAX, event);
//			
//			stdout->_write = realStdOut;
//
//			if (event.IsValid())
//			{
//
//				if (event.GetBroadcaster().IsValid())
//				{
//					uint32_t event_type = event.GetType();
//					done = [self handleIOEvent:event];
//				}
//			}
//		}
//	}
}


@end
