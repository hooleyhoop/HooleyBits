//
//  Debugger.mm
//  SimpleFileParser
//
//  Created by Steven Hooley on 17/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "SHDebugger.h"


@implementation SHDebugger

- (BOOL)handleIOEvent:(lldb::SBEvent)event {
	
    const uint32_t event_type = event.GetType();
	const char *command_string = lldb::SBEvent::GetCStringFromEvent(event);
	if (command_string == NULL)
		command_string = "";
	
	// -- get current line 
    lldb::SBTarget target = m_debugger->GetCurrentTarget();
    lldb::SBProcess process = target.GetProcess();
		
	lldb::StateType state = process.GetState();
	if( state==lldb::eStateStopped ) {
		
		char hmmm[255];
		process.GetSTDOUT (hmmm, 255);

		lldb::SBThread thread1 = process.GetThreadAtIndex(0);
		m_debugger->HandleCommand ("step");    
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


-- sample from this list 

lldb::SBDebugger debugger = lldb::SBDebugger::Create();
lldb::SBTarget target = debugger.CreateTarget(fileName);
lldb::SBProcess process = target.CreateProcess();
lldb::SBError error = process.Attach(pid):
print error.GetCString()  --> "invalid state after attach: Exited"

- (void)goforit {

	// std::String blah; // who new that in c++ this gives you an initialized c++ object
	
	lldb::SBDebugger::Initialize();
	lldb::SBHostOS::ThreadCreated ("[main]");

	::setbuf (stdin, NULL);
	::setbuf (stdout, NULL);

	lldb::SBDebugger m_debugger2 (lldb::SBDebugger::Create());

	m_debugger = &m_debugger2;

	m_debugger->SetAsync(false);

	m_debugger->SetErrorFileHandle( stderr, false );
	m_debugger->SetOutputFileHandle( stdout, false );
	m_debugger->SetInputFileHandle( stdin, true );

	lldb::SBCommunication master_out_comm("driver.editline");

	lldb::SBCommandInterpreter sb_interpreter = m_debugger->GetCommandInterpreter();
	lldb::SBTarget target = m_debugger->CreateTargetWithFileAndArch("/Applications/6-386.app", "i386");
 	bool flag1 = target.IsValid();
	NSAssert( flag1, @"oops - target failed");
	
	lldb::SBListener listener( m_debugger->GetListener() );

	lldb::SBEvent event;
	
//	lldb::SBProcess process = target.CreateProcess();
// 	bool flag2 = process.IsValid();
//	NSAssert( flag2, @"oops - process failed");
	
	lldb::SBBreakpoint bp1 = target.BreakpointCreateByName( "start", NULL );
	
	lldb::SBCommandReturnObject result;
	m_debugger->GetCommandInterpreter().HandleCommand ("process launch", result, false);
	result.PutOutput(stdout);
	
//	listener.WaitForEvent (UINT32_MAX, event);
	m_debugger->HandleCommand("process status");

//	listener.WaitForEvent (UINT32_MAX, event);
	m_debugger->HandleCommand("process status");
	
	lldb::SBTarget currentTarget = m_debugger->GetCurrentTarget();
	NSAssert( currentTarget==target, @"oops - what going on?");

	lldb::SBProcess currentProcess = currentTarget.GetProcess();
	bool flag2 = currentProcess.IsValid();
	NSAssert( flag2, @"oops - process failed");
	
    uint32_t threadCount = currentProcess.GetNumThreads();
	
	// Need Python!
	// getFrameAtIndex(0).getFunction().getName()
	
	//	lldb::StateType state = currentProcess.GetState();
//	while(state < lldb::eStateStopped) {
//		state = currentProcess.GetState();
//	}

	lldb::SBThread currentThread = currentProcess.GetThreadAtIndex(0);

//	NSAssert( currentProcess.SetCurrentThread( currentThread ), @"doh! no current thread");
	
	/* GUESSING WE ARE STOPPED */

	// lets try deleting a bp
	m_debugger->HandleCommand( [[NSString stringWithFormat:@"breakpoint delete %i", bp1.GetID()] cString] );
	
	// try breaking at he crash point 	- crashes on 2b2c
	lldb::addr_t crashAddress = 0x2b2c;
//	for( NSUInteger i=0; i<40000;i++){
//		lldb::SBBreakpoint bp2 = target.BreakpointCreateByAddress( crashAddress+i );
//	}
	
	
	while ( true ) {

		lldb::SBThread threadCheck = currentProcess.GetCurrentThread();
		if( threadCheck.IsValid()==false ) {
			currentThread = currentProcess.GetThreadAtIndex(0);
			NSAssert( currentProcess.SetCurrentThread( currentThread ), @"doh! no current thread");
		}
		NSAssert( currentThread.IsValid(), @"why does current thread become invald?" );
		
		// Start running the process
		m_debugger->GetCommandInterpreter().HandleCommand ("continue", result, false);
		result.PutOutput(stdout);
		
		// Loop until we stop
		while ( currentProcess.GetState() != lldb::eStateStopped ) {
			listener.WaitForEvent (UINT32_MAX, event);
			m_debugger->HandleCommand("process status");
		}
//		m_debugger->HandleCommand("process status");


		threadCheck = currentProcess.GetCurrentThread();
		if( threadCheck.IsValid()==false ) {
			currentThread = currentProcess.GetThreadAtIndex(0);
			NSAssert( currentProcess.SetCurrentThread( currentThread ), @"doh! no current thread");
		}
		NSAssert( currentThread.IsValid(), @"why does current thread become invald?" );
		
		//currentThread.StepInto( lldb::eOnlyDuringStepping );
	//	currentThread.StepInstruction(false);
//		try {
//			m_debugger->GetCommandInterpreter().HandleCommand ("thread step-inst --avoid_no_debug=false --run_mode=thisThread", result, false);
//			result.PutOutput(stdout);
//			sleep(0.33f);
//			
//			// Loop until we stop
//			while ( currentProcess.GetState() != lldb::eStateStopped ) {
//				listener.WaitForEvent (UINT32_MAX, event);
////				m_debugger->HandleCommand("process status");
//			}
////			m_debugger->HandleCommand("process status");
//			
//			
//		} catch (NSException *exception) {
//			NSLog(@"woops");
//		}
				
		threadCount = currentProcess.GetNumThreads();
	//	currentThread.StepOver();
	//	currentThread.Backtrace (1);

//		uint32_t frameCount = currentThread.GetNumFrames();		
				
		lldb::SBFrame sf = currentThread.GetFrameAtIndex(0);
		lldb::SBAddress addRess1 = sf.GetPCAddress();
		
//		NSString *disassembleInstruction = [NSString stringWithFormat:@"disassemble --start-address=%x  --end-address=%x --context=1", addRess1.GetFileAddress(), addRess1.GetFileAddress() ];
//		m_debugger->HandleCommand([disassembleInstruction cString]);
		
		lldb::SBFunction currentFunction = sf.GetFunction();
		if(currentFunction.IsValid())
		{
			const char * fnName = currentFunction.GetName();
			NSLog(@"FUNCTION! %s", fnName);
		}
		
		lldb::SBModule module = sf.GetModule ();
		if(module.IsValid())
		{
			lldb::SBFileSpec fs = module.GetFileSpec();
			const char * fn = fs.GetFileName();
			if( strcmp("Sibelius 6", fn )==0 )
			{
				NSLog(@"Sibelius %x", addRess1.GetFileAddress() );
			} else {
				NSLog(@"%s %x", fn, addRess1.GetFileAddress() );
			}

// TODO: -- is the current line a crasher?
//			
			
			
//			lldb::SBLineEntry who = sf.GetLineEntry ();
//			lldb::SBAddress address = who.GetStartAddress();
//			lldb::addr_t hexVal = address.GetFileAddress ();
//			
//	//		const char *woo = sf.Disassemble ();
//
//			NSLog(@"Step %x", hexVal);
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
