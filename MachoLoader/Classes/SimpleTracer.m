/* Code sample: using ptrace for simple tracing of a child process.
**
** Eli Bendersky (http://eli.thegreenplace.net)
** This code is in the public domain.
*/

#import <sys/param.h>

#import <stdio.h>
#import <stdarg.h>
#import <stdlib.h>
#import <signal.h>
//#import <syscall.h>
#import <sys/types.h>
#import <sys/ptrace.h>
#import <sys/wait.h>
//#import <sys/proc.h>
#import <sys/user.h>
//#import <sys/systm.h>
//#import <sys/ux_exception.h>
#import <sys/vmparam.h>	/* MAXSSIZ */
//#import <sys/reg.h>

#import <unistd.h>
#import <errno.h>
#import <spawn.h>
#import <string.h>
#import <crt_externs.h>
#import <Security/Authorization.h>

#import <mach/mach_traps.h>
#import <mach/mach_init.h>
#import <mach/task.h>
#import <mach/thread_act.h>
#import <mach/mach_error.h>
#import <mach/mach_port.h>
#import <mach/port.h>
#import <mach/message.h>
#import <mach/mach.h>

#import <mach/boolean.h>
#import <mach/exception.h>
#import <mach/kern_return.h>
#import <mach/mig_errors.h>
//#import <mach/exc_server.h>
//#import <mach/mach_exc_server.h>
//#import <kern/task.h>
//#import <kern/thread.h>
//#import <kern/sched_prim.h>
//#import <kern/kalloc.h>


/* This file is built by running mig -v mach_exc.defs */
#import "mach_exc.h"

#import <assert.h>
#import <alloca.h>

#import "SimpleTracer.h"
#import "HooPermissions.h"


/* Useful links 
 *
 * http://www.opensource.apple.com/source/gdb/gdb-1128/src/gdb/macosx/macosx-nat-inferior.c
 * http://www.omnigroup.com/mailman/archive/macosx-dev/2000-June/014178.html
 * http://www.cocoabuilder.com/archive/cocoa/35756-mach-exception-handlers-101-was-re-ptrace-gdb.html
 * http://www.google.com/codesearch/p?hl=en#OAMlx_jo-ck/src/third_party/WebKit/Source/WebKit2/UIProcess/Launcher/mac/ProcessLauncherMac.mm&q=POSIX_SPAWN_START_SUSPENDED&sa=N&cd=3&ct=rc
 * Remember to codesign like lldb (use the lldb certificate)
 * http://michael.bebenita.com/imported-20100930232226/2010/8/12/debugging-on-snow-leopard-getting-task_for_pid-to-work.html
 * http://rgaucher.info/planet/Matasano_Chargen/2008/07/17/What_I’ve_Been_Doing_On_My_Summer_Vacation_or__“It_has_to_work__Otherwise_gdb_wouldn’t”
*/

/* Documentation
 *
 * Each thread and task in Mach has an exception handler port
*/

// Deliver signals as mach exceptions
// signals are implemented ontop of mach exceptions
// I think you need this because signals can't be handled by a different task
// i signal can be sent using kill()

// Environment variables
// DYLD_NO_PIE DYLD_BIND_AT_LAUNCH

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

@implementation SimpleTracer

#define HANDLER_COUNT 64 

struct ExceptionPorts {
    mach_msg_type_number_t maskCount;
    exception_mask_t      masks[HANDLER_COUNT];
    exception_handler_t    handlers[HANDLER_COUNT];
    exception_behavior_t  behaviors[HANDLER_COUNT];
    thread_state_flavor_t  flavors[HANDLER_COUNT];
};

#pragma mark globals
mach_port_t             _exceptionPort;
pid_t                   _child_pid=1;
struct ExceptionPorts   *_oldHandlerData;
mach_port_name_t        _childTaskPort;
thread_act_t            _firstThread;

static unsigned int mask_table[] = { 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 
    0x100UL, 0x200, 0x400, 0x800, 0x1000, 0x2000, 0x4000, 0x8000, 
    0x10000, 0x20000 };

#pragma mark -
extern boolean_t mach_exc_server(  mach_msg_header_t *InHeadP, mach_msg_header_t *OutHeadP );

/* Print a message to stdout, prefixed by the process ID
 */
void procmsg( const char *format, ... ) {
	
    va_list ap;
    fprintf(stdout, "[%d] ", getpid());
    va_start(ap, format);
    vfprintf( stdout, format, ap );
    va_end(ap);
}

void error( char *msg ) {
    printf("[!] error: %s.\n", msg );
    exit(1);
}

