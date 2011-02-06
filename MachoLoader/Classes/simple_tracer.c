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
#include <spawn.h>
#include <string.h>
#include <crt_externs.h>
#include <Security/Authorization.h>
#include <mach/mach_traps.h>
#include <mach/mach_init.h>

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

    /* Make sure the task gets default signal setup.
     */
    for( int i=0; i<32; i++ ) {
        signal( i, SIG_DFL );
	}
    
 //   setsid(); // lldb
    
    /* Allow tracing of this process */
    if( ptrace(PT_TRACE_ME, 0, 0, 0) < 0) {
        perror("ptrace");
        return;
    }
    ptrace (PT_SIGEXC, 0, 0, 0);    // lldb // Get BSD signals as mach exceptions
    setgid (getgid ());           // lldb
    setpgid (0, 0);               // lldb Set the child process group to match its pid
    
    int pid = (int)getpid();
   // setpgid(pid, pid);              // Thimk this doesnt do much
    procmsg("pid = %u. \n", pid);

    sleep (1);                    // lldb
    
    /* Replace this process's image with the given program */
	int result = execl( programname, programname, NULL ); // -- THis should never return?
    procmsg("Whoops, execl returned  = %u. \n", result);
    
   // execve(executable, (char**)args, (char**)envl);

}

// -(void)waitUntilExit {
//    while(isRunning)
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode 
//                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
// }

void run_debugger( pid_t child_pid ) {
    
    
    int wait_status;
    unsigned icounter = 0;
    procmsg("debugger started\n");

    // we need to be authorized to do this
    mach_port_name_t port = TASK_NULL;
	int result = task_for_pid( mach_task_self(), child_pid, &port);
    
    /* Wait for child to stop on its first instruction */
    wait( &wait_status );

    while( WIFSTOPPED(wait_status) ) 
    {
        icounter++;
        printf("waiting");
//jiggy	struct user_regs_struct regs;
//jiggy        ptrace(PTRACE_GETREGS, child_pid, 0, &regs);
	
	// alternative way
	thread_act_port_array_t thread_list;
	mach_msg_type_number_t thread_count;
    task_threads(port, &thread_list, &thread_count);
//alt	thread_get_state() i396_thread_state_t
//alt	printf(&quot; lr: 0x%x\n&quot;,ppc_state.lr);

//jiggy        unsigned instr = ptrace(PTRACE_PEEKTEXT, child_pid, regs.eip, 0);
 
       // procmsg("icounter = %u.  EIP = 0x%08x.  instr = 0x%08x\n", icounter, regs.eip, instr);
        procmsg("icounter = %u. \n", icounter);

        /* Make the child execute another instruction */
        if( ptrace(PT_STEP, child_pid, 0, 0) < 0) {
            perror("ptrace");
            return;
        }

        /* Wait for child to stop on its next instruction */
        wait( &wait_status );
    }

    procmsg("the child executed %u instructions\n", icounter);
}

static cpu_type_t preferredArchitecture()
{
#if defined(__ppc__)
    return CPU_TYPE_POWERPC;
#elif defined(__LP64__)
    return CPU_TYPE_X86_64;
#else
    return CPU_TYPE_X86;
#endif
}

int acquireTaskportRight() {
    OSStatus status;
    AuthorizationItem taskport_item[] = {{"system.privilege.taskport"}};
    AuthorizationRights rights = {1, taskport_item}, *out_rights = NULL;
    AuthorizationRef author;
    AuthorizationFlags authorizationFlags = kAuthorizationFlagExtendRights
    
    | kAuthorizationFlagPreAuthorize
    | kAuthorizationFlagInteractionAllowed
    | (1 << 5);
    
    status = AuthorizationCreate(NULL,
                                 kAuthorizationEmptyEnvironment,
                                 authorizationFlags,
                                 &author);
    if (status != errAuthorizationSuccess) {
        return 0;
    }
    
    status = AuthorizationCopyRights(author,
                                     &rights,
                                     kAuthorizationEmptyEnvironment,
                                     authorizationFlags,
                                     &out_rights);
    if (status != errAuthorizationSuccess) {
        return 1;
    }
    
    return 0;
}

#define _POSIX_SPAWN_DISABLE_ASLR       0x0100

// Remember to codesign like lldb (use the lldb certificate)
// http://michael.bebenita.com/imported-20100930232226/2010/8/12/debugging-on-snow-leopard-getting-task_for_pid-to-work.html

// http://rgaucher.info/planet/Matasano_Chargen/2008/07/17/What_I’ve_Been_Doing_On_My_Summer_Vacation_or__“It_has_to_work__Otherwise_gdb_wouldn’t”

//http://www.opensource.apple.com/source/gdb/gdb-1128/src/gdb/macosx/macosx-nat-inferior.c
int simple_tracer( const char *programname ) {
	    
    acquireTaskportRight();
    
    char **argv = (char **)calloc(sizeof(char *), 8 + 1);
    char **env = (char **)calloc(sizeof(char *), 8 + 1);
    
    argv[0] = programname;

    char const *envp[0];
   	char*** envPtr = _NSGetEnviron();
	char** environ = *envPtr;
    
    posix_spawnattr_t attr;
    pid_t result = posix_spawnattr_init( &attr );
    cpu_type_t architecturePreference[] = { preferredArchitecture(), CPU_TYPE_X86 };
    posix_spawnattr_setbinpref_np(&attr, 2, architecturePreference, 0);
    
    result = ptrace(PT_TRACE_ME, getpid(), NULL, 0);
    
    short flags = 0;
    //flags |= POSIX_SPAWN_SETEXEC; // this makes it act like execve, ie not return
    flags |= POSIX_SPAWN_START_SUSPENDED;
    flags |= _POSIX_SPAWN_DISABLE_ASLR;
    
    result = posix_spawnattr_setflags( &attr, flags );
    
    //const char *working_dir = "/";
    //chdir( working_dir );
    
    pid_t child_pid=1;
   // pid_t result = posix_spawn( &child_pid, spawnedArgs[0], NULL, &attr, spawnedArgs, environ );
    result = posix_spawn( &child_pid, argv[0], NULL, &attr, argv, environ );

    if(result!=0) {
        fprintf( stderr, "ERROR %s", strerror(result) );
        return 1;
    }
    
    result = ptrace(PT_TRACE_ME, child_pid, NULL, 0);
    
    posix_spawnattr_destroy (&attr);

    //TODO: vfork or fork?
    // Suggest getting it to work with fork first
    // child_pid = fork();
    if( child_pid<0 ) {

        // fork failed
        procmsg( "FAILED TO CREATE CHILD \n" );
        
    } else if ( child_pid==0 ) {
        
        // child process
        procmsg( "CHILD!!! \n" );        
        sleep(1000);
        run_target( programname );
        
    } else if (child_pid > 0) {

        // parent process
        procmsg( "PARENT!!! \n" );        

        result = ptrace(PT_SIGEXC, child_pid, 0, 0);    // lldb // Get BSD signals as mach exceptions

        procmsg( "Child pid is = %u. \n", child_pid );
  //      setpgid( child_pid, child_pid );
        int err = ptrace( PT_ATTACHEXC, child_pid, 0, 0 );
        if( err==0 ) {
            printf( "successfully attached to pid %d", child_pid );
        } else {
            printf( "error: failed to attach to pid %d", child_pid );
        }
            
        run_debugger( child_pid );
    } else {
        perror("fork");
        return -1;
    }

    return 0;
}
