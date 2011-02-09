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
#include <mach/task.h>
#include <mach/thread_act.h>
#include <mach/mach_error.h>
#include <assert.h>

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
    mach_port_name_t childTaskPort = TASK_NULL;

	int result = task_for_pid( mach_task_self(), child_pid, &childTaskPort);
    if( result!=KERN_SUCCESS ) {
        printf( "task_for_pid() failed with message %s!\n", (char *)mach_error_string(result) );
        exit(0);
    }
    //   int err = task_resume(childTaskPort);
    //int err = task_suspend(childTaskPort);
    while(true)
    {
        // alternative way for ptrace(PTRACE_GETREGS, child_pid, 0, &regs);	
        thread_act_port_array_t thread_list;
        mach_msg_type_number_t thread_count;
        result = task_threads( childTaskPort, &thread_list, &thread_count);
        if( result!=KERN_SUCCESS ) {
            printf( "task_threads() failed with message %s!\n", mach_error_string(result) );
            exit(0);
        }
        x86_thread_state32_t thread_state;
        mach_msg_type_number_t stateCount = x86_THREAD_STATE32_COUNT;
        long thread = 0;	// for first thread
        result = thread_get_state( thread_list[thread], x86_THREAD_STATE32, (thread_state_t)&thread_state, &stateCount );
        if( result!=KERN_SUCCESS ) {
            printf( "thread_get_state() failed with message %s!\n", mach_error_string(result) );
            exit(0);
        }
        
        printf( "EIP: %u\nEAX: %u\nEBX: %u\nECX: %u\nEDX: %u\nSS: %u\n", thread_state.__eip, thread_state.__eax, thread_state.__ebx, thread_state.__ecx, thread_state.__edx, thread_state.__ss );

        
        /* Wait for child to stop on its first instruction */
        wait( &wait_status );
    }

    // what happens if we stop the while loop from exiting?
    while( WIFSTOPPED(wait_status) ) 
    {
        icounter++;
        printf("waiting");
        

        
        //alt	printf( " lr: 0x%x\n",ppc_state.lr);

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
#define	O_NOCTTY	0x20000		/* don't assign controlling terminal */

/* open-only flags */
#define	O_RDONLY	0x0000		/* open for reading only */
#define	O_WRONLY	0x0001		/* open for writing only */
#define	O_RDWR		0x0002		/* open for reading and writing */
#define	O_ACCMODE	0x0003		/* mask for above modes */
#define _POSIX_SPAWN_DISABLE_ASLR       0x0100
#define	POSIX_SPAWN_SETEXEC		0x0040
#define	POSIX_SPAWN_START_SUSPENDED	0x0080
#define	POSIX_SPAWN_SETSIGMASK		0x0008	/* [SPN] set signal mask */

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
    cpu_type_t architecturePreference[] = { preferredArchitecture(), CPU_TYPE_X86 }; // 7
    posix_spawnattr_setbinpref_np(&attr, 2, architecturePreference, 0);
    
    
    posix_spawn_file_actions_t file_actions;
    posix_spawn_file_actions_init (&file_actions);
    posix_spawn_file_actions_addclose (&file_actions, STDIN_FILENO);
    posix_spawn_file_actions_addclose (&file_actions, STDOUT_FILENO);
    posix_spawn_file_actions_addclose (&file_actions, STDERR_FILENO);
    posix_spawn_file_actions_addopen (&file_actions, STDIN_FILENO, "/dev/null", O_RDONLY | O_NOCTTY, 0);
    posix_spawn_file_actions_addopen (&file_actions, STDOUT_FILENO, "/dev/null",  O_WRONLY | O_NOCTTY, 0);
    posix_spawn_file_actions_addopen (&file_actions, STDERR_FILENO, "/dev/null", O_RDWR | O_NOCTTY, 0);
    
    result = ptrace(PT_TRACE_ME, getpid(), NULL, 0);
    
    // DYLD_NO_PIE
    
    short flags = 0;
//    uint32_t launch_flags = eLaunchFlagNone;
//    launch_flags |= eLaunchFlagDisableASLR;

    // http://www.google.com/codesearch/p?hl=en#OAMlx_jo-ck/src/third_party/WebKit/Source/WebKit2/UIProcess/Launcher/mac/ProcessLauncherMac.mm&q=POSIX_SPAWN_START_SUSPENDED&sa=N&cd=3&ct=rc
    
    // We want our process to receive all signals.
    sigset_t signalMaskSet;
    sigemptyset(&signalMaskSet);
    posix_spawnattr_setsigmask(&attr, &signalMaskSet);
    flags |= POSIX_SPAWN_SETSIGMASK;
   // flags |= POSIX_SPAWN_SETEXEC; // this makes it act like execve, ie not return
    flags |= POSIX_SPAWN_START_SUSPENDED;
    flags |= _POSIX_SPAWN_DISABLE_ASLR;
    
    result = posix_spawnattr_setflags( &attr, flags );
    
    static int debug_setpgrp = 657473;
    result = posix_spawnattr_setpgroup (&attr, debug_setpgrp);
    assert(result == 0);
    
    //const char *working_dir = "/";
    //chdir( working_dir );
    
    pid_t child_pid=1;
   // pid_t result = posix_spawn( &child_pid, spawnedArgs[0], NULL, &attr, spawnedArgs, environ );
    result = posix_spawnp( &child_pid, argv[0], &file_actions, &attr, argv, environ );
    char pid_str[32];    
    snprintf (pid_str, 31, "%d", child_pid);

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
 //min       procmsg( "FAILED TO CREATE CHILD \n" );
        
    } else if ( child_pid==0 ) {
        
        // child process
 //min       procmsg( "CHILD!!! \n" );        
//min        run_target( programname );
        
    } else if (child_pid > 0) {

        // parent process
        procmsg( "PARENT!!! \n" );        

        result = ptrace( PT_SIGEXC, child_pid, 0, 0 );    // lldb // Get BSD signals as mach exceptions

        procmsg( "Child pid is = %u. \n", child_pid );
        setpgid( child_pid, child_pid );
        
    int err = ptrace( PT_ATTACHEXC, child_pid, 0, 0 );
//min        kill( child_pid, SIGCONT );

//min        usleep(250000);
        
      //   macosx_child_attach (pid_str, from_tty);


//        if( err==0 ) {
//            printf( "successfully attached to pid %d", child_pid );
//        } else {
//            printf( "error: failed to attach to pid %d", child_pid );
//        }
            
        run_debugger( child_pid );
    } else {
        perror("fork");
        return -1;
    }

    return 0;
}
