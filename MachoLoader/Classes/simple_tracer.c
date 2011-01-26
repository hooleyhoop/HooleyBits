/* Code sample: using ptrace for simple tracing of a child process.
**
** Eli Bendersky (http://eli.thegreenplace.net)
** This code is in the public domain.
*/
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <signal.h>
//#include <syscall.h>
#include <sys/types.h>
#include <sys/ptrace.h>
#include <sys/wait.h>
//#include <sys/reg.h>
#include <sys/user.h>
#include <unistd.h>
#include <errno.h>


/* Print a message to stdout, prefixed by the process ID
*/
void procmsg( const char* format, ... ) {
	
    va_list ap;
    fprintf(stdout, "[%d] ", getpid());
    va_start(ap, format);
    vfprintf( stdout, format, ap );
    va_end(ap);
}


void run_target( const char *programname ) {
	
	procmsg( "target started. will run '%s'\n", programname );

 //   setsid(); // lldb
    
    /* Allow tracing of this process */
    if( ptrace(PT_TRACE_ME, 0, 0, 0) < 0) {
        perror("ptrace");
        return;
    }
    ptrace (PT_SIGEXC, 0, 0, 0);    // lldb // Get BSD signals as mach exceptions
 //   setgid (getgid ());           // lldb
 //   setpgid (0, 0);               // lldb Set the child process group to match its pid
    sleep (1);                    // lldb
    
    /* Replace this process's image with the given program */
	execl( programname, programname, NULL ); // -- THis should never return? 
}


void run_debugger( pid_t child_pid ) {
    
    int wait_status;
    unsigned icounter = 0;
    procmsg("debugger started\n");

    /* Wait for child to stop on its first instruction */
    wait( &wait_status );

    while( WIFSTOPPED(wait_status) ) {
        icounter++;
//jiggy	struct user_regs_struct regs;
//jiggy        ptrace(PTRACE_GETREGS, child_pid, 0, &regs);
	
	// alternative way
//alt	thread_act_port_array_t thread_list;
//alt	mach_msg_type_number_t thread_count;
//alt	task_threads( port, &amp;thread_list, &amp;thread_count );
//alt	thread_get_state() i396_thread_state_t
//alt	printf(&quot; lr: 0x%x\n&quot;,ppc_state.lr);

//jiggy        unsigned instr = ptrace(PTRACE_PEEKTEXT, child_pid, regs.eip, 0);
 
       // procmsg("icounter = %u.  EIP = 0x%08x.  instr = 0x%08x\n", icounter, regs.eip, instr);
        procmsg("icounter = %u. \n", icounter);

        /* Make the child execute another instruction */
        if (ptrace(PT_STEP, child_pid, 0, 0) < 0) {
            perror("ptrace");
            return;
        }

        /* Wait for child to stop on its next instruction */
        wait( &wait_status );
    }

    procmsg("the child executed %u instructions\n", icounter);
}


int simple_tracer( const char *programname ) {
	
    pid_t child_pid = vfork();
    if( child_pid<0 ) {
        // fork failed
    } else if ( child_pid==0 ) {
        // child process
        run_target(programname);
    } else if (child_pid > 0)
        // parent process
        run_debugger( child_pid );
    else {
        perror("fork");
        return -1;
    }

    return 0;
}