#define MACH_CHECK_ERROR(name,ret) \
if (ret != KERN_SUCCESS) { \
mach_error(#name, ret); \
exit(1); \
}

static cpu_type_t preferredArchitecture() {
    
#if defined(__ppc__)
    return CPU_TYPE_POWERPC;
#elif defined(__LP64__)
    return CPU_TYPE_X86_64;
#else
    return CPU_TYPE_X86;
#endif
}

static kern_return_t forward_exception( mach_port_t thread_port, mach_port_t task_port, exception_type_t exception_type, exception_data_t exception_data, mach_msg_type_number_t data_count, struct ExceptionPorts *oldExceptionPorts )
{
    kern_return_t kret;
    unsigned int portIndex;
    
    mach_port_t port;
    exception_behavior_t behavior;
    thread_state_flavor_t flavor;
    
 //   thread_state_data_t thread_state;
    struct x86_thread_state thread_state;

    mach_msg_type_number_t thread_state_count;
    
    for (portIndex = 0; portIndex < oldExceptionPorts->maskCount; portIndex++) {
        if (oldExceptionPorts->masks[portIndex] & (1 << exception_type)) {
            // This handler wants the exception
            break;
        }
    }
    
    if (portIndex >= oldExceptionPorts->maskCount) {
        fprintf(stderr, "No handler for exception_type = %d.  Not fowarding\n", exception_type);
        return KERN_FAILURE;
    }
    
    port = oldExceptionPorts->handlers[portIndex];
    behavior = oldExceptionPorts->behaviors[portIndex];
    flavor = oldExceptionPorts->flavors[portIndex];
    
    fprintf(stderr, "forwarding exception, port = 0x%x, behaviour = %d, flavor = %d\n", port, behavior, flavor);

    if (behavior != EXCEPTION_DEFAULT) {
        thread_state_count = MACHINE_THREAD_STATE_COUNT;
        memset( &thread_state, 0, sizeof(i386_thread_state_t));        
        kret = thread_get_state( thread_port, MACHINE_THREAD_STATE, (thread_state_t)&thread_state, &thread_state_count );
        MACH_CHECK_ERROR( thread_get_state, kret );
    }
    
    switch (behavior) {
            
        case EXCEPTION_DEFAULT:
            fprintf(stderr, "forwarding to exception_raise\n");
            kret = exception_raise (port, thread_port, task_port, exception_type, exception_data, data_count);
            MACH_CHECK_ERROR (exception_raise, kret);
            break;
            
        case EXCEPTION_STATE:
            fprintf(stderr, "forwarding to exception_raise_state\n");
            kret = exception_raise_state (port, exception_type, exception_data, data_count, &flavor, thread_state, thread_state_count, thread_state, &thread_state_count);
            MACH_CHECK_ERROR (exception_raise_state, kret);
            break;
            
        case EXCEPTION_STATE_IDENTITY:
            fprintf(stderr, "forwarding to exception_raise_state_identity\n");
            kret = exception_raise_state_identity (port, thread_port, task_port, exception_type, exception_data,  data_count, &flavor, thread_state, thread_state_count, thread_state, &thread_state_count);
            MACH_CHECK_ERROR (exception_raise_state_identity, kret);
            break;
            
        default:
            fprintf(stderr, "forward_exception got unknown behavior\n");
            break;
    }
    
    if (behavior != EXCEPTION_DEFAULT) {
        kret = thread_set_state (thread_port, MACHINE_THREAD_STATE, (thread_state_t)&thread_state, thread_state_count );
        MACH_CHECK_ERROR (thread_set_state, kret);
    }
    
    return KERN_SUCCESS;
}

thread_act_t threadFromTask( int index, mach_port_name_t task ) {

    thread_array_t thread_list = NULL;
    mach_msg_type_number_t thread_list_count = 0;

    kern_return_t result = task_threads( _childTaskPort, &thread_list, &thread_list_count );
    if( result!=KERN_SUCCESS ) {
        printf( "task_threads() failed with message %s!\n", mach_error_string(result) );
        exit(0);
    }
    printf( "Child task has %i threads\n", thread_list_count );
    assert( index < thread_list_count );

    thread_act_t threadPort = thread_list[index];
    
    vm_deallocate( mach_task_self(), (vm_address_t)thread_list, (vm_size_t)(sizeof(thread_t)*thread_list_count) );

    return threadPort;
}

void enableTraceFlag( thread_act_t theThread, BOOL enable ) {
    
    // TF resides in bit 8 of the EFLAGS register and when set to 1 the pro-
    // cessor generates exception 1 (debug exception) after each instruction
    // is executed. When INT3 is executed, the processor generates exception 3
    // (breakpoint).
    
    // TF flag (single step) is bit 8 (9th bit!)
    
    struct x86_thread_state thread_state;
    mach_msg_type_number_t stateCount = MACHINE_THREAD_STATE_COUNT;
    memset( &thread_state, 0, sizeof(i386_thread_state_t));            
    kern_return_t result = thread_get_state( _firstThread, MACHINE_THREAD_STATE, (thread_state_t)&thread_state, &stateCount );
    MACH_CHECK_ERROR( thread_get_state, result );
    
    if( thread_state.tsh.flavor==x86_THREAD_STATE32 )
    {
        x86_thread_state32_t tState = thread_state.uts.ts32;
        
        /* Check if PC is at a sigreturn system call.  */        
        if( tState.__eax==0xb8) {
            NSLog(@"oh bugger, there has to be one, right?");
        }
//        if (target_read_memory (regs->uts.ts32.__eip, buf, sizeof (buf))==0 && memcmp (buf, darwin_syscall, sizeof (darwin_syscall))==0 && regs->uts.ts32.__eax == 0xb8 /* SYS_sigreturn */)
//        {
//            
//        }
        
        BOOL bit8 = (tState.__eflags & mask_table[8]) >0 ? 1 : 0;
        if( bit8!=enable ){
            if(enable)
                tState.__eflags |= mask_table[ 8 ];     // set the bit
            else
                tState.__eflags &= ~mask_table[ 8 ];    // clear the bit
            bit8 = (tState.__eflags & mask_table[8]) >0 ? 1 : 0;
            thread_state.uts.ts32 = tState;
            if( thread_set_state( theThread, MACHINE_THREAD_STATE, (thread_state_t)&thread_state, stateCount ) ) error((char *)"setting state");                
        }
        assert( bit8==enable );    
        
    } else if( thread_state.tsh.flavor==x86_THREAD_STATE64 ) {
        x86_thread_state64_t tState = thread_state.uts.ts64;
        [NSException raise:NSInternalInconsistencyException format:@"Do this"];
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"What the fuck"];
    }      
}

