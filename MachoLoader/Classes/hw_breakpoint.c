#import "hw_breakpoint.h"

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

#include <inttypes.h>
#include <signal.h>
#include <mach/mach_types.h>
#import <mach/thread_act.h>
#import <mach/mach_error.h>

// compile:
// monoco% gcc -m32 -o break break.m -lpthread -F/Developer/SDKs/MacOSX10.6.sdk/System/Library/Frameworks/Kernel.framework

#define MACH_CHECK_ERROR(name,ret) \
if (ret != KERN_SUCCESS) { \
mach_error(#name, ret); \
exit(1); \
}

void hw_breakpoint_handler(int signum)
{
    printf("***** HIT BREAKPOINT *****\n");
//temp    clear_hw_breakpoint();
}

uint32_t hw_dummy(char c)
{
    printf("in dummy. c is %c\n", c);
    return 0xBABE;
}

void clear_hw_breakpoint( thread_act_t thread ) {
    
    struct x86_debug_state dr;
    mach_msg_type_number_t dr_count = x86_DEBUG_STATE_COUNT;
    
    kern_return_t rc = thread_get_state( thread, x86_DEBUG_STATE, (thread_state_t)&dr, &dr_count );
    
    // Clear out the state and disable the breakpoint
    dr.uds.ds32.__dr6 &= ~(1 << 0);
    dr.uds.ds32.__dr7 &= ~(1 << 0);
    
    dr_count = x86_DEBUG_STATE_COUNT;
    rc = thread_set_state( thread, x86_DEBUG_STATE, (thread_state_t)&dr, dr_count );
    printf("Breakpoint cleared\n");
}

void set_hw_breakpoint( void *addr, thread_act_t thread ) {
    
    struct x86_debug_state dr;
    mach_msg_type_number_t dr_count = x86_DEBUG_STATE_COUNT;
    
    kern_return_t result = thread_get_state( thread, x86_DEBUG_STATE, (thread_state_t)&dr, &dr_count );    
    MACH_CHECK_ERROR( thread_get_state, result );
    
    // set the address to break on
    dr.uds.ds32.__dr0 = (uint32_t)addr;
    
    // set some enables
    dr.uds.ds32.__dr7 = (1 << 9) | (1 << 8) | (1 << 0);
    
    result = thread_set_state( thread, x86_DEBUG_STATE, (thread_state_t)&dr, dr_count );
    MACH_CHECK_ERROR( thread_get_state, result );
}

void* hw_trampoline(void* arg)
{
    uint32_t* start = (uint32_t*)arg;
    
    // Wait until we're supposed to start
    while(*start != 1)
    {}
    
    printf("About to call dummy()\n");
    uint32_t result = hw_dummy('N');
    printf("Dummy complete: 0x%08x\n", result);
    return (void*)result;
}


int main3(int argc, char** argv)
{
    // Create a new thread
    //
    pthread_t thread;
    uint32_t start = 0;
    int rc = pthread_create( &thread, NULL, &hw_trampoline, &start );
    if(rc != 0)
    {
        perror("pthread_create: ");
        return(1);
    }
    
    thread_t mythread = pthread_mach_thread_np(thread);

    // Set our breakpoint on dummy
    //
    set_hw_breakpoint(&hw_dummy, mythread);
    
    // Setup a breakpoint handler
    {
        struct sigaction action;
        action.sa_handler = hw_breakpoint_handler;
        sigemptyset(&action.sa_mask);
        action.sa_flags = 0;
        sigaction(SIGTRAP, &action, NULL);        
    }

    
    // Start the thread running.
    //
    start = 1;
    
    // Wait until it's done and cleanup.
    //
    void* result = 0;
    pthread_join(thread, &result);
    printf("All threads complete: 0x%08x\n", (uint32_t)result);
    return(0);
}
