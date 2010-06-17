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

+ (BOOL)handleIOEvent:(lldb::SBEvent)event {
	
    const uint32_t event_type = event.GetType();
	const char *command_string = lldb::SBEvent::GetCStringFromEvent(event);
	if (command_string == NULL)
		command_string == "";
	return NO;
}

+ (void)goforit {

	lldb::SBDebugger::Initialize();
	lldb::SBHostOS::ThreadCreated ("[main]");
	lldb::SBDebugger::SetAsync(false);
	
    ::setbuf (stdin, NULL);
    ::setbuf (stdout, NULL);
	
	lldb::SBDebugger::SetErrorFileHandle (stderr, false);
	lldb::SBDebugger::SetOutputFileHandle (stdout, false);
	lldb::SBDebugger::SetInputFileHandle (stdin, true);
	
	lldb::SBCommandInterpreter sb_interpreter = lldb::SBDebugger::GetCommandInterpreter();
	lldb::SBTarget target = lldb::SBDebugger::CreateTargetWithFileAndArch("/Applications/6-386.app", "i386");
	lldb::SBProcess proc = target.CreateProcess ();
    lldb::SBBreakpoint bp1 = target.BreakpointCreateByName ("start", NULL);
	
	lldb::SBDebugger::HandleCommand ("breakpoint set --name=start");    
	lldb::SBDebugger::HandleCommand ("process launch"); 

	while (true) {
		sleep(1);
	}
	
//	proc.Launch( char const *argv[], char const *envp[],  const char *stdin_path, const char *stdout_path, const char *stderr_path );	
//	
//	lldb::SBError err = proc.Continue();
	

	
	lldb::SBCommunication master_out_comm("driver.editline");

	

//	lldb::SBDebugger::HandleCommand ("file --arch=i386 '/Applications/6-386.app'");
//	lldb::SBDebugger::HandleCommand ("breakpoint set --name=start");    
//	lldb::SBDebugger::HandleCommand ("process launch"); 
	
//	CommandObjectBreakpointSet::Execute


	
    lldb::SBListener listener(lldb::SBDebugger::GetListener());
    if (listener.IsValid())
    {
		lldb::SBEvent event;
		bool done = false;
		while (!done)
		{
			listener.WaitForEvent (UINT32_MAX, event);
			if (event.IsValid())
			{
				if (event.GetBroadcaster().IsValid())
				{
					uint32_t event_type = event.GetType();
					done = [self handleIOEvent:event];
				}
			}
		}
	}
}


@end