void printRegisters() {
    
    struct x86_thread_state thread_state;
    mach_msg_type_number_t stateCount = MACHINE_THREAD_STATE_COUNT;
    memset( &thread_state, 0, sizeof(i386_thread_state_t));    
    kern_return_t result = thread_get_state( _firstThread, MACHINE_THREAD_STATE, (thread_state_t)&thread_state, &stateCount );
  
    MACH_CHECK_ERROR( thread_get_state, result );
    
    if( thread_state.tsh.flavor==x86_THREAD_STATE32 ){
        
        x86_thread_state32_t tState = thread_state.uts.ts32;
        
        printf(
               "Instruction Pointer:\t\t %0x\n"
               "Accumulator:\t\t\t\t %0x\n"
               "Data:\t\t\t\t\t\t %0x\n"
               "Count:\t\t\t\t\t\t %0x\n"               
               "Base:\t\t\t\t\t\t %0x\n"
               "Frame base pointer:\t\t\t %0x\n"
               "Source index:\t\t\t\t %0x\n"
               "Destination index:\t\t\t %0x\n"
               "Stack Pointer:\t\t\t\t %0x\n"
               
               /* Other registers */
               "stack segment:\t\t\t\t %0x\n"
               "eflags:\t\t\t\t\t\t %0x\n"
               "code segment:\t\t\t\t %0x\n"
               "data segment:\t\t\t\t %0x\n"
               "data segment (string):\t\t %0x\n"
               "data segment:\t\t\t\t  %0x\n"
               "data segment:\t\t\t\t  %0x\n",
               
               //TODO:    0x0000264a vs 8fe01030
               tState.__eip, 
               tState.__eax,
               tState.__edx,
               tState.__ecx,
               tState.__ebx,
               tState.__ebp,
               tState.__esi,
               tState.__edi,
               tState.__esp,
               
               tState.__ss,
               tState.__eflags,
               tState.__cs,
               tState.__ds,
               tState.__es,
               tState.__fs,
               tState.__gs
               );
    } else if( thread_state.tsh.flavor==x86_THREAD_STATE64 ) {
        x86_thread_state64_t tState = thread_state.uts.ts64;
        [NSException raise:NSInternalInconsistencyException format:@"Do this"];
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"What the fuck"];
    } 
}

static id _staticInstance;
+ (id)staticInstanc {
    return _staticInstance;
}

- (id)init {
    
    self = [super init];
    _staticInstance = self;
    return self;
}

- (void)SaveExceptionPortInfo {
    
    _oldHandlerData = NSZoneMalloc( [self zone], sizeof(struct ExceptionPorts));
    memset(_oldHandlerData, 0, sizeof(*_oldHandlerData));
    _oldHandlerData->maskCount = sizeof(_oldHandlerData->masks)/sizeof(_oldHandlerData->masks[0]);
    kern_return_t krc = task_get_exception_ports( _childTaskPort, EXC_MASK_ALL, _oldHandlerData->masks, &_oldHandlerData->maskCount, _oldHandlerData->handlers, _oldHandlerData->behaviors, _oldHandlerData->flavors);
    if( krc!=KERN_SUCCESS )
        [NSException raise: NSInternalInconsistencyException format:@"Unable to get old task exception ports, krc = %d, %s", krc, mach_error_string(krc)];
}

static void setUpTerminationNotificationHandler( pid_t pid ) {
    
    dispatch_source_t processDiedSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_PROC, pid, DISPATCH_PROC_EXIT, dispatch_get_current_queue());
    dispatch_source_set_event_handler(processDiedSource, ^{
        int status;
        waitpid(dispatch_source_get_handle(processDiedSource), &status, 0);
        dispatch_source_cancel(processDiedSource);
    });
    dispatch_source_set_cancel_handler(processDiedSource, ^{
        dispatch_release(processDiedSource);
    });
    dispatch_resume(processDiedSource);
}

- (int)trace:(const char *)programname {
        
    [HooPermissions acquireTaskportRight];
    
    char **argv = (char **)calloc(sizeof(char *), 8 + 1);
    // char **env = (char **)calloc(sizeof(char *), 8 + 1);
    
    argv[0] = (char *)programname;
    
    char const *envp[0];
   	char*** envPtr = _NSGetEnviron();
	char** environ = *envPtr;
    
    // Allocate an exception port that we will use to track our child process
    // -- Create the listening port --

    _exceptionPort = MACH_PORT_NULL;
    mach_port_t task_self = mach_task_self();

    kern_return_t krc = mach_port_allocate( task_self, MACH_PORT_RIGHT_RECEIVE, &_exceptionPort );
    if( krc != KERN_SUCCESS )
        [NSException raise: NSInternalInconsistencyException format: @"Unable to create handler port, krc = %d, %s", krc, mach_error_string(krc)];
    
    // Insert a send right so we can send to it.    
    krc = mach_port_insert_right( task_self, _exceptionPort, _exceptionPort, MACH_MSG_TYPE_MAKE_SEND );
    if( krc != KERN_SUCCESS )
        [NSException raise: NSInternalInconsistencyException format:@"Unable insert send write into handler port, krc = %d, %s", krc, mach_error_string(krc)];

    // Make a unique, per pid, per process launcher web process service name.
    // CString serviceName = String::format("STEVE.WebKit.WebProcess-%d", getpid() );
    // kern_return_t kr = bootstrap_register2( bootstrap_port, const_cast<char*>(serviceName.data()), listeningPort, 0);

    posix_spawnattr_t attr;
    int result = posix_spawnattr_init( &attr );
    assert( result==0 );

    cpu_type_t architecturePreference[] = { preferredArchitecture(), CPU_TYPE_X86 }; // 7
    posix_spawnattr_setbinpref_np( &attr, 2, architecturePreference, 0 );

    posix_spawn_file_actions_t file_actions;
    posix_spawn_file_actions_init( &file_actions);
    posix_spawn_file_actions_addclose( &file_actions, STDIN_FILENO );
    posix_spawn_file_actions_addclose( &file_actions, STDOUT_FILENO );
    posix_spawn_file_actions_addclose( &file_actions, STDERR_FILENO );
    posix_spawn_file_actions_addopen( &file_actions, STDIN_FILENO, "/dev/null", O_RDONLY | O_NOCTTY, 0 );
    posix_spawn_file_actions_addopen( &file_actions, STDOUT_FILENO, "/dev/null",  O_WRONLY | O_NOCTTY, 0 );
    posix_spawn_file_actions_addopen( &file_actions, STDERR_FILENO, "/dev/null", O_RDWR | O_NOCTTY, 0 );

    // We want our process to receive all signals.
    sigset_t signalMaskSet;
    sigemptyset(&signalMaskSet);
    posix_spawnattr_setsigmask( &attr, &signalMaskSet );

    short flags = 0;    
    flags |= POSIX_SPAWN_SETSIGMASK;
    // flags |= POSIX_SPAWN_SETEXEC;            // this makes it act like execve, ie not return
    flags |= POSIX_SPAWN_START_SUSPENDED;
    flags |= _POSIX_SPAWN_DISABLE_ASLR;

    result = posix_spawnattr_setflags( &attr, flags );
    assert( result==0 );

    static int debug_setpgrp = 657473;
    result = posix_spawnattr_setpgroup (&attr, debug_setpgrp);
    assert( result==0 );

    const char *working_dir = "/";
    chdir( working_dir );

    // pid_t result = posix_spawn( &_child_pid, spawnedArgs[0], NULL, &attr, spawnedArgs, environ );
    result = posix_spawnp( &_child_pid, argv[0], &file_actions, &attr, argv, environ );
    if(result!=0) error( strerror(result) );

//    int res = ptrace( PT_TRACE_ME, _child_pid, NULL, 0 );
//    assert( res==0 );

//    char pid_str[32];    
//    snprintf( pid_str, 31, "%d", _child_pid );


    posix_spawnattr_destroy(&attr);

    // Set up the termination notification handler and then ask the child process to continue.
    setUpTerminationNotificationHandler( _child_pid );

    // we need to be authorized to do this
    _childTaskPort = TASK_NULL;

    // This is like ptrace attach, no?
    krc = task_for_pid( task_self, _child_pid, &_childTaskPort );
    if( krc!=KERN_SUCCESS ) {
        printf( "task_for_pid() failed with message %s!\n", (char *)mach_error_string(result) );
        exit(0);
    }

    _firstThread = threadFromTask( 0, _childTaskPort );

    [self setExceptionPorts];
    [self createExceptionThread];

    enableTraceFlag( _firstThread, YES );

    /* The task needs starting */
    kill( _child_pid, SIGCONT );


    
  //   [SimpleTracer performSelectorOnMainThread:@selector(run_debugger) withObject:nil waitUntilDone:NO];        
    //    [_staticInstance resumeChildTask];

//    run_debugger(_child_pid);
//    [_staticInstance resumeChildTask];
    
    
//    run_debugger( _child_pid );
//    run_debugger( _child_pid );




 //   res = ptrace(PT_CONTINUE, _child_pid, 1, 0);
 //  assert( res==0 );
 //   return 1;


//    usleep(250000);
//    sleep(1);
//    
//
//
//    usleep(250000);
 
//    int err = ptrace( PT_ATTACHEXC, _child_pid, 0, 0 );

/* Make the child execute another instruction */
//        if( ptrace(PT_STEP, _child_pid, 1, 0) < 0) {
//            perror("ptrace");
//            return;
//        }
    
 //   int rc = thread_resume( _firstThread );

 //   [self resumeChildTask];
    


//
//    int waiter=0;
//    waitpid( _child_pid, &waiter, 0 );
//
//    [self resumeChildTask];
//    
//    usleep(250000);
//
////boo    run_debugger( _child_pid );
//    usleep(250000);
    
//boo    enableTraceFlag( _firstThread, NO );

//boo    [self resumeChildTask];
//boo    usleep(250000);

//boo    kill( _child_pid, SIGCONT );

    /* Task is not running here - lets see what the thread status is */
//boo     assert( thread_suspend_state( _firstThread )==0 );

//boo    thread_identifier_info_data_t tident;
//boo    unsigned int info_count = THREAD_IDENTIFIER_INFO_COUNT;
//boo    kern_return_t kret = thread_info( _firstThread, THREAD_IDENTIFIER_INFO, (thread_info_t) &tident, &info_count);
//boo    MACH_CHECK_ERROR( thread_info, kret );

//boo    if (tident.thread_handle != 0)
//boo    {
//        char *queue_name = get_dispatch_queue_name (tident.dispatch_qaddr);
//        if (queue_name && queue_name[0] != '\0')
//            printf_filtered ("\tdispatch queue name: \"%s\"\n", queue_name);
//        
//        uint32_t queue_flags;
//        if (get_dispatch_queue_flags (tident.dispatch_qaddr, &queue_flags))
//        {
//            printf_filtered ("\tdispatch queue flags: 0x%x", queue_flags);
//            /* Constants defined in libdispatch's src/private.h,
//             dispatch_queue_flags_t */
//            if (queue_flags & 0x1)
//                printf_filtered (" (concurrent)");
//            if (queue_flags & 0x4)
//                printf_filtered (" (always locked)");
//            printf_filtered ("\n");
//        }
//boo    }
    /* see if we get cilds exceptions */
    // kill( _child_pid, SIGKILL );
    /* see if we get cilds exceptions */

//    int wait_status;        
//    while( wait( &wait_status ) ) {
//        
//        NSLog(@"Running ...");
//    }
    return 0;
}


- (void)setExceptionPorts {
    
    //TODO: vfork or fork?
    // Suggest getting it to work with fork first
    // _child_pid = fork();
    if( _child_pid<0 ) {
        
        // fork failed
        //min       procmsg( "FAILED TO CREATE CHILD \n" );
        
    } else if ( _child_pid==0 ) {
        
        // child process
        //min       procmsg( "CHILD!!! \n" );        
        //min        run_target( programname );
        
    } else if (_child_pid > 0) {
        
        // parent process
        procmsg( "PARENT!!! \n" );        

 //err       int result = ptrace( PT_SIGEXC, _child_pid, 0, 0 );    // lldb // Get BSD signals as mach exceptions
//err        assert( result==0 );

 //eerr       procmsg( "Child pid is = %u. \n", _child_pid );
//errr        setpgid( _child_pid, _child_pid );


        
        // task you be stopped, no?
        // better shut down the task while we do this.
        // if( task_suspend(childTaskPort) ) error("suspending the task");



        // Save the original state of the exception ports for our child process
//BLAH        [self SaveExceptionPortInfo];

        // Set the ability to get all exceptions on this port
        
        // I should also note that what I describe below sets the exception handler
        // on a single thread.  With minor modifications, you can use this to set the
        // handler on the entire task
        
//        The only time I think it makes
//        sense to use the task exception port is in an external process attaching to
//        another process (like what you are describing).  Even so, you will need to
//        turn on the SE bit for every thread in the target process since the SE bit
//            is stored in the per-thread CPU state -- there is no way to turn on this
//            bit for all threads (hence, if a new thread starts, you will need to turn
//                                 the bit on in it too).
                
        // Is this for the thread or task or what?
        // I think we need to examine THREAD_STATE_NONE - i dont think it is what we need
        // EXCEPTION_DEFAULT - Send a catch_exception_raise message including the thread identity.
        // EXCEPTION_STATE - Send a catch_exception_raise_state message including the thread state.
        // EXCEPTION_STATE_IDENTITY - Send a catch_exception_raise_state_identity message including the thread identity and state.
        
        // http://flylib.com/books/en/3.126.1.109/1/

        
// HERE!DO TASK OR THREAD?
        

        _firstThread = _firstThread = threadFromTask( 0, _childTaskPort );

        
        //kern_return_t krc = thread_set_exception_ports( _firstThread, EXC_MASK_ALL, _exceptionPort, EXCEPTION_DEFAULT | MACH_EXCEPTION_CODES, THREAD_STATE_NONE );        
         kern_return_t krc = task_set_exception_ports( _childTaskPort, EXC_MASK_ALL, _exceptionPort, EXCEPTION_DEFAULT | MACH_EXCEPTION_CODES, THREAD_STATE_NONE );
        if( krc != KERN_SUCCESS )
            [NSException raise: NSInternalInconsistencyException format: @"Unable to create set exception ports, krc = %d, %s", krc, mach_error_string(krc)];


// TODO, check our exception ports are still set!!??
//        thread_get_exception_ports
        
    
        
        // I think we need to take the first step
//fscript        run_debugger( _child_pid );
        
        /* Wait for child to stop on its first instruction */

//fscript        int wait_status;        
        
//fscript        wait( &wait_status );

        // what happens if we stop the while loop from exiting?
//fscript        while( WIFSTOPPED(wait_status) ) 
//fscript        { 
//fscript            NSLog(@"Running..?");
//fscript        }

        // taskforpid is equivalent to this
        // int err = ptrace( PT_ATTACHEXC, _child_pid, 0, 0 );
        
        //min        kill( _child_pid, SIGCONT ); // send a bsd signal
        
        
        //   macosx_child_attach (pid_str, from_tty);
        
        
        //        if( err==0 ) {
        //            printf( "successfully attached to pid %d", _child_pid );
        //        } else {
        //            printf( "error: failed to attach to pid %d", _child_pid );
        //        }
        
        //put_back     } else {
        //perror("fork");
        return;
    }
    
    return;
}


- (void)createExceptionThread {
    [NSThread detachNewThreadSelector: @selector(_handleExceptions) toTarget: isa withObject: nil];        
}

#define MSG_SIZE 512

+ (void)_handleExceptions {
    
    kern_return_t krc;
    mach_msg_header_t *msg, *reply;
    
    msg = alloca(MSG_SIZE); // woo! allocate space in the stack frame
    reply = alloca(MSG_SIZE);
    
    while (TRUE) {
        fprintf(stderr, "Waiting for exception messages...\n");
        krc = mach_msg( msg, MACH_RCV_MSG, MSG_SIZE, MSG_SIZE, _exceptionPort, 0, MACH_PORT_NULL );
        MACH_CHECK_ERROR(mach_msg, krc);
        
        fprintf(stderr, "Message received on exception port\n");
        fprintf(stderr, "  msgh_bits:        0x%08x\n", msg->msgh_bits);
        fprintf(stderr, "  msgh_size:        %d\n", msg->msgh_size);
        fprintf(stderr, "  msgh_remote_port: 0x%x\n", msg->msgh_remote_port);
        fprintf(stderr, "  msgh_local_port:  0x%x\n", msg->msgh_local_port);
        fprintf(stderr, "  msgh_reserved:    0x%x\n", msg->msgh_reserved);
        fprintf(stderr, "  msgh_id:          %d\n", msg->msgh_id);
        
        // The exc_server function is the MIG generated server handling function
        // to handle messages from the kernel relating to the occurrence of an
        // exception in a thread. Such messages are delivered to the exception port
        // set via thread_set_exception_ports or task_set_exception_ports. When an
        // exception occurs in a thread, the thread sends an exception message to
        // its exception port, blocking in the kernel waiting for the receipt of a
        // reply. The exc_server function performs all necessary argument handling
        // for this kernel message and calls catch_exception_raise,
        // catch_exception_raise_state or catch_exception_raise_state_identity,
        // which should handle the exception. If the called routine returns
        // KERN_SUCCESS, a reply message will be sent, allowing the thread to
        // continue from the point of the exception; otherwise, no reply message
        // is sent and the called routine must have dealt with the exception
        // thread directly.
        
//        There are certain MIG options that a server might want to turn on. These options (like getting the security token of the sender, or a sequence number for ordering messages to a multi-threaded server) may change the prototype of the called function in the server. Instead of providing a header with our "assumed" set of options fixed, we provide the MIG .defs file so you can set your own options and compile a server header "just for you."
//
//        All-in-all, its a bit of a pain. If the server side interface is heavily used (the number of exception servers in "on the cusp" of meeting that definition), we'll do all that for you. But in the case of exceptions we held off because of the other complexities involved in correctly handling exceptions. Most notably, exception handlers are voluntarily daisy-chained. When you register an exception handler at the task or thread level, you are responsible to forward unhandled exceptions on to the previous registrant. The format message you requested may not match theirs, too. So, you have to convert the messages to the format they wanted (gather additional information, or dropping info they didn't ask for) before forwarding it.

            /* 
             * So, you need to implement the various functions in the exc.defs interface:
             * /System/Library/Frameworks/Kernel.framework/Versions/A/Headers/mach/mach_exc.defs
            */
        
        // http://lists.apple.com/archives/darwin-kernel/2004/Jan/msg00034.html
        // http://stackoverflow.com/questions/2824105/handling-mach-exceptions-in-64bit-os-x-application
  
        if( !mach_exc_server(msg, reply) ) {
            fprintf(stderr, "mach_exc_server hated the message\n");
            exit(1);
        }

        krc = mach_msg(reply, MACH_SEND_MSG, reply->msgh_size, 0, msg->msgh_local_port, 0, MACH_PORT_NULL);
        MACH_CHECK_ERROR(mach_msg, krc);
        
        
        
        fprintf(stderr, "wooooooooooo!\n");
    }
}

+ (void)run_debugger {
    
    usleep(1000000);
    run_debugger(_child_pid);
}

integer_t child_suspend_count() {

    struct task_basic_info *taskInformation = calloc(sizeof(struct task_basic_info), 1);
    task_info_t taskInformation_ptr = (task_info_t)taskInformation;
    mach_msg_type_number_t count = sizeof(struct task_basic_info);
    kern_return_t rc = task_info( _childTaskPort, TASK_BASIC_INFO, taskInformation_ptr, &count );
    if( rc != KERN_SUCCESS )
        error((char *)"getting task info");    
    integer_t suspendCount = taskInformation->suspend_count;
    free(taskInformation);
    printf( "Task suspend count >%i\n", suspendCount );
    return suspendCount;
}

integer_t thread_suspend_state( thread_act_t thread ) {

    struct thread_basic_info *basicInfoPtr = calloc(sizeof(struct thread_basic_info), 1);    
    unsigned int info_count = THREAD_BASIC_INFO_COUNT;    
    kern_return_t rc = thread_info( thread, THREAD_BASIC_INFO, (thread_info_t) basicInfoPtr, &info_count );
    if( rc != KERN_SUCCESS )
        error((char *)"getting thread info");
    integer_t runState = basicInfoPtr->run_state;
    integer_t suspendCount = basicInfoPtr->suspend_count;
    free( basicInfoPtr );
    printf( "Thread run state >%i, thread suspend count >%i\n", runState, suspendCount );
    return suspendCount;
}

+ (void)nudge {
    
    [_staticInstance resumeChildTask];
}

- (void)resumeChildTask {
    
    sleep(1);
    
    mach_port_t task_self = mach_task_self();
    int krc = task_for_pid( task_self, _child_pid, &_childTaskPort );

    kill( _child_pid, SIGCONT );

    assert( child_suspend_count()==0 );
    assert( thread_suspend_state( _firstThread )==0 );

//    kern_return_t rc = task_resume(_childTaskPort);
//    if( rc != KERN_SUCCESS )
//        error((char *)"resuming task");
  
    // i think its proabbly wrong to examine the state when not suspended
//    assert( child_suspend_count()==0 );
 ///   assert( thread_suspend_state( _firstThread )==0 );
 //   kill( _child_pid, SIGCONT );
}

void run_debugger( pid_t child_pid ) {
    
    int wait_status;
    static unsigned icounter = 0;
    
//    if( child_suspend_count()==0 ) {
//        procmsg("supending task\n");
//        
//        kern_return_t rc = task_suspend( _childTaskPort );
//        if( rc != KERN_SUCCESS )
//            error((char *)"suspending thread");
//    }
//    assert( child_suspend_count()==1 );
    
    // kill( _child_pid, SIGTSTP );

    // alternative way for ptrace(PTRACE_GETREGS, child_pid, 0, &regs);	

    
    // you need to dealloc the threads!
    
    _firstThread = threadFromTask( 0, _childTaskPort );
    
//    static int debugger = 0;
//    if(debugger==0) {
//        int err = ptrace( PT_ATTACHEXC, _child_pid, 0, 0 );
//        kill( _child_pid, SIGCONT );        
//    }
//    debugger++;    
//    return;
    
    int tada=  thread_suspend_state( _firstThread );
    
    // using task suspend / resume instead
    // rc = thread_suspend( _firstThread );
    // if( rc != KERN_SUCCESS )
    //    error((char *)"suspending thread");

    printRegisters( _firstThread );
        
    enableTraceFlag( _firstThread, YES );

//        debugger++;

        // rc = thread_resume( _firstThread );


    /* Wait for child to stop on its first instruction */
    //        wait( &wait_status );
    //    }
    
    // what happens if we stop the while loop from exiting?
    //   while( WIFSTOPPED(wait_status) ) 
    //   {
    icounter++;
    
    //alt	printf( " lr: 0x%x\n",ppc_state.lr);
    
    //jiggy        unsigned instr = ptrace(PTRACE_PEEKTEXT, child_pid, regs.eip, 0);
    
    // procmsg("icounter = %u.  EIP = 0x%08x.  instr = 0x%08x\n", icounter, regs.eip, instr);
    procmsg("icounter = %u. \n", icounter);
    
    /* Make the child execute another instruction */
    //        if( ptrace(PT_STEP, child_pid, 1, 0) < 0) {
    //            perror("ptrace");
    //            return;
    //        }
    
    /* Wait for child to stop on its next instruction */
    //        wait( &wait_status ); NOHANG
    //   }

    
    procmsg("the child executed %u instructions\n", icounter);
}

@end




void run_target( const char *programname ) {
	
	procmsg( "target started. will run '%s'\n", programname );

    /* Make sure the task gets default signal setup.
     */
    for( int i=0; i<32; i++ ) {
        signal( i, SIG_DFL );
	}
    
 //   setsid(); // lldb
    

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


//- (void)suspendThread;
//{
//    kern_return_t rc;
//    
//    rc = thread_suspend(_targetThread);
//    if (rc != KERN_SUCCESS)
//        // This isn't a hard error since the thread might have terminated  
//        between when you decided to call this method and when it actually got  
//        invoked.
//        [NSException raise:NSInternalInconsistencyException
//                    format:@"Unable to suspend thread, rc = %d", rc];
//}
//
//- (void)resumeThread;
//{
//    kern_return_t rc;
//    
//    rc = thread_resume(_targetThread);
//    if (rc != KERN_SUCCESS) {
//        mach_error("task_resume", rc);
//        abort();
//    }
//}

//- (void) setSingleStepEnabled: (BOOL) yn;
//{
//    [self suspendThread];
//    
//    struct ppc_thread_state state;
//    
//    stateCount = PPC_THREAD_STATE_COUNT;
//    krc = thread_get_state(_targetThread, PPC_THREAD_STATE, (natural_t  
//                                                             *)&state, &stateCount);
//    if (krc != KERN_SUCCESS) {
//        [self resumeThread];
//        [NSException raise: NSInternalInconsistencyException format: @"Error getting thread state, krc = %d, %s", krc, mach_error_string(krc)];
//    }
//    
//    if (yn)
//        state.srr1 |= 0x400UL; // enable SE bit
//        else
//            state.srr1 &= ~0x400UL; // disable SE bit
//            
//            krc = thread_set_state(_targetThread, PPC_THREAD_STATE, (natural_t  
//                                                                     *)&state, stateCount);
//            if (krc != KERN_SUCCESS) {
//                [self resumeThread];
//                [NSException raise: NSInternalInconsistencyException
//                            format: @"Error setting thread state, krc = %d,  
//                 %s", krc, mach_error_string(krc)];
//            }
//    
//    [self resumeThread];
//    
//}


#pragma mark - 64bit mach_exc_server()

/* Handle the three exception flavours - Depends on arguments to task_set_exception_ports() */

// in a sinal handler you can only do very limited things (eg you cant call malloc!)
// are these signal handlers?

/*
 * XXX Things that should be retrieved from Mach headers, but aren't
 */
struct ipc_object;
extern kern_return_t ipc_object_copyin( ipc_space_t space, mach_port_name_t name, mach_msg_type_name_t msgt_name, struct ipc_object **objectp );

//extern mach_msg_return_t mach_msg_receive(mach_msg_header_t *msg,
//                                          mach_msg_option_t option, mach_msg_size_t rcv_size,
//                                          mach_port_name_t rcv_name, mach_msg_timeout_t rcv_timeout,
//                                          void (*continuation)(mach_msg_return_t),
//                                          mach_msg_size_t slist_size);
//extern mach_msg_return_t mach_msg_send(mach_msg_header_t *msg,
//                                       mach_msg_option_t option, mach_msg_size_t send_size,
//                                       mach_msg_timeout_t send_timeout, mach_port_name_t notify);
// extern thread_t convert_port_to_thread(ipc_port_t port);
// extern void ipc_port_release(ipc_port_t);

static void darwin_encode_reply( mig_reply_error_t *reply, mach_msg_header_t *hdr, integer_t code )
{
    mach_msg_header_t *rh = &reply->Head;
    rh->msgh_bits = MACH_MSGH_BITS(MACH_MSGH_BITS_REMOTE(hdr->msgh_bits), 0);
    rh->msgh_remote_port = hdr->msgh_remote_port;
    rh->msgh_size = (mach_msg_size_t)sizeof(mig_reply_error_t);
    rh->msgh_local_port = MACH_PORT_NULL;
    rh->msgh_id = hdr->msgh_id + 100;
    
    reply->NDR = NDR_record;
    reply->RetCode = code;
}

kern_return_t catch_mach_exception_raise( mach_port_t exception_port, mach_port_t thread, mach_port_t task, exception_type_t exception,
                                    exception_data_t code, mach_msg_type_number_t codeCount ) {

    assert( exception_port==_exceptionPort );
    assert( task==_childTaskPort );
    assert( thread==_firstThread );

    kern_return_t krc = MACH_MSG_SUCCESS;

    if( exception == EXC_BREAKPOINT ) {

        // main thread must not be blocked!
        [_staticInstance performSelectorOnMainThread:@selector(resumeChildTask) withObject:nil waitUntilDone:NO];        

        mig_reply_error_t reply;

        /* The child task will only continue if we return KERN_SUCCESS */
        return KERN_SUCCESS; 

    } else {
        fprintf( stdout, "UNKNOWN EXCEPTION" );        
        fprintf( stdout, "%s(): thread: 0x%x task: 0x%x type: 0x%x code: %p codeCnt: 0x%x", __func__, thread, task, exception, code, codeCount );
    }
    krc = forward_exception( thread, task, exception, code, codeCount, _oldHandlerData );

    return krc;
}

kern_return_t catch_mach_exception_raise_state( mach_port_t exception_port, exception_type_t exception, exception_data_t code, mach_msg_type_number_t codeCnt, int *flavor, thread_state_t old_state, mach_msg_type_number_t old_stateCnt, thread_state_t new_state, mach_msg_type_number_t *new_stateCnt )
{
	//... exactly the same sort of thing as catch_exception_raise ...
    return KERN_SUCCESS;
}

kern_return_t catch_mach_exception_raise_state_identity( mach_port_t exception_port, mach_port_t thread, mach_port_t task, exception_type_t exception, exception_data_t code, mach_msg_type_number_t codeCnt, int *flavor, thread_state_t old_state, mach_msg_type_number_t old_stateCnt, thread_state_t new_state, mach_msg_type_number_t *new_stateCnt ) {
    
	// ... exactly the same sort of thing as catch_exception_raise ...
    return KERN_SUCCESS;
}
